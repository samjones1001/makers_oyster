class Oystercard
  attr_reader :balance, :current_journey, :journey_history
  MAX_BALANCE = 90
  MINIMUM_FARE = 1

  def initialize
    @balance = 0
    @current_journey = {entry: nil, exit: nil}
    @journey_history = []
  end

  def top_up(amount)
    raise "exceeds maximum balance of £#{MAX_BALANCE}" if exceeds_max?(amount)
    @balance += amount
  end

  def in_journey?
    !!current_journey[:entry]
  end

  def touch_in(entry_station)
    raise "insufficient funds - minimum fare is £#{MINIMUM_FARE}" if below_min?
    @current_journey[:entry] = entry_station
  end

  def touch_out(exit_station)
    @current_journey[:exit] = exit_station
    add_journey
    deduct(MINIMUM_FARE)
  end

  private
  def deduct(amount)
    @balance -= amount
  end

  def exceeds_max?(top_up_amount)
    @balance + top_up_amount > MAX_BALANCE
  end

  def below_min?
    balance < MINIMUM_FARE
  end

  def add_journey
    journey_history << current_journey
    erase_current_journey
  end

  def erase_current_journey
    @current_journey = {entry: nil, exit: nil}
  end
end
