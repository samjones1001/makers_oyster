require 'oystercard'

describe Oystercard do
  let(:card)  { described_class.new }

  it('has a balance of 0 at initialization') do
    expect(card.balance).to eq(0)
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
end
