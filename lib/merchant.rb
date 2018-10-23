class Merchant
  attr_reader :id, :name, :created_at, :updated_at

  def initialize(merchant_hash)
    @id = merchant_hash[:id].to_i
    @name = merchant_hash[:name]
    @created_at = merchant_hash[:created_at]
    @updated_at = merchant_hash[:updated_at]
  end


end
