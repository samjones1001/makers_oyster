require_relative 'journey'
require_relative 'station'

class Oystercard
  attr_reader :balance, :current_journey, :journey_history, :journey_class
  MAX_BALANCE = 90

  def initialize(journey_class = Journey)
    @balance = 0
    @journey_class = journey_class
    @current_journey = journey_class.new
    @journey_history = []
  end

  def top_up(amount)
    raise "exceeds maximum balance of £#{MAX_BALANCE}" if exceeds_max?(amount)
    @balance += amount
  end

  def touch_in(entry_station)
    process_penalty if !current_journey.complete?
    raise "insufficient funds - minimum fare is £#{Journey::MINIMUM_FARE}" if below_min?
    current_journey.start(entry_station)
  end

  def touch_out(exit_station)
    current_journey.end(exit_station)
    deduct(current_journey.calculate_fare)
    reset_journey
  end

  private
  def deduct(amount)
    @balance -= amount
  end

  def exceeds_max?(top_up_amount)
    @balance + top_up_amount > MAX_BALANCE
  end

  def below_min?
    balance < Journey::MINIMUM_FARE
  end

  def reset_journey
    journey_history << current_journey
    p journey_history
    erase_current_journey
  end

  def erase_current_journey
    @current_journey = journey_class.new
  end

  def process_penalty
    deduct(current_journey.calculate_fare)
    reset_journey
  end
end
