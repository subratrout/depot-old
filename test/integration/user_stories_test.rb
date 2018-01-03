require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products
  include ActiveJob::TestHelper

  # A user goes to index page, select a product, add it to his/her cart
  # and check out , filling their details on checkout form.
  # 
  # When submit the order is created containing their information, along
  # with a single line item corresponding to the product he/she adder to
  # her cart
  test "buying a product" do
    start_order_count = Order.count
    ruby_book = products(:ruby)

    get "/"
    assert_response :success 
    assert_select 'h1', "Book Catalog"

    post '/line_items', params: {product_id: ruby_book.id}, xhr: true
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    get "/orders/new"
    assert_response :success
    assert_select 'legend', 'Please Enter Your Details'

    perform_enqueued_jobs do
      post "/orders", params: {
        order: {
          name: "Subrat Rout",
          address: "123 The Street",
          email: "subrat@subrat.com",
          pay_type: "Check"
        }
      }

      follow_redirect!

      assert_response :success
      assert_select 'h1', "Book Catalog"
      cart = Cart.find(session[:cart_id])
      assert_equal 0, cart.line_items.size

      assert_equal start_order_count + 1, Order.count
      order = Order.last

      assert_equal "Subrat Rout", order.name
      assert_equal "123 The Street", order.address
      assert_equal "subrat@subrat.com", order.email
      assert_equal "Check", order.pay_type

      assert_equal 1, order.line_items.size
      line_item = order.line_items[0]
      assert_equal ruby_book, line_item.product

      mail = ActionMailer::Base.deliveries.last
      assert_equal "subrat@subrat.com", mail[:to].value
      assert_equal "from@example.com", mail[:from].value
      assert_equal "ROR Store Order Confirmation", mail.subject
    end
  end
end
