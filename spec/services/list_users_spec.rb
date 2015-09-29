require 'spec_helper'

describe ListUsers do
  let!(:users) { create_list(:user, 3, name: 'Mario Bro') }

  context 'searching by name' do
    let!(:lucas_moura) { create(:user, name: 'Lucas Moura') }

    subject(:returned_users) { described_class.new(params).fetch }

    context 'using like search' do
      let(:params) do
        {
          name: 'luca',
          like: true
        }
      end

      it 'returns the user which has the search string as part of the name' do
        expect(returned_users).to match_array([lucas_moura])
      end
    end

    context 'using fuzzy search' do
      context 'with a small part of a word' do
        let(:params) do
          {
            name: 'lu',
            like: false
          }
        end

        it 'doesnt return any user' do
          expect(returned_users).to be_blank
        end
      end

      context 'with a full word' do
        let(:params) do
          {
            name: 'lucas',
            like: false
          }
        end

        it 'returns the correct user' do
          expect(returned_users).to match_array([lucas_moura])
        end
      end
    end

    context 'using default search (fuzzy)' do
      let(:params) do
        {
          name: 'lu'
        }
      end

      it 'doesnt return any user' do
        expect(returned_users).to be_blank
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

  context 'ordering search' do
    let!(:first_user) { create(:user, name: 'Aaaa') }
    let!(:last_user) { create(:user, name: 'Zzzzz') }
    let(:valid_params) do
      {
        sort: 'name',
        order: 'asc'
      }
    end

    subject { described_class.new(valid_params) }

    it 'returns the users on the correct position' do
      returned_users = subject.fetch
      expect(returned_users.first.id).to eq(first_user.id)
      expect(returned_users.last.id).to eq(last_user.id)
    end
  end
end
