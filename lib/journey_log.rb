class JourneyLog
  attr_reader :current_journey, :journey_class

  def initialize(journey_class = Journey)
    @journeys = []
    @journey_class = journey_class
    @current_journey = journey_class.new
  end

  def start(entry_station)
    current_journey.start(entry_station)
  end

  def end(exit_station)
    current_journey.end(exit_station)
  end

  def journeys
    @journeys.dup
  end

  def journey_complete?
    current_journey.complete?
  end

  def process_fare
    fare = current_journey.calculate_fare
    reset_journey
    fare
  end

  private
  def reset_journey
    @journeys << current_journey
    @current_journey = journey_class.new
  end
end
