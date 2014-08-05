require 'spec_helper'

describe Inventory::Section do
  context "validations" do
    it "requires the title" do
      section = Inventory::Section.new
      expect(section.save).to eq(false)
      expect(section.errors.messages).to include(:title)
    end
  end
end
