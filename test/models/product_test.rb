require "test_helper"

class ProductTest < ActiveSupport::TestCase
  # 加载指定的静态测试文件数据
  fixtures :products

  # test "the truth" do
  #   assert true
  # end
  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    product = Product.new(:title       => "my book titile",
                          :description => "yyy",
                          :image_url   => "zzz.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
                 product.errors[:price].join(';')

    product.price = 0
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
                 product.errors[:price].join(';')

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(:title       => "My Book Title",
                :description => "yyy",
                :price       => 1,
                :image_url   => image_url)
  end

  test "product image url must be allowed" do
    ok = %w{ fred.jpg fred.gif fred.png FRED.JPG FRED.Jpg
             http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.git.more }

    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end

    bad.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end
  end

  test "product is not valid without a unique title" do
    product = Product.new(:title       => products(:ruby).title,
                          :description => "yyy",
                          :price       => 1,
                          :image_url   => "fred.jpg")
    assert !product.save
    # assert_equal "has already been taken", product.errors[:title].join(';')
    # 避免 Active Record 错误中使用硬编码的字符串，可以将返回的
    #           错误信息与其内置的错误信息进行比较来解决这个问题
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
                 product.errors[:title].join(';')
  end

end
