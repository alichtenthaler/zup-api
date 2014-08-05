require "spec_helper"

describe Search::Inventory::Categories::API do
  let(:user) { create(:user) }

  describe "GET /search/inventory/categories" do
    let(:categories) { create_list(:inventory_category, 10) }

    context "searching by title" do
      let!(:desired_category) do
        c = categories.sample
        c.update(
          title: "nomedeteste"
        )
        c
      end

      it "returns the correct inventory" do
        get "/search/inventory/categories?title=teste", nil, auth(user)
        expect(parsed_body['categories'].map do |c|
          c['id']
        end).to eq([desired_category.id])
      end
    end
  end
end
