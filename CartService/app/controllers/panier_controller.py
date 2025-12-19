"""
Controller for Panier (Cart) REST API endpoints.
"""
from flask import Blueprint, request
from config.database import get_db
from services.panier_service import PanierService
from utils.responses import success_response, error_response
from utils.validation import validate_pagination_params
from utils.user_service import verify_user_exists

panier_bp = Blueprint('panier', __name__, url_prefix='/paniers')


@panier_bp.route('', methods=['POST'])
def create_panier():
    """
    Create a new panier.
    
    Request body (JSON):
        - userId (optional): ID of the user
        - status (optional): Initial status (default: 'active')
        
    Returns:
        201: Created panier
        400: Validation error
    """
    data = request.get_json() or {}
    
    user_id = data.get('userId')
    status = data.get('status', 'active')
    
    # Verify user exists if user_id is provided
    if user_id is not None:
        user_exists, error_msg = verify_user_exists(user_id)
        if not user_exists:
            return error_response(
                'USER_NOT_FOUND',
                error_msg or f'User with ID {user_id} not found',
                {'field': 'userId'},
                404
            )
    
    db = next(get_db())
    try:
        service = PanierService(db)
        panier = service.create_panier(user_id=user_id, status=status)
        
        return success_response(panier.to_dict(), status_code=201)
    finally:
        db.close()


@panier_bp.route('', methods=['GET'])
def get_paniers():
    """
    Get all paniers with pagination.
    
    Query parameters:
        - page (optional): Page number (default: 1)
        - limit (optional): Items per page (default: 20, max: 100)
        - userId (optional): Filter by user ID
        - status (optional): Filter by status
        
    Returns:
        200: List of paniers with pagination metadata
        400: Invalid pagination parameters
    """
    page = request.args.get('page', 1)
    limit = request.args.get('limit', 20)
    user_id = request.args.get('userId')
    status = request.args.get('status')
    
    # Validate pagination
    page, limit, error = validate_pagination_params(page, limit)
    if error:
        return error_response('VALIDATION_ERROR', error, {'field': 'page or limit'})
    
    # Convert user_id to int if provided
    if user_id is not None:
        try:
            user_id = int(user_id)
        except ValueError:
            return error_response('VALIDATION_ERROR', 'Invalid userId', {'field': 'userId'})
    
    db = next(get_db())
    try:
        service = PanierService(db)
        paniers, total, total_pages = service.get_all_paniers(
            page=page,
            limit=limit,
            user_id=user_id,
            status=status
        )
        
        return success_response(
            [panier.to_dict() for panier in paniers],
            page=page,
            limit=limit,
            total=total,
            totalPages=total_pages
        )
    finally:
        db.close()


@panier_bp.route('/<int:panier_id>', methods=['GET'])
def get_panier(panier_id):
    """
    Get a panier by ID with all its articles.
    
    Path parameters:
        - panier_id: ID of the panier
        
    Returns:
        200: Panier with articles and totals
        404: Panier not found
    """
    db = next(get_db())
    try:
        service = PanierService(db)
        panier_data = service.get_panier_with_articles(panier_id)
        
        if not panier_data:
            return error_response(
                'NOT_FOUND',
                f'Panier with ID {panier_id} not found',
                {},
                404
            )
        
        return success_response(panier_data)
    finally:
        db.close()


@panier_bp.route('/<int:panier_id>', methods=['PUT'])
def update_panier(panier_id):
    """
    Update a panier.
    
    Path parameters:
        - panier_id: ID of the panier
        
    Request body (JSON):
        - userId (optional): New user ID
        - status (optional): New status
        
    Returns:
        200: Updated panier
        404: Panier not found
    """
    data = request.get_json() or {}
    
    user_id = data.get('userId')
    status = data.get('status')
    
    # Verify user exists if user_id is provided
    if user_id is not None:
        user_exists, error_msg = verify_user_exists(user_id)
        if not user_exists:
            return error_response(
                'USER_NOT_FOUND',
                error_msg or f'User with ID {user_id} not found',
                {'field': 'userId'},
                404
            )
    
    db = next(get_db())
    try:
        service = PanierService(db)
        panier = service.update_panier(panier_id, user_id=user_id, status=status)
        
        if not panier:
            return error_response(
                'NOT_FOUND',
                f'Panier with ID {panier_id} not found',
                {},
                404
            )
        
        return success_response(panier.to_dict())
    finally:
        db.close()


@panier_bp.route('/<int:panier_id>', methods=['DELETE'])
def delete_panier(panier_id):
    """
    Delete a panier by ID.
    
    Path parameters:
        - panier_id: ID of the panier
        
    Returns:
        204: No content (successful deletion)
        404: Panier not found
    """
    db = next(get_db())
    try:
        service = PanierService(db)
        deleted = service.delete_panier(panier_id)
        
        if not deleted:
            return error_response(
                'NOT_FOUND',
                f'Panier with ID {panier_id} not found',
                {},
                404
            )
        
        return '', 204
    finally:
        db.close()


@panier_bp.route('/user/<int:user_id>', methods=['GET'])
def get_user_paniers(user_id):
    """
    Get all paniers for a specific user.
    
    Path parameters:
        - user_id: ID of the user
        
    Query parameters:
        - page (optional): Page number (default: 1)
        - limit (optional): Items per page (default: 20, max: 100)
        
    Returns:
        200: List of user's paniers with pagination
        400: Invalid pagination parameters
    """
    page = request.args.get('page', 1)
    limit = request.args.get('limit', 20)
    
    # Validate pagination
    page, limit, error = validate_pagination_params(page, limit)
    if error:
        return error_response('VALIDATION_ERROR', error, {'field': 'page or limit'})
    
    db = next(get_db())
    try:
        service = PanierService(db)
        paniers, total, total_pages = service.get_paniers_by_user(
            user_id=user_id,
            page=page,
            limit=limit
        )
        
        return success_response(
            [panier.to_dict() for panier in paniers],
            page=page,
            limit=limit,
            total=total,
            totalPages=total_pages
        )
    finally:
        db.close()
