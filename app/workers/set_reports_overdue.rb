class SetReportsOverdue
  include Sidekiq::Worker

  # Send push notification for mobile clients
  def perform
    items = Reports::StatusControl.reports_with_possible_overdue

    items.find_in_batches do |group|
      group = Reports::Item.where(id: group.map(&:id))

      group.each do |item|
        overdue = Reports::StatusControl.new(item).overdue?

        if item.overdue != overdue
          item.update(overdue: overdue)

          Reports::CreateHistoryEntry.new(item)
            .create('overdue', 'Relato entrou em atraso, quando estava no status:', item.status)
        end
      end
    end
  end
end
