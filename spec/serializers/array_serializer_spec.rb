# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArraySerializer do
  it 'serializes an empty relation under its model root' do
    result = described_class.new(User.none, each_serializer: UserSerializer)

    expect(result.to_h).to eq('users' => [])
  end

  it 'serializes an array with a custom root and metadata' do
    user = create(:user)
    result = described_class.new(
      [user],
      each_serializer: UserSerializer,
      root: :accounts,
      meta: { count: 1 }
    )

    expect(JSON.parse(result.to_json)).to eq(
      'accounts' => [{
        'id' => user.id,
        'email' => user.email,
        'created_at' => user.created_at.iso8601,
        'updated_at' => user.updated_at.iso8601(3)
      }],
      'meta' => { 'count' => 1 }
    )
  end
end
