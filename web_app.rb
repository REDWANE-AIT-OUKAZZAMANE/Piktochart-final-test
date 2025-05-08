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
  set :bind, '0.0.0.0'
  
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

  post '/add/:code' do
    @basket = setup_app
    
    code = params[:code]
    
    begin
      @basket.add(code)
      
      session[:items] ||= []
      session[:items] << code
      
      content_type :json
      { 
        success: true, 
        message: "Added #{code} to basket", 
        basket_count: @basket.items.sum { |item| item[:quantity] } 
      }.to_json
    rescue ArgumentError => e
      content_type :json
      status 400
      { success: false, message: e.message }.to_json
    end
  end

  post '/remove/:code' do
    @basket = setup_app
    code = params[:code]
    
    begin
      item_index = session[:items].index(code)
      
      if item_index
        session[:items].delete_at(item_index)
        
        @basket = setup_app
        
        content_type :json
        { 
          success: true, 
          message: "Removed one #{code} from basket", 
          basket_count: @basket.items.sum { |item| item[:quantity] }
        }.to_json
      else
        content_type :json
        status 400
        { success: false, message: "Item not found in basket" }.to_json
      end
    rescue => e
      content_type :json
      status 500
      { success: false, message: e.message }.to_json
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

  # JSON endpoint for order summary updates
  get '/order-summary' do
    @basket = setup_app
    
    subtotal = @basket.items.sum { |item| item[:product].price * item[:quantity] }
    
    item_total_before_delivery = subtotal
    
    if @basket.items.any? { |item| item[:product].code == 'R01' && item[:quantity] >= 2 }
      red_widgets = @basket.items.find { |item| item[:product].code == 'R01' }
      if red_widgets
        pairs = red_widgets[:quantity] / 2
        discount_per_pair = red_widgets[:product].price / 2.0
        red_widget_discount = pairs * discount_per_pair
        item_total_before_delivery -= red_widget_discount
      end
    end
    
    if item_total_before_delivery >= 90
      delivery = 0
    elsif item_total_before_delivery >= 50
      delivery = 2.95
    else
      delivery = 4.95
    end
    
    discount = subtotal - item_total_before_delivery
    total = @basket.total
    
    content_type :json
    {
      subtotal: format_price(subtotal),
      discount: format_price(discount),
      delivery: format_price(delivery),
      total: format_price(total)
    }.to_json
  end

  run! if app_file == $0
end 