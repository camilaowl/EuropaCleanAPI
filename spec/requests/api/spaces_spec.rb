# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API spaces', type: :request do
  let(:user) { create(:user) }
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/spaces' do
    it 'returns only spaces owned by the authenticated user' do
      owned_space = create(:space, user: user, name: 'Family Home')
      room = create(:room, space: owned_space, name: 'Kitchen', room_type: :kitchen)
      room_item = create(:room_item, room: room, name: 'Table')
      create(:space, name: 'Someone Else')

      get '/api/spaces', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('spaces').pluck('id')).to eq([owned_space.id])

      serialized_space = response.parsed_body.fetch('spaces').first
      expect(serialized_space).to include(
        'id' => owned_space.id,
        'name' => 'Family Home',
        'space_type' => 'home'
      )
      expect(serialized_space.dig('user', 'id')).to eq(user.id)
      expect(serialized_space.dig('rooms', 0, 'id')).to eq(room.id)
      expect(serialized_space.dig('rooms', 0, 'room_items', 0, 'id')).to eq(room_item.id)
    end

    it 'returns an empty collection when the user owns no spaces' do
      create(:space)

      get '/api/spaces', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('spaces' => [])
    end

    it 'requires authentication' do
      get '/api/spaces', as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/spaces/:id' do
    it 'returns a user-owned space' do
      space = create(:space, user: user)

      get "/api/spaces/#{space.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('space', 'id')).to eq(space.id)
    end

    it 'does not expose another users space' do
      space = create(:space)

      get "/api/spaces/#{space.id}", headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/spaces' do
    it 'creates a space owned by the authenticated user' do
      expect do
        post '/api/spaces', params: { space: { name: 'Family Home' } }, headers: headers, as: :json
      end.to change(user.spaces, :count).by(1)

      space = user.spaces.last
      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig('space', 'id')).to eq(space.id)
      expect(space).to have_attributes(name: 'Family Home', space_type: 'home')
    end

    it 'ignores submitted ownership and space type' do
      another_user = create(:user)

      post '/api/spaces',
           params: { space: { name: 'Family Home', user_id: another_user.id, space_type: 'warehouse' } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:created)
      space = Space.find(response.parsed_body.dig('space', 'id'))
      expect(space).to have_attributes(user: user, space_type: 'home')
    end

    it 'returns validation errors for an invalid space' do
      expect do
        post '/api/spaces', params: { space: { name: 'ab' } }, headers: headers, as: :json
      end.not_to change(Space, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig('errors', 'name'))
        .to include('must be at least 3 characters long')
    end

    it 'returns bad request when space parameters are missing' do
      post '/api/spaces', params: {}, headers: headers, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body.fetch('error')).to match(/param is missing.*space/)
    end
  end

  describe 'PATCH /api/spaces/:id' do
    it 'updates a user-owned space' do
      space = create(:space, user: user, name: 'Old Name')

      patch "/api/spaces/#{space.id}",
            params: { space: { name: 'New Name' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('space', 'name')).to eq('New Name')
      expect(space.reload.name).to eq('New Name')
    end

    it 'does not update a space when validation fails' do
      space = create(:space, user: user, name: 'Old Name')

      patch "/api/spaces/#{space.id}",
            params: { space: { name: 'ab' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(space.reload.name).to eq('Old Name')
    end

    it 'does not update another users space' do
      space = create(:space, name: 'Someone Else')

      patch "/api/spaces/#{space.id}",
            params: { space: { name: 'Changed Name' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:not_found)
      expect(space.reload.name).to eq('Someone Else')
    end
  end

  describe 'DELETE /api/spaces/:id' do
    it 'deletes a user-owned space' do
      space = create(:space, user: user)

      expect do
        delete "/api/spaces/#{space.id}", headers: headers, as: :json
      end.to change(Space, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end

    it 'does not delete another users space' do
      space = create(:space)

      expect do
        delete "/api/spaces/#{space.id}", headers: headers, as: :json
      end.not_to change(Space, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
