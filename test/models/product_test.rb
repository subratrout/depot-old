require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  test "product attributes should not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    product = Product.new(
      title: "My new book title",
      description: "Some description",
      image_url: "abc.jpg"
      )
    product.price = -1
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(
      title: "New book title",
      description: "any",
      price: 2,
      image_url: image_url

      )
  end

  test "presence of image url when adding product" do

    good = %w{subrat.gif subrat.jpg subrat.png SUBRAT.jpg SUBRAT.gif
      SUBRAT.png http://a.b.c/x/z/subrat.jpg
    }
    bad = %w{subrat.doc subrat.jif/some subrat.jpg.more}

    good.each do |image|
      assert new_product(image).valid?, "#{image} shouldn't be invalid"
    end

    bad.each do |image|
      assert new_product(image).invalid? "#{image} should not be valid"
    end
  end


  test "product is not valid without a unique title" do
    product = Product.new(
      title: products(:ruby).title,
      description: "something",
      price: 1,
      image_url: "ruby.jpg"
    )

    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end
end
