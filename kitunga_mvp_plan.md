## 🎯 MVP Objective

Launch a **two-sided online marketplace** where small businesses can create product listings and customers can browse, purchase, and pay (including mobile money).
The goal is to validate:

1. **Seller demand** to list and sell products.
2. **Customer willingness** to buy through the platform.

```markdown
## 🎯 MVP Objective

Launch a **two-sided online marketplace** where small businesses can create product listings and customers can browse, purchase, and pay (including mobile money).
The goal is to validate:

1. **Seller demand** to list and sell products.
2. **Customer willingness** to buy through the platform.

---

## 🗂️ Core Scope

### 1. User Accounts & Roles

* **Customer**: Sign up, log in/out, browse, add to cart, checkout, view past orders.
* **Seller**: Sign up, log in/out, create and edit profile (business name, category, contact info, address, payment method).
* **Admin (You)**: Basic dashboard to view/manage users, orders, and payments.

### 2. Product Catalog

* Sellers can **add/edit/delete products** with:

  * Title, description, price, quantity, one featured image.
* Customers can:

  * Browse all products, filter by category, search by name/keyword.
* SEO-friendly **product detail pages**.

### 3. Checkout & Payments

* **Cart system** with quantity update and price total. 
* **Single integrated payment method** at launch (choose one of these depending on target region):

  * **Flutterwave** or **Paystack** (mobile money + card) for African markets.
  * **Stripe** for international card payments.
* **Order confirmation page** + email notification.

### 4. Seller Order Management

* Simple dashboard to:

  * View new orders.
  * Update order status to “Processing,” “Shipped,” or “Completed.”

### 5. Platform Admin Dashboard

* List of all users and products.
* View orders and payment logs.
* Ability to deactivate a seller or product if needed.

---

## 🏗️ Technical Architecture

| Layer             | Choice (Recommended)                                            | Reason                                                                         |
| ----------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| **Frontend**      | **Next.js + TypeScript + Tailwind CSS**                         | SEO-friendly, responsive, fast to build.                                       |
| **Backend/API**   | **Ruby on Rails (API mode)**                                    | You’re already skilled; rapid development with built-in auth and ActiveRecord. |
| **Database**      | **PostgreSQL**                                                  | Reliable relational database for marketplace data.                             |
| **Payments**      | Flutterwave/Paystack (Africa) **or** Stripe (global)            | Handles mobile money and cards.                                                |
| **Storage**       | AWS S3 (or Supabase Storage)                                    | Product images and other assets.                                               |
| **Hosting**       | Vercel for Next.js; Render/Fly.io/Heroku for Rails + PostgreSQL | Simple and scalable.                                                           |
| **Notifications** | Transactional email via SendGrid/Postmark                       | Order confirmations, password reset.                                           |

---

## � Current status (as of Oct 16, 2025)

- Phase 1 (Frontend design & initial Next.js implementation): DONE ✅
  - The UI and frontend flows have been implemented and wired to mock data.
- Remaining: full backend authentication, implement API routes, and backend implementations for products, cart, orders, payments and admin features.

> Because the frontend is ready, the next work items are backend-focused: Phase 2 (auth + routes) plus backend work in Phases 3 and 4.

---

## 🗓️ Updated Implementation Timeline (Backend-focused)

Goals:

* Set up the Rails API backend and React frontend foundations for further development.
* Ensure both environments can communicate securely through CORS.
* Establish database, folder structure, and Git version control.
* Deliver a working development environment ready for authentication and API expansion.

### Phase 2 – Full Authentication & API Routes (Week 3)

Backend work only. Goals:

* Implement secure auth (email/password) with JWT (Devise + Devise-JWT or custom JWT). Include email verification and password reset.
* Role support (customer, seller, admin) and role-based access control on API endpoints.
* Implement token refresh/revoke and a JWT denylist (already scaffolded in repo as `jwt_denylist`).
* Create the canonical API routes needed by the frontend (see API routes below).

Acceptance criteria:

* Users can sign up (customer or seller), confirm email, sign in, refresh token, and sign out (token revoked).
* Protected endpoints return 401 for missing/invalid tokens and 403 for forbidden roles.
* Password reset emails work end-to-end.

### Phase 3 – Backend: Products & Seller Management (Week 4–5)

Backend work only. Goals:

* Implement product CRUD with image upload support to S3 (or local storage in dev).
* Implement product search and category filtering endpoints used by the frontend.
* Expose seller profile endpoints (create/edit seller data) and seller order listing.

Acceptance criteria:

* Sellers can create/update/delete products via API and images persist in storage.
* Public listing, category filters and product details endpoints return the expected JSON shape for the frontend.

### Phase 4 – Backend: Cart, Orders & Payments (Week 6–7)

Backend work only. Goals:

* Implement cart persistence (session-backed or DB-backed per user) and order creation flow.
* Integrate chosen payment gateway (Flutterwave/Paystack/Stripe) on the server side and validate payment callbacks/webhooks.
* Implement payment records and update order status from payment events.

Acceptance criteria:

* Customers can create an order from their cart via API; orders are saved with order_items and subtotal calculations match frontend totals.
* Payment flow returns success/failure back to frontend and webhooks update order/payment records reliably.

### Phase 5 – Dashboards, Admin & Finalization (Week 8)

* Implement seller and admin dashboards endpoints: order management, user/product moderation, and simple reporting.
* Final API polish, pagination, input validation, rate limiting basics, and API documentation (Postman/OpenAPI).

### Phase 6 – QA & Launch (Week 9–10)

* End-to-end testing, security review, load testing, and deploy to production.

---

## 🔌 API Routes (suggested canonical list)

Authentication & users:

* POST /api/auth/sign_up (role param: customer|seller)
* POST /api/auth/sign_in -> { access_token, refresh_token }
* POST /api/auth/refresh -> { access_token }
* DELETE /api/auth/sign_out (revoke)
* POST /api/auth/password/forgot
* POST /api/auth/password/reset
* GET /api/users/:id (public profile)
* PUT /api/users/:id (profile update - auth required)

Products & catalog:

* GET /api/products
* GET /api/products/:id
* POST /api/products (seller only)
* PUT /api/products/:id (seller only)
* DELETE /api/products/:id (seller only)
* GET /api/categories

Cart, orders & payments:

* GET /api/cart
* POST /api/cart/items
* PUT /api/cart/items/:id
* DELETE /api/cart/items/:id
* POST /api/orders (creates order from cart)
* GET /api/orders/:id
* GET /api/orders (user or seller filtered)
* POST /api/payments (initiate payment)
* POST /api/payments/webhook (payment gateway callbacks)

Admin / Seller management:

* GET /api/admin/users
* PUT /api/admin/users/:id/deactivate
* GET /api/seller/orders
* PUT /api/seller/orders/:id/status

Notes:

* Use namespaced controllers under `api/` and versioning if desired (e.g., `/api/v1/...`).
* Ensure strong parameter validation and consistent serializer outputs (see `serializers/` directory).

---

## ✅ Deliverables after backend phases 2–4

* Fully functional authentication with JWT (email confirmation, password reset, refresh/revoke).
* A complete REST API for products, cart, orders and payments consumed by the frontend.
* Webhook handling for payment gateway and reliable order state updates.
* Seller and admin endpoints for managing products, orders and users.

---

## Next steps (short-term)

1. Prioritize Phase 2 backend tasks and wire up real auth endpoints to the existing frontend flows.
2. Implement the JWT denylist / Devise-JWT integration and email flows.
3. Implement the API routes above incrementally (auth → products → cart/orders → payments).

---

### Key Takeaway

With the frontend complete, focus the next 4–6 weeks on backend work that unlocks real end-to-end functionality: authentication, the API routes the frontend uses, secure payments and seller/admin workflows.

```
