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

## 🗓️ Implementation Timeline (Approx. 8–10 Weeks)

### **Phase 1 – Setup & Foundation (Week 1–2)**

* Finalize wireframes and UI design.
* Set up GitHub repository, CI/CD pipelines, and environment configuration.
* Initialize Next.js frontend and Rails API backend projects.
* Design database schema (Users, Products, Orders, Payments).

### **Phase 2 – Authentication & Profiles (Week 3)**

* Implement email/password signup/login with JWT or Devise-JWT (Rails).
* Build separate flows for Seller vs. Customer roles.
* Create Seller profile page (business name, category, address).

### **Phase 3 – Product Management (Week 4–5)**

* Seller CRUD operations: add/edit/delete product with image upload to S3.
* Public catalog page with category filters and search.
* Individual product detail page.

### **Phase 4 – Cart & Checkout (Week 6–7)**

* Cart management (add/remove/update items).
* Integrate chosen payment gateway (Flutterwave/Paystack/Stripe).
* Implement order confirmation page and email receipt.

### **Phase 5 – Dashboards & Admin (Week 8)**

* Seller dashboard: view and update order status.
* Simple admin dashboard for platform owner.
* Final UI polish, responsive testing (desktop + mobile).

### **Phase 6 – QA & Launch (Week 9–10)**

* End-to-end testing, security review, load testing.
* Deploy to production (Vercel + Render/Fly.io).
* Invite a small group of sellers/customers for beta feedback.

---

## 🛠️ Post-MVP (Future Enhancements)

These are intentionally **not** in the MVP, but you can add them after you validate traction:

* Ratings & reviews.
* Advanced seller analytics and inventory management.
* Multiple payment methods and currencies.
* Referral/coupon system.
* Real-time chat between sellers and customers.
* Logistics/shipping integrations.

---

## ✅ Deliverables at Launch

* **Responsive web app** where:

  * Sellers can register, upload products, and manage orders.
  * Customers can browse products, pay securely, and receive confirmations.
* **Admin panel** for basic moderation.
* **Deployed production environment** with SSL and a custom domain.

---

### Key Takeaway

This plan keeps your MVP laser-focused:

> *Enable sellers to list products and customers to purchase them with mobile-friendly payments.*
> Everything else—analytics, reviews, complex marketing features—can wait until the market validates Kitunga.
