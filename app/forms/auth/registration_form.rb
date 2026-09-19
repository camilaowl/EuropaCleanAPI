# frozen_string_literal: true

class RegistrationForm < BaseForm

  def initialize(params)
    super(params)
    @contract = Auth::RegistrationCreateContract.new
  end

  private

  def persist!
    @model = User.create!(@validated_params)
  end

end