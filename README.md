# Acme Widget Co Shopping Cart Application

This is a Ruby implementation of a shopping cart system for Acme Widget Co, created as part of the Piktochart coding challenge.

## Project Description

The system implements a comprehensive shopping experience for Acme Widget Co, which sells three products and has specific delivery charge rules and special offers.

### Products

| Product      | Code | Price  |
| ------------ | ---- | ------ |
| Red Widget   | R01  | $32.95 |
| Green Widget | G01  | $24.95 |
| Blue Widget  | B01  | $7.95  |

### Delivery Charges

- Orders under $50: $4.95 delivery
- Orders under $90 (but $50 or more): $2.95 delivery
- Orders of $90 or more: Free delivery

### Special Offers

- Buy one red widget, get the second half price

## Features

This application includes:

1. **Web Interface**

   - Responsive design for desktop and mobile devices
   - Interactive product catalog
   - Dynamic shopping cart with real-time updates
   - Quantity adjustment controls (+/-)
   - Checkout flow with delivery information
   - Order confirmation page

2. **Backend Implementation**

   - RESTful API endpoints
   - Session-based cart management
   - Advanced discount calculation
   - Delivery charge calculation
   - Special offer handling

3. **Design Principles**
   - Clean, structured code organization
   - Separation of concerns
   - Dependency injection
   - Strategy pattern for extensibility
   - Responsive design patterns

## Design Principles

This solution implements the following design principles:

1. **Good separation/encapsulation of concerns**:

   - Models represent data entities (Product, Basket)
   - Services handle business logic (PriceCalculator)
   - Strategies implement specific algorithms (DeliveryChargeStrategy, offer strategies)
   - Views handle presentation logic

2. **Small accurate interfaces/classes**:

   - Each class has a single responsibility
   - Clear interfaces between components
   - Minimized dependencies

3. **Dependency injection**:

   - Dependencies are passed into classes rather than created inside them
   - Makes testing easier and promotes loose coupling

4. **Strategy pattern/extensible code**:
   - Delivery charge calculation uses a strategy
   - Offers are implemented as strategies
   - New strategies can be added without modifying existing code

## Project Structure

```
.
├── lib/                      # Core business logic
│   ├── models/               # Domain models
│   │   ├── product.rb        # Product representation
│   │   ├── basket.rb         # Basket implementation
│   ├── services/             # Service objects
│   │   ├── price_calculator.rb # Handles price calculations
│   ├── strategies/           # Strategy implementations
│       ├── delivery_charge_strategy.rb   # Delivery charge calculation
│       ├── offer_strategy.rb             # Base class for offers
│       ├── buy_one_get_one_half_price_strategy.rb # Specific offer
├── public/                   # Static assets
│   ├── css/                  # Stylesheets
│   │   ├── styles.css        # Main stylesheet
├── views/                    # Sinatra view templates
│   ├── layout.erb            # Main layout template
│   ├── index.erb             # Product catalog page
│   ├── basket.erb            # Shopping cart page
│   ├── checkout.erb          # Checkout form
│   ├── order_complete.erb    # Order confirmation page
├── web_app.rb                # Sinatra web application
├── main.rb                   # Application entry point
└── README.md                 # This file
```

## Technologies Used

- **Backend**: Ruby, Sinatra
- **Frontend**: HTML5, CSS3, JavaScript, jQuery
- **UI Framework**: Bootstrap 5
- **Icons**: Font Awesome
- **Testing**: RSpec

## Key Features Implemented

1. **Responsive UI**

   - Mobile-first design approach
   - Content centers properly on small screens
   - Adapts to different device sizes

2. **Interactive Shopping Experience**

   - Add to cart functionality with AJAX
   - Real-time cart updates without page refresh
   - Toast notifications for user feedback

3. **Cart Management**

   - Quantity controls to increase/decrease items
   - Automatic price and discount calculations
   - Visual delivery charge indicators

4. **Checkout Process**

   - Comprehensive order summary
   - Form validation
   - Order confirmation page

5. **Visual Enhancements**
   - Consistent color scheme and styling
   - Product images with hover effects
   - Card-based layout for content organization
   - Animated transitions

## How to Run

```bash
# Install dependencies
bundle install

# Run the Sinatra web application
ruby main.rb
```

## Web Application Routes

- `GET /` - Product catalog
- `POST /add/:code` - Add a product to the basket
- `POST /remove/:code` - Remove a product from the basket
- `GET /basket` - View the shopping cart
- `POST /clear` - Clear the basket
- `GET /checkout` - Checkout form
- `POST /checkout` - Submit order and get confirmation

## Example Test Cases

| Products                | Expected Total |
| ----------------------- | -------------- |
| B01, G01                | $37.85         |
| R01, R01                | $54.37         |
| R01, G01                | $60.85         |
| B01, B01, R01, R01, R01 | $98.27         |

## Recent Improvements

1. **UI Enhancements**

   - Added responsive design for mobile devices
   - Improved navigation with dedicated product and basket buttons
   - Fixed "Add to Cart" buttons at the bottom of product cards
   - Implemented quantity controls in the basket
   - Added toast notifications for user actions

2. **Code Quality**

   - Restructured JavaScript for better maintainability
   - Organized CSS into logical sections
   - Improved error handling
   - Optimized AJAX requests
   - Ensured correct discount and delivery price calculations

3. **User Experience**

   - Added visual feedback during cart interactions
   - Improved form layouts and validation
   - Enhanced mobile experience with centered elements
   - Simplified navigation for better usability

4. **Architecture Changes**
   - Fully web-based application
   - Implemented Sinatra for handling web requests
   - Added session management for user carts
   - Created structured views with ERB templates
   - Integrated client-side JavaScript for interactions

## Future Enhancements

1. Add persistence layer (database integration)
2. Implement user authentication and accounts
3. Add product categories and filtering
4. Implement a wishlist feature
5. Add product reviews and ratings
6. Enhance the checkout process with multiple payment options
