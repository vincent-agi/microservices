"""
Utility functions for API responses.
"""
import time
from flask import jsonify


def success_response(data, status_code=200, **meta_extra):
    """
    Create a standardized success response.
    
    Args:
        data: The data to return
        status_code: HTTP status code
        **meta_extra: Additional metadata fields
        
    Returns:
        Flask response with standardized format
    """
    meta = {
        'timestamp': str(int(time.time() * 1000))
    }
    meta.update(meta_extra)
    
    return jsonify({
        'data': data,
        'meta': meta
    }), status_code


def error_response(code, message, details=None, status_code=400):
    """
    Create a standardized error response.
    
    Args:
        code: Error code (e.g., 'VALIDATION_ERROR', 'NOT_FOUND')
        message: Human-readable error message
        details: Additional error details (dictionary)
        status_code: HTTP status code
        
    Returns:
        Flask response with standardized error format
    """
    error_obj = {
        'code': code,
        'message': message,
        'details': details or {}
    }
    
    return jsonify({
        'error': error_obj
    }), status_code


def paginate_query(query, page, limit):
    """
    Paginate a SQLAlchemy query.
    
    Args:
        query: SQLAlchemy query object
        page: Page number (1-indexed)
        limit: Items per page
        
    Returns:
        Tuple of (items, total_count, total_pages)
    """
    total = query.count()
    total_pages = (total + limit - 1) // limit if limit > 0 else 0
    
    items = query.limit(limit).offset((page - 1) * limit).all()
    
    return items, total, total_pages
