"""
Service layer for Panier (Cart) operations.
"""
from sqlalchemy.orm import Session
from sqlalchemy import func
from models.panier import Panier
from models.article import Article
from utils.responses import paginate_query
from datetime import datetime, timezone


class PanierService:
    """
    Service for managing Panier (shopping cart) entities.
    """
    
    def __init__(self, db: Session):
        """
        Initialize PanierService with database session.
        
        Args:
            db: SQLAlchemy database session
        """
        self.db = db
    
    def create_panier(self, user_id=None, status='active'):
        """
        Create a new panier.
        
        Args:
            user_id: ID of the user who owns the cart
            status: Initial status of the cart (default: 'active')
            
        Returns:
            Created Panier entity
        """
        panier = Panier(
            user_id=user_id,
            status=status
        )
        
        self.db.add(panier)
        self.db.commit()
        self.db.refresh(panier)
        
        return panier
    
    def get_panier_by_id(self, panier_id):
        """
        Get a panier by its ID.
        
        Args:
            panier_id: ID of the panier
            
        Returns:
            Panier entity or None if not found
        """
        return self.db.query(Panier).filter(Panier.id_panier == panier_id).first()
    
    def get_all_paniers(self, page=1, limit=20, user_id=None, status=None):
        """
        Get all paniers with pagination and optional filtering.
        
        Args:
            page: Page number (1-indexed)
            limit: Items per page
            user_id: Filter by user ID (optional)
            status: Filter by status (optional)
            
        Returns:
            Tuple of (paniers, total_count, total_pages)
        """
        query = self.db.query(Panier)
        
        # Apply filters
        if user_id is not None:
            query = query.filter(Panier.user_id == user_id)
        
        if status is not None:
            query = query.filter(Panier.status == status)
        
        # Order by most recent first
        query = query.order_by(Panier.date_creation.desc())
        
        return paginate_query(query, page, limit)
    
    def update_panier(self, panier_id, user_id=None, status=None):
        """
        Update a panier.
        
        Args:
            panier_id: ID of the panier to update
            user_id: New user ID (optional)
            status: New status (optional)
            
        Returns:
            Updated Panier entity or None if not found
        """
        panier = self.get_panier_by_id(panier_id)
        
        if not panier:
            return None
        
        if user_id is not None:
            panier.user_id = user_id
        
        if status is not None:
            panier.status = status
        
        panier.date_modification = datetime.now(timezone.utc)
        
        self.db.commit()
        self.db.refresh(panier)
        
        return panier
    
    def delete_panier(self, panier_id):
        """
        Delete a panier by ID.
        
        Args:
            panier_id: ID of the panier to delete
            
        Returns:
            True if deleted, False if not found
        """
        panier = self.get_panier_by_id(panier_id)
        
        if not panier:
            return False
        
        self.db.delete(panier)
        self.db.commit()
        
        return True
    
    def get_panier_with_articles(self, panier_id):
        """
        Get a panier with all its articles and calculated totals.
        
        Args:
            panier_id: ID of the panier
            
        Returns:
            Dictionary with panier data and articles or None if not found
        """
        panier = self.get_panier_by_id(panier_id)
        
        if not panier:
            return None
        
        # Calculate totals
        total_quantity = sum(article.quantity for article in panier.articles)
        total_price = sum(float(article.total_line) for article in panier.articles)
        
        return {
            **panier.to_dict(),
            'articles': [article.to_dict() for article in panier.articles],
            'totalQuantity': total_quantity,
            'totalPrice': round(total_price, 2)
        }
    
    def get_paniers_by_user(self, user_id, page=1, limit=20):
        """
        Get all paniers for a specific user with pagination.
        
        Args:
            user_id: ID of the user
            page: Page number (1-indexed)
            limit: Items per page
            
        Returns:
            Tuple of (paniers, total_count, total_pages)
        """
        return self.get_all_paniers(page=page, limit=limit, user_id=user_id)
