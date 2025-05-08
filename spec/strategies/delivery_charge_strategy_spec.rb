require 'rspec'
require_relative '../../lib/strategies/delivery_charge_strategy'

RSpec.describe DeliveryChargeStrategy do
  let(:delivery_rules) do
    [
      { threshold: 90, charge: 0 },      # Free delivery for orders >= $90
      { threshold: 50, charge: 2.95 },   # $2.95 delivery for orders >= $50 and < $90
      { threshold: 0, charge: 4.95 }     # $4.95 delivery for orders < $50
    ]
  end
  
  describe '#initialize' do
    it 'creates a valid strategy with rules' do
      strategy = DeliveryChargeStrategy.new(delivery_rules)
      expect(strategy).to be_a(DeliveryChargeStrategy)
    end
    
    it 'raises an error if rules are empty' do
      expect { DeliveryChargeStrategy.new([]) }.to raise_error(ArgumentError)
      expect { DeliveryChargeStrategy.new(nil) }.to raise_error(ArgumentError)
    end
    
    it 'raises an error if rules are invalid' do
      invalid_rules = [{ wrong: 'format' }]
      expect { DeliveryChargeStrategy.new(invalid_rules) }.to raise_error(ArgumentError)
      
      invalid_rules = [{ threshold: 'not a number', charge: 5 }]
      expect { DeliveryChargeStrategy.new(invalid_rules) }.to raise_error(ArgumentError)
    end
  end
  
  describe '#calculate_charge' do
    let(:strategy) { DeliveryChargeStrategy.new(delivery_rules) }
    
    it 'returns the correct charge for orders under $50' do
      expect(strategy.calculate_charge(0)).to eq(4.95)
      expect(strategy.calculate_charge(25)).to eq(4.95)
      expect(strategy.calculate_charge(49.99)).to eq(4.95)
    end
    
    it 'returns the correct charge for orders between $50 and $90' do
      expect(strategy.calculate_charge(50)).to eq(2.95)
      expect(strategy.calculate_charge(75)).to eq(2.95)
      expect(strategy.calculate_charge(89.99)).to eq(2.95)
    end
    
    it 'returns the correct charge for orders $90 and above' do
      expect(strategy.calculate_charge(90)).to eq(0)
      expect(strategy.calculate_charge(100)).to eq(0)
      expect(strategy.calculate_charge(1000)).to eq(0)
    end
  end
end 