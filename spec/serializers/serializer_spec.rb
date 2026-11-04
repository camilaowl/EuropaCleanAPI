# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Serializer do
  let(:user) { create(:user) }

  it 'wraps a user with its default root and public fields' do
    result = described_class.new(user, serializer: UserSerializer).to_h

    expect(result).to eq(
      'user' => {
        'id' => user.id,
        'email' => user.email,
        'created_at' => user.created_at.iso8601,
        'updated_at' => user.updated_at.iso8601(3)
      }
    )
    expect(result.fetch('user')).not_to have_key('encrypted_password')
  end

  it 'supports an explicit root and metadata in JSON output' do
    result = described_class.new(
      user,
      serializer: UserSerializer,
      root: :account,
      meta: { source: 'test' }
    )

    expect(JSON.parse(result.to_json)).to eq(
      'account' => {
        'id' => user.id,
        'email' => user.email,
        'created_at' => user.created_at.iso8601,
        'updated_at' => user.updated_at.iso8601(3)
      },
      'meta' => { 'source' => 'test' }
    )
  end
end
