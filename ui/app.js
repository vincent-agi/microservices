// API Configuration
const API_CONFIG = {
    // Use Traefik gateway by default, fallback to direct ports
    userService: 'http://localhost/api',
    cartService: 'http://localhost:5001',
    orderService: 'http://localhost:8080'
};

// State management
let authToken = localStorage.getItem('authToken') || null;
let currentUser = JSON.parse(localStorage.getItem('currentUser') || 'null');

// Initialize the app
document.addEventListener('DOMContentLoaded', () => {
    initTabs();
    initAuthForms();
    initUserForms();
    initCartForms();
    initOrderForms();
    initLogoutButton();
    updateAuthStatus();
});

// Tab management
function initTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const tabId = button.getAttribute('data-tab');
            
            // Remove active class from all tabs
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));
            
            // Add active class to clicked tab
            button.classList.add('active');
            document.getElementById(`${tabId}-tab`).classList.add('active');
        });
    });
}

// Update authentication status
function updateAuthStatus() {
    const authMessage = document.getElementById('auth-message');
    const logoutBtn = document.getElementById('logout-btn');

    if (authToken && currentUser) {
        authMessage.textContent = `Connecté: ${currentUser.email}`;
        logoutBtn.style.display = 'inline-block';
    } else {
        authMessage.textContent = 'Non connecté';
        logoutBtn.style.display = 'none';
    }
}

// Initialize logout button (called once on page load to prevent multiple event listeners)
function initLogoutButton() {
    const logoutBtn = document.getElementById('logout-btn');
    logoutBtn.addEventListener('click', logout);
}

function logout() {
    authToken = null;
    currentUser = null;
    localStorage.removeItem('authToken');
    localStorage.removeItem('currentUser');
    updateAuthStatus();
    showResult('login-result', 'Déconnexion réussie', 'success');
}

// Authentication forms
function initAuthForms() {
    // Register form
    document.getElementById('register-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('register-email').value;
        const password = document.getElementById('register-password').value;
        const firstName = document.getElementById('register-firstname').value;
        const lastName = document.getElementById('register-lastname').value;

        try {
            const response = await fetch(`${API_CONFIG.userService}/auth/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password, firstName, lastName })
            });

            const data = await response.json();
            
            if (response.ok) {
                showResult('register-result', 'Inscription réussie!', 'success', data);
                document.getElementById('register-form').reset();
            } else {
                showResult('register-result', 'Erreur lors de l\'inscription', 'error', data);
            }
        } catch (error) {
            showResult('register-result', `Erreur: ${error.message}`, 'error');
        }
    });

    // Login form
    document.getElementById('login-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('login-email').value;
        const password = document.getElementById('login-password').value;

        try {
            const response = await fetch(`${API_CONFIG.userService}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            });

            const data = await response.json();
            
            if (response.ok && data.data) {
                authToken = data.data.accessToken;
                currentUser = data.data.user;
                localStorage.setItem('authToken', authToken);
                localStorage.setItem('currentUser', JSON.stringify(currentUser));
                updateAuthStatus();
                showResult('login-result', 'Connexion réussie!', 'success', data);
                document.getElementById('login-form').reset();
            } else {
                showResult('login-result', 'Erreur lors de la connexion', 'error', data);
            }
        } catch (error) {
            showResult('login-result', `Erreur: ${error.message}`, 'error');
        }
    });
}

