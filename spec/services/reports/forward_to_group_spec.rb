require 'app_helper'

describe Reports::ForwardToGroup do
  let(:category) { create(:reports_category_with_statuses) }
  let(:report) { create(:reports_item, category: category) }
  let(:user) { create(:user) }

  subject { described_class.new(report, user) }

  describe '#forward!' do
    let(:group) { create(:group) }

    context 'group is a solver' do
      before do
        category.solver_groups = [group]
        category.save!
      end

      it 'assigns to that group' do
        subject.forward!(group)
        expect(report.reload.assigned_group).to eq(group)
      end

      it 'should reset the assigned for an user' do
        report.update(assigned_user: create(:user))

        subject.forward!(group)
        expect(report.reload.assigned_user).to be_nil
      end

      context 'report category demands a comment' do
        before do
          category.update(
            comment_required_when_forwarding: true
          )
        end

        context 'user don\'t type a comment' do
          it 'throws an error' do
            expect do
              subject.forward!(group)
            end.to raise_error
          end
        end

        context 'user does type a comment' do
          let(:message) { 'This is a test' }
          it 'creates the comment' do
            subject.forward!(group, message)
            comment = report.comments.last

            expect(comment.author).to eq(user)
            expect(comment.visibility).to eq(Reports::Comment::INTERNAL)
            expect(comment.message).to eq(message)
          end
        end
      end
    end

    context 'group isn\'t a solver' do
      it 'assigns to that group' do
        expect { subject.forward!(group) }.to raise_error
      end
    end
  end
end
