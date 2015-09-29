namespace :reports do
  desc 'Set reports as overdue'
  task set_overdue: :environment do
    SetReportsOverdue.new.perform
  end

  desc 'Set protocol as id'
  task normalize_protocol: :environment do
    puts 'Updating protocol from reports...'

    Reports::Item.find_in_batches do |items|
      items.each do |item|
        if item.update(protocol: item.id)
          puts "Item ##{item.id} updated successfully!"
        else
          puts "Couldn't update item ##{item.id}: #{item.errors.full_messages.join(", ")}"
        end
      end
    end

    ActiveRecord::Base.connection.execute(
      <<-SQL
        SELECT setval('protocol_seq', (SELECT MAX(protocol) FROM reports_items));
      SQL
    )

    puts 'Reports updated!'
  end
end
