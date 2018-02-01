require 'oystercard'

describe Oystercard do
  let(:card)              { described_class.new(current_journey) }
  let(:entry_station)     { double :station }
  let(:exit_station)      { double :station }
  let(:current_journey)   { double :current_journey, new: journey }
  let(:journey)           { double :journey, entry_station: nil, exit_station: nil }

  it('has a balance of 0 at initialization') do
    expect(card.balance).to eq(0)
  end

  it('initializes with an empty current journey') do
    expect(card.current_journey).to eq(journey)
  end

  it('initializes with an empty journey history') do
    expect(card.journey_history).to eq([])
  end

  describe("#top_up") do
    it("increases the balance by the passed amount") do
      expect{ card.top_up(10) }.to change{ card.balance }.by(10)
    end

    it("raises an error if above maximum balance") do
      Oystercard::MAX_BALANCE.times { card.top_up(1) }
      expect{ card.top_up(1) }.to raise_error("exceeds maximum balance of £#{Oystercard::MAX_BALANCE}")
    end
  end

  context('before topping up') do
    describe("#touch_in") do
      it('raises an error if below minimum fare') do
        allow(journey).to receive(:complete?).and_return(true)
        expect{ card.touch_in(entry_station) }.to raise_error("insufficient funds - minimum fare is £#{Journey::MINIMUM_FARE}")
      end
    end
  end

  context('after topping up') do
    before(:each) do
      card.top_up(10)
    end

    describe('#touch_in') do
      it('starts the current journey') do
        allow(journey).to receive(:complete?).and_return(true)
        expect(journey).to receive(:start).with(entry_station)
        card.touch_in(entry_station)
      end

      it('charges a penalty fare if previous journey was incomplete') do
        allow(journey).to receive(:complete?).and_return(false)
        allow(journey).to receive(:start).with(entry_station)
        allow(journey).to receive(:calculate_fare).and_return(Journey::PENALTY_FARE)
        expect{ card.touch_in(entry_station) }.to change{ card.balance }.by(-Journey::PENALTY_FARE)
      end

      it('add a journey to the journey history if previous journey was incomplete') do
        allow(journey).to receive(:complete?).and_return(false)
        allow(journey).to receive(:start).with(entry_station)
        allow(journey).to receive(:calculate_fare).and_return(Journey::PENALTY_FARE)
        card.touch_in(entry_station)
        expect(card.journey_history.length).to eq(1)
      end
    end

    context('after touching in') do
      before(:each) do
        allow(journey).to receive(:complete?).and_return(true)
        allow(journey).to receive(:start).with(entry_station)
        card.touch_in(entry_station)
      end

      describe('#touch_out') do
        before(:each) do
          allow(journey).to receive(:calculate_fare).and_return(Journey::MINIMUM_FARE)
          allow(journey).to receive(:end)
        end

        it('ends the current journey') do
          expect(journey).to receive(:end).with(exit_station)
          card.touch_out(exit_station)
        end

        it('charges a fare') do
          expect{ card.touch_out(exit_station) }.to change{ card.balance }.by(-Journey::MINIMUM_FARE)
        end

        it('resets the current_journey') do
          card.touch_out(exit_station)
          expect(card.current_journey).to eq(journey)
        end

        it('stores the journey') do
          card.touch_out(exit_station)
          expect(card.journey_history.length).to eq(1)
        end
      end
    end
  end
end
