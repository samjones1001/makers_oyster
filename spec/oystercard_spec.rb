require 'oystercard'

describe Oystercard do
  let(:card)  { described_class.new }

  it('has a balance of 0 at initialization') do
    expect(card.balance).to eq(0)
  end

  it('is not in a journey at initialization') do
    expect(card.in_journey?).to eq(false)
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

  describe('#deduct') do
    it('decreases the balance by the passed amount') do
      card.top_up(10)
      expect{ card.deduct(5) }.to change{ card.balance }.by(-5)
    end
  end

  context('before topping up') do
    describe("#touch_in") do
      it('raises an error if below minimum fare') do
        expect{ card.touch_in }.to raise_error("insufficient funds - minimum fare is £#{Oystercard::MINIMUM_FARE}")
      end
    end
  end

  context('after topping up') do
    before(:each) do
      card.top_up(10)
    end

    describe('#touch_in') do
      it('sets the card to be in journey') do
        card.touch_in
        expect(card).to be_in_journey
      end
    end

    describe('#touch_out') do
      it('sets the card to not be in a journey') do
        card.touch_in
        card.touch_out
        expect(card).to_not be_in_journey
      end
    end
  end
end
