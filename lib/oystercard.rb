require_relative 'journey'
require_relative 'station'
require_relative 'journey_log'

class Oystercard
  attr_reader :balance, :journey_log
  MAX_BALANCE = 90

  def initialize(journey_log_class = JourneyLog)
    @balance = 0
    @journey_log = journey_log_class.new
  end

  def top_up(amount)
    raise "exceeds maximum balance of £#{MAX_BALANCE}" if exceeds_max?(amount)
    @balance += amount
  end

  def touch_in(entry_station)
    process_penalty if !journey_log.journey_complete?
    raise "insufficient funds - minimum fare is £#{Journey::MINIMUM_FARE}" if below_min?
    journey_log.start(entry_station)
  end

  def touch_out(exit_station)
    journey_log.end(exit_station)
    deduct(journey_log.process_fare)
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

  def process_penalty
    deduct(journey_log.process_fare)
  end
end
