require 'spec_helper'

describe Reports::Category do
  context 'statuses' do
    it 'have relation with statuses' do
      category = create(:reports_category_with_statuses)
      expect(category.statuses).to_not be_empty
    end

    it "don't create any other statuses if it already exists" do
    end
  end

  context '#update_statuses!' do
    it "create status if it doesn't exists (by title)" do
      category = create(:reports_category)

      expect(Reports::Status.count).to eq(0)

      category.update_statuses!([{
        'title' => 'Inicio',
        'color' => '#ff0033',
        'initial' => true,
        'final' => true
      }])

      expect(Reports::Status.count).to eq(1)
      last_created_status = Reports::Status.last
      expect(last_created_status.title).to eq('Inicio')
      expect(last_created_status.color).to eq('#ff0033')
      expect(last_created_status.initial).to eq(true)
    end

    context 'when already exists the same title' do
      let(:status) { create(:status) }
      let(:category) { create(:reports_category) }

      it "doesn't create more than one status with same title" do
        category.update_statuses!([{
          'title' => status.title,
          'color' => '#ff0033',
          'initial' => true,
          'final' => true
        }])
        category.reload
        expect(category.reload.statuses).to include(status)

        expect(Reports::Status.count).to eq(1)
        last_created_status = Reports::Status.last
        expect(last_created_status.id).to eq(status.id)
        expect(last_created_status.title).to eq(status.title)
        expect(last_created_status.color).to eq(status.color)
        expect(last_created_status.initial).to eq(status.initial)
      end

      it "doesn't create more than one status with same title (case insensitive)" do
        category.update_statuses!([{
          'title' => status.title.upcase,
          'color' => '#ff0033',
          'initial' => true,
          'final' => true
        }])
        category.reload
        expect(category.reload.statuses).to include(status)

        expect(Reports::Status.count).to eq(1)
        last_created_status = Reports::Status.last
        expect(last_created_status.id).to eq(status.id)
        expect(last_created_status.title).to eq(status.title)
        expect(last_created_status.color).to eq(status.color)
        expect(last_created_status.initial).to eq(status.initial)
      end
    end
  end
end
