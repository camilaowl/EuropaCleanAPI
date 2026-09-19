# frozen_string_literal: true

class SessionCreateForm < BaseForm

  def initialize(params)
    super(params)
    @contract = Auth::SessionCreateContract.new
  end

  private

  def persist!
    @model = User.find_by(email: @validated_params[:email])
  end

end