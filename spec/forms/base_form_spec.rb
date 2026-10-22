# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseForm do
  describe '#valid?' do
    it 'requires subclasses to configure a contract' do
      form = described_class.new(name: 'Home')

      expect { form.valid? }
        .to raise_error(RuntimeError, /Set @contract in BaseForm#initialize/)
    end
  end

  describe '#save' do
    it 'requires valid subclasses to implement persistence' do
      contract = Class.new(ApplicationContract) do
        params do
          required(:name).filled(:string)
        end
      end
      form_class = Class.new(described_class) do
        define_method(:initialize) do |params|
          super(params)
          @contract = contract.new
        end
      end
      form = form_class.new(name: 'Home')

      expect { form.save }
        .to raise_error(NotImplementedError, /#persist! must be implemented/)
    end
  end
end
