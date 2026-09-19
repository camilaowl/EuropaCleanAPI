# Wrapper for Panko::ArraySerializer to add root for the object
class ArraySerializer
  # @param [ActiveRecord::Relation, Array] objects
  # @param [Class<Panko::Serializer>] each_serializer
  # @param [Symbol, String] root automatically generated from the model name or first object class name
  # @param [Hash] meta
  # @param [Hash] context
  def initialize(objects, each_serializer:, root: nil, meta: nil, context: nil)
    @objects = objects
    @each_serializer = each_serializer
    @root = root
    @meta = meta
    @context = context
  end

  # @return [Hash]
  def to_h
    if meta
      {
        root.to_s => serialized_objects,
        'meta' => meta
      }
    else
      {
        root.to_s => serialized_objects
      }
    end
  end

  # @return [String]
  def to_json(*)
    Oj.dump(to_h, mode: :json)
  end

  private

  attr_reader :objects, :each_serializer, :meta, :context

  def serialized_objects
    Panko::ArraySerializer.new(objects, each_serializer: each_serializer, context: context).to_a
  end

  def root
    return @root if @root

    object_class = objects.is_a?(ActiveRecord::Relation) ? objects.model : objects.first.class
    @root = object_class.name.underscore.pluralize
  end
end
