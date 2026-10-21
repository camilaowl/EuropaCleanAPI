# frozen_string_literal: true

class Api::SpacesController < Api::BaseController
  before_action :authenticate_user!

  def index
    @spaces = current_user.spaces
    render json: @spaces
  end

  def create
    @space = current_user.spaces.build(space_params)
    if @space.save
      render json: @space, status: :created
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @space = current_user.spaces.find(params[:id])
    render json: @space
  end

  def update
    @space = current_user.spaces.find(params[:id])
    if @space.update(space_params)
      render json: @space
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @space = current_user.spaces.find(params[:id])
    @space.destroy
    head :no_content
  end

  private

  def space_params
    params.require(:space).permit(:name, :description)
  end
end