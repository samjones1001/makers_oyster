require 'oystercard'

describe Oystercard do
  let(:card)                    { described_class.new(journey_log_class) }
  let(:entry_station)           { double :station }
  let(:exit_station)            { double :station }
  let(:journey_log_class)       { double :journey_log, new: journey_log }
  let(:journey_log)             { double :journey_log }

  it('has a balance of 0 at initialization') do
    expect(card.balance).to eq(0)
  end

  it('initializes with a journey history') do
    expect(card.journey_log).to eq(journey_log)
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
        allow(journey_log).to receive(:journey_complete?).and_return(true)
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
        allow(journey_log).to receive(:journey_complete?).and_return(true)
        expect(journey_log).to receive(:start).with(entry_station)
        card.touch_in(entry_station)
      end

      it('charges a penalty fare if previous journey was incomplete') do
        allow(journey_log).to receive(:journey_complete?).and_return(false)
        allow(journey_log).to receive(:start).with(entry_station)
        allow(journey_log).to receive(:process_fare).and_return(Journey::PENALTY_FARE)
        allow(journey_log).to receive(:reset_journey)
        expect{ card.touch_in(entry_station) }.to change{ card.balance }.by(-Journey::PENALTY_FARE)
      end
    end

    context('after touching in') do
      before(:each) do
        allow(journey_log).to receive(:journey_complete?).and_return(true)
        allow(journey_log).to receive(:start).with(entry_station)
        card.touch_in(entry_station)
      end

      describe('#touch_out') do
        before(:each) do
          allow(journey_log).to receive(:process_fare).and_return(Journey::MINIMUM_FARE)
          allow(journey_log).to receive(:end)
          allow(journey_log).to receive(:reset_journey)
        end

        it('ends the current journey') do
          expect(journey_log).to receive(:end).with(exit_station)
          card.touch_out(exit_station)
        end

        it('charges a fare') do
          expect{ card.touch_out(exit_station) }.to change{ card.balance }.by(-Journey::MINIMUM_FARE)
        end
      end
    end
  end
end
