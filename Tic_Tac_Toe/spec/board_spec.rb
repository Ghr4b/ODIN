require_relative "spec_helper"

RSpec.describe Board do
  describe "#initialize" do
    it "creates a grid with numbers 1 through 9" do
      board = Board.new
      expect(board.grid).to eq(%w[1 2 3 4 5 6 7 8 9])
    end
  end

  describe "#update" do
    subject(:board) { Board.new }

    it "marks a cell with the player's symbol" do
      board.update(0, "X")
      expect(board.grid[0]).to eq("X")
    end

    it "raises an error for an invalid player" do
      expect { board.update(0, "A") }.to raise_error("Invalid player")
    end

    it "raises an error for an index below 0" do
      expect { board.update(-1, "X") }.to raise_error("Invalid index")
    end

    it "raises an error for an index above 8" do
      expect { board.update(9, "X") }.to raise_error("Invalid index")
    end

    it "raises an error when the cell is already occupied" do
      board.update(4, "X")
      expect { board.update(4, "O") }.to raise_error("Cell already occupied")
    end
  end

  describe "#full?" do
    it "returns false for a new board" do
      board = Board.new
      expect(board.full?).to be false
    end

    it "returns true when all cells are occupied" do
      board = Board.new
      %w[X O X O X O X O X].each_with_index { |p, i| board.update(i, p) }
      expect(board.full?).to be true
    end

    it "returns false when only some cells are occupied" do
      board = Board.new
      board.update(0, "X")
      board.update(1, "O")
      expect(board.full?).to be false
    end
  end
end
