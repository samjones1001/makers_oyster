require 'station'

describe Station do
  let (:station)  { described_class.new("station one", 1)}

  it ('retains a name') do
    expect(station.name).to eq("station one")
  end

  it('reatins a zone') do
    expect(station.zone).to eq(1)
  end
end
