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

      last_sc = Reports::StatusCategory.last
      expect(last_sc.color).to eq('#ff0033')
      expect(last_sc.initial).to be_truthy
      expect(last_sc.final).to be_truthy
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

  context '#find_perimeter' do
    let!(:category)           { create(:reports_category) }
    let!(:perimeter)          { create(:reports_perimeter, :imported) }
    let!(:category_perimeter) { create(:reports_category_perimeter, category: category, perimeter: perimeter) }

    it 'find perimeter with latitude and longitude' do
      expect(category.find_perimeter(-22.9053121, -43.1956711)).to eq(category_perimeter)
    end
  end

  context 'entity' do
    context 'subcategories' do
      let!(:category) { create(:reports_category) }
      let!(:subcategories) { create_list(:reports_category, 3, parent_category: category) }
      let!(:user) { create(:user) }
      let!(:group) { create(:group) }

      context "user doesn't have permission to see subcategories" do
        before do
          group.permission.update!(reports_items_create: [category.id])
          user.groups = [group]
          user.save
        end

        it do
          represented = Reports::Category::Entity.represent(category,
                                                            only: [subcategories: [:id]],
                                                            display_type: :full,
                                                            user: user).as_json

          expect(represented[:subcategories]).to be_empty
        end
      end

      context 'user does have permission to see subcategories' do
        before do
          group.permission.update!(reports_items_create: [category.id] + subcategories.map(&:id))
          user.groups = [group]
          user.save
        end

        it do
          represented = Reports::Category::Entity.represent(category,
                                                            only: [subcategories: [:id]],
                                                            display_type: :full,
                                                            user: user).as_json

          expect(represented[:subcategories]).to_not be_empty
        end
      end
    end
  end
end
