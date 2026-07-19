require_relative "spec_helper"

RSpec.describe "#check_winner" do
  describe "winning conditions" do
    it "returns X when X wins across the top row" do
      board = instance_double("Board", grid: %w[X X X 4 5 6 7 8 9])
      expect(check_winner(board)).to eq("X")
    end

    it "returns O when O wins across the middle row" do
      board = instance_double("Board", grid: %w[1 2 3 O O O 7 8 9])
      expect(check_winner(board)).to eq("O")
    end

    it "returns X when X wins across the bottom row" do
      board = instance_double("Board", grid: %w[1 2 3 4 5 6 X X X])
      expect(check_winner(board)).to eq("X")
    end

    it "returns X when X wins down the first column" do
      board = instance_double("Board", grid: %w[X 2 3 X 5 6 X 8 9])
      expect(check_winner(board)).to eq("X")
    end

    it "returns O when O wins down the second column" do
      board = instance_double("Board", grid: %w[1 O 3 4 O 6 7 O 9])
      expect(check_winner(board)).to eq("O")
    end

    it "returns X when X wins down the third column" do
      board = instance_double("Board", grid: %w[1 2 X 4 5 X 7 8 X])
      expect(check_winner(board)).to eq("X")
    end

    it "returns X when X wins diagonally (top-left to bottom-right)" do
      board = instance_double("Board", grid: %w[X 2 3 4 X 6 7 8 X])
      expect(check_winner(board)).to eq("X")
    end

    it "returns O when O wins diagonally (top-right to bottom-left)" do
      board = instance_double("Board", grid: %w[1 2 O 4 O 6 O 8 9])
      expect(check_winner(board)).to eq("O")
    end
  end

  describe "no winner" do
    it "returns nil when no winning combination exists" do
      board = instance_double("Board", grid: %w[X O X O X O O X O])
      expect(check_winner(board)).to be_nil
    end

    it "returns nil for an empty board" do
      board = instance_double("Board", grid: %w[1 2 3 4 5 6 7 8 9])
      expect(check_winner(board)).to be_nil
    end

    it "returns nil for a full board with no winner (draw)" do
      board = instance_double("Board", grid: %w[X O X O X O O X O])
      expect(check_winner(board)).to be_nil
    end
  end
end
