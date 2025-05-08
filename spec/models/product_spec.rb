require 'rspec'
require_relative '../../lib/models/product'

RSpec.describe Product do
  describe '#initialize' do
    it 'creates a valid product with proper attributes' do
      product = Product.new('R01', 'Red Widget', 32.95)
      expect(product.code).to eq('R01')
      expect(product.name).to eq('Red Widget')
      expect(product.price).to eq(32.95)
    end
    
    it 'raises an error if code is empty' do
      expect { Product.new('', 'Empty Code', 10.0) }.to raise_error(ArgumentError)
      expect { Product.new(nil, 'Nil Code', 10.0) }.to raise_error(ArgumentError)
    end
    
    it 'raises an error if name is empty' do
      expect { Product.new('X01', '', 10.0) }.to raise_error(ArgumentError)
      expect { Product.new('X01', nil, 10.0) }.to raise_error(ArgumentError)
    end
    
    it 'raises an error if price is not positive' do
      expect { Product.new('X01', 'Test', 0) }.to raise_error(ArgumentError)
      expect { Product.new('X01', 'Test', -5.0) }.to raise_error(ArgumentError)
      expect { Product.new('X01', 'Test', 'not a price') }.to raise_error(ArgumentError)
    end
  end
end 