require 'spec_helper'

describe AccessKey do
  let(:access_key) { create(:access_key) }
  let(:expired_access_key) { create(:expired_access_key) }
  let(:user) { create(:user) }

  it "generates a random string when creating" do
    AccessKey.create(
      user: user
    ).key.should_not be_blank
  end

  it "active scope should return only not expired access keys" do
    expect(AccessKey.active).to include(access_key)
  end

  describe "#expire!" do
    it "marks the access key as expired" do
      access_key.expire!
      expect(access_key).to be_expired
      expect(access_key.expired_at).to_not be_blank
    end
  end
end
