require 'rspec'
require_relative '../../lib/models/product'
require_relative '../../lib/strategies/buy_one_get_one_half_price_strategy'

RSpec.describe BuyOneGetOneHalfPriceStrategy do
  let(:red_widget) { Product.new('R01', 'Red Widget', 32.95) }
  let(:blue_widget) { Product.new('B01', 'Blue Widget', 7.95) }
  
  let(:strategy) { BuyOneGetOneHalfPriceStrategy.new('R01') }
  
  describe '#applicable?' do
    it 'returns true when there are at least 2 matching products' do
      items = [
        { product: red_widget, quantity: 2 }
      ]
      expect(strategy.applicable?(items)).to be true
      
      items = [
        { product: red_widget, quantity: 3 },
        { product: blue_widget, quantity: 1 }
      ]
      expect(strategy.applicable?(items)).to be true
    end
    
    it 'returns false when there are fewer than 2 matching products' do
      items = [
        { product: red_widget, quantity: 1 }
      ]
      expect(strategy.applicable?(items)).to be false
      
      items = [
        { product: blue_widget, quantity: 5 }
      ]
      expect(strategy.applicable?(items)).to be false
    end
    
    it 'returns false for an empty basket' do
      expect(strategy.applicable?([])).to be false
    end
  end
  
  describe '#apply_offer' do
    it 'returns zero discount when not applicable' do
      items = [
        { product: red_widget, quantity: 1 }
      ]
      expect(strategy.apply_offer(items)).to eq(0)
    end
    
    it 'applies half price discount to every second item' do
      
      # 2 red widgets: discount on 1 item
      items = [
        { product: red_widget, quantity: 2 }
      ]
      expected_discount = red_widget.price / 2
      expect(strategy.apply_offer(items)).to eq(expected_discount)
      
      # 3 red widgets: discount on 1 item
      items = [
        { product: red_widget, quantity: 3 }
      ]
      expected_discount = red_widget.price / 2
      expect(strategy.apply_offer(items)).to eq(expected_discount)
      
      # 4 red widgets: discount on 2 items
      items = [
        { product: red_widget, quantity: 4 }
      ]
      expected_discount = red_widget.price / 2 * 2
      expect(strategy.apply_offer(items)).to eq(expected_discount)
    end
    
    it 'ignores other products' do
      items = [
        { product: red_widget, quantity: 2 },
        { product: blue_widget, quantity: 5 }
      ]
      expected_discount = red_widget.price / 2
      expect(strategy.apply_offer(items)).to eq(expected_discount)
    end
  end
end 