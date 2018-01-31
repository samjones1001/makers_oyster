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
  end
end
