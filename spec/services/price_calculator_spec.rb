require 'rspec'
require_relative '../../lib/models/product'
require_relative '../../lib/services/price_calculator'
require_relative '../../lib/strategies/delivery_charge_strategy'
require_relative '../../lib/strategies/buy_one_get_one_half_price_strategy'

RSpec.describe PriceCalculator do
  let(:red_widget) { Product.new('R01', 'Red Widget', 32.95) }
  let(:green_widget) { Product.new('G01', 'Green Widget', 24.95) }
  let(:blue_widget) { Product.new('B01', 'Blue Widget', 7.95) }
  
  let(:delivery_rules) do
    [
      { threshold: 90, charge: 0 },
      { threshold: 50, charge: 2.95 },
      { threshold: 0, charge: 4.95 }
    ]
  end
  
  let(:delivery_strategy) { DeliveryChargeStrategy.new(delivery_rules) }
  let(:offer_strategy) { BuyOneGetOneHalfPriceStrategy.new('R01') }
  
  describe '#calculate_total' do
    context 'with no offers' do
      let(:calculator) { PriceCalculator.new(delivery_strategy) }
      
      it 'calculates total with delivery charge for B01, G01' do
        items = [
          { product: blue_widget, quantity: 1 },
          { product: green_widget, quantity: 1 }
        ]
        
        # Subtotal: 7.95 + 24.95 = 32.90
        # Delivery: 4.95 (under $50)
        # Total: 37.85
        expect(calculator.calculate_total(items)).to eq(37.85)
      end
      
      it 'calculates total with delivery charge for R01, G01' do
        items = [
          { product: red_widget, quantity: 1 },
          { product: green_widget, quantity: 1 }
        ]
        
        # Subtotal: 32.95 + 24.95 = 57.90
        # Delivery: 2.95 (under $90 but over $50)
        # Total: 60.85
        expect(calculator.calculate_total(items)).to eq(60.85)
      end
    end
    
    context 'with offers' do
      let(:calculator) { PriceCalculator.new(delivery_strategy, [offer_strategy]) }
      
      it 'calculates total with red widget offer for R01, R01' do
        items = [
          { product: red_widget, quantity: 2 }
        ]
        
        # Subtotal: 32.95 * 2 = 65.90
        # Discount: 32.95 / 2 = 16.475
        # Item total: 65.90 - 16.475 = 49.425
        # Delivery: 4.95 (under $50)
        # Total: 49.425 + 4.95 = 54.375 ≈ 54.38
        expect(calculator.calculate_total(items)).to eq(54.38)
      end
      
      it 'calculates total with red widget offer for multiple items' do
        items = [
          { product: blue_widget, quantity: 2 },
          { product: red_widget, quantity: 3 }
        ]
        
        # Subtotal: (7.95 * 2) + (32.95 * 3) = 15.90 + 98.85 = 114.75
        # Discount: 32.95 / 2 = 16.475 (one pair of red widgets)
        # Item total: 114.75 - 16.475 = 98.275
        # Delivery: 0 (over $90)
        # Total: 98.275 ≈ 98.28
        expect(calculator.calculate_total(items)).to eq(98.28)
      end
    end
  end
end 