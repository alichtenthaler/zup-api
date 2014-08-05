require "spec_helper"

describe Users::API do
  context "POST /authenticate" do
    let(:user) { create(:user, password: '123456') }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "email": "#{user.email}",
          "password": "123456"
        }
      JSON
    end

    it "returns the user and the access key if successful" do
      post "/authenticate", valid_params
      response.status.should == 201
      parsed_body['token'].should == user.last_access_key
    end

    it "returns error message" do
      valid_params[:password] = 'wrongpassword'
      post "/authenticate", valid_params
      response.status.should == 401
      parsed_body.should include("error")
    end
  end

  context "DELETE /sign_out" do
    let(:user) { create(:user) }
    let(:access_key) { user.access_keys.last }

    it "expires the access key" do
      delete '/sign_out', token: access_key.key
      expect(response.status).to eq(200)

      access_key.reload
      expect(access_key).to be_expired
      expect(access_key.expired).to_not be_blank
    end
  end

  context "PUT /recover_password" do
    let(:user) { create(:user) }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "email": "#{user.email}"
        }
      JSON
    end

    it "sends a reset password e-mail" do
      expect(user.reset_password_token).to be_blank
      put "/recover_password", valid_params
      expect(response.status).to eq(200)
      expect(user.reload.reset_password_token).to_not be_blank
    end
  end

  context "PUT /reset_password" do
    let(:user) { user = create(:user) }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "token": "#{user.reset_password_token}",
          "new_password": "otherpassword"
        }
      JSON
    end

    it "resets the user password" do
      User.request_password_recovery(user.email)
      user.reload

      put "/reset_password", valid_params
      expect(response.status).to eq(200)

      user.reload
      expect(user.check_password('otherpassword')).to be(true)
    end
  end

  context "POST /users" do
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "email": "johnk12@gmail.com",
          "password": "astrongpassword",
          "password_confirmation": "astrongpassword",
          "name": "John Mayer",
          "phone": "11941892958",
          "document": "11111111111",
          "address": "Rua Abilio Soares, 140",
          "postal_code": "04005000",
          "district": "Paraiso",
          "facebook_user_id": 12345678
        }
      JSON
    end

    it "creates a user if every required param is ok" do
      post "/users", valid_params
      expect(response.status).to eq(201)
      expect(User.last.email).to eq("johnk12@gmail.com")

      body = parsed_body
      expect(body).to include("message")
      expect(body).to include("user")
      expect(body["user"]["email"]).to eq("johnk12@gmail.com")
      expect(body["user"]["encrypted_password"]).to be_nil
      expect(body["user"]["updated_at"]).to be_blank
      expect(body["user"]["facebook_user_id"]).to eq(12345678)
    end

    it "returns error message if a required param is missing" do
      valid_params.delete("email")
      post "/users", valid_params
      expect(response.status).to eq(400)
      body = parsed_body

      expect(body).to include("error")
      expect(body['error']).to include("email")
      expect(body['error']['email']).to include("não pode ficar em branco")
    end
  end

  context "GET /users/:id" do
    let(:user) { create(:user) }

    it "returns user's data" do
      get "/users/#{user.id}"
      expect(response.status).to eq(200)

      body = parsed_body
      expect(body).to include("user")

      expect(body["user"]["id"]).to eq(user.id)
      expect(body["user"]["email"]).to eq(user.email)
      expect(body["user"]["encrypted_password"]).to be_nil
      expect(body["user"]["updated_at"]).to be_blank
    end

    it "returns error message if id doesn't exists" do
      get "/users/1231231"
      expect(response.status).to eq(404)
      body = parsed_body
      expect(body).to include("error")
      expect(body["error"]).to match(/Couldn't find/)
    end
  end

  context "GET /me" do
    let(:user) { create(:user) }
    it "returns the signed user's data" do
      get "/me", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("user")
      expect(body["user"]["id"]).to eq(user.id)
      expect(body["user"]["encrypted_password"]).to be_nil
      expect(body["user"]["updated_at"]).to be_blank
    end

    it "accepts the token on header" do
      get "/me", nil, auth(user)
      expect(response.status).to eq(200)
    end
  end

  context "DELETE /me" do
    let(:user) { create(:user) }

    it "destroys current user" do
      delete "/me", nil, auth(user)
      expect(User.find_by(id: user.id)).to eq(nil)
    end
  end

  context "PUT /users" do
    let(:user) { create(:user, password: '123456') }

    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "email": "anotheremail@gmail.com"
        }
      JSON
    end

    it "updates user's info" do
      put "/users/#{user.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      expect(user.reload.email).to eq("anotheremail@gmail.com")
    end

    context "changing password" do
      let(:valid_params) do
        JSON.parse <<-JSON
          {
            "password": "12345678",
            "password_confirmation": "12345678"
          }
        JSON
      end

      it "throw error if the current_password attribute isn't present" do
        put "/users/#{user.id}", valid_params, auth(user)
        expect(response.status).to eq(400)
      end

      it "doesn't throw error if the current_password attribute is present" do
        valid_params['current_password'] = '123456'
        old_password_hash = user.encrypted_password
        put "/users/#{user.id}", valid_params, auth(user)
        expect(response.status).to eq(200)

        expect(user.reload.encrypted_password).to_not eq(old_password_hash)
      end
    end
  end

  context "DELETE /users/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it "destroys user's account" do
      delete "/users/#{user.id}", nil, auth(user)
      expect(response.status).to eq(200)
      expect(User.find_by(id: user.id)).to be_nil
    end

    it "can't destroy user account if it doesn't have permission to" do
      user.groups.first.update(manage_users: false)
      delete "/users/#{other_user.id}", nil, auth(user)
      expect(response.status).to eq(403)
    end
  end

  context "GET /users" do
    let!(:user) { create(:user, name: "Burns", email: "burns@test.com") }
    let!(:users) { create_list(:user, 5) }
    let!(:group) { create(:group) }
    let(:valid_params) do
      JSON.parse <<-JSON
        {
          "name": "burns",
          "email": "burns",
          "groups": [#{group.id}]
        }
      JSON
    end

    it "returns all users if no filter is selected" do
      get "/users", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("users")
      expect(body["users"].size).to eq(6)
      expect(body["users"].first["id"]).to_not be_nil
    end

    it "returns the user that satisfy the filter" do
      valid_params.delete("groups")
      get "/users", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("users")
      expect(body["users"].first["id"]).to eq(user.id)
    end

    it "retuns the user that is on the group" do
      valid_params.delete("name")
      valid_params.delete("email")

      group.users << user
      group.save

      get "/users", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include("users")
      expect(body["users"].first["id"]).to eq(user.id)
      expect(body["users"].size).to eq(1)
    end
  end
end
