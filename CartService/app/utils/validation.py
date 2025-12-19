"""
Validation utility functions.
"""

# Valid status values for panier
VALID_PANIER_STATUS = ['active', 'completed', 'abandoned']


def validate_pagination_params(page, limit):
    """
    Validate and normalize pagination parameters.
    
    Args:
        page: Page number (string or int)
        limit: Limit per page (string or int)
        
    Returns:
        Tuple of (page: int, limit: int, error: str or None)
    """
    try:
        page = 1 if page is None or page == "" else int(page)
        limit = 20 if limit is None or limit == "" else int(limit)
        
        if page < 1:
            return None, None, "Page must be greater than or equal to 1"
        
        if limit < 1:
            return None, None, "Limit must be greater than or equal to 1"
            
        if limit > 100:
            return None, None, "Limit cannot exceed 100"
            
        return page, limit, None
        
    except (ValueError, TypeError):
        return None, None, "Invalid pagination parameters"


def validate_required_fields(data, required_fields):
    """
    Validate that required fields are present in data.
    
    Args:
        data: Dictionary of data
        required_fields: List of required field names
        
    Returns:
        Error message or None if all fields are present
    """
    missing_fields = [field for field in required_fields if field not in data]
    
    if missing_fields:
        return f"Missing required fields: {', '.join(missing_fields)}"
    
    return None


def validate_panier_status(status):
    """
    Validate panier status value.
    
    Args:
        status: Status string to validate
        
    Returns:
        True if valid, False otherwise
    """
    if status is None:
        return True
    return status in VALID_PANIER_STATUS
