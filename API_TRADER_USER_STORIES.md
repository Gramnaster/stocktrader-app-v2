# Trader User Stories & API Documentation

## Overview
This document outlines all user stories and API endpoints available to **Trader** users in the Stock Trading application. Traders are regular users who can buy and sell stocks, manage their portfolio, and view their transaction history.

---

## Authentication
All trader endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## User Status Requirements
- **Approved Status**: Traders must have `user_status: "approved"` to buy/sell stocks
- **Pending/Rejected**: Users with pending or rejected status can view data but cannot trade

---

## Trader User Stories

### 1. Authentication & Account Management

#### Story 1.1: User Registration
**As a trader, I want to register for an account so that I can start trading stocks.**

- **Implementation**: Handled by Devise registration
- **Endpoint**: `POST /api/v1/users/sign_up`
- **Status**: User starts with `pending` status until admin approval
- **Auto-Created**: Wallet with initial balance

#### Story 1.2: User Login
**As a trader, I want to log in to my account so that I can access trading features.**

- **Implementation**: Devise JWT authentication
- **Endpoint**: `POST /api/v1/users/login`
- **Returns**: JWT token for subsequent API calls

#### Story 1.3: Account Confirmation
**As a trader, I want to confirm my email address so that I can complete my registration.**

- **Implementation**: Devise confirmable module
- **Auto-Confirmed**: Admin-created users bypass confirmation

### 2. Stock Information & Research

#### Story 2.1: Browse Available Stocks
**As a trader, I want to view all available stocks so that I can research investment opportunities.**

- **Endpoint**: `GET /api/v1/stocks`
- **Returns**: List of all stocks with current prices, company names, currencies
- **Data Source**: Real-time data from Finnhub API

#### Story 2.2: View Stock Details
**As a trader, I want to see detailed information about a specific stock so that I can make informed decisions.**

- **Endpoint**: `GET /api/v1/stocks/:id`
- **Returns**: Detailed stock information including current price, market cap, currency

#### Story 2.3: View Historical Prices
**As a trader, I want to see historical price data so that I can analyze stock trends.**

- **Endpoint**: `GET /api/v1/historical_prices`
- **Returns**: Historical price data for stocks
- **Background Jobs**: Daily price updates via `UpdateDailyClosingPricesJob`

### 3. Portfolio Management

#### Story 3.1: View My Portfolio
**As a trader, I want to see all my current stock holdings so that I can track my investments.**

- **Endpoint**: `GET /api/v1/portfolios/my_portfolios`
- **Returns**: Current user's portfolios with quantities and market values
- **Authorization**: User can only see their own portfolios

```json
[
  {
    "id": 1,
    "user_id": 1,
    "stock_id": 1,
    "quantity": 10.0,
    "current_market_value": 1500.00,
    "created_at": "2025-09-30T12:00:00.000Z",
    "updated_at": "2025-09-30T12:00:00.000Z",
    "stock": {
      "id": 1,
      "ticker": "AAPL",
      "company_name": "Apple Inc.",
      "current_price": 150.00,
      "currency": "USD"
    }
  }
]
```

#### Story 3.2: View Portfolio Details
**As a trader, I want to see detailed information about a specific portfolio holding.**

- **Endpoint**: `GET /api/v1/portfolios/:id`
- **Authorization**: Users can only view their own portfolios
- **Admin Override**: Admins can view any portfolio

### 4. Stock Trading

#### Story 4.1: Buy Stocks
**As a trader, I want to buy stocks so that I can build my investment portfolio.**

- **Endpoint**: `POST /api/v1/portfolios/buy`
- **Requirements**: 
  - Must have `approved` user status
  - Sufficient wallet balance
  - Valid stock ticker

**Request Body:**
```json
{
  "ticker": "AAPL",
  "quantity": 10
}
```

**Response:**
```json
{
  "message": "Shares bought successfully",
  "receipt": {
    "id": 123,
    "quantity": 10,
    "price_per_share": 150.00,
    "total_amount": 1500.00,
    "transaction_type": "buy",
    "created_at": "2025-09-30T12:00:00.000Z",
    "stock": {
      "id": 1,
      "ticker": "AAPL",
      "company_name": "Apple Inc."
    },
    "wallet_balance": 500.00
  }
}
```

**Business Logic:**
- Real-time price fetching from current stock price
- Automatic wallet balance deduction
- Portfolio creation/update (one portfolio per user-stock combination)
- Receipt generation for transaction record
- Error handling for insufficient funds

