# Kitunga API Documentation (Phase 1)

Base URL: `/api/v1`

---

## 🧑 Users

| Method | Endpoint | Description |
|--------|-----------|--------------|
| **GET** | `/users` | List all users |
| **GET** | `/users/:id` | Retrieve a single user |
| **POST** | `/users` | Create a new user |
| **PATCH** | `/users/:id` | Update user information |
| **DELETE** | `/users/:id` | Delete a user |

---

## 🛍️ Products

| Method | Endpoint | Description |
|--------|-----------|--------------|
| **GET** | `/products` | List all products |
| **GET** | `/products/:id` | Retrieve a single product |
| **POST** | `/products` | Create a new product |
| **PATCH** | `/products/:id` | Update product details |
| **DELETE** | `/products/:id` | Delete a product |

---

## 📦 Orders

| Method | Endpoint | Description |
|--------|-----------|--------------|
| **GET** | `/orders` | List all orders |
| **GET** | `/orders/:id` | Retrieve a single order |
| **POST** | `/orders` | Create a new order |
| **PATCH** | `/orders/:id` | Update order details |
| **DELETE** | `/orders/:id` | Delete an order |

---

## 🧾 Order Items

| Method | Endpoint | Description |
|--------|-----------|--------------|
| **GET** | `/order_items` | List all order items |
| **GET** | `/order_items/:id` | Retrieve a single order item |
| **POST** | `/order_items` | Create a new order item |
| **PATCH** | `/order_items/:id` | Update an order item |
| **DELETE** | `/order_items/:id` | Delete an order item |

---

## 💳 Payments

| Method | Endpoint | Description |
|--------|-----------|--------------|
| **GET** | `/payments` | List all payments |
| **GET** | `/payments/:id` | Retrieve a single payment |
| **POST** | `/payments` | Create a new payment |
| **PATCH** | `/payments/:id` | Update payment details |
| **DELETE** | `/payments/:id` | Delete a payment |

---

### 📘 Notes

- All responses are in **JSON format**.  
- Use proper HTTP headers:
