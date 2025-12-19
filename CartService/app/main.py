"""
CartService - Flask REST API for shopping cart management.
"""
from flask import Flask
from config.database import init_db
from controllers.panier_controller import panier_bp
from controllers.article_controller import article_bp

app = Flask(__name__)


# Initialize database tables
with app.app_context():
    init_db()


# Register blueprints
app.register_blueprint(panier_bp)
app.register_blueprint(article_bp)


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
    app.run(debug=True, host='0.0.0.0', port=5001)
