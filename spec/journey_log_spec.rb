require 'journey_log'

describe JourneyLog do
  let(:log)               { described_class.new(current_journey) }
  let(:entry_station)     { double :station }
  let(:exit_station)      { double :station }
  let(:current_journey)   { double :current_journey, new: journey }
  let(:journey)           { double :journey, entry_station: nil, exit_station: nil }

  it 'initializes with a journey' do
    expect(log.current_journey).to eq(journey)
  end

  it 'initialzes with no stored journeys' do
    expect(log.journeys).to be_empty
  end

  describe('#start') do
    it('starts the current journey') do
      expect(journey).to receive(:start).with(entry_station)
      log.start(entry_station)
    end
  end

  describe('#end') do
    it('ends the current journey') do
      expect(journey).to receive(:end).with(exit_station)
      log.end(exit_station)
    end
  end

  describe('#journey_complete?') do
    it('returns true for a complete journey') do
      allow(journey).to receive(:complete?).and_return(true)
      expect(log.journey_complete?).to eq(true)
    end

    it('returns false for an incomplete journey') do
      allow(journey).to receive(:complete?).and_return(false)
      expect(log.journey_complete?).to eq(false)
    end
  end

  describe('#process_fare') do
    before(:each) do
      example_fare = 5
      allow(journey).to receive(:calculate_fare).and_return(example_fare)
    end

    it('returns the correct fare for the journey') do
      expect(log.process_fare).to eq(5)
    end

    it('stores the current journey') do
      log.process_fare
      expect(log.journeys).to include(journey)
    end

    it('resets the current journey') do
      expect(current_journey).to receive(:new)
      log.process_fare
    end
  end
end
