"""
CartService - Flask REST API for shopping cart management.
"""
from flask import Flask
from controllers.panier_controller import panier_bp
from controllers.article_controller import article_bp
import atexit

app = Flask(__name__)


# Register blueprints
app.register_blueprint(panier_bp)
app.register_blueprint(article_bp)


def init_app_db():
    """
    Initialize database at application startup.
    Only called once during app initialization.
    """
    try:
        from config.database import init_db
        init_db()
        print("Database initialized successfully")
    except Exception as e:
        # Log error and raise to prevent app from starting with bad DB config
        print(f"Critical error: Could not initialize database: {e}")
        raise


# Initialize database once at startup
with app.app_context():
    init_app_db()


@app.route("/hello")
def hello_world():
    """
    Health check endpoint.
    
    Returns:
        Simple hello message
    """
    return {"message": "Hello World"}


@app.route("/health")
def health_check():
    """
    Health check endpoint for monitoring.
    
    Returns:
        Health status
    """
    return {"status": "healthy", "service": "CartService"}


if __name__ == '__main__':
    import os
    debug_mode = os.getenv('FLASK_ENV', 'production') == 'development'
    app.run(debug=debug_mode, host='0.0.0.0', port=5001)
