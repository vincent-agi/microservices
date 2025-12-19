"""
Helper functions for communicating with UserService.
"""
import os
import requests


def verify_user_exists(user_id):
    """
    Verify if a user exists in the UserService.
    
    Args:
        user_id: The ID of the user to verify
        
    Returns:
        Tuple of (exists: bool, error_message: str or None)
    """
    # Get UserService URL from environment or use default
    user_service_url = os.getenv('USER_SERVICE_URL', 'http://user-api:3000')
    
    try:
        response = requests.get(
            f"{user_service_url}/users/{user_id}",
            timeout=5
        )
        
        if response.status_code == 200:
            return True, None
        elif response.status_code == 404:
            return False, f"User with ID {user_id} not found"
        else:
            return False, f"Error verifying user: {response.status_code}"
            
    except requests.exceptions.Timeout:
        return False, "UserService request timeout"
    except requests.exceptions.ConnectionError:
        return False, "Cannot connect to UserService"
    except Exception as e:
        return False, f"Error communicating with UserService: {str(e)}"