// User forms
function initUserForms() {
    // List users
    document.getElementById('list-users-btn').addEventListener('click', async () => {
        if (!authToken) {
            showResult('users-list', 'Vous devez être connecté pour voir les utilisateurs', 'error');
            return;
        }

        try {
            const response = await fetch(`${API_CONFIG.userService}/users`, {
                headers: { 'Authorization': `Bearer ${authToken}` }
            });

            const data = await response.json();
            
            if (response.ok && data.data) {
                displayUsersList(data.data);
            } else {
                showResult('users-list', 'Erreur lors du chargement', 'error', data);
            }
        } catch (error) {
            showResult('users-list', `Erreur: ${error.message}`, 'error');
        }
    });

    // Create user
    document.getElementById('create-user-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        if (!authToken) {
            showResult('create-user-result', 'Vous devez être connecté', 'error');
            return;
        }

        const email = document.getElementById('user-email').value;
        const password = document.getElementById('user-password').value;
        const firstName = document.getElementById('user-firstname').value;
        const lastName = document.getElementById('user-lastname').value;

        try {
            const response = await fetch(`${API_CONFIG.userService}/users`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${authToken}`
                },
                body: JSON.stringify({ email, password, firstName, lastName })
            });

            const data = await response.json();
            
            if (response.ok) {
                showResult('create-user-result', 'Utilisateur créé avec succès!', 'success', data);
                document.getElementById('create-user-form').reset();
            } else {
                showResult('create-user-result', 'Erreur lors de la création', 'error', data);
            }
        } catch (error) {
            showResult('create-user-result', `Erreur: ${error.message}`, 'error');
        }
    });
}

// Cart forms
function initCartForms() {
    // List carts
    document.getElementById('list-carts-btn').addEventListener('click', async () => {
        const userId = document.getElementById('filter-user-id').value;
        let url = `${API_CONFIG.cartService}/paniers`;
        
        if (userId) {
            url += `/user/${userId}`;
        }

        try {
            const response = await fetch(url);
            const data = await response.json();
            
            if (response.ok && data.data) {
                displayCartsList(data.data);
            } else {
                showResult('carts-list', 'Erreur lors du chargement', 'error', data);
            }
        } catch (error) {
            showResult('carts-list', `Erreur: ${error.message}`, 'error');
        }
    });

    // Create cart
    document.getElementById('create-cart-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const userId = document.getElementById('cart-user-id').value;
        const status = document.getElementById('cart-status').value;

        try {
            const response = await fetch(`${API_CONFIG.cartService}/paniers`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ userId: parseInt(userId), status })
            });

            const data = await response.json();
            
            if (response.ok) {
                showResult('create-cart-result', 'Panier créé avec succès!', 'success', data);
                document.getElementById('create-cart-form').reset();
            } else {
                showResult('create-cart-result', 'Erreur lors de la création', 'error', data);
            }
        } catch (error) {
            showResult('create-cart-result', `Erreur: ${error.message}`, 'error');
        }
    });

    // Add article
    document.getElementById('add-article-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const panierId = document.getElementById('article-cart-id').value;
        const productId = document.getElementById('article-product-id').value;
        const quantity = document.getElementById('article-quantity').value;
        const unitPrice = document.getElementById('article-price').value;

        try {
            const response = await fetch(`${API_CONFIG.cartService}/articles`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    panierId: parseInt(panierId),
                    productId,
                    quantity: parseInt(quantity),
                    unitPrice: parseFloat(unitPrice)
                })
            });

            const data = await response.json();
            
            if (response.ok) {
                showResult('add-article-result', 'Article ajouté avec succès!', 'success', data);
                document.getElementById('add-article-form').reset();
            } else {
                showResult('add-article-result', 'Erreur lors de l\'ajout', 'error', data);
            }
        } catch (error) {
            showResult('add-article-result', `Erreur: ${error.message}`, 'error');
        }
    });

    // View cart with articles
    document.getElementById('view-cart-btn').addEventListener('click', async () => {
        const cartId = document.getElementById('view-cart-id').value;
        
        if (!cartId) {
            showResult('view-cart-result', 'Veuillez entrer un ID de panier', 'error');
            return;
        }

        try {
            const response = await fetch(`${API_CONFIG.cartService}/paniers/${cartId}`);
            const data = await response.json();
            
            if (response.ok && data.data) {
                displayCartDetails(data.data);
            } else {
                showResult('view-cart-result', 'Erreur lors du chargement', 'error', data);
            }
        } catch (error) {
            showResult('view-cart-result', `Erreur: ${error.message}`, 'error');
        }
    });
}

// Order forms
function initOrderForms() {
    // List orders
    document.getElementById('list-orders-btn').addEventListener('click', async () => {
        const userId = document.getElementById('filter-order-user-id').value;
        let url = `${API_CONFIG.orderService}/orders`;
        
        const params = new URLSearchParams();
        if (userId) {
            params.append('userId', userId);
        }
        
        if (params.toString()) {
            url += `?${params.toString()}`;
        }

        try {
            const response = await fetch(url);
            const data = await response.json();
            
            if (response.ok && data.data) {
                displayOrdersList(data.data);
            } else {
                showResult('orders-list', 'Erreur lors du chargement', 'error', data);
            }
        } catch (error) {
            showResult('orders-list', `Erreur: ${error.message}`, 'error');
        }
    });

    // Create order
    document.getElementById('create-order-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const userId = document.getElementById('order-user-id').value;
        const status = document.getElementById('order-status').value;
        const totalAmount = document.getElementById('order-total').value;

        try {
            const response = await fetch(`${API_CONFIG.orderService}/orders`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    userId: parseInt(userId),
                    status,
                    totalAmount: parseFloat(totalAmount)
                })
            });

            const data = await response.json();
            
            if (response.ok) {
                showResult('create-order-result', 'Commande créée avec succès!', 'success', data);
                document.getElementById('create-order-form').reset();
            } else {
                showResult('create-order-result', 'Erreur lors de la création', 'error', data);
            }
        } catch (error) {
            showResult('create-order-result', `Erreur: ${error.message}`, 'error');
        }
    });

    // Add order item
    document.getElementById('add-order-item-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const orderId = document.getElementById('orderitem-order-id').value;
        const productId = document.getElementById('orderitem-product-id').value;
        const quantity = document.getElementById('orderitem-quantity').value;
        const unitPrice = document.getElementById('orderitem-price').value;

        try {
            const response = await fetch(`${API_CONFIG.orderService}/order-items`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    orderId: parseInt(orderId),
                    productId,
                    quantity: parseInt(quantity),
                    unitPrice: parseFloat(unitPrice)
                })
            });

            const data = await response.json();
            
            if (response.ok) {
                showResult('add-order-item-result', 'Item ajouté avec succès!', 'success', data);
                document.getElementById('add-order-item-form').reset();
            } else {
                showResult('add-order-item-result', 'Erreur lors de l\'ajout', 'error', data);
            }
        } catch (error) {
            showResult('add-order-item-result', `Erreur: ${error.message}`, 'error');
        }
    });
}

// Display functions
function displayUsersList(users) {
    const container = document.getElementById('users-list');
    
    if (Array.isArray(users) && users.length > 0) {
        container.className = 'result success';
        container.innerHTML = `<h4>Liste des utilisateurs (${users.length})</h4>` +
            users.map(user => `
                <div class="user-item">
                    <h4>👤 ${user.firstName} ${user.lastName}</h4>
                    <p><strong>ID:</strong> ${user.id}</p>
                    <p><strong>Email:</strong> ${user.email}</p>
                </div>
            `).join('');
    } else {
        container.className = 'result';
        container.innerHTML = '<p>Aucun utilisateur trouvé</p>';
    }
}

function displayCartsList(carts) {
    const container = document.getElementById('carts-list');
    
    if (Array.isArray(carts) && carts.length > 0) {
        container.className = 'result success';
        container.innerHTML = `<h4>Liste des paniers (${carts.length})</h4>` +
            carts.map(cart => `
                <div class="cart-item">
                    <h4>🛒 Panier #${cart.idPanier}</h4>
                    <p><strong>User ID:</strong> ${cart.userId}</p>
                    <p><strong>Status:</strong> ${cart.status}</p>
                    <p><strong>Date création:</strong> ${cart.dateCreation ? new Date(cart.dateCreation).toLocaleString('fr-FR') : 'N/A'}</p>
                </div>
            `).join('');
    } else {
        container.className = 'result';
        container.innerHTML = '<p>Aucun panier trouvé</p>';
    }
}

function displayCartDetails(cart) {
    const container = document.getElementById('view-cart-result');
    container.className = 'result success';
    
    let articlesHtml = '';
    if (cart.articles && cart.articles.length > 0) {
        articlesHtml = `
            <div class="articles-list">
                <h4>Articles (${cart.articles.length})</h4>
                ${cart.articles.map(article => `
                    <div class="article-item">
                        <p><strong>Product ID:</strong> ${article.productId} | 
                           <strong>Quantité:</strong> ${article.quantity} | 
                           <strong>Prix unitaire:</strong> ${article.unitPrice}€ | 
                           <strong>Total:</strong> ${article.totalLine}€</p>
                    </div>
                `).join('')}
                <p><strong>Total Panier:</strong> ${cart.totalPrice}€</p>
            </div>
        `;
    }
    
    container.innerHTML = `
        <div class="cart-item">
            <h4>🛒 Détails du Panier #${cart.idPanier}</h4>
            <p><strong>User ID:</strong> ${cart.userId}</p>
            <p><strong>Status:</strong> ${cart.status}</p>
            <p><strong>Date création:</strong> ${cart.dateCreation ? new Date(cart.dateCreation).toLocaleString('fr-FR') : 'N/A'}</p>
            ${articlesHtml}
        </div>
    `;
}

function displayOrdersList(orders) {
    const container = document.getElementById('orders-list');
    
    if (Array.isArray(orders) && orders.length > 0) {
        container.className = 'result success';
        container.innerHTML = `<h4>Liste des commandes (${orders.length})</h4>` +
            orders.map(order => `
                <div class="order-item">
                    <h4>📦 Commande #${order.id}</h4>
                    <p><strong>User ID:</strong> ${order.userId}</p>
                    <p><strong>Status:</strong> ${order.status}</p>
                    <p><strong>Montant total:</strong> ${order.totalAmount}€</p>
                    <p><strong>Date création:</strong> ${order.createdAt ? new Date(order.createdAt).toLocaleString('fr-FR') : 'N/A'}</p>
                </div>
            `).join('');
    } else {
        container.className = 'result';
        container.innerHTML = '<p>Aucune commande trouvée</p>';
    }
}

// Utility function to show results
function showResult(elementId, message, type = '', data = null) {
    const element = document.getElementById(elementId);
    element.className = `result ${type}`;
    
    let html = `<p>${message}</p>`;
    
    if (data) {
        html += `<pre>${JSON.stringify(data, null, 2)}</pre>`;
    }
    
    element.innerHTML = html;
}
