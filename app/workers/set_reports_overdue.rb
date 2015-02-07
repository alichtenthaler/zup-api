class SetReportsOverdue
  include Sidekiq::Worker

  # Send push notification for mobile clients
  def perform
    items = Reports::StatusControl.reports_with_possible_overdue

    items.find_in_batches do |group|
      group = Reports::Item.where(id: group.map(&:id))

      group.each do |item|
        overdue = Reports::StatusControl.new(item).overdue?
        item.update(overdue: overdue) if item.overdue != overdue
      end
    end
  end
end
