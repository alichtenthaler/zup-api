require 'spec_helper'

describe Reports::Item do
  context 'validations' do
    it 'should not allow description' do
      report = build(:reports_item)
      report.description = 'a' * 801

      expect(report.save).to eq(false)
      expect(report.errors).to include(:description)
    end

    context 'validations for boundary' do
      let(:item) { build(:reports_item) }
      let(:latitude) { -46.32341 }
      let(:longitude) { -23.134234 }

      before do
        item.position = Reports::Item.rgeo_factory.point(longitude, latitude)
      end

      context 'validation for boundary is enabled' do
        before do
          allow(CityShape).to receive(:validation_enabled?).and_return(true)
        end

        context 'position in boundaries' do
          before do
            allow(CityShape).to receive(:contains?)
            .and_return(true)
          end

          it 'is valid' do
            expect(item.valid?).to be_truthy
          end
        end

        context 'position not in boundaries' do
          before do
            allow(CityShape).to receive(:contains?)
                            .and_return(false)
          end

          it 'is valid' do
            expect(item.valid?).to be_falsy
          end
        end
      end

      context 'validation for boundary is disabled' do
        before do
          allow(CityShape).to receive(:validation_enabled?).and_return(false)
        end

        context 'position not in boundaries' do
          it 'is valid' do
            expect(item.valid?).to be_truthy
          end
        end
      end
    end
  end

  context 'postal_code' do
    it "stripes everything else that isn't a number" do
      postal_code = '13456-234$%$'
      report = build(:reports_item, postal_code: postal_code)

      expect(report).to be_valid
    end
  end

  it 'has relationship with inventory category through category' do
    inventory_categories = create_list(:inventory_category, 3)
    category = create(
      :reports_category_with_statuses,
      inventory_category_ids: inventory_categories.map(&:id)
    )
    item = create(:reports_item, category: category)

    expect(item.inventory_categories).to eq(inventory_categories)
  end

  it 'has the same position of the inventory item' do
    inventory_item = create(:inventory_item)
    report = build(:reports_item)

    report.inventory_item = inventory_item
    expect(report.save).to eq(true)
    expect(report.position).to eq(inventory_item.position)
  end

  context 'status history' do
    it 'create a new entry on status history when status is created' do
      item = create(:reports_item)
      new_status = item.statuses.last
      Reports::UpdateItemStatus.new(item).set_status(new_status)

      expect(item.save!).to eq(true)
      expect(item.status_history.reload.size).to eq(2)
      expect(item.status_history.last.new_status).to eq(new_status)
    end
  end

  describe '#can_receive_feedback?' do
    let(:report) { create(:reports_item) }

    it "returns true if the report is final and the time isn't expired" do
      Reports::UpdateItemStatus.new(report).update_status!(report.category.status_categories.final.first.status)
      expect(report.can_receive_feedback?).to eq(true)
    end

    it "returns false if the report category doesn't accept feedback" do
      report.category.update!(user_response_time: nil)
      expect(report.can_receive_feedback?).to eq(false)
    end

    it 'returns false if the report is final but the time expired' do
      Reports::UpdateItemStatus.new(report).update_status!(report.category.status_categories.final.first.status)
      report.status_history
            .last
            .update!(
              created_at: \
                Time.now - report.category.user_response_time.seconds - 1.day
            )

      expect(report.can_receive_feedback?).to eq(false)
    end
  end

  context 'comments_count' do
    let(:report) { create(:reports_item) }

    it "it's updated when a new comment is created" do
      create(:reports_comment, item: report)
      expect(report.reload.comments_count).to eq(1)
    end
  end

  context 'protocol' do
    let(:report) { build(:reports_item) }

    it 'returns the protocol just after created' do
      report.save!
      expect(report.protocol).to_not be_blank
    end
  end
end
