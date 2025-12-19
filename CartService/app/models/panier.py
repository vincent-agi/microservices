"""
Panier (Cart) entity model.
"""
from sqlalchemy import Column, Integer, DateTime, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from config.database import Base


class Panier(Base):
    """
    Panier entity representing a shopping cart.
    
    Attributes:
        id_panier: Primary key, auto-incremented
        date_creation: Creation timestamp
        date_modification: Last modification timestamp
        status: Cart status (string: 'active', 'completed', 'abandoned')
        user_id: ID of the user who owns this cart
        articles: Relationship to Article entities
    """
    __tablename__ = 'panier'

    id_panier = Column(Integer, primary_key=True, autoincrement=True)
    date_creation = Column(DateTime, default=func.current_timestamp())
    date_modification = Column(DateTime, onupdate=func.current_timestamp(), nullable=True)
    status = Column(String(50), nullable=True)
    user_id = Column(Integer, nullable=True)
    
    # Relationship with articles
    articles = relationship("Article", back_populates="panier", cascade="all, delete-orphan")

    def to_dict(self):
        """
        Convert entity to dictionary.
        
        Returns:
            Dictionary representation of the Panier
        """
        return {
            'idPanier': self.id_panier,
            'dateCreation': self.date_creation.isoformat() if self.date_creation else None,
            'dateModification': self.date_modification.isoformat() if self.date_modification else None,
            'status': self.status,
            'userId': self.user_id,
        }
