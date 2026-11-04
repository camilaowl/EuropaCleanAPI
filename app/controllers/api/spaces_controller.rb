# frozen_string_literal: true

class Api::SpacesController < Api::BaseController
  before_action :set_space, only: [:show, :update, :destroy]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    spaces = policy_scope(Space)
    render json: ArraySerializer.new(
        spaces,
        each_serializer: SpacesSerializer
    ).to_json, status: :ok
  end

  def show
    render json: Serializer.new(
        @space,
        serializer: SpacesSerializer
    ).to_json, status: :ok
  end

  def create
    authorize Space

    form = Spaces::SpacesCreateForm.new(current_user, space_params)
    if form.save
      render json: Serializer.new(
          form.model,
          serializer: SpacesSerializer
      ).to_json, status: :created
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  def update
    form = Spaces::SpacesUpdateForm.new(current_user, space_params.merge(id: params[:id]))
    if form.save
      render json: Serializer.new(
          form.model,
          serializer: SpacesSerializer
      ).to_json, status: :ok
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    form = Spaces::SpacesDeleteForm.new(current_user, { id: params[:id] })
    if form.save
      head :no_content
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  private

  attr_reader :space

  def set_space
    @space = current_user.spaces.find(params[:id])
    authorize @space
  end

  def space_params
    required_object_param(:space).permit(:name)
  end
end
