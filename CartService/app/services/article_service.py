"""
Service layer for Article (Cart Item) operations.
"""
from sqlalchemy.orm import Session
from models.article import Article
from models.panier import Panier
from utils.responses import paginate_query


class ArticleService:
    """
    Service for managing Article (cart item) entities.
    """
    
    def __init__(self, db: Session):
        """
        Initialize ArticleService with database session.
        
        Args:
            db: SQLAlchemy database session
        """
        self.db = db
    
    def create_article(self, panier_id, product_id, quantity, unit_price):
        """
        Create a new article in a panier.
        
        Args:
            panier_id: ID of the panier
            product_id: ID of the product
            quantity: Quantity of the product
            unit_price: Price per unit
            
        Returns:
            Created Article entity or None if panier doesn't exist
        """
        # Verify panier exists
        panier = self.db.query(Panier).filter(Panier.id_panier == panier_id).first()
        if not panier:
            return None
        
        article = Article(
            panier_id=panier_id,
            product_id=product_id,
            quantity=quantity,
            unit_price=unit_price
        )
        
        self.db.add(article)
        self.db.commit()
        self.db.refresh(article)
        
        return article
    
    def get_article_by_id(self, article_id):
        """
        Get an article by its ID.
        
        Args:
            article_id: ID of the article
            
        Returns:
            Article entity or None if not found
        """
        return self.db.query(Article).filter(Article.id_article == article_id).first()
    
    def get_all_articles(self, page=1, limit=20, panier_id=None):
        """
        Get all articles with pagination and optional filtering.
        
        Args:
            page: Page number (1-indexed)
            limit: Items per page
            panier_id: Filter by panier ID (optional)
            
        Returns:
            Tuple of (articles, total_count, total_pages)
        """
        query = self.db.query(Article)
        
        # Apply filter
        if panier_id is not None:
            query = query.filter(Article.panier_id == panier_id)
        
        # Order by most recent first
        query = query.order_by(Article.created_at.desc())
        
        return paginate_query(query, page, limit)
    
    def get_articles_by_panier(self, panier_id, page=1, limit=20):
        """
        Get all articles for a specific panier with pagination.
        
        Args:
            panier_id: ID of the panier
            page: Page number (1-indexed)
            limit: Items per page
            
        Returns:
            Tuple of (articles, total_count, total_pages)
        """
        return self.get_all_articles(page=page, limit=limit, panier_id=panier_id)
    
    def update_article(self, article_id, product_id=None, quantity=None, unit_price=None):
        """
        Update an article.
        
        Args:
            article_id: ID of the article to update
            product_id: New product ID (optional)
            quantity: New quantity (optional)
            unit_price: New unit price (optional)
            
        Returns:
            Updated Article entity or None if not found
        """
        article = self.get_article_by_id(article_id)
        
        if not article:
            return None
        
        if product_id is not None:
            article.product_id = product_id
        
        if quantity is not None:
            article.quantity = quantity
        
        if unit_price is not None:
            article.unit_price = unit_price
        
        self.db.commit()
        self.db.refresh(article)
        
        return article
    
    def delete_article(self, article_id):
        """
        Delete an article by ID.
        
        Args:
            article_id: ID of the article to delete
            
        Returns:
            True if deleted, False if not found
        """
        article = self.get_article_by_id(article_id)
        
        if not article:
            return False
        
        self.db.delete(article)
        self.db.commit()
        
        return True
    
    def update_article_quantity(self, article_id, quantity):
        """
        Update the quantity of an article.
        
        Args:
            article_id: ID of the article
            quantity: New quantity
            
        Returns:
            Updated Article entity or None if not found
        """
        return self.update_article(article_id, quantity=quantity)
