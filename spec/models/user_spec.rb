require 'spec_helper'

describe User do
  it "validates basic login fields" do
    user = User.new
    user.should_not be_valid
    user.errors.should include(:email)
    user.errors.should include(:encrypted_password)
  end

  context "validations" do
    context "password length" do
      let(:user) { build(:user) }

      it "is at least 6 chars" do
        user.password = user.password_confirmation = "12345"
        expect(user).to_not be_valid
        expect(user.errors).to include(:password)
      end

      it "is 16 chars length at maximum" do
        user.password = user.password_confirmation = "12345678901234567"
        expect(user).to_not be_valid
        expect(user.errors).to include(:password)
      end
    end

    context "name length" do
      let(:user) { build(:user) }

      it "is at least 6 chars" do
        user.password = user.password_confirmation = "12345"
        expect(user).to_not be_valid
        expect(user.errors).to include(:password)
      end
    end
  end

  context "password encryptation" do
    let(:user) do
      build(:user,
        email: 'test@gmail.com',
        password: '123456',
        password_confirmation: '123456'
      )
    end

    it "encrypts password before validation" do
      user.valid?
      user.encrypted_password.should_not be_blank
      user.should be_valid
    end

    it "generates a random salt for the user" do
      user.valid?
      user.salt.should_not be_blank
    end

    it "doens't allow the leave the password blank on creation" do
      user.password = ""
      user.password_confirmation = ""
      expect(user.valid?).to eq(false)
      expect(user.errors.messages).to include(:password, :password_confirmation)
    end

    it "allows password blank if the record already exists" do
      user.save
      user.password = ""
      user.password_confirmation = ""
      expect(user.valid?).to eq(true)
    end

    it "blank password fields don't update the password" do
      user.save
      current_password = user.encrypted_password
      user.password_confirmation = user.password = ""
      user.save
      expect(user.encrypted_password).to eq(current_password)
    end
  end

  context "authentication" do
    let(:user) { create(:user, password: '123456') }

    describe "#check_password" do
      it "returns true if the passwords checks" do
        expect(user.check_password('123456')).to be(true)
      end

      it "returns false if the passwords are different" do
        expect(user.check_password('wrongpassword')).to be(false)
      end
    end

    describe ".authenticate" do
      it "returns true if the authentication is successful" do
        User.authenticate(user.email, '123456').should == user
      end

      it "returns false if the password is wrong" do
        User.authenticate(user.email, 'wrongpass').should == false
      end

      it "returns false if the username is wrong" do
        User.authenticate('wronguseremail', '123456').should == false
      end
    end
  end

  context "generating a new access key" do
    let(:user) { create(:user) }

    it "generate_access_key! creates a new key" do
      new_key = user.generate_access_key!
      new_key.should be_a(AccessKey)

      user.last_access_key.should == new_key.key
    end
  end

  context "password recovery" do
    let(:user) { create(:user) }

    context "requesting and generating tokens" do
      describe "#generate_reset_password_token!" do
        it "generates a new reset_password_token for the user" do
          expect(user.reset_password_token).to be_blank
          expect(user.generate_reset_password_token!).to be(true)
          expect(user.reload.reset_password_token).to_not be_blank
        end
      end

      describe ".request_password_recovery" do
        it "generates a new password recovery token for user with given email" do
          expect(user.reset_password_token).to be_blank
          expect(User.request_password_recovery(user.email)).to be(true)
          expect(user.reload.reset_password_token).to_not be_blank
        end
      end
    end

    describe ".reset_password" do
      let(:pass) { "changedpass" }

      subject do
        User.reset_password(user.reset_password_token, pass)
      end

      before do
        user.generate_reset_password_token!
        subject
        user.reload
      end


      it "resets the user password" do
        expect(user.check_password("changedpass")).to be_truthy
      end

      it "set reset_password_token to nil" do
        expect(user.reset_password_token).to be_nil
      end
    end
  end

  context "token authentication" do
    let(:user) { create(:user) }

    describe ".authorize" do
      it "returns the user if the given token is valid" do
        result = User.authorize(user.last_access_key)
        expect(result).to eq(user)
      end
    end
  end

  it "has relation with groups" do
    user = create(:user)
    group = create(:group)

    user.groups << group
    user.save

    user = User.find(user.id)
    expect(user.groups).to include(group)
  end

  describe "#guest?" do
    it "returns false for normal records" do
      user = create(:user)
      expect(user.guest?).to eq(false)

      user = User::Guest.new
      expect(user.guest?).to eq(true)
    end
  end

  context "changing the password" do
    it "to change the password you need to provide the current password" do
      allow_any_instance_of(UserAbility).to \
        receive(:can?).with(:manage, User).and_return(false)
      user = create(:user)
      user.current_password = "1234"
      user.password = "123456"
      user.password_confirmation = "123456"
      expect(user.valid?).to eq(false)
      expect(user.errors.messages).to include(:current_password)
    end

    it "if he user can manage users, he doesn't need to provide the current password" do
      allow_any_instance_of(UserAbility).to \
        receive(:can?).with(:manage, User).and_return(true)
      user = create(:user)
      user.password = "123456"
      user.password_confirmation = "123456"
      expect(user.valid?).to eq(true)
    end

    it "changes if the password is the same" do
      user = create(:user, password: 'foobar')

      expect(user.check_password('foobar')).to eq(true)

      user.current_password = "foobar"
      user.password = "123456"
      user.password_confirmation = "123456"

      expect(user.save).to eq(true)

      user.reload
      expect(user.check_password("123456")).to eq(true)
    end
  end

  describe 'permissions' do
    let(:group1) do
      group = create(:group)
      group.permission.update(inventory_categories_can_edit: [1,3], manage_users: 'true')
      group
    end
    let(:group2) do
      group = create(:group)
      group.permission.update(inventory_categories_can_edit: [3,9], manage_users: 'false')
      group
    end
    let(:user) { create(:user, groups: [group1, group2]) }

    it "merge all user group's permissions" do
      expect(user.permissions).to include(
        "inventory_categories_can_edit" => [1,3,9],
        "manage_users" => true
      )
    end
  end
end
