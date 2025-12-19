"""
CartService - Flask REST API for shopping cart management.
"""
from flask import Flask
from controllers.panier_controller import panier_bp
from controllers.article_controller import article_bp

app = Flask(__name__)

# Flag to track database initialization
app.db_initialized = False


# Register blueprints
app.register_blueprint(panier_bp)
app.register_blueprint(article_bp)


@app.before_request
def initialize_database():
    """
    Initialize database tables on first request.
    This is deferred to avoid connection errors when DB is not available at startup.
    """
    if not app.db_initialized:
        try:
            from config.database import init_db
            init_db()
            app.db_initialized = True
        except Exception as e:
            # Log error but don't crash the app
            print(f"Warning: Could not initialize database: {e}")


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
