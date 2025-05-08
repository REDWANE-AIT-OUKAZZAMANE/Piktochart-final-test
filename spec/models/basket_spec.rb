require 'rspec'
require_relative '../../lib/models/product'
require_relative '../../lib/models/basket'
require_relative '../../lib/services/price_calculator'

RSpec.describe Basket do
  let(:products) do
    [
      Product.new('R01', 'Red Widget', 32.95),
      Product.new('G01', 'Green Widget', 24.95),
      Product.new('B01', 'Blue Widget', 7.95)
    ]
  end
  
  let(:mock_calculator) { instance_double(PriceCalculator) }
  
  describe '#initialize' do
    it 'creates an empty basket' do
      basket = Basket.new(products, mock_calculator)
      expect(basket.items).to be_empty
    end
    
    it 'raises an error if products catalog is empty' do
      expect { Basket.new([], mock_calculator) }.to raise_error(ArgumentError)
      expect { Basket.new(nil, mock_calculator) }.to raise_error(ArgumentError)
    end
    
    it 'raises an error if price calculator is nil' do
      expect { Basket.new(products, nil) }.to raise_error(ArgumentError)
    end
  end
  
  describe '#add' do
    let(:basket) { Basket.new(products, mock_calculator) }
    
    it 'adds a product to the basket' do
      basket.add('R01')
      expect(basket.items.size).to eq(1)
      expect(basket.items.first[:product].code).to eq('R01')
      expect(basket.items.first[:quantity]).to eq(1)
    end
    
    it 'increases the quantity when adding the same product' do
      basket.add('R01')
      basket.add('R01')
      expect(basket.items.size).to eq(1)
      expect(basket.items.first[:quantity]).to eq(2)
    end
    
    it 'adds different products separately' do
      basket.add('R01')
      basket.add('G01')
      basket.add('B01')
      expect(basket.items.size).to eq(3)
      expect(basket.items.map { |item| item[:product].code }).to contain_exactly('R01', 'G01', 'B01')
    end
    
    it 'raises an error for unknown product codes' do
      expect { basket.add('UNKNOWN') }.to raise_error(ArgumentError)
    end
  end
  
  describe '#total' do
    let(:basket) { Basket.new(products, mock_calculator) }
    
    it 'delegates to the price calculator' do
      basket.add('R01')
      basket.add('G01')
      
      expect(mock_calculator).to receive(:calculate_total).with(basket.items).and_return(60.85)
      expect(basket.total).to eq(60.85)
    end
  end
end 