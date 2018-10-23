require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/merchant_repository'
require './lib/merchant'

class MerchantRepositoryTest < Minitest::Test
  def test_merchant_reposity_exists
    mr = MerchantRepository.new("./data/merchants.csv")
    assert_instance_of MerchantRepository, mr
  end

  def test_merchant_reposity_has_merchants
    mr = MerchantRepository.new("./data/merchants.csv")
    assert_instance_of Merchant, mr.merchants_array[0]
  end

  def test_it_can_find_all_merchants
    mr = MerchantRepository.new("./data/merchants.csv")
    assert_equal 475, mr.all.count
  end

  def test_it_can_find_merchant_by_id
    mr = MerchantRepository.new("./data/merchants.csv")
    assert_equal mr.merchants_array[4], mr.find_by_id(12334123)
  end

  def test_it_can_find_merchants_by_name
    mr = MerchantRepository.new("./data/merchants.csv")
    assert_equal mr.merchants_array[6], mr.find_by_name("GoldenRayPress")
  end

  def test_it_can_find_all_merchants_by_name
    mr = MerchantRepository.new("./data/merchants.csv")
    assert_equal [mr.merchants_array[6], mr.merchants_array[143]], mr.find_all_by_name("Ray")
  end

  def test_it_can_create_a_new_merchant_in_the_array
    mr = MerchantRepository.new("./data/merchants.csv")
    m = {:name => "Turing School",
      :created_at => "2012-09-10", :updated_at => "2012-10-10"}
    actual = mr.create(m).last
    expected = mr.find_by_id(12337412)
    assert_equal expected , actual
  end

  def test_it_can_update_an_existing_merchant
    mr = MerchantRepository.new("./data/merchants.csv")
    mr.update(12334105, {name: "Shopin2018"})
    new_shop = mr.merchants_array[0]
    actual = new_shop.name
    assert_equal "Shopin2018" , actual
  end
end
