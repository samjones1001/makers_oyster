require 'oystercard'

describe Oystercard do
  let(:card)              { described_class.new }
  let(:entry_station)     { double :station }
  let(:exit_station)      { double :station }
  let(:empty_journey)     { {entry: nil, exit: nil} }
  let(:started_journey)   { {entry: entry_station, exit: nil} }
  let(:completed_journey) { {entry: entry_station, exit: exit_station} }

  it('has a balance of 0 at initialization') do
    expect(card.balance).to eq(0)
  end

  it('is not in a journey at initialization') do
    expect(card.in_journey?).to eq(false)
  end

  it('initializes with an empty current journey') do
    expect(card.current_journey).to eq(empty_journey)
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
        expect{ card.touch_in(entry_station) }.to raise_error("insufficient funds - minimum fare is £#{Oystercard::MINIMUM_FARE}")
      end
    end
  end

  context('after topping up') do
    before(:each) do
      card.top_up(10)
    end

    describe('#touch_in') do
      it('sets the card to be in journey') do
        card.touch_in(entry_station)
        expect(card).to be_in_journey
      end

      it('retains the entry station') do
        card.touch_in(entry_station)
        expect(card.current_journey).to eq(started_journey)
      end
    end

    context('after touching in') do
      before(:each) do
        card.touch_in(entry_station)
      end

      describe('#touch_out') do
        it('sets the card to not be in a journey') do
          card.touch_out(exit_station)
          expect(card).to_not be_in_journey
        end

        it('charges the minimum fare') do
          expect{ card.touch_out(exit_station) }.to change{ card.balance }.by(-Oystercard::MINIMUM_FARE)
        end

        it('resets the current_journey') do
          card.touch_out(exit_station)
          expect(card.current_journey).to eq(empty_journey)
        end

        it('stores the journey') do
          card.touch_out(exit_station)
          expect(card.journey_history).to include(completed_journey)
        end
      end
    end
  end
end
