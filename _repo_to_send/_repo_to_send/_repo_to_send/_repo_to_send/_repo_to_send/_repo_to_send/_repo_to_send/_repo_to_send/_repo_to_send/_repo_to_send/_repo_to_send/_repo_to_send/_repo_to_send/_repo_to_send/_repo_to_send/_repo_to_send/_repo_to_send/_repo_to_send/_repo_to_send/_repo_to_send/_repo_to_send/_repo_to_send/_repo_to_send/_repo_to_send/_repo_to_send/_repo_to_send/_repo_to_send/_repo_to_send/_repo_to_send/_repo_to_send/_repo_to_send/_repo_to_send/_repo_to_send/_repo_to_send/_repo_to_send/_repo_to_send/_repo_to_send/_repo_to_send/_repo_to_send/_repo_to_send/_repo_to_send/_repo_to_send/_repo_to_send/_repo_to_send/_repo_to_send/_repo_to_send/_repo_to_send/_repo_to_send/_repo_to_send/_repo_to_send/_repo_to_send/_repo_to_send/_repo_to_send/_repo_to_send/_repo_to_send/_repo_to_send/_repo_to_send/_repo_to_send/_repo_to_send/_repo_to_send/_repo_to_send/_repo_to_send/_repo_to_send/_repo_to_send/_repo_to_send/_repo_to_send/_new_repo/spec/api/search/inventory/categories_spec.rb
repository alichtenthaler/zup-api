require 'app_helper'

describe Search::Inventory::Categories::API do
  let(:user) { create(:user) }

  describe 'GET /search/inventory/categories' do
    let!(:categories) { create_list(:inventory_category, 3) }

    let(:url) { '/search/inventory/categories' }

    context 'searching by title' do
      let!(:desired_category) do
        c = categories.sample
        c.update(
          title: 'nomedeteste'
        )
        c
      end

      it 'returns the correct inventory' do
        get "#{url}?title=teste", nil, auth(user)
        expect(parsed_body['categories'].map do |c|
          c['id']
        end).to eq([desired_category.id])
      end
    end

    context 'permission validations' do
      let(:group) { create(:group) }

      before do
        user.update!(groups: [group])
      end

      subject do
        get url, nil, auth(user)
      end

      context 'with permission to manage inventory category' do
        before do
          group.permission.update(
            inventories_full_access: true
          )
        end

        it 'can see list categories' do
          subject
          expect(parsed_body['categories'].map do |c|
                   c['id']
                 end).to match_array(categories.map(&:id))
        end
      end

      context 'without permission to manage inventory category' do
        let(:visible_categories) { categories.first(3) }

        before do
          group.permission.update(
            inventories_items_read_only: visible_categories.map(&:id),
            inventories_full_access: false
          )
        end

        it 'can see only visible categories' do
          subject
          expect(parsed_body['categories'].map do |c|
                   c['id']
                 end).to match_array(visible_categories.map(&:id))
        end
      end
    end
  end
end
