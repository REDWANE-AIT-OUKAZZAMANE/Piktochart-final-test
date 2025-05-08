class DeliveryChargeStrategy
  def initialize(rules)
    @rules = rules
    validate_rules!
  end

  def calculate_charge(basket_total)
    @rules.sort_by { |rule| -rule[:threshold] }.each do |rule|
      if basket_total >= rule[:threshold]
        return rule[:charge]
      end
    end

    @rules.map { |rule| rule[:charge] }.max || 0
  end

  private

  def validate_rules!
    raise ArgumentError, "Delivery charge rules cannot be empty" if @rules.nil? || @rules.empty?
    
    @rules.each do |rule|
      unless rule.is_a?(Hash) && 
             rule.key?(:threshold) && 
             rule.key?(:charge) && 
             rule[:threshold].is_a?(Numeric) && 
             rule[:charge].is_a?(Numeric)
        raise ArgumentError, "Each delivery rule must have a numeric threshold and charge"
      end
    end
  end
end 