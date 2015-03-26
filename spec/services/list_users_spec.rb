require 'spec_helper'

describe ListUsers do
  let(:users) { create_list(:user, 20) }

  context 'searching by name' do
    let(:correct_user) do
      user = users.sample
      user.update(name: 'Test Name')
      user
    end

    context 'using like search' do
      let(:valid_params) do
        {
          name: 'Test'
        }
      end

      subject { described_class.new(valid_params) }

      it 'returns only the user with part of the name' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end

    context 'using common search' do
      let(:wrong_user) do
        users.delete(correct_user)
        user - users.sample
        user.update(name: 'Test Wrong')
        user
      end
      let(:valid_params) do
        {
          name: 'Test Name'
        }
      end

      subject { described_class.new(valid_params) }

      it 'returns only the user with part of the name' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end
  end

  context 'searching by email' do
    let(:correct_user) do
      user = users.sample
      user.update(email: 'test@gmail.com')
      user
    end

    context 'using like search' do
      let(:valid_params) do
        {
          email: 'test'
        }
      end

      subject { described_class.new(valid_params) }

      it 'returns only the user with part of the name' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end

    context 'using common search' do
      let(:wrong_user) do
        users.delete(correct_user)
        user - users.sample
        user.update(name: 'gmail@test.com')
        user
      end
      let(:valid_params) do
        {
          email: 'test@gmail.com'
        }
      end

      subject { described_class.new(valid_params) }

      it 'returns only the user with part of the name' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end
  end

  context 'searching by groups' do
    let(:group) { create(:group) }
    let(:correct_user) do
      user = users.sample
      user.groups << group
      user
    end

    let(:valid_params) do
      {
        groups: [group]
      }
    end

    subject { described_class.new(valid_params) }

    it 'returns only the user with the defined group' do
      users = subject.fetch
      expect(users).to match_array([correct_user])
    end
  end

  # FIXME: This is breaking randomly
  # context "ordering search" do
  #   let(:correct_order_users) do
  #     users.sort_by do |user|
  #       user.name
  #     end
  #   end
  #   let(:valid_params) do
  #     {
  #       sort: "name",
  #       order: "asc"
  #     }
  #   end

  #   subject { described_class.new(valid_params) }

  #   it "returns the users on the correct position" do
  #     returned_users = subject.fetch
  #     expect(returned_users).to_not eq(users)
  #     expect(returned_users).to eq(correct_order_users)
  #   end
  # end
end
