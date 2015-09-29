require 'spec_helper'

describe Search::Users::API do
  let(:logged_user) { create(:user) }

  context 'GET /search/users' do
    let!(:users) { create_list(:user, 5) }

    context 'by name' do
      it 'returns the correct users' do
        any_user = users.sample
        any_user.update(name: 'Nome de teste')

        get '/search/users?name=teste', nil, auth(logged_user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['users']).to_not be_empty
        expect(body['users'].first['id']).to eq(any_user.id)
      end
    end

    context 'by email' do
      it 'returns the correct users' do
        any_user = users.sample
        any_user.update(email: 'teste@gmail.com')

        get '/search/users?email=tes', nil, auth(logged_user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['users']).to_not be_empty
        expect(body['users'].first['id']).to eq(any_user.id)
      end
    end

    context 'by email and group' do
      let(:another_user) { create(:user) }
      let(:group) { create(:group) }

      before do
        logged_user.groups = [group]
        logged_user.email = 'test1@gmail.com'
        logged_user.save!
        another_user.update!(email: 'test2@gmail.com')
      end

      it 'returns only users with certain group' do
        get "/search/users?email=test&groups=#{group.id}", nil, auth(logged_user)
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['users'].size).to eq(1)
        expect(body['users'].first['id']).to eq(logged_user.id)
      end
    end

    context 'sorting' do
      let!(:first_user) { create(:user, name: 'Aaaa') }
      let!(:last_user) { create(:user, name: 'Zzzzz') }
      let(:valid_params) do
        {
          sort: 'name',
          order: 'asc'
        }
      end

      it 'returns the users in the correct sorting order' do
        get '/search/users', valid_params, auth(logged_user)
        expect(response.status).to eq(200)
        users = parsed_body['users']

        expect(users.first['id']).to eq(first_user.id)
        expect(users.last['id']).to eq(last_user.id)
      end
    end
  end

  context 'GET /search/groups/:group_id/users' do
    let!(:group) { create(:group) }
    let!(:other_group) { create(:group) }
    let!(:users) do
      users = create_list(:user, 5)
      users.each do |user|
        user.groups << group
        user.groups << other_group
        user.save!
      end
    end
    let!(:wrong_users) { create_list(:user, 3) }

    it 'returns the correct users from the group' do
      any_user = users.sample
      any_user.update(name: 'Nome de teste')

      get "/search/groups/#{group.id}/users?name=teste", nil, auth(logged_user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body['users'].size).to eq(1)
      user_id = body['users'].first['id']

      expect(user_id).to eq(any_user.id)
      expect(wrong_users.map(&:id)).to_not include(user_id)
    end

    context 'by email' do
      it 'returns the correct users' do
        any_user = users.sample
        any_user.update(email: 'teste@gmail.com')

        get "/search/groups/#{group.id}/users?email=tes", nil, auth(logged_user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['users']).to_not be_empty
        expect(body['users'].first['id']).to eq(any_user.id)
      end
    end

    context 'sorting' do
      let(:correct_order_users) do
        users.sort_by do |user|
          user.name
        end
      end
      let(:valid_params) do
        {
          sort: 'name',
          order: 'asc'
        }
      end

      it 'returns the users on the correct position' do
        get "/search/groups/#{group.id}/users", valid_params, auth(logged_user)
        expect(response.status).to eq(200)

        users = parsed_body['users']

        expect(users).to_not be_blank
        expect(users.map do |u|
          u['id']
        end).to eq(correct_order_users.map(&:id))
      end
    end
  end
end
