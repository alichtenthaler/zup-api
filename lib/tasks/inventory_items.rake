namespace :inventory_items do
  task unlock: :environment do
    UnlockInventoryItems.new.perform
  end
end
