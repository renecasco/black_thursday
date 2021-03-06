require 'pry'


class SalesAnalyst
  attr_reader :items,
              :merchants,
              :invoices,
              :invoice_items,
              :customers,
              :transactions

  def initialize(items, merchants, invoices = [], invoice_items = [], customers = [], transactions = [])
    @items = items
    @merchants = merchants
    @invoices = invoices
    @invoice_items = invoice_items
    @customers = customers
    @transactions = transactions
  end

  def items_by_merchant
    @items.all.group_by {|item| item.merchant_id}
  end

  def average(array)
    (sums(array).to_f/array.count).round(2)
  end

  def average_items_per_merchant
    (items_by_merchant.values.flatten.count.to_f/items_by_merchant.count).round(2)
  end

  def sums(array)
    array.reduce(:+)
  end

  def variance(values_array, mean)
    sums(values_array.map {|value|(value - mean)**2})
  end

  def standard_deviation(values_array, mean)
     Math.sqrt(variance(values_array, mean)/(values_array.count-1)).round(2)
  end

  def average_items_per_merchant_standard_deviation
    values_array = items_by_merchant.values.map {|items| items.count}
    standard_deviation(values_array, average_items_per_merchant)
  end

  def merchants_with_high_item_count
    merchants_hash = items_by_merchant.select do |id, items|
      (items.count - average_items_per_merchant) > 3.26
    end
    @merchants.all.find_all {|merchant| merchants_hash.include?(merchant.id)}
  end

  def average_item_price_for_merchant(merchant_id)
    items_by_merchant_array = @items.find_all_by_merchant_id(merchant_id)
    item_prices_array = items_by_merchant_array.map {|item| item.unit_price}
    BigDecimal(average(item_prices_array),6)
  end

  def average_price_per_merchant
    merchant_id_array = @merchants.all.map { |merchant| merchant.id }
    merchant_id_array.map do |merchant|
      average_item_price_for_merchant(merchant)
    end
  end

  def average_average_price_per_merchant
    BigDecimal(average(average_price_per_merchant),6)
  end

  def average_prices_per_merchant_standard_deviation
    prices = @items.all.map {|item| item.unit_price}
    standard_deviation(prices, average_average_price_per_merchant)
  end

  def golden_items
    standard_deviation = average_prices_per_merchant_standard_deviation
    @items.all.find_all { |item| item.unit_price >= standard_deviation * 2 }
  end

  def invoices_by_merchant
    @invoices.all.group_by do |invoice|
      invoice.merchant_id
    end
  end

  def average_invoices_per_merchant
    (invoices_by_merchant.values.flatten.count.to_f/invoices_by_merchant.count).round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    value_array =
    invoices_by_merchant.values.map do |invoices|
      invoices.count
    end
    standard_deviation(value_array, average_invoices_per_merchant)
  end

  def top_merchants_by_invoice_count
    standard_deviation = average_invoices_per_merchant_standard_deviation
    merchant_ids = invoices_by_merchant.select do |merchant_id, invoices|
      (invoices.count - average_invoices_per_merchant) >= (standard_deviation * 2)
    end
    @merchants.all.select {|merchant| merchant_ids.include?(merchant.id)}
  end

  def bottom_merchants_by_invoice_count
    standard_deviation = average_invoices_per_merchant_standard_deviation
    merchant_ids = invoices_by_merchant.select do |merchant_id, invoices|
      (invoices.count - average_invoices_per_merchant) < (-standard_deviation * 2)
    end
    @merchants.all.select {|merchant| merchant_ids.include?(merchant.id)}
  end

  def invoices_by_day
    @invoices.all.group_by do |invoice|
      invoice.created_at.strftime("%A")
    end
  end

  def average_invoices_per_day
    (invoices_by_day.values.flatten.count.to_f/invoices_by_day.count).round(2)
  end

  def average_invoices_per_day_standard_deviation
    values_array = invoices_by_day.values.map {|invoices| invoices.count}
    standard_deviation(values_array, average_invoices_per_day)
  end

  def top_days_by_invoice_count
    standard_deviation = average_invoices_per_day_standard_deviation
    invoices_by_day.select do |day, invoices|
      (invoices.count - average_invoices_per_day) >= (standard_deviation)
    end.keys
  end

  def invoice_status(status_arg)
    i_c = @invoices.all.select do |invoice|
      invoice.status == status_arg
    end
    ((i_c.count.to_f / @invoices.all.count )*100).round(2)
  end

  def invoice_paid_in_full?(invoice_id)
      selected_transactions =@transactions.find_all_by_invoice_id(invoice_id)
    return false if selected_transactions == []
    if selected_transactions.any? {|transaction| transaction.result == :success}
      true
    else
      false
    end
  end

  def invoice_total(invoice_id)
    selected_invoice_items = @invoice_items.find_all_by_invoice_id(invoice_id)
    invoice_items_totals = selected_invoice_items.map do |invoice_item|
      invoice_item.unit_price * invoice_item.quantity
    end
    sums(invoice_items_totals)
  end

  def total_revenue_by_date(date)
    selected_invoices = @invoices.all.select do |invoice|
      invoice.created_at.strftime("%Y%m%d") == date.strftime("%Y%m%d")
    end
    invoice_ids = selected_invoices.map do |invoice|
      invoice.id
    end
    totals_array = invoice_ids.map do |invoice_item|
      invoice_total(invoice_item)
    end
    sums(totals_array)
  end

  def successful_invoices_by_merchant
    succ_hash = Hash.new
    invoices_by_merchant.map do |merchant_id, invoices|
      good_invoices = invoices.select do |invoice|
        invoice_paid_in_full?(invoice.id)
      end
      succ_hash[merchant_id] = good_invoices
    end
    succ_hash
  end

  def merch_ids_to_invoice_ids
    ids_hash = Hash.new
    successful_invoices_by_merchant.map do |merchant_id, invoices|
      in_id = invoices.map do |invoice|
        invoice.id
      end
      ids_hash[merchant_id] = in_id
    end
    ids_hash
  end

  def top_revenue_earners(number = 20)
    totaled_invoice_by_merch = Hash.new
    merch_ids_to_invoice_ids.map do |merch_ids ,invoice_ids|
      totals_array = invoice_ids.map {|id|invoice_total(id)}
      summed_total = sums(totals_array.compact)
      totaled_invoice_by_merch[@merchants.find_by_id(merch_ids)] = summed_total
    end

    array_maxs = totaled_invoice_by_merch.max_by(number) {|keys, values| values.to_f}
    merch_only = array_maxs.flatten
    a = merch_only.delete_if {|obj| obj.class == BigDecimal}
    a
  end

  def invoice_with_all_failed_transactions(invoice_id)
    transactions_for_invoice = @transactions.find_all_by_invoice_id(invoice_id)
    if transactions_for_invoice.all? {|transaction| transaction.result == :failed}
      @invoices.find_by_id(invoice_id)
    end
  end

  def merchants_with_pending_invoices
    invoices = @invoices.all.find_all do |invoice|
      invoice_with_all_failed_transactions(invoice.id)
    end
    (invoices.map {|invoice| @merchants.find_by_id(invoice.merchant_id)}).uniq
  end

  def merchants_with_only_one_item
    selected_merchants = items_by_merchant.select do |key, value|
      value.count == 1
    end
    selected_merchants.keys.map do |merchant_id|
      @merchants.find_by_id(merchant_id)
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.find_all do |merchant|
      Time.parse(merchant.created_at).strftime("%B") == month
    end
  end

  def most_sold_item_for_merchant(merchant_id)
    merchant_invoices = invoices_by_merchant
    selected_invoice_items = merchant_invoices[merchant_id].map do |invoice|
      if invoice_paid_in_full?(invoice.id)
        @invoice_items.find_all_by_invoice_id(invoice.id)
      end
    end.compact.flatten
    invoice_items_by_item = selected_invoice_items.group_by do |invoice_item|
      invoice_item.item_id
    end
    hash = {}
    invoice_items_by_item.each do |item_id, invoice_items|
      top_invoice = invoice_items.max_by {|invoice_item| invoice_item.quantity}
      hash[item_id] = top_invoice
    end
    top_item = hash.max_by {|item_id, invoice_item| invoice_item.quantity}
    hash.map do |item_id, invoice_item|
      @items.find_by_id(item_id) if top_item[1].quantity == invoice_item.quantity
    end.compact
  end

  def revenue_by_merchant(merchant_id)
    selected_merchant =
    merch_ids_to_invoice_ids.select do |merch_id, invoice_id|
      merch_id == merchant_id
    end
    totaled_array = sums(selected_merchant.values.flatten)
    BigDecimal(totaled_array)
  end

  def best_item_for_merchant(merchant_id)
    array_1 = Array.new
    items_by_revenue_hash = Hash.new
    selected_merchant =
    successful_invoices_by_merchant.select do |merch_id, invoice_id|
      merch_id == merchant_id
    end
    invoice_ids = selected_merchant.values
    flattened_array = invoice_ids.flatten
    invoice_items = flattened_array.map do |invoice_item|
      @invoice_items.find_all_by_invoice_id(invoice_item.id)
    end
      items_by_revenue_hash[(invoice_items.flatten).flatten] = (invoice_items.flatten.map {|i_i| i_i.unit_price * i_i.quantity}).flatten
    a = items_by_revenue_hash.keys
    b = items_by_revenue_hash.values
    c = a.flatten
    d = b.flatten.compact
    i_i_values_hash = c.zip(d).to_h
    best_item_hash = i_i_values_hash.max_by {|keys,values| values}
    i_i_selected = best_item_hash[0].item_id
    @items.find_by_id (i_i_selected)
  end

  def merchants_ranked_by_revenue
    top_revenue_earners(@merchants.all.count).compact
  end
end
