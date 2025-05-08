class Product
  attr_reader :code, :name, :price

  def initialize(code, name, price)
    @code = code
    @name = name
    @price = price
    validate!
  end

  private

  def validate!
    raise ArgumentError, "Product code cannot be empty" if code.nil? || code.strip.empty?
    raise ArgumentError, "Product name cannot be empty" if name.nil? || name.strip.empty?
    raise ArgumentError, "Product price must be a positive number" unless price.is_a?(Numeric) && price > 0
  end
end 