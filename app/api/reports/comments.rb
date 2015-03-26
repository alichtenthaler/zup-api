module Reports::Comments
  class API < Grape::API
    namespace ':id/comments' do
      desc 'Get all comments from a report item'
      params do
        requires :id, type: Integer, desc: 'The id of the report'
      end
      get do
        authenticate!

        report = Reports::Item.find(params[:id])

        comments = Reports::GetCommentsForUser.new(report, current_user).comments

        {
          comments: \
            Reports::Comment::Entity.represent(comments)
        }
      end

      desc 'Create a comment for the report item'
      params do
        requires :id, type: Integer,
                 desc: 'The id of the report'
        requires :visibility, type: Integer,
                 desc: '0 = Public, 1 = Private, 2 = Internal'
        optional :message, type: String,
                 desc: 'The message itself'
      end
      post do
        authenticate!

        report = Reports::Item.find(params[:id])

        comment_params = safe_params.permit(:visibility, :message)
        comment_params[:author_id] = current_user.id
        comment_params[:reports_item_id] = report.id

        comment = Reports::Comment.new(comment_params)

        if [Reports::Comment::INTERNAL, Reports::Comment::PRIVATE].include?(comment.visibility)
          validate_permission!(:edit, report)
        end

        comment.save!

        unless comment.visibility == Reports::Comment::INTERNAL
          Reports::NotifyUser.new(report).notify_new_comment!
        end

        {
          comment: Reports::Comment::Entity.represent(comment)
        }
      end
    end
  end
end
