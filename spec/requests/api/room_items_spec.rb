# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API room items', type: :request do
  let(:user) { create(:user) }
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:space) { create(:space, user: user) }
  let(:room) { create(:room, space: space) }
  let(:furniture_item_type) { create(:item_type, item_type_key: 'furniture') }
  let(:appliance_item_type) { create(:item_type, item_type_key: 'appliance') }
  let(:room_items_endpoint) { "/api/spaces/#{space.id}/rooms/#{room.id}/room_items" }
  let(:room_item_endpoint) { ->(room_item_id) { "#{room_items_endpoint}/#{room_item_id}" } }

  describe 'GET /api/spaces/:space_id/rooms/:room_id/room_items' do
    it 'returns items from the selected room and excludes items from other rooms' do
      owned_item = create(
        :room_item,
        room: room,
        name: 'Table',
        item_type: furniture_item_type
      )
      create(:room_item, room: create(:room, space: space))
      create(:room_item)

      get room_items_endpoint, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('room_items').pluck('id')).to contain_exactly(owned_item.id)
      expect(response.parsed_body.fetch('room_items').first).to eq(
        'id' => owned_item.id,
        'name' => 'Table',
        'item_type' => 'furniture',
        'created_at' => owned_item.created_at.iso8601,
        'updated_at' => owned_item.updated_at.iso8601
      )
    end

    it 'returns an empty collection when the selected room has no items' do
      get room_items_endpoint, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('room_items' => [])
    end

    it 'does not expose another users room' do
      other_room = create(:room)

      get "/api/spaces/#{other_room.space.id}/rooms/#{other_room.id}/room_items",
          headers: headers,
          as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'requires authentication' do
      get room_items_endpoint, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/spaces/:space_id/rooms/:room_id/room_items/:id' do
    it 'returns an item from a user-owned room' do
      room_item = create(
        :room_item,
        room: room,
        name: 'Table',
        item_type: furniture_item_type
      )

      get room_item_endpoint.call(room_item.id), headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/json')
      expect(response.parsed_body.fetch('room_item')).to eq(
        'id' => room_item.id,
        'name' => 'Table',
        'item_type' => 'furniture',
        'created_at' => room_item.created_at.iso8601,
        'updated_at' => room_item.updated_at.iso8601
      )
    end

    it 'returns not found for a nonexistent item' do
      get room_item_endpoint.call(0), headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'does not expose another users item' do
      room_item = create(:room_item)

      get room_item_endpoint.call(room_item.id), headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'requires authentication' do
      room_item = create(:room_item, room: room)

      get room_item_endpoint.call(room_item.id), as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/spaces/:space_id/rooms/:room_id/room_items' do
    let(:room_item_params) do
      { room_id: room.id, name: 'Table', item_type: furniture_item_type.item_type_key }
    end

    it 'creates an item in a user-owned room' do
      expect do
        post room_items_endpoint,
             params: { room_item: room_item_params },
             headers: headers,
             as: :json
      end.to change(room.room_items, :count).by(1)

      room_item = room.room_items.last
      expect(response).to have_http_status(:created)
      expect(response.parsed_body.fetch('room_item')).to include(
        'id' => room_item.id,
        'name' => 'Table',
        'item_type' => 'furniture'
      )
      expect(room_item).to have_attributes(
        name: 'Table',
        item_type: furniture_item_type,
        room: room
      )
    end

    it 'ignores a submitted item id' do
      existing_item = create(:room_item, room: room)

      expect do
        post room_items_endpoint,
             params: { room_item: room_item_params.merge(id: existing_item.id) },
             headers: headers,
             as: :json
      end.to change(RoomItem, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig('room_item', 'id')).not_to eq(existing_item.id)
      expect(existing_item.reload.name).to eq('Bed')
    end

    it 'does not create an item in another users room' do
      other_room = create(:room)

      expect do
        post room_items_endpoint,
             params: { room_item: room_item_params.merge(room_id: other_room.id) },
             headers: headers,
             as: :json
      end.not_to change(RoomItem, :count)

      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for a nonexistent parent room' do
      expect do
        post room_items_endpoint,
             params: { room_item: room_item_params.merge(room_id: 0) },
             headers: headers,
             as: :json
      end.not_to change(RoomItem, :count)

      expect(response).to have_http_status(:not_found)
    end

    %i[room_id name item_type].each do |attribute|
      it "rejects a missing #{attribute}" do
        expect do
          post room_items_endpoint,
               params: { room_item: room_item_params.except(attribute) },
               headers: headers,
               as: :json
        end.not_to change(RoomItem, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.fetch('errors').fetch(attribute.to_s)).to be_present
      end
    end

    { room_id: 'invalid', name: '', item_type: nil }.each do |attribute, value|
      it "returns validation errors for #{attribute} set to #{value.inspect}" do
        expect do
          post room_items_endpoint,
               params: { room_item: room_item_params.merge(attribute => value) },
               headers: headers,
               as: :json
        end.not_to change(RoomItem, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.fetch('errors').fetch(attribute.to_s)).to be_present
      end
    end

    it 'returns validation errors for invalid item attributes' do
      expect do
        post room_items_endpoint,
             params: { room_item: room_item_params.merge(name: 'ab', item_type: 'unknown') },
             headers: headers,
             as: :json
      end.not_to change(RoomItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig('errors', 'name'))
        .to include('must be at least 3 characters long')
      expect(response.parsed_body.dig('errors', 'item_type'))
        .to include('is not included in the list')
    end

    it 'returns bad request when room item parameters are missing' do
      post room_items_endpoint, params: {}, headers: headers, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body.fetch('error')).to match(/param is missing.*room_item/)
    end

    ['Table', ['Table'], [{ name: 'Table' }], 42, true, false, nil].each do |payload|
      it "returns bad request when room_item is #{payload.inspect}" do
        expect do
          post room_items_endpoint,
               params: { room_item: payload },
               headers: headers,
               as: :json
        end.not_to change(RoomItem, :count)

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to match(/param is missing.*room_item/)
      end
    end

    it 'requires authentication' do
      expect do
        post room_items_endpoint, params: { room_item: room_item_params }, as: :json
      end.not_to change(RoomItem, :count)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/spaces/:space_id/rooms/:room_id/room_items/:id' do
    let(:room_item) do
      create(:room_item, room: room, name: 'Table', item_type: furniture_item_type)
    end

    it 'partially updates a user-owned item' do
      patch room_item_endpoint.call(room_item.id),
            params: { room_item: { name: 'Dining Table' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('room_item')).to include(
        'id' => room_item.id,
        'name' => 'Dining Table',
        'item_type' => 'furniture'
      )
      expect(room_item.reload).to have_attributes(
        name: 'Dining Table',
        item_type: furniture_item_type
      )
    end

    it 'updates only the item type when the name is omitted' do
      patch room_item_endpoint.call(room_item.id),
            params: { room_item: { item_type: appliance_item_type.item_type_key } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('room_item')).to include(
        'name' => 'Table',
        'item_type' => 'appliance'
      )
      expect(room_item.reload).to have_attributes(
        name: 'Table',
        item_type: appliance_item_type
      )
    end

    it 'does not move the item when a room id is submitted' do
      another_room = create(:room, space: space)

      patch room_item_endpoint.call(room_item.id),
            params: { room_item: { name: 'Dining Table', room_id: another_room.id } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(room_item.reload).to have_attributes(name: 'Dining Table', room: room)
    end

    it 'uses the URL id instead of a submitted item id' do
      another_item = create(:room_item, room: room, name: 'Chair')

      patch room_item_endpoint.call(room_item.id),
            params: { room_item: { id: another_item.id, name: 'Dining Table' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('room_item', 'id')).to eq(room_item.id)
      expect(room_item.reload.name).to eq('Dining Table')
      expect(another_item.reload.name).to eq('Chair')
    end

    it 'does not save any changes when the item type is invalid' do
      patch room_item_endpoint.call(room_item.id),
            params: { room_item: { name: 'Changed Name', item_type: 'unknown' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig('errors', 'item_type')).to include('is not included in the list')
      expect(room_item.reload).to have_attributes(name: 'Table', item_type: furniture_item_type)
    end

    it 'does not save any changes when the name is too short' do
      patch room_item_endpoint.call(room_item.id),
            params: { room_item: { name: 'ab', item_type: appliance_item_type.item_type_key } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig('errors', 'name')).to include('must be at least 3 characters long')
      expect(room_item.reload).to have_attributes(name: 'Table', item_type: furniture_item_type)
    end

    { name: '', item_type: nil }.each do |attribute, value|
      it "rejects clearing #{attribute}" do
        patch room_item_endpoint.call(room_item.id),
              params: { room_item: { attribute => value } },
              headers: headers,
              as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.fetch('errors').fetch(attribute.to_s)).to be_present
        expect(room_item.reload).to have_attributes(name: 'Table', item_type: furniture_item_type)
      end
    end

    [{}, { room_item: {} }].each do |request_params|
      it "returns bad request for #{request_params.inspect}" do
        patch room_item_endpoint.call(room_item.id),
              params: request_params,
              headers: headers,
              as: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to match(/param is missing.*room_item/)
        expect(room_item.reload.name).to eq('Table')
      end
    end

    it 'rejects an update containing only unsupported form attributes' do
      patch room_item_endpoint.call(room_item.id),
            params: { room_item: { room_id: room.id } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.fetch('errors').values.flatten)
        .to include('must include name or item_type')
      expect(room_item.reload).to have_attributes(
        name: 'Table',
        item_type: furniture_item_type,
        room: room
      )
    end

    it 'returns not found for a nonexistent item' do
      patch room_item_endpoint.call(0),
            params: { room_item: { name: 'Dining Table' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'does not update another users item' do
      other_item = create(:room_item, name: 'Bed')

      patch room_item_endpoint.call(other_item.id),
            params: { room_item: { name: 'Changed Name' } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:not_found)
      expect(other_item.reload.name).to eq('Bed')
    end

    it 'requires authentication' do
      patch room_item_endpoint.call(room_item.id),
            params: { room_item: { name: 'Dining Table' } },
            as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(room_item.reload.name).to eq('Table')
    end
  end

  describe 'DELETE /api/spaces/:space_id/rooms/:room_id/room_items/:id' do
    let(:room_item) { create(:room_item, room: room) }

    it 'deletes a user-owned item while preserving other items' do
      another_item = create(:room_item, room: room)
      room_item

      expect do
        delete room_item_endpoint.call(room_item.id), headers: headers, as: :json
      end.to change(RoomItem, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
      expect(RoomItem.exists?(room_item.id)).to be(false)
      expect(another_item.reload).to be_persisted
    end

    it 'does not delete another users item' do
      other_item = create(:room_item)

      expect do
        delete room_item_endpoint.call(other_item.id), headers: headers, as: :json
      end.not_to change(RoomItem, :count)

      expect(response).to have_http_status(:not_found)
      expect(other_item.reload).to be_persisted
    end

    it 'returns not found for a nonexistent item' do
      expect do
        delete room_item_endpoint.call(0), headers: headers, as: :json
      end.not_to change(RoomItem, :count)

      expect(response).to have_http_status(:not_found)
    end

    it 'requires authentication' do
      room_item

      expect do
        delete room_item_endpoint.call(room_item.id), as: :json
      end.not_to change(RoomItem, :count)

      expect(response).to have_http_status(:unauthorized)
      expect(room_item.reload).to be_persisted
    end
  end
end
