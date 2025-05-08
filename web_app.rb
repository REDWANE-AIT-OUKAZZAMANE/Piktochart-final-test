require 'sinatra/base'
require 'sinatra/reloader'
require 'json'

Dir[File.join(__dir__, 'lib', '**', '*.rb')].sort.each { |file| require file }

class AcmeWidgetWebApp < Sinatra::Base
  # Development configuration
  configure :development do
    register Sinatra::Reloader
  end

  # Production configuration
  configure :production do
    # Disable showing exceptions in production
    set :show_exceptions, false
    set :raise_errors, false
    
    # Enable logging
    enable :logging
  end

  # Common configuration
  set :views, File.join(__dir__, 'views')
  set :public_folder, File.join(__dir__, 'public')
  set :bind, 'localhost'
  
  # Enable sessions
  enable :sessions

  helpers do
    def setup_app
      @products = [
        Product.new('R01', 'Red Widget', 32.95),
        Product.new('G01', 'Green Widget', 24.95),
        Product.new('B01', 'Blue Widget', 7.95)
      ]

      delivery_rules = [
        { threshold: 90, charge: 0 },
        { threshold: 50, charge: 2.95 },
        { threshold: 0, charge: 4.95 }
      ]

      offers = [
        BuyOneGetOneHalfPriceStrategy.new('R01')
      ]

      delivery_strategy = DeliveryChargeStrategy.new(delivery_rules)
      price_calculator = PriceCalculator.new(delivery_strategy, offers)

      @basket = Basket.new(@products, price_calculator)
      session[:items]&.each { |item| @basket.add(item) }
      
      @basket
    end
    
    def format_price(price)
      sprintf('%.2f', price)
    end
  end

  get '/' do
    @basket = setup_app
    erb :index
  end

  post '/add/:code' do |code|
    begin
      @basket = setup_app
      product = @products.find { |p| p.code == code }
      
      if product.nil?
        content_type :json
        status 400
        { success: false, message: "Product not found" }.to_json
      else
        session[:items] ||= []
        
        item = session[:items].find { |i| i[:code] == code }
        
        if item.nil?
          session[:items] << { code: code, quantity: 1 }
        else
          item[:quantity] += 1
        end
        
        # Calculate more detailed response information
        subtotal = @basket.items.sum { |item| item[:product].price * item[:quantity] }
        
        # Calculate discount for red widgets
        discount = 0
        if @basket.items.any? { |item| item[:product].code == 'R01' && item[:quantity] >= 2 }
          red_widgets = @basket.items.find { |item| item[:product].code == 'R01' }
          if red_widgets
            pairs = red_widgets[:quantity] / 2
            discount_per_pair = red_widgets[:product].price / 2.0
            discount = pairs * discount_per_pair
          end
        end
        
        # Calculate item total before delivery
        item_total_before_delivery = subtotal - discount
        
        # Calculate delivery cost
        if item_total_before_delivery >= 90
          delivery = 0
        elsif item_total_before_delivery >= 50
          delivery = 2.95
        else
          delivery = 4.95
        end
        
        # Calculate total
        total = item_total_before_delivery + delivery
        
        content_type :json
        { 
          success: true, 
          message: "Added #{product.name} to basket", 
          basket_count: @basket.items.sum { |item| item[:quantity] },
          subtotal: subtotal,
          discount: discount,
          delivery: delivery,
          total: total
        }.to_json
      end
    rescue => e
      content_type :json
      status 500
      { success: false, message: "Error processing request: #{e.message}" }.to_json
    end
  end

  post '/remove/:code' do |code|
    begin
      @basket = setup_app
      item_index = session[:items]&.find_index { |i| i[:code] == code }
      
      if item_index
        if session[:items][item_index][:quantity] > 1
          session[:items][item_index][:quantity] -= 1
        else
          session[:items].delete_at(item_index)
        end
        
        # Calculate more detailed response information
        subtotal = @basket.items.sum { |item| item[:product].price * item[:quantity] }
        
        # Calculate discount for red widgets
        discount = 0
        if @basket.items.any? { |item| item[:product].code == 'R01' && item[:quantity] >= 2 }
          red_widgets = @basket.items.find { |item| item[:product].code == 'R01' }
          if red_widgets
            pairs = red_widgets[:quantity] / 2
            discount_per_pair = red_widgets[:product].price / 2.0
            discount = pairs * discount_per_pair
          end
        end
        
        # Calculate item total before delivery
        item_total_before_delivery = subtotal - discount
        
        # Calculate delivery cost
        if item_total_before_delivery >= 90
          delivery = 0
        elsif item_total_before_delivery >= 50
          delivery = 2.95
        else
          delivery = 4.95
        end
        
        # Calculate total
        total = item_total_before_delivery + delivery
        
        content_type :json
        { 
          success: true, 
          message: "Removed one #{code} from basket", 
          basket_count: @basket.items.sum { |item| item[:quantity] },
          subtotal: subtotal,
          discount: discount,
          delivery: delivery,
          total: total
        }.to_json
      else
        content_type :json
        status 400
        { success: false, message: "Item not found in basket" }.to_json
      end
    rescue => e
      content_type :json
      status 500
      { success: false, message: "Error processing request: #{e.message}" }.to_json
    end
  end

  get '/basket' do
    @basket = setup_app
    erb :basket
  end

  post '/clear' do
    session[:items] = []
    redirect '/basket'
  end

  get '/checkout' do
    @basket = setup_app
    erb :checkout
  end

  post '/checkout' do
    @basket = setup_app
    
    session[:items] = []
    
    erb :order_complete
  end

  run! if app_file == $0
end 