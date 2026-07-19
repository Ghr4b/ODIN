require_relative "spec_helper"

RSpec.describe Player do
  describe "#initialize" do
    it "has a name" do
      player = Player.new("Alice", :X)
      expect(player.name).to eq("Alice")
    end

    it "has a piece" do
      player = Player.new("Alice", :X)
      expect(player.piece).to eq(:X)
    end
  end
end
