# Wrapper for Panko::Serializer to add root for the object
class Serializer
  # @param [any] object
  # @param [Class<Panko::Serializer>] serializer
  # @param [Symbol, String] root automatically generated from the object class name
  # @param [Hash] meta
  # @param [Hash] context
  def initialize(object, serializer:, root: nil, meta: nil, context: nil)
    @object = object
    @serializer = serializer
    @root = root
    @meta = meta
    @context = context
  end

  # @return [Hash]
  def to_h
    if meta
      {
        root.to_s => serialized_object,
        'meta' => meta
      }
    else
      {
        root.to_s => serialized_object
      }
    end
  end

  # @return [String]
  def to_json(*)
    Oj.dump(to_h, mode: :json)
  end

  private

  attr_reader :object, :serializer, :meta, :context

  def serialized_object
    serializer.new(context: context).serialize(object)
  end

  def root
    @root ||= object.class.name.underscore
  end
end
