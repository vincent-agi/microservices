"""
Controller for Article (Cart Item) REST API endpoints.
"""
from flask import Blueprint, request
from config.database import DBSession
from services.article_service import ArticleService
from utils.responses import success_response, error_response
from utils.validation import validate_pagination_params, validate_required_fields
from sqlalchemy.exc import SQLAlchemyError

article_bp = Blueprint('article', __name__, url_prefix='/articles')


@article_bp.route('', methods=['POST'])
def create_article():
    """
    Create a new article in a panier.
    
    Request body (JSON):
        - panierId (required): ID of the panier
        - productId (required): ID of the product
        - quantity (required): Quantity of the product
        - unitPrice (required): Price per unit
        
    Returns:
        201: Created article
        400: Validation error
        404: Panier not found
    """
    data = request.get_json() or {}
    
    # Validate required fields
    error = validate_required_fields(data, ['panierId', 'productId', 'quantity', 'unitPrice'])
    if error:
        return error_response('VALIDATION_ERROR', error, {})
    
    try:
        panier_id = int(data['panierId'])
        product_id = str(data['productId'])
        quantity = int(data['quantity'])
        unit_price = float(data['unitPrice'])
        
        if quantity <= 0:
            return error_response(
                'VALIDATION_ERROR',
                'Quantity must be greater than 0',
                {'field': 'quantity'}
            )
        
        if unit_price < 0:
            return error_response(
                'VALIDATION_ERROR',
                'Unit price cannot be negative',
                {'field': 'unitPrice'}
            )
        
    except (ValueError, TypeError) as e:
        return error_response(
            'VALIDATION_ERROR',
            f'Invalid data type: {str(e)}',
            {}
        )
    
    with DBSession() as db:
        try:
            service = ArticleService(db)
            article = service.create_article(
                panier_id=panier_id,
                product_id=product_id,
                quantity=quantity,
                unit_price=unit_price
            )
            
            if not article:
                return error_response(
                    'NOT_FOUND',
                    f'Panier with ID {panier_id} not found',
                    {'field': 'panierId'},
                    404
                )
            
            return success_response(article.to_dict(), status_code=201)
        except SQLAlchemyError as e:
            return error_response(
                'DATABASE_ERROR',
                'An error occurred while creating the article',
                {'error': str(e)},
                500
            )



@article_bp.route('', methods=['GET'])
def get_articles():
    """
    Get all articles with pagination.
    
    Query parameters:
        - page (optional): Page number (default: 1)
        - limit (optional): Items per page (default: 20, max: 100)
        - panierId (optional): Filter by panier ID
        
    Returns:
        200: List of articles with pagination metadata
        400: Invalid pagination parameters
    """
    page = request.args.get('page', 1)
    limit = request.args.get('limit', 20)
    panier_id = request.args.get('panierId')
    
    # Validate pagination
    page, limit, error = validate_pagination_params(page, limit)
    if error:
        return error_response('VALIDATION_ERROR', error, {'field': 'page or limit'})
    
    # Convert panier_id to int if provided
    if panier_id is not None:
        try:
            panier_id = int(panier_id)
        except ValueError:
            return error_response('VALIDATION_ERROR', 'Invalid panierId', {'field': 'panierId'})
    
    with DBSession() as db:
        service = ArticleService(db)
        articles, total, total_pages = service.get_all_articles(
            page=page,
            limit=limit,
            panier_id=panier_id
        )
        
        return success_response(
            [article.to_dict() for article in articles],
            page=page,
            limit=limit,
            total=total,
            totalPages=total_pages
        )




@article_bp.route('/<int:article_id>', methods=['GET'])
def get_article(article_id):
    """
    Get an article by ID.
    
    Path parameters:
        - article_id: ID of the article
        
    Returns:
        200: Article data
        404: Article not found
    """
    with DBSession() as db:
        service = ArticleService(db)
        article = service.get_article_by_id(article_id)
        
        if not article:
            return error_response(
                'NOT_FOUND',
                f'Article with ID {article_id} not found',
                {},
                404
            )
        
        return success_response(article.to_dict())


@article_bp.route('/<int:article_id>', methods=['PUT'])
def update_article(article_id):
    """
    Update an article.
    
    Path parameters:
        - article_id: ID of the article
        
    Request body (JSON):
        - productId (optional): New product ID
        - quantity (optional): New quantity
        - unitPrice (optional): New unit price
        
    Returns:
        200: Updated article
        400: Validation error
        404: Article not found
    """
    data = request.get_json() or {}
    
    product_id = data.get('productId')
    quantity = data.get('quantity')
    unit_price = data.get('unitPrice')
    
    # Validate data types if provided
    try:
        if product_id is not None:
            product_id = str(product_id)
        
        if quantity is not None:
            quantity = int(quantity)
            if quantity <= 0:
                return error_response(
                    'VALIDATION_ERROR',
                    'Quantity must be greater than 0',
                    {'field': 'quantity'}
                )
        
        if unit_price is not None:
            unit_price = float(unit_price)
            if unit_price < 0:
                return error_response(
                    'VALIDATION_ERROR',
                    'Unit price cannot be negative',
                    {'field': 'unitPrice'}
                )
                
    except (ValueError, TypeError) as e:
        return error_response(
            'VALIDATION_ERROR',
            f'Invalid data type: {str(e)}',
            {}
        )
    
    with DBSession() as db:
        try:
            service = ArticleService(db)
            article = service.update_article(
                article_id=article_id,
                product_id=product_id,
                quantity=quantity,
                unit_price=unit_price
            )
            
            if not article:
                return error_response(
                    'NOT_FOUND',
                    f'Article with ID {article_id} not found',
                    {},
                    404
                )
            
            return success_response(article.to_dict())
        except SQLAlchemyError as e:
            return error_response(
                'DATABASE_ERROR',
                'An error occurred while updating the article',
                {'error': str(e)},
                500
            )


@article_bp.route('/<int:article_id>', methods=['DELETE'])
def delete_article(article_id):
    """
    Delete an article by ID.
    
    Path parameters:
        - article_id: ID of the article
        
    Returns:
        204: No content (successful deletion)
        404: Article not found
    """
    with DBSession() as db:
        service = ArticleService(db)
        deleted = service.delete_article(article_id)
        
        if not deleted:
            return error_response(
                'NOT_FOUND',
                f'Article with ID {article_id} not found',
                {},
                404
            )
        
        return '', 204


@article_bp.route('/panier/<int:panier_id>', methods=['GET'])
def get_panier_articles(panier_id):
    """
    Get all articles for a specific panier.
    
    Path parameters:
        - panier_id: ID of the panier
        
    Query parameters:
        - page (optional): Page number (default: 1)
        - limit (optional): Items per page (default: 20, max: 100)
        
    Returns:
        200: List of panier's articles with pagination
        400: Invalid pagination parameters
    """
    page = request.args.get('page', 1)
    limit = request.args.get('limit', 20)
    
    # Validate pagination
    page, limit, error = validate_pagination_params(page, limit)
    if error:
        return error_response('VALIDATION_ERROR', error, {'field': 'page or limit'})
    
    with DBSession() as db:
        service = ArticleService(db)
        articles, total, total_pages = service.get_articles_by_panier(
            panier_id=panier_id,
            page=page,
            limit=limit
        )
        
        return success_response(
            [article.to_dict() for article in articles],
            page=page,
            limit=limit,
            total=total,
            totalPages=total_pages
        )
