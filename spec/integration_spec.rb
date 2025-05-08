require 'rspec'
require_relative '../lib/models/product'
require_relative '../lib/models/basket'
require_relative '../lib/services/price_calculator'
require_relative '../lib/strategies/delivery_charge_strategy'
require_relative '../lib/strategies/buy_one_get_one_half_price_strategy'

RSpec.describe 'Integration Tests' do
  let(:products) do
    [
      Product.new('R01', 'Red Widget', 32.95),
      Product.new('G01', 'Green Widget', 24.95),
      Product.new('B01', 'Blue Widget', 7.95)
    ]
  end
  
  let(:delivery_rules) do
    [
      { threshold: 90, charge: 0 },
      { threshold: 50, charge: 2.95 },
      { threshold: 0, charge: 4.95 }
    ]
  end
  
  let(:delivery_strategy) { DeliveryChargeStrategy.new(delivery_rules) }
  let(:offer_strategy) { BuyOneGetOneHalfPriceStrategy.new('R01') }
  let(:price_calculator) { PriceCalculator.new(delivery_strategy, [offer_strategy]) }
  let(:basket) { Basket.new(products, price_calculator) }
  
  def test_basket_with_products(product_codes, expected_total)
    basket = Basket.new(products, price_calculator)
    
    product_codes.each do |code|
      basket.add(code)
    end
    
    expect(basket.total).to eq(expected_total)
  end
  
  it 'returns the correct total for B01, G01' do
    test_basket_with_products(['B01', 'G01'], 37.85)
  end
  
  it 'returns the correct total for R01, R01' do
    test_basket_with_products(['R01', 'R01'], 54.38)
  end
  
  it 'returns the correct total for R01, G01' do
    test_basket_with_products(['R01', 'G01'], 60.85)
  end
  
  it 'returns the correct total for B01, B01, R01, R01, R01' do
    test_basket_with_products(['B01', 'B01', 'R01', 'R01', 'R01'], 98.28)
  end
end 