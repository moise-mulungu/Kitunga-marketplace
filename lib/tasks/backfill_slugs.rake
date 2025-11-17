namespace :data do
  desc "Backfill category slugs from names"
  task backfill_category_slugs: :environment do
    Category.find_each do |c|
      next if c.slug.present?
      c.generate_slug
      c.save!(validate: false)
      puts "Backfilled category #{c.id} -> #{c.slug}"
    end
  end
end
