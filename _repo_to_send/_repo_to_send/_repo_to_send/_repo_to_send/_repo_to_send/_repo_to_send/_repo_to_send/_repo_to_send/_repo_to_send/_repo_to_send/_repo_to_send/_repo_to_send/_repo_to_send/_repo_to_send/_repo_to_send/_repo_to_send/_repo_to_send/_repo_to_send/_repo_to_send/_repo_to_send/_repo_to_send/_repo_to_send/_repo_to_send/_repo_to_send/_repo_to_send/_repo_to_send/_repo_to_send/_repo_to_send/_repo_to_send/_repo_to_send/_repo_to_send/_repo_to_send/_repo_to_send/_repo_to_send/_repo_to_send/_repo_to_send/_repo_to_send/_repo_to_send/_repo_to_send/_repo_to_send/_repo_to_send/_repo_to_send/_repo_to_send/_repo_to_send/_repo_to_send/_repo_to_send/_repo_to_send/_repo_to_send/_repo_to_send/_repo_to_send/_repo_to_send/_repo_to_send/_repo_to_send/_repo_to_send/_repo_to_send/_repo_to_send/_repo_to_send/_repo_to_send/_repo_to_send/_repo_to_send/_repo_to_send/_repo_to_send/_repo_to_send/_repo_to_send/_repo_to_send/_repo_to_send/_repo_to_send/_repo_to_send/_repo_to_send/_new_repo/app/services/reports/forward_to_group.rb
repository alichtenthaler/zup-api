module Reports
  class ForwardToGroup
    attr_reader :report, :category, :user, :old_group

    def initialize(report, user = nil)
      @report = report
      @category = report.category
      @user = user
      @old_group = report.assigned_group
    end

    def forward!(group, message = nil)
      forward(group)

      if category.comment_required_when_forwarding || message.present?
        create_comment!(message)
      end

      create_history_entry(group)
    end

    def forward_without_comment!(group)
      forward(group)

      create_history_entry(group)
    end

    private

    def validate_group_belonging!(group)
      unless category.solver_groups.include?(group)
        fail "Group '#{group.name}' isn't a solver"
      end
    end

    # Creates an internal comment
    def create_comment!(message)
      Reports::Comment.create!(
        item: report,
        message: message,
        author: user,
        visibility: Reports::Comment::INTERNAL
      )
    end

    def create_history_entry(group)
      unless old_group
        Reports::CreateHistoryEntry.new(report, user)
          .create('forward', "Relato foi encaminhado para o grupo '#{group.name}'",             new: group.entity(only: [:id, :name]))
      else
        Reports::CreateHistoryEntry.new(report, user)
          .create('forward', "Relato foi encaminhado do grupo '#{old_group.name}' para o grupo '#{group.name}'",             old: old_group.entity(only: [:id, :name]),
            new: group.entity(only: [:id, :name]))
      end
    end

    def forward(group)
      return if report.assigned_group == group
      validate_group_belonging!(group)

      report.update!(
        assigned_group: group,
        assigned_user: nil
      )
    end
  end
end
