require 'rails_helper'

RSpec.describe 'Healthcheck', type: :request do
  describe 'GET /up' do
    it 'returns an OK response' do
      get '/up'

      expect(response).to have_http_status(:ok)
    end
  end
end
