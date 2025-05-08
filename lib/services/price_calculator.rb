class PriceCalculator
  def initialize(delivery_strategy, offer_strategies = [])
    @delivery_strategy = delivery_strategy
    @offer_strategies = offer_strategies
  end
  
  def calculate_total(items)
    subtotal = calculate_subtotal(items)
    discount = calculate_discount(items)
    item_total = subtotal - discount
    delivery_charge = @delivery_strategy.calculate_charge(item_total)
    
    (item_total + delivery_charge).round(2)
  end
  
  private
  
  def calculate_subtotal(items)
    items.sum { |item| item[:product].price * item[:quantity] }
  end
  
  def calculate_discount(items)
    @offer_strategies.sum do |offer|
      offer.applicable?(items) ? offer.apply_offer(items) : 0
    end
  end
end 