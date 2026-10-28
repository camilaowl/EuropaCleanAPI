# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API rooms', type: :request do
  let(:user) { create(:user) }
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:space) { create(:space, user: user) }
  let(:kitchen_room_type) { create(:room_type, room_type_key: 'kitchen') }
  let(:dining_room_type) { create(:room_type, room_type_key: 'dining_room') }
  let(:furniture_item_type) { create(:item_type, item_type_key: 'furniture') }
  let(:rooms_endpoint) { "/api/spaces/#{space.id}/rooms" }
  let(:room_endpoint) { ->(room_id) { "#{rooms_endpoint}/#{room_id}" } }

  describe 'GET /api/spaces/:space_id/rooms' do
    it 'returns rooms from the selected space and excludes rooms from other spaces' do
      owned_room = create(:room, space: space, name: 'Kitchen', room_type: kitchen_room_type)
      room_items = create_list(:room_item, 2, room: owned_room)
      create(:room, space: create(:space, user: user))
      create(:room, name: 'Someone Else')

      get rooms_endpoint, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('rooms').pluck('id')).to contain_exactly(owned_room.id)

      serialized_room = response.parsed_body.fetch('rooms').find { |item| item.fetch('id') == owned_room.id }
      expect(serialized_room).to include(
        'id' => owned_room.id,
        'name' => 'Kitchen',
        'room_type' => 'kitchen'
      )
      expect(serialized_room.fetch('room_items').pluck('id')).to match_array(room_items.map(&:id))
    end

    it 'returns an empty collection when the selected space has no rooms' do
      get rooms_endpoint, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('rooms' => [])
    end

    it 'does not expose another users space' do
      other_space = create(:space)

      get "/api/spaces/#{other_space.id}/rooms", headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'requires authentication' do
      get rooms_endpoint, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/spaces/:space_id/rooms/:id' do
    it 'returns room fields and nested items from a user-owned space' do
      room = create(:room, space: space, name: 'Kitchen', room_type: kitchen_room_type)
      item = create(:room_item, room: room, name: 'Table', item_type: furniture_item_type)
      create(:room_item, room: create(:room, space: space))

      get room_endpoint.call(room.id), headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/json')
      expect(response.parsed_body.fetch('room')).to include(
        'id' => room.id,
        'name' => 'Kitchen',
        'room_type' => 'kitchen',
        'created_at' => room.created_at.iso8601,
        'updated_at' => room.updated_at.iso8601
      )
      expect(response.parsed_body.dig('room', 'room_items')).to eq([{
        'id' => item.id,
        'name' => 'Table',
        'item_type' => 'furniture',
        'created_at' => item.created_at.iso8601,
        'updated_at' => item.updated_at.iso8601
      }])
    end

    it 'returns an empty items array for a room without items' do
      room = create(:room, space: space)

      get room_endpoint.call(room.id), headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('room', 'room_items')).to eq([])
    end

    it 'returns not found for a nonexistent room' do
      get room_endpoint.call(0), headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'does not expose another users room' do
      room = create(:room)

      get room_endpoint.call(room.id), headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'requires authentication' do
      room = create(:room, space: space)

      get room_endpoint.call(room.id), as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/spaces/:space_id/rooms' do
    let(:room_params) do
      { space_id: space.id, name: 'Kitchen', room_type: kitchen_room_type.room_type_key }
    end

    it 'creates a room in a user-owned space' do
      expect do
        post rooms_endpoint, params: { room: room_params }, headers: headers, as: :json
      end.to change(space.rooms, :count).by(1)

      room = space.rooms.last
      expect(response).to have_http_status(:created)
      expect(response.parsed_body.fetch('room')).to include(
        'id' => room.id,
        'name' => 'Kitchen',
        'room_type' => 'kitchen',
        'room_items' => []
      )
      expect(room).to have_attributes(name: 'Kitchen', room_type: kitchen_room_type, space: space)
    end

    it 'ignores submitted ids and nested items' do
      existing_room = create(:room, space: space)
      submitted_params = room_params.merge(
        id: existing_room.id,
        room_items: [{ name: 'Injected item', item_type: 'furniture' }]
      )

      expect do
        expect do
          post rooms_endpoint, params: { room: submitted_params }, headers: headers, as: :json
        end.to change(Room, :count).by(1)
      end.not_to change(RoomItem, :count)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig('room', 'id')).not_to eq(existing_room.id)
      expect(existing_room.reload.name).to eq('Bedroom')
    end

    it 'does not create a room in another users space' do
      other_space = create(:space)

      expect do
        post rooms_endpoint,
             params: { room: room_params.merge(space_id: other_space.id) },
             headers: headers,
             as: :json
      end.not_to change(Room, :count)

      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for a nonexistent parent space' do
      expect do
        post rooms_endpoint,
             params: { room: room_params.merge(space_id: 0) },
             headers: headers,
             as: :json
      end.not_to change(Room, :count)

      expect(response).to have_http_status(:not_found)
    end

    %i[space_id name room_type].each do |attribute|
      it "rejects a missing #{attribute}" do
        expect do
          post rooms_endpoint,
               params: { room: room_params.except(attribute) },
               headers: headers,
               as: :json
        end.not_to change(Room, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.fetch('errors').fetch(attribute.to_s)).to be_present
      end
    end

    { space_id: 'invalid', name: '', room_type: nil }.each do |attribute, value|
      it "returns validation errors for #{attribute} set to #{value.inspect}" do
        expect do
          post rooms_endpoint,
               params: { room: room_params.merge(attribute => value) },
               headers: headers,
               as: :json
        end.not_to change(Room, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.fetch('errors').fetch(attribute.to_s)).to be_present
      end
    end

    it 'returns validation errors for invalid room attributes' do
      expect do
        post rooms_endpoint,
             params: { room: room_params.merge(name: 'ab', room_type: 'garden') },
             headers: headers,
             as: :json
      end.not_to change(Room, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig('errors', 'name'))
        .to include('must be at least 3 characters long')
      expect(response.parsed_body.dig('errors', 'room_type'))
        .to include('is not included in the list')
    end

    it 'returns bad request when room parameters are missing' do
      post rooms_endpoint, params: {}, headers: headers, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body.fetch('error')).to match(/param is missing.*room/)
    end

    ['Kitchen', ['Kitchen'], [{ name: 'Kitchen' }], 42, true, false, nil].each do |payload|
      it "returns bad request when room is #{payload.inspect}" do
        expect do
          post rooms_endpoint, params: { room: payload }, headers: headers, as: :json
        end.not_to change(Room, :count)

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to match(/param is missing.*room/)
      end
    end

    it 'requires authentication' do
      expect do
        post rooms_endpoint, params: { room: room_params }, as: :json
      end.not_to change(Room, :count)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/spaces/:space_id/rooms/:id' do
    let(:room) { create(:room, space: space, name: 'Kitchen', room_type: kitchen_room_type) }

    it 'partially updates a user-owned room' do
      patch room_endpoint.call(room.id),
            params: { room: { name: 'Main Kitchen' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('room')).to include(
        'id' => room.id,
        'name' => 'Main Kitchen',
        'room_type' => 'kitchen'
      )
      expect(room.reload).to have_attributes(name: 'Main Kitchen', room_type: kitchen_room_type)
    end

    it 'updates only the room type when the name is omitted' do
      patch room_endpoint.call(room.id),
            params: { room: { room_type: dining_room_type.room_type_key } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('room')).to include('name' => 'Kitchen', 'room_type' => 'dining_room')
      expect(room.reload).to have_attributes(name: 'Kitchen', room_type: dining_room_type)
    end

    it 'updates both room attributes and returns existing items' do
      item = create(:room_item, room: room)

      patch room_endpoint.call(room.id),
            params: { room: { name: 'Dining Room', room_type: dining_room_type.room_type_key } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(room.reload).to have_attributes(name: 'Dining Room', room_type: dining_room_type)
      expect(response.parsed_body.fetch('room')).to include('name' => 'Dining Room', 'room_type' => 'dining_room')
      expect(response.parsed_body.dig('room', 'room_items').pluck('id')).to eq([item.id])
    end

    it 'does not move the room into another users space when a space id is submitted' do
      another_space = create(:space)

      patch room_endpoint.call(room.id),
            params: { room: { name: 'Main Kitchen', space_id: another_space.id } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(room.reload.space).to eq(space)
    end

    it 'uses the URL id instead of a submitted room id' do
      another_room = create(:room, space: space, name: 'Bedroom')

      patch room_endpoint.call(room.id),
            params: { room: { id: another_room.id, name: 'Main Kitchen' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('room', 'id')).to eq(room.id)
      expect(room.reload.name).to eq('Main Kitchen')
      expect(another_room.reload.name).to eq('Bedroom')
    end

    it 'does not save any changes when the room type is invalid' do
      patch room_endpoint.call(room.id),
            params: { room: { name: 'Changed Name', room_type: 'garden' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig('errors', 'room_type')).to include('is not included in the list')
      expect(room.reload).to have_attributes(name: 'Kitchen', room_type: kitchen_room_type)
    end

    it 'does not save any changes when the name is too short' do
      patch room_endpoint.call(room.id),
            params: { room: { name: 'ab', room_type: dining_room_type.room_type_key } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig('errors', 'name')).to include('must be at least 3 characters long')
      expect(room.reload).to have_attributes(name: 'Kitchen', room_type: kitchen_room_type)
    end

    { name: '', room_type: nil }.each do |attribute, value|
      it "rejects clearing #{attribute}" do
        patch room_endpoint.call(room.id),
              params: { room: { attribute => value } },
              headers: headers,
              as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.fetch('errors').fetch(attribute.to_s)).to be_present
        expect(room.reload).to have_attributes(name: 'Kitchen', room_type: kitchen_room_type)
      end
    end

    [{}, { room: {} }].each do |request_params|
      it "returns bad request for #{request_params.inspect}" do
        patch room_endpoint.call(room.id), params: request_params, headers: headers, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to match(/param is missing.*room/)
        expect(room.reload.name).to eq('Kitchen')
      end
    end

    it 'rejects an update containing only unsupported form attributes' do
      patch room_endpoint.call(room.id),
            params: { room: { space_id: space.id } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.fetch('errors').values.flatten).to include('must include name or room_type')
      expect(room.reload).to have_attributes(name: 'Kitchen', room_type: kitchen_room_type, space: space)
    end

    it 'returns not found for a nonexistent room' do
      patch room_endpoint.call(0), params: { room: { name: 'Main Kitchen' } }, headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'does not update another users room' do
      room = create(:room, name: 'Bedroom')

      patch room_endpoint.call(room.id),
            params: { room: { name: 'Changed Name' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:not_found)
      expect(room.reload.name).to eq('Bedroom')
    end

    it 'requires authentication' do
      patch room_endpoint.call(room.id), params: { room: { name: 'Main Kitchen' } }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(room.reload.name).to eq('Kitchen')
    end
  end

  describe 'DELETE /api/spaces/:space_id/rooms/:id' do
    let(:room) { create(:room, space: space) }

    it 'deletes a user-owned room and its items while preserving other rooms' do
      item = create(:room_item, room: room)
      another_room = create(:room, space: space)
      other_item = create(:room_item, room: another_room)

      expect do
        delete room_endpoint.call(room.id), headers: headers, as: :json
      end.to change(Room, :count).by(-1).and change(RoomItem, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
      expect(Room.exists?(room.id)).to be(false)
      expect(RoomItem.exists?(item.id)).to be(false)
      expect(another_room.reload).to be_persisted
      expect(other_item.reload).to be_persisted
    end

    it 'does not delete another users room' do
      room = create(:room)
      item = create(:room_item, room: room)

      expect do
        delete room_endpoint.call(room.id), headers: headers, as: :json
      end.not_to change(Room, :count)

      expect(response).to have_http_status(:not_found)
      expect(room.reload).to be_persisted
      expect(item.reload).to be_persisted
    end

    it 'returns not found for a nonexistent room' do
      expect do
        delete room_endpoint.call(0), headers: headers, as: :json
      end.not_to change(Room, :count)

      expect(response).to have_http_status(:not_found)
    end

    it 'requires authentication' do
      room

      expect do
        delete room_endpoint.call(room.id), as: :json
      end.not_to change(Room, :count)

      expect(response).to have_http_status(:unauthorized)
      expect(room.reload).to be_persisted
    end
  end
end
