puts "🌱 Seeding data..."

# --- CLEAR EXISTING DATA ---
Payment.destroy_all
OrderItem.destroy_all
Order.destroy_all
Product.destroy_all
Category.destroy_all
User.destroy_all

# --- ADMIN ---
admin = User.create!(
  full_name: "Admin User",
  email: "admin@kitunga.com",
  password: "password",
  role: "admin"
)
admin.confirm # Confirm the admin user

# --- SELLERS ---
sellers_data = [
  {
    full_name: "Moïse Seller",
    email: "seller@kitunga.com",
    password: "password",
    role: "seller",
    business_name: "Moïse Store",
    address: "Goma, DRC",
    phone: "+243900000000"
  },
  {
    full_name: "John Seller",
    email: "seller2@kitunga.com",
    password: "password123",
    role: "seller",
    business_name: "John Store",
    address: "Matadi, DRC",
    phone: "+243900000123"
  },
  {
    full_name: "Alice Seller",
    email: "seller3@kitunga.com",
    password: "password",
    role: "seller",
    business_name: "Alice Fashion",
    address: "Kinshasa, DRC",
    phone: "+243900000456"
  }
]

sellers = sellers_data.map { |s| User.create!(s) }
puts "✅ Created #{sellers.count} sellers"

# --- CUSTOMERS ---
customers_data = [
  {
    full_name: "Jane Buyer",
    email: "customer@kitunga.com",
    password: "password",
    role: "customer",
    address: "Bukavu, DRC",
    phone: "+243811111111"
  },
  {
    full_name: "Patrick Customer",
    email: "customer2@kitunga.com",
    password: "password",
    role: "customer",
    address: "Lubumbashi, DRC",
    phone: "+243822222222"
  },
  {
    full_name: "Grace Customer",
    email: "customer3@kitunga.com",
    password: "password",
    role: "customer",
    address: "Kisangani, DRC",
    phone: "+243833333333"
  }
]

customers = customers_data.map { |c| User.create!(c) }
puts "✅ Created #{customers.count} customers"

# --- CATEGORIES ---
product_categories = [
  "Electronics",
  "Phones",
  "Accessories",
  "Clothing",
  "Foods",
  "Traditional Products"
]

service_categories = [
  "Hotel Services",
  "Catering Services",
  "Tourism",
  "Travel Services",
  "Car & Equipment Rental",
  "Training & Education"
]

categories = {}

product_categories.each do |name|
  categories[name] = Category.create!(
    name: name,
    category_type: "product",
    slug: name.parameterize
  )
end

service_categories.each do |name|
  categories[name] = Category.create!(
    name: name,
    category_type: "service",
    slug: name.parameterize
  )
end


puts "✅ Created #{Category.count} categories (#{Category.product_categories.count} products, #{Category.service_categories.count} services)"


# --- PRODUCTS / SERVICES ---
product_data = [
  # Products
  {
    title: "HP Laptop 15",
    description: "Core i7, 16GB RAM, 512GB SSD",
    price: 750.00,
    quantity: 10,
    category: "Electronics",
    image_url: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "Samsung A55",
    description: "6.5-inch display, 128GB storage",
    price: 400.00,
    quantity: 25,
    category: "Phones",
    image_url: "https://images.unsplash.com/photo-1512499617640-c2f999098ef5?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "Wireless Headphones",
    description: "Noise cancelling, Bluetooth 5.0",
    price: 80.00,
    quantity: 40,
    category: "Accessories",
    image_url: "https://images.unsplash.com/photo-1512314889357-e157c22f938d?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "Nike Air Max",
    description: "Running shoes, size 42",
    price: 120.00,
    quantity: 20,
    category: "Clothing",
    image_url: "https://images.unsplash.com/photo-1600180758890-6e9e8a37aa15?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "Organic Honey 1L",
    description: "Pure natural honey from DRC",
    price: 25.00,
    quantity: 30,
    category: "Foods",
    image_url: "https://images.unsplash.com/photo-1607958996333-e81e7a2c9349?auto=format&fit=crop&w=800&q=80"
  },

  # Services
  {
    title: "Luxury Room Booking",
    description: "5-star hotel room with breakfast included",
    price: 150.00,
    quantity: 5,
    category: "Hotel Services",
    image_url: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "Wedding Catering Package",
    description: "Full catering for 100 guests with local cuisine",
    price: 1200.00,
    quantity: 3,
    category: "Catering Services",
    image_url: "https://images.unsplash.com/photo-1528715471579-d1bcf0ba5e83?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "City Tour Experience",
    description: "Full-day guided tour of Goma attractions",
    price: 80.00,
    quantity: 10,
    category: "Tourism",
    image_url: "https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "Airport Shuttle",
    description: "Travel between Goma airport and city center",
    price: 30.00,
    quantity: 10,
    category: "Travel Services",
    image_url: "https://images.unsplash.com/photo-1504215680853-026ed2a45def?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "Car Rental – Toyota Prado",
    description: "Luxury car rental per day",
    price: 100.00,
    quantity: 4,
    category: "Car & Equipment Rental",
    image_url: "https://images.unsplash.com/photo-1525609004556-c46c7d6cf023?auto=format&fit=crop&w=800&q=80"
  },
  {
    title: "Web Development Bootcamp",
    description: "3-month intensive training on React and Ruby on Rails",
    price: 500.00,
    quantity: 10,
    category: "Training & Education",
    image_url: "https://images.unsplash.com/photo-1581093588401-22d6363d6f32?auto=format&fit=crop&w=800&q=80"
  }
]

sellers.each do |seller|
  2.times do
    pdata = product_data.sample
    seller.products.create!(
      title: pdata[:title],
      description: pdata[:description],
      price: pdata[:price],
      quantity: pdata[:quantity],
      category: categories[pdata[:category]],
      image_url: pdata[:image_url]
    )
  end
end
puts "✅ Created #{Product.count} products/services"

# --- ORDERS & PAYMENTS ---
customers.each do |customer|
  2.times do
    order = customer.orders.create!(status: "pending", shipping_address: "DRC, City", payment_method: "Card")

    random_products = Product.order("RANDOM()").limit(2)
    random_products.each do |product|
      order.order_items.create!(
        product: product,
        quantity: rand(1..3),
        price: product.price
      )
    end

    order.update!(total_amount: order.order_items.sum("quantity * price"))

    order.create_payment!(
      payment_method: [ "Flutterwave", "PayPal", "Card" ].sample,
      transaction_id: "TX#{rand(1000..9999)}#{('A'..'Z').to_a.sample(3).join}",
      amount: order.total_amount,
      status: [ "completed", "pending" ].sample,
      provider: [ "Flutterwave", "PayPal", "Visa" ].sample,
      paid_at: Time.now
    )
  end
end

puts "✅ Created #{Order.count} orders"
puts "✅ Created #{Payment.count} payments"

puts "🌟 Seeding completed successfully!"
