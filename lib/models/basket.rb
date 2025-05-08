class Basket
  def initialize(products, price_calculator)
    @products = products
    @items = []
    @price_calculator = price_calculator
    validate_products!
  end
  
  def add(product_code)
    product = find_product(product_code)
    raise ArgumentError, "Product with code '#{product_code}' not found" unless product
    
    existing_item = @items.find { |item| item[:product].code == product_code }
    
    if existing_item
      existing_item[:quantity] += 1
    else
      @items << { product: product, quantity: 1 }
    end
  end
  
  def total
    @price_calculator.calculate_total(@items)
  end
  
  def items
    @items.dup
  end
  
  private
  
  def find_product(code)
    @products.find { |product| product.code == code }
  end
  
  def validate_products!
    raise ArgumentError, "Products catalog cannot be empty" if @products.nil? || @products.empty?
    raise ArgumentError, "Price calculator cannot be nil" unless @price_calculator
  end
end 