#### Story 4.2: Sell Stocks
**As a trader, I want to sell stocks so that I can realize profits or cut losses.**

- **Endpoint**: `POST /api/v1/portfolios/sell`
- **Requirements**:
  - Must have `approved` user status
  - Must own sufficient shares
  - Valid stock ticker

**Request Body:**
```json
{
  "ticker": "AAPL",
  "quantity": 5
}
```

**Response:**
```json
{
  "message": "Shares sold successfully",
  "receipt": {
    "id": 124,
    "quantity": 5,
    "price_per_share": 155.00,
    "total_amount": 775.00,
    "transaction_type": "sell",
    "created_at": "2025-09-30T12:00:00.000Z",
    "stock": {
      "id": 1,
      "ticker": "AAPL",
      "company_name": "Apple Inc."
    },
    "wallet_balance": 1275.00
  }
}
```

**Business Logic:**
- Validates sufficient share ownership
- Real-time price calculation
- Automatic wallet balance credit
- Portfolio quantity reduction (auto-deletion if quantity reaches 0)
- Receipt generation for transaction record

### 5. Transaction History

#### Story 5.1: View My Transaction History
**As a trader, I want to see all my past transactions so that I can track my trading activity.**

- **Endpoint**: `GET /api/v1/receipts` (filtered to user's transactions)
- **Authorization**: Users see only their own receipts
- **Returns**: All buy/sell transactions with complete details

#### Story 5.2: View Transaction Details
**As a trader, I want to see details of a specific transaction for my records.**

- **Endpoint**: `GET /api/v1/receipts/:id`
- **Authorization**: Users can only view their own receipts
- **Returns**: Complete transaction details including stock info and amounts

### 6. Wallet Management

#### Story 6.1: View Wallet Balance
**As a trader, I want to see my current wallet balance so that I know how much I can invest.**

- **Endpoint**: `GET /api/v1/wallets/:id` (Admin users only - can view any wallet)
- **Endpoint**: `GET /api/v1/wallets/my_wallet` (Recommended for regular users)
- **Security**: Users can only access their own wallet data
- **Returns**: Current wallet balance and user information
- **Auto-Updated**: Balance changes automatically with buy/sell transactions

**For regular users, accessing any wallet ID will return their own wallet for security.**

#### Story 6.2: Deposit Money
**As a trader, I want to deposit money into my wallet so that I can have funds available for trading.**

- **Endpoint**: `POST /api/v1/wallets/deposit`
- **Authentication**: Required (approved users only)
- **Request Body**:
```json
{
  "amount": 100.00
}
```
- **Response**:
```json
{
  "message": "Deposit successful",
  "receipt": {
    "id": 123,
    "amount": 100.00,
    "transaction_type": "deposit",
    "created_at": "2025-10-01T12:00:00Z",
    "wallet_balance": 150.00
  }
}
```
- **Features**:
  - Creates receipt record for tracking
  - Immediate wallet balance update
  - Amount validation (positive, max $1,000,000)

#### Story 6.3: Withdraw Money
**As a trader, I want to withdraw money from my wallet so that I can access my funds.**

- **Endpoint**: `POST /api/v1/wallets/withdraw`
- **Authentication**: Required (approved users only)
- **Request Body**:
```json
{
  "amount": 50.00
}
```
- **Response**:
```json
{
  "message": "Withdrawal successful",
  "receipt": {
    "id": 124,
    "amount": 50.00,
    "transaction_type": "withdraw",
    "created_at": "2025-10-01T12:05:00Z",
    "wallet_balance": 100.00
  }
}
```
- **Features**:
  - Validates sufficient balance before withdrawal
  - Creates receipt record for tracking
  - Immediate wallet balance update
  - Prevents negative balances

#### Story 6.4: Track Wallet History
**As a trader, I want to see how my wallet balance changes over time through my transaction history.**

- **Implementation**: Tracked through receipt records (buy/sell/deposit/withdraw)
- **Each Receipt Shows**: Updated wallet balance after transaction
- **Transaction Types**: `buy`, `sell`, `deposit`, `withdraw`
- **Real-time Updates**: Balance immediately reflects in all transaction responses

### 7. Market Data Access

#### Story 7.1: View Country Information
**As a trader, I want to see information about different countries so that I can understand market contexts.**

- **Endpoint**: `GET /api/v1/countries`
- **Returns**: List of countries with codes and names

#### Story 7.2: Access Market Data
**As a trader, I want to access current market data so that I can make informed trading decisions.**

- **Real-time Prices**: Current stock prices updated via Finnhub API
- **Market Cap Data**: Available through stock endpoints
- **Background Jobs**: Automatic daily price and market cap updates

---

## Error Handling

### Common Error Responses

#### 401 Unauthorized
```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

#### 403 Forbidden (Unapproved User)
```json
{
  "error": "Account pending approval. Please wait for admin approval to start trading."
}
```

#### 422 Unprocessable Entity (Insufficient Funds)
```json
{
  "error": "Insufficient funds: balance is 500.0, need 1500.0"
}
```

#### 422 Unprocessable Entity (Insufficient Shares)
```json
{
  "error": "Insufficient shares: you have 5, trying to sell 10"
}
```

#### 404 Not Found (Invalid Stock)
```json
{
  "error": "Stock not found"
}
```

---

## Business Rules & Constraints

### Portfolio Management
- **One Portfolio Per Stock**: Each user can have only one portfolio entry per stock
- **Automatic Creation**: Portfolios created automatically on first purchase
- **Auto-Deletion**: Portfolios automatically deleted when quantity reaches 0
- **Composite Primary Key**: Portfolios identified by [user_id, stock_id]

### Transaction Processing
- **Atomic Operations**: All buy/sell operations are atomic (wallet + portfolio + receipt)
- **Real-time Pricing**: All transactions use current market prices
- **Receipt Generation**: Every transaction automatically generates a receipt
- **Balance Validation**: Insufficient funds prevent buy orders
- **Share Validation**: Insufficient shares prevent sell orders

### Security & Authorization
- **JWT Authentication**: Required for all trading operations
- **User Status Check**: Only approved users can trade
- **Data Isolation**: Users can only access their own data
- **Admin Override**: Admins can view all data but cannot trade on behalf of users

### Data Integrity
- **Positive Balances**: Wallet balances cannot go negative
- **Positive Quantities**: Portfolio quantities cannot be negative
- **Unique Constraints**: One portfolio per user-stock combination
- **Foreign Key Constraints**: All references must exist

### Wallet Transaction Rules
- **Deposit Limits**: Maximum deposit amount of $1,000,000
- **Positive Amounts**: All deposits and withdrawals must be positive
- **Balance Validation**: Withdrawals require sufficient wallet balance
- **Receipt Tracking**: All wallet transactions create receipt records
- **Immediate Updates**: Wallet balance updates immediately after transactions

---

## Frontend Integration Examples

### React-Vite Integration

#### Get User Portfolio
```javascript
const getMyPortfolio = async () => {
  const response = await fetch('/api/v1/portfolios/my_portfolios', {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
  return response.json();
};
```

#### Buy Stocks
```javascript
const buyStock = async (ticker, quantity) => {
  const response = await fetch('/api/v1/portfolios/buy', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ ticker, quantity })
  });
  return response.json();
};
```

#### Sell Stocks
```javascript
const sellStock = async (ticker, quantity) => {
  const response = await fetch('/api/v1/portfolios/sell', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ ticker, quantity })
  });
  return response.json();
};
```

#### Deposit Money
```javascript
const depositMoney = async (amount) => {
  const response = await fetch('/api/v1/wallets/deposit', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ amount })
  });
  return response.json();
};
```

#### Withdraw Money
```javascript
const withdrawMoney = async (amount) => {
  const response = await fetch('/api/v1/wallets/withdraw', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ amount })
  });
  return response.json();
};
```

#### Check Wallet Balance
```javascript
const getWalletBalance = async (walletId) => {
  const response = await fetch(`/api/v1/wallets/${walletId}`, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
  return response.json();
};
```

---

## Status & Approval Workflow

### User Status Progression
1. **Registration**: User signs up → Status: `pending`
2. **Admin Review**: Admin reviews application
3. **Approval**: Admin updates status → Status: `approved`
4. **Trading Access**: User can now buy/sell stocks

### Status-Based Permissions
- **Pending**: Can view stocks, cannot trade
- **Approved**: Full trading access
- **Rejected**: Limited access, cannot trade

---

## Notes for Developers

1. **Real-time Data**: Stock prices are fetched in real-time during transactions
2. **Background Jobs**: Daily price updates via SolidQueue background jobs
3. **Error Handling**: Comprehensive error messages for all failure scenarios
4. **Performance**: Includes eager loading for related data (stocks, users)
5. **Scalability**: Composite primary keys and proper indexing for performance
6. **Testing**: Comprehensive RSpec test coverage for all trading scenarios
7. **Security**: Admin authorization concerns and proper data isolation

The system is fully functional for trader operations with proper error handling, real-time pricing, and comprehensive transaction management.