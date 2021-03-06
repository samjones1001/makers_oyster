require 'journey'

describe Journey do
  let (:journey)          { described_class.new }
  let(:entry_station)     { double :station, :zone => 1 }
  let(:exit_station)      { double :station }

  it('initializes with no entry station') do
    expect(journey.entry_station).to eq(nil)
  end

  it('initializes with no exit station') do
    expect(journey.exit_station).to eq(nil)
  end

  describe('#start') do
    it('sets the entry station') do
      journey.start(entry_station)
      expect(journey.entry_station).to eq(entry_station)
    end
  end

  describe('#end') do
    it('sets the exit station') do
      journey.end(exit_station)
      expect(journey.exit_station).to eq(exit_station)
    end
  end

  describe('#calculate_fare') do
    it('returns the minimum fare if a journey is completed with stations in the same zone') do
      allow(exit_station).to receive(:zone).and_return(1)
      journey.start(entry_station)
      journey.end(exit_station)
      expect(journey.calculate_fare).to eq(Journey::MINIMUM_FARE)
    end

    it('calculates the correct fare if a journey is completed with stations in different zones') do
      zone = 1 + rand(5)
      fare_from_zone_one = zone
      allow(exit_station).to receive(:zone).and_return(zone)
      journey.start(entry_station)
      journey.end(exit_station)
      expect(journey.calculate_fare).to eq(fare_from_zone_one)
    end

    it('returns the penalty fare if the journey is not complete') do
      journey.start(entry_station)
      expect(journey.calculate_fare).to eq(Journey::PENALTY_FARE)
    end
  end

  describe('#complete?') do
    it('returns true if there is a entry and an exit station') do
      journey.start(entry_station)
      journey.end(exit_station)
      expect(journey).to be_complete
    end

    it('return false if the is an entry station but no exit station') do
      journey.start(entry_station)
      expect(journey).to_not be_complete
    end

    it('returns false if there is an exit station but no entry station') do
      journey.end(exit_station)
      expect(journey).to_not be_complete
    end
  end
end
