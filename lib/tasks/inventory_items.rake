namespace :inventory_items do
  task :unlock => :environment do
    Inventory::Item.locked.each do |item|
      Inventory::ItemLocking.new(item).unlock_if_expired!
    end
  end
end
