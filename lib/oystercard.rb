class Oystercard
  attr_reader :balance, :in_journey
  MAX_BALANCE = 90

  def initialize
    @balance = 0
    @in_journey = false
  end

  def top_up(amount)
    raise "exceeds maximum balance of £#{MAX_BALANCE}" if exceeds_max?(amount)
    @balance += amount
  end

  def deduct(amount)
    @balance -= amount
  end

  def in_journey?
    in_journey
  end

  def touch_in
    @in_journey = true
  end

  def touch_out
    @in_journey = false
  end

  private
  def exceeds_max?(top_up_amount)
    @balance + top_up_amount > MAX_BALANCE
  end
end
