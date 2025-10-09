# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 Seeding data..."

# Clear existing data (optional for development)
Payment.destroy_all
OrderItem.destroy_all
Order.destroy_all
Product.destroy_all
User.destroy_all

# --- USERS ---
admin = User.create!(
  full_name: "Admin User",
  email: "admin@kitunga.com",
  password: "password",
  role: "admin"
)

seller = User.create!(
  full_name: "Moïse Seller",
  email: "seller@kitunga.com",
  password: "password",
  role: "seller",
  business_name: "Moïse Store",
  category: "Electronics",
  address: "Goma, DRC",
  phone: "+243900000000"
)

customer = User.create!(
  full_name: "Jane Buyer",
  email: "customer@kitunga.com",
  password: "password",
  role: "customer",
  address: "Bukavu, DRC",
  phone: "+243811111111"
)

puts "✅ Created users: #{User.count}"

# --- PRODUCTS ---
products = [
  { title: "HP Laptop 15", description: "Core i7, 16GB RAM, 512GB SSD", price: 750.00, quantity: 10, category: "Electronics" },
  { title: "Samsung A55", description: "6.5-inch display, 128GB storage", price: 400.00, quantity: 25, category: "Phones" },
  { title: "Wireless Headphones", description: "Noise cancelling, Bluetooth 5.0", price: 80.00, quantity: 40, category: "Accessories" }
]

products.each do |p|
  seller.products.create!(p)
end

puts "✅ Created products: #{Product.count}"

# --- ORDERS ---
order1 = customer.orders.create!(
  status: "pending",
  payment_status: "unpaid"
)

# Add products to order
product1 = Product.first
product2 = Product.second

order1.order_items.create!(product: product1, quantity: 1, price: product1.price)
order1.order_items.create!(product: product2, quantity: 2, price: product2.price)

# Recalculate total
order1.update!(total_amount: order1.order_items.sum("quantity * price"))

puts "✅ Created orders: #{Order.count}"

# --- PAYMENTS ---
order1.create_payment!(
  payment_method: "Flutterwave",
  transaction_id: "TX12345ABC",
  amount: order1.total_amount,
  status: "completed",
  provider: "Flutterwave",
  paid_at: Time.now
)

puts "✅ Created payments: #{Payment.count}"

puts "🌟 Seeding completed successfully!"
