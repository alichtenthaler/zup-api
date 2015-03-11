require 'rails_helper'

describe Inventory::Item do
  context "position" do
    let(:item) { create(:inventory_item) }

    it "updates the item's position with data of localization" do
      item.data.each do |data|
        next unless data.field.location

        if data.field.title == "latitude"
          data.content = "51.5033630"
        elsif data.field.title == "longitude"
          data.content = "-0.1276250"
        elsif data.field.title == "address"
          data.content = "Cool Street"
        end
      end

      item.save

      expect(item.position).to_not be_blank
      expect(item.position.latitude).to eq(51.5033630)
      expect(item.position.longitude).to eq(-0.1276250)
      expect(item.address).to eq("Cool Street")
    end
  end

  context "validations" do
    describe "status" do
      context "when category requires item status" do
        let(:category) { create(:inventory_category, require_item_status: true) }

        context "with status empty" do
          let(:item) { build(:inventory_item, status: nil, category: category) }

          it "validate the presence the status" do
            expect(item.valid?).to be_falsy
            expect(item.errors).to include(:status)
          end
        end

        context "with status full" do
          let(:item) { build(:inventory_item, :with_status, category: category) }

          it "don't validate the presence the status" do
            expect(item.valid?).to be_truthy
          end
        end
      end

      context "when category don't requires item status" do
        let(:category) { create(:inventory_category, require_item_status: false) }
        let(:item) { build(:inventory_item, status: nil, category: category) }

        it "validate the presence the status" do
          expect(item.valid?).to be_truthy
        end
      end
    end
  end
end
