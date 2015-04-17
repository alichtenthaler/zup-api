require 'rails_helper'

describe Reports::StatusCategory do
  context 'entity' do
    let(:category) { build(:reports_category) }
    let(:status) { build(:status) }

    subject do
      Reports::StatusCategory.new(
        category: category,
        status: status,
        active: true,
        final: true
      )
    end

    it 'exposes correctly the status data' do
      entity = Reports::StatusCategory::Entity.represent(subject, serializable: true)
      expect(entity).to match(
                          id: status.id,
                          private: subject.private,
                          initial: subject.initial,
                          final: subject.final,
                          color: subject.color,
                          title: status.title,
                          active: subject.active
                        )
    end
  end
end
