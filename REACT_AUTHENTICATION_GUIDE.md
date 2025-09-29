# React-Vite Authentication with Rails JWT API

## Complete Implementation Guide

### 1. Install Dependencies

```bash
npm install axios
```

### 2. Create Authentication Service

Create `src/services/authService.js`:

```javascript
import axios from 'axios';

// Base API configuration
const API_BASE_URL = 'http://localhost:3000'; // Adjust to your Rails server URL

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Token storage utilities
const TOKEN_KEY = 'auth_token';

const tokenStorage = {
  get: () => localStorage.getItem(TOKEN_KEY),
  set: (token) => localStorage.setItem(TOKEN_KEY, token),
  remove: () => localStorage.removeItem(TOKEN_KEY),
};

// Add token to requests automatically
api.interceptors.request.use(
  (config) => {
    const token = tokenStorage.get();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Handle token expiration
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      tokenStorage.remove();
      window.location.href = '/login'; // Redirect to login
    }
    return Promise.reject(error);
  }
);

// Authentication service
export const authService = {
  // Login function
  async login(email, password) {
    try {
      const response = await api.post('/api/v1/users/login', {
        user: {
          email,
          password,
        },
      });

      // Extract JWT token from response headers
      const token = response.headers.authorization;
      
      if (token) {
        // Remove 'Bearer ' prefix if present
        const cleanToken = token.replace('Bearer ', '');
        tokenStorage.set(cleanToken);
        
        // Return user data from response body
        return {
          success: true,
          user: response.data.data,
          token: cleanToken,
        };
      } else {
        throw new Error('No token received from server');
      }
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.error || 'Login failed',
      };
    }
  },

  // Register function
  async register(userData) {
    try {
      const response = await api.post('/api/v1/users/signup', {
        user: userData,
      });

      // Extract JWT token from response headers
      const token = response.headers.authorization;
      
      if (token) {
        const cleanToken = token.replace('Bearer ', '');
        tokenStorage.set(cleanToken);
        
        return {
          success: true,
          user: response.data.data,
          token: cleanToken,
        };
      } else {
        throw new Error('No token received from server');
      }
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.errors || 'Registration failed',
      };
    }
  },

  // Logout function
  async logout() {
    try {
      await api.delete('/api/v1/users/logout');
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      tokenStorage.remove();
    }
  },

  // Check if user is authenticated
  isAuthenticated() {
    return !!tokenStorage.get();
  },

  // Get current token
  getToken() {
    return tokenStorage.get();
  },

  // Get current user (you might want to store this during login)
  getCurrentUser() {
    const userData = localStorage.getItem('current_user');
    return userData ? JSON.parse(userData) : null;
  },

  // Set current user
  setCurrentUser(user) {
    localStorage.setItem('current_user', JSON.stringify(user));
  },

  // Clear current user
  clearCurrentUser() {
    localStorage.removeItem('current_user');
  },
};

// Export the configured axios instance for other API calls
export default api;
```

### 3. Create API Services for Trading

Create `src/services/tradingService.js`:

```javascript
import api from './authService';

export const tradingService = {
  // Get user's portfolios
  async getMyPortfolios() {
    try {
      const response = await api.get('/api/v1/portfolios/my_portfolios');
      return { success: true, data: response.data };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.error || 'Failed to fetch portfolios' 
      };
    }
  },

  // Get all stocks
  async getStocks() {
    try {
      const response = await api.get('/api/v1/stocks');
      return { success: true, data: response.data };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.error || 'Failed to fetch stocks' 
      };
    }
  },

  // Buy stocks
  async buyStock(ticker, quantity) {
    try {
      const response = await api.post('/api/v1/portfolios/buy', {
        ticker,
        quantity,
      });
      return { success: true, data: response.data };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.error || 'Failed to buy stock' 
      };
    }
  },

  // Sell stocks
  async sellStock(ticker, quantity) {
    try {
      const response = await api.post('/api/v1/portfolios/sell', {
        ticker,
        quantity,
      });
      return { success: true, data: response.data };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.error || 'Failed to sell stock' 
      };
    }
  },

  // Get wallet info
  async getWallet(walletId) {
    try {
      const response = await api.get(`/api/v1/wallets/${walletId}`);
      return { success: true, data: response.data };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.error || 'Failed to fetch wallet' 
      };
    }
  },

  // Get transaction history
  async getTransactionHistory() {
    try {
      const response = await api.get('/api/v1/receipts');
      return { success: true, data: response.data };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.error || 'Failed to fetch transactions' 
      };
    }
  },
};
```

### 4. React Components Examples

#### Login Component (`src/components/Login.jsx`):

```jsx
import React, { useState } from 'react';
import { authService } from '../services/authService';

const Login = ({ onLoginSuccess }) => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    const result = await authService.login(formData.email, formData.password);

    if (result.success) {
      // Store user data
      authService.setCurrentUser(result.user);
      onLoginSuccess(result.user);
    } else {
      setError(result.error);
    }

    setLoading(false);
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label>Email:</label>
        <input
          type="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          required
        />
      </div>
      
      <div>
        <label>Password:</label>
        <input
          type="password"
          name="password"
          value={formData.password}
          onChange={handleChange}
          required
        />
      </div>

      {error && <div style={{ color: 'red' }}>{error}</div>}

      <button type="submit" disabled={loading}>
        {loading ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
};

export default Login;
```

#### Portfolio Component (`src/components/Portfolio.jsx`):

