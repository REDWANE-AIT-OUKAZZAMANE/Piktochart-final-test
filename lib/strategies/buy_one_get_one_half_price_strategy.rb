require_relative 'offer_strategy'

class BuyOneGetOneHalfPriceStrategy < OfferStrategy
  def initialize(product_code)
    @product_code = product_code
  end
  
  def apply_offer(items)
    return 0 unless applicable?(items)
    
    matching_items = items.find { |item| item[:product].code == @product_code }
    quantity = matching_items[:quantity]
    
    pairs = quantity / 2
    
    discount_per_pair = matching_items[:product].price / 2.0
    total_discount = pairs * discount_per_pair
    
    total_discount
  end
  
  def applicable?(items)
    return false if items.nil? || items.empty?
    
    matching_items = items.find { |item| item[:product].code == @product_code }
    
    !matching_items.nil? && matching_items[:quantity] >= 2
  end
end 