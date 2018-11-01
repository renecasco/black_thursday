require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/sales_analyst'
require './lib/merchant_repository'
require './lib/item_repository'
require './lib/invoice_repository'
require './lib/invoice_item_repository'
require './lib/customer_repository'
require './lib/transaction_repository'
require 'bigdecimal'
require 'pry'


class SalesAnalystTest < Minitest::Test

  def test_it_exists
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    assert_instance_of SalesAnalyst, sa
  end

  def test_it_calculates_average_items_per_merchant
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    assert_equal 2.88, sa.average_items_per_merchant
  end

  def test_standard_deviation
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    assert_equal 3.26, sa.average_items_per_merchant_standard_deviation
  end

  def test_it_can_return_merchants_with_high_item_count
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
#   binding.pry
    assert_equal 52, sa.merchants_with_high_item_count.length
  end

  def test_it_can_find_average_item_price_for_merchant
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    assert_equal 16.66, sa.average_item_price_for_merchant(12334105)
  end

  def test_it_can_average_average_price_per_merchant
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    assert_equal 350.29, sa.average_average_price_per_merchant
  end

  def test_it_returns_average
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    array = [5, 6, 7, 8, 9, 10]
    assert_equal 7.5, sa.average(array)
  end

  def test_sums_adds_elements_of_array
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    array = [5, 6, 7, 8, 9, 10]
    assert_equal 45, sa.sums(array)
  end

  def test_variance_returns_sum_of_squared_differences
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    array = [5, 6, 7, 8, 9, 10]
    mean = 7.5
    assert_equal 17.5, sa.variance(array, mean)
  end

  def test_it_returns_standard_deviation
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    array = [5, 6, 7, 8, 9, 10]
    mean = 7.5
    assert_equal 1.87, sa.standard_deviation(array, mean)
  end

  def test_it_returns_average_items_per_merchant_standard_deviation
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    assert_equal 2902.69, sa.average_prices_per_merchant_standard_deviation
  end

  def test_golden_items_returns_array_of_items_2_stnd_devs_above_avg
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    sa = SalesAnalyst.new(items, merchants)
    assert_equal 5, sa.golden_items.count
    assert_instance_of Item, sa.golden_items[0]
  end

  def test_it_can_calculate_the_avg_invoices_per_merchant
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    invoices = InvoiceRepository.new("./data/invoices.csv")
    sa = SalesAnalyst.new(items, merchants, invoices)

    assert_equal 10.49, sa.average_invoices_per_merchant
  end

  def test_it_can_calculate_average_invoices_per_merchant_standard_deviation
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    invoices = InvoiceRepository.new("./data/invoices.csv")
    sa = SalesAnalyst.new(items, merchants, invoices)

    assert_equal 3.29, sa.average_invoices_per_merchant_standard_deviation
  end

  def test_it_can_calculate_top_merchants_by_invoice_count
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    invoices = InvoiceRepository.new("./data/invoices.csv")
    sa = SalesAnalyst.new(items, merchants, invoices)

    assert_equal 12, sa.top_merchants_by_invoice_count.count
  end

  def test_it_can_calculate_bottom_merchants_by_invoice_count
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    invoices = InvoiceRepository.new("./data/invoices.csv")
    sa = SalesAnalyst.new(items, merchants, invoices)

    assert_equal 4, sa.bottom_merchants_by_invoice_count.count
  end

  def test_it_can_calculate_bottom_merchants_by_invoice_count
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    invoices = InvoiceRepository.new("./data/invoices.csv")
    sa = SalesAnalyst.new(items, merchants, invoices)
    assert_equal ["Wednesday"], sa.top_days_by_invoice_count
  end

  def test_it_can_return_by_invoice_status
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    invoices = InvoiceRepository.new("./data/invoices.csv")
    sa = SalesAnalyst.new(items, merchants, invoices)

    assert_equal 56.95, sa.invoice_status(:shipped)
    assert_equal 29.55, sa.invoice_status(:pending)
    assert_equal 13.5, sa.invoice_status(:returned)
  end

  def test_it_can_check_invoices_paid_in_full
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    invoices = InvoiceRepository.new("./data/invoices.csv")
    invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
    customers = CustomerRepository.new('./data/customers.csv')
    transactions = TransactionRepository.new('./data/transactions.csv')
    sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)

    assert sa.invoice_paid_in_full?(1)
  end

  def test_it_can_check_for_invoice_total_amount
    items = ItemRepository.new("./data/items.csv")
    merchants = MerchantRepository.new("./data/merchants.csv")
    invoices = InvoiceRepository.new("./data/invoices.csv")
    invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
    customers = CustomerRepository.new('./data/customers.csv')
    transactions = TransactionRepository.new('./data/transactions.csv')
    sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)

    assert_equal 21067.77, sa.invoice_total(1)
  end

    def test_it_can_return_total_revenue_by_date
      items = ItemRepository.new("./data/items.csv")
      merchants = MerchantRepository.new("./data/merchants.csv")
      invoices = InvoiceRepository.new("./data/invoices.csv")
      invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
      customers = CustomerRepository.new('./data/customers.csv')
      transactions = TransactionRepository.new('./data/transactions.csv')
      sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)
      date = Time.parse("2009-02-07")
      assert_equal BigDecimal(21067.77,7), sa.total_revenue_by_date(date)
    end

    def test_it_returns_an_array_of_top_revenue_earners
      skip
      items = ItemRepository.new("./data/items.csv")
      merchants = MerchantRepository.new("./data/merchants.csv")
      invoices = InvoiceRepository.new("./data/invoices.csv")
      invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
      customers = CustomerRepository.new('./data/customers.csv')
      transactions = TransactionRepository.new('./data/transactions.csv')
      sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)
      date = Time.parse("2009-02-07")
      assert_instance_of Merchant, sa.top_revenue_earners(10).first
      assert_equal 12334634, sa.top_revenue_earners(10).first.id
      assert_equal 12335747, sa.top_revenue_earners(10).last.id
    end

    def test_it_returns_an_array_merchants_with_pending_invoices
      items = ItemRepository.new("./data/items.csv")
      merchants = MerchantRepository.new("./data/merchants.csv")
      invoices = InvoiceRepository.new("./data/invoices.csv")
      invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
      customers = CustomerRepository.new('./data/customers.csv')
      transactions = TransactionRepository.new('./data/transactions.csv')
      sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)
      assert_instance_of Merchant, sa.merchants_with_pending_invoices.first
      assert_equal 467, sa.merchants_with_pending_invoices.length
    end

    def test_it_returns_merchants_with_only_one_item
      items = ItemRepository.new("./data/items.csv")
      merchants = MerchantRepository.new("./data/merchants.csv")
      invoices = InvoiceRepository.new("./data/invoices.csv")
      invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
      customers = CustomerRepository.new('./data/customers.csv')
      transactions = TransactionRepository.new('./data/transactions.csv')
      sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)
      assert_instance_of Merchant, sa.merchants_with_only_one_item.first
      assert_equal 243, sa.merchants_with_only_one_item.length
    end


    def test_it_returns_merchants_with_only_one_item_registered_in_month
      items = ItemRepository.new("./data/items.csv")
      merchants = MerchantRepository.new("./data/merchants.csv")
      invoices = InvoiceRepository.new("./data/invoices.csv")
      invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
      customers = CustomerRepository.new('./data/customers.csv')
      transactions = TransactionRepository.new('./data/transactions.csv')
      sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)
      assert_instance_of Merchant, sa.merchants_with_only_one_item_registered_in_month("March").first
      assert_equal 21, sa.merchants_with_only_one_item_registered_in_month("March").length
      assert_equal 18, sa.merchants_with_only_one_item_registered_in_month("June").length
    end

    def test_if_can_total_revenue_by_merchant
      items = ItemRepository.new("./data/items.csv")
      merchants = MerchantRepository.new("./data/merchants.csv")
      invoices = InvoiceRepository.new("./data/invoices.csv")
      invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
      customers = CustomerRepository.new('./data/customers.csv')
      transactions = TransactionRepository.new('./data/transactions.csv')
      sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)

      actual = sa.revenue_by_merchant(12334194)
      assert_equal 33898, actual
    end

    def test_if_can_return_the_best_item_for_merchant
      items = ItemRepository.new("./data/items.csv")
      merchants = MerchantRepository.new("./data/merchants.csv")
      invoices = InvoiceRepository.new("./data/invoices.csv")
      invoice_items = InvoiceItemRepository.new('./data/invoice_items.csv')
      customers = CustomerRepository.new('./data/customers.csv')
      transactions = TransactionRepository.new('./data/transactions.csv')
      sa = SalesAnalyst.new(items, merchants, invoices,invoice_items, customers, transactions)

      assert_equal 263516130, sa.best_item_for_merchant(12334189).id
    end
end
