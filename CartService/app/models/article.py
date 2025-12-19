"""
Article (Cart Item) entity model.
"""
from sqlalchemy import Column, Integer, String, DECIMAL, DateTime, ForeignKey, Computed
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from config.database import Base


class Article(Base):
    """
    Article entity representing an item in a shopping cart.
    
    Attributes:
        id_article: Primary key, auto-incremented
        panier_id: Foreign key to Panier
        product_id: ID of the product (string to allow external product service IDs)
        quantity: Quantity of the product
        unit_price: Price per unit
        total_line: Computed column (quantity * unit_price)
        created_at: Creation timestamp
        panier: Relationship to Panier entity
    """
    __tablename__ = 'article'

    id_article = Column(Integer, primary_key=True, autoincrement=True)
    panier_id = Column(Integer, ForeignKey('panier.id_panier', ondelete='CASCADE'), nullable=False)
    product_id = Column(String(255), nullable=False)
    quantity = Column(Integer, nullable=False)
    unit_price = Column(DECIMAL(10, 2), nullable=False)
    total_line = Column(DECIMAL(10, 2), Computed('(quantity * unit_price)', persisted=True))
    created_at = Column(DateTime, default=func.current_timestamp())
    
    # Relationship with panier
    panier = relationship("Panier", back_populates="articles")

    def to_dict(self):
        """
        Convert entity to dictionary.
        
        Returns:
            Dictionary representation of the Article
        """
        return {
            'idArticle': self.id_article,
            'panierId': self.panier_id,
            'productId': self.product_id,
            'quantity': self.quantity,
            'unitPrice': float(self.unit_price) if self.unit_price else 0.0,
            'totalLine': float(self.total_line) if self.total_line else 0.0,
            'createdAt': self.created_at.isoformat() + 'Z' if self.created_at else None,
        }
