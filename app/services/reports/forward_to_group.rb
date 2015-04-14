module Reports
  class ForwardToGroup
    attr_reader :report, :category, :user

    def initialize(report, user)
      @report = report
      @category = report.category
      @user = user
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
      Reports::CreateHistoryEntry.new(report, user)
        .create('forward', "Relato foi encaminhado para o grupo #{group.name}",
                group)
    end

    def forward(group)
      return if report.assigned_group == group
      validate_group_belonging!(group)

      report.update(
        assigned_group: group,
        assigned_user: nil
      )
    end
  end
end