```jsx
import React, { useState, useEffect } from 'react';
import { tradingService } from '../services/tradingService';

const Portfolio = () => {
  const [portfolios, setPortfolios] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadPortfolios();
  }, []);

  const loadPortfolios = async () => {
    setLoading(true);
    const result = await tradingService.getMyPortfolios();
    
    if (result.success) {
      setPortfolios(result.data);
    } else {
      setError(result.error);
    }
    
    setLoading(false);
  };

  if (loading) return <div>Loading portfolios...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      <h2>My Portfolio</h2>
      {portfolios.length === 0 ? (
        <p>No stocks in portfolio</p>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Stock</th>
              <th>Quantity</th>
              <th>Current Price</th>
              <th>Market Value</th>
            </tr>
          </thead>
          <tbody>
            {portfolios.map((portfolio) => (
              <tr key={portfolio.id}>
                <td>{portfolio.stock.ticker} - {portfolio.stock.company_name}</td>
                <td>{portfolio.quantity}</td>
                <td>${portfolio.stock.current_price}</td>
                <td>${portfolio.current_market_value}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default Portfolio;
```

#### Trading Component (`src/components/TradingForm.jsx`):

```jsx
import React, { useState } from 'react';
import { tradingService } from '../services/tradingService';

const TradingForm = ({ onTradeSuccess }) => {
  const [formData, setFormData] = useState({
    ticker: '',
    quantity: '',
    action: 'buy', // 'buy' or 'sell'
  });
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage('');

    const { ticker, quantity, action } = formData;
    
    let result;
    if (action === 'buy') {
      result = await tradingService.buyStock(ticker, parseInt(quantity));
    } else {
      result = await tradingService.sellStock(ticker, parseInt(quantity));
    }

    if (result.success) {
      setMessage(`Successfully ${action === 'buy' ? 'bought' : 'sold'} ${quantity} shares of ${ticker}`);
      onTradeSuccess?.(result.data);
      setFormData({ ticker: '', quantity: '', action: 'buy' });
    } else {
      setMessage(`Error: ${result.error}`);
    }

    setLoading(false);
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <div>
      <h3>Trade Stocks</h3>
      <form onSubmit={handleSubmit}>
        <div>
          <label>Action:</label>
          <select name="action" value={formData.action} onChange={handleChange}>
            <option value="buy">Buy</option>
            <option value="sell">Sell</option>
          </select>
        </div>

        <div>
          <label>Stock Ticker:</label>
          <input
            type="text"
            name="ticker"
            value={formData.ticker}
            onChange={handleChange}
            placeholder="e.g., AAPL"
            required
          />
        </div>

        <div>
          <label>Quantity:</label>
          <input
            type="number"
            name="quantity"
            value={formData.quantity}
            onChange={handleChange}
            min="1"
            required
          />
        </div>

        <button type="submit" disabled={loading}>
          {loading ? 'Processing...' : `${formData.action.toUpperCase()} Stocks`}
        </button>
      </form>

      {message && (
        <div style={{ 
          color: message.includes('Error') ? 'red' : 'green',
          marginTop: '10px' 
        }}>
          {message}
        </div>
      )}
    </div>
  );
};

export default TradingForm;
```

### 5. App.jsx - Main Application

```jsx
import React, { useState, useEffect } from 'react';
import { authService } from './services/authService';
import Login from './components/Login';
import Portfolio from './components/Portfolio';
import TradingForm from './components/TradingForm';

function App() {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    // Check if user is already logged in
    if (authService.isAuthenticated()) {
      const currentUser = authService.getCurrentUser();
      if (currentUser) {
        setUser(currentUser);
        setIsAuthenticated(true);
      }
    }
  }, []);

  const handleLoginSuccess = (userData) => {
    setUser(userData);
    setIsAuthenticated(true);
  };

  const handleLogout = async () => {
    await authService.logout();
    authService.clearCurrentUser();
    setUser(null);
    setIsAuthenticated(false);
  };

  const handleTradeSuccess = () => {
    // Refresh portfolio or show success message
    console.log('Trade completed successfully');
  };

  if (!isAuthenticated) {
    return (
      <div className="app">
        <h1>Stock Trader Login</h1>
        <Login onLoginSuccess={handleLoginSuccess} />
      </div>
    );
  }

  return (
    <div className="app">
      <header>
        <h1>Stock Trader Dashboard</h1>
        <div>
          Welcome, {user?.first_name} {user?.last_name} ({user?.user_role})
          <button onClick={handleLogout} style={{ marginLeft: '10px' }}>
            Logout
          </button>
        </div>
      </header>

      <main>
        <Portfolio />
        <TradingForm onTradeSuccess={handleTradeSuccess} />
      </main>
    </div>
  );
}

export default App;
```

## Key Points:

1. **Token Location**: JWT token comes in the `Authorization` header, NOT the JSON body
2. **JTI vs Token**: Use the JWT token for authentication, JTI is just for reference
3. **Token Storage**: Store in localStorage (or sessionStorage for better security)
4. **Automatic Headers**: Axios interceptors automatically add the token to requests
5. **Error Handling**: Handle 401 responses to detect token expiration
6. **User Data**: Store user info separately from the token

## Security Notes:

- Consider using `sessionStorage` instead of `localStorage` for tokens
- Implement token refresh logic for long-term sessions  
- Add CSRF protection if needed
- Use HTTPS in production

This setup gives you a complete authentication flow that works seamlessly with your Rails JWT API!