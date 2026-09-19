# frozen_string_literal: true

class BaseForm
  attr_reader :model, :params, :errors, :validated_params

  def initialize(params)
    @params = params.to_h.deep_symbolize_keys
    @validated_params = nil
    @errors = nil
    @model = nil
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def valid?
    raise "Set @contract in #{self.class}#initialize" unless @contract

    result = @contract.call(params)

    if result.success?
      @validated_params = extract_attributes(result)
      @errors = {}
      true
    else
      @errors = extract_errors(result)
      false
    end
  end

  private

  def persist!
    raise NotImplementedError, "#{self.class}#persist! must be implemented"
  end

  def extract_attributes(result)
    if result.respond_to?(:attributes)
      result.attributes
    elsif result.respond_to?(:values)
      values = result.values
      values.respond_to?(:to_h) ? values.to_h : values
    else
      params
    end
  end

  def extract_errors(result)
    return {} unless result.respond_to?(:errors)

    errs = result.errors
    errs.respond_to?(:to_h) ? errs.to_h : errs
  end
end
