require_relative "spec_helper"

RSpec.describe Board do
  subject(:board) { Board.new }

  describe "#initialize" do
    it "creates a grid with 6 rows" do
      expect(board.grid.length).to eq(6)
    end

    it "creates a grid with 7 columns" do
      board.grid.each do |row|
        expect(row.length).to eq(7)
      end
    end

    it "all cells start as nil" do
      board.grid.each do |row|
        row.each do |cell|
          expect(cell).to be_nil
        end
      end
    end
  end

  describe "#drop" do
    it "places a piece in the bottom row of a column" do
      board.drop(0, :X)
      expect(board.grid[5][0]).to eq(:X)
    end

    it "stacks pieces in a column" do
      board.drop(0, :X)
      board.drop(0, :O)
      expect(board.grid[5][0]).to eq(:X)
      expect(board.grid[4][0]).to eq(:O)
    end

    it "returns false when column is full" do
      6.times { board.drop(0, :X) }
      expect(board.drop(0, :X)).to be false
    end

    it "returns false for a negative column" do
      expect(board.drop(-1, :X)).to be false
    end

    it "returns false for a column beyond the grid" do
      expect(board.drop(7, :X)).to be false
    end
  end

  describe "#column_full?" do
    it "returns false when column has space" do
      expect(board.column_full?(0)).to be false
    end

    it "returns true when column is full" do
      6.times { board.drop(0, :X) }
      expect(board.column_full?(0)).to be true
    end

    it "returns true for negative column" do
      expect(board.column_full?(-1)).to be true
    end

    it "returns true for column beyond the grid" do
      expect(board.column_full?(7)).to be true
    end
  end

  describe "#full?" do
    it "returns false on a new board" do
      expect(board.full?).to be false
    end

    it "returns true when all cells are filled" do
      7.times { |col| 6.times { board.drop(col, :X) } }
      expect(board.full?).to be true
    end
  end

  describe "#win?" do
    it "returns false on an empty board" do
      expect(board.win?(:X)).to be false
    end

    context "horizontal win" do
      it "detects four in a row horizontally" do
        4.times { |col| board.drop(col, :X) }
        expect(board.win?(:X)).to be true
      end

      it "does not detect win with three in a row" do
        3.times { |col| board.drop(col, :X) }
        expect(board.win?(:X)).to be false
      end
    end

    context "vertical win" do
      it "detects four in a column vertically" do
        4.times { board.drop(0, :X) }
        expect(board.win?(:X)).to be true
      end
    end

    context "diagonal win" do
      it "detects four in a diagonal (bottom-left to top-right)" do
        board.drop(0, :X)
        board.drop(1, :O)
        board.drop(1, :X)
        board.drop(2, :O)
        board.drop(2, :O)
        board.drop(2, :X)
        board.drop(3, :O)
        board.drop(3, :O)
        board.drop(3, :O)
        board.drop(3, :X)
        expect(board.win?(:X)).to be true
      end

      it "detects four in a diagonal (top-left to bottom-right)" do
        board.drop(3, :X)
        board.drop(2, :O)
        board.drop(2, :X)
        board.drop(1, :O)
        board.drop(1, :O)
        board.drop(1, :X)
        board.drop(0, :O)
        board.drop(0, :O)
        board.drop(0, :O)
        board.drop(0, :X)
        expect(board.win?(:X)).to be true
      end
    end
  end

  describe "#winner" do
    it "returns the winning piece" do
      4.times { board.drop(0, :X) }
      expect(board.winner).to eq(:X)
    end

    it "returns nil when no winner" do
      expect(board.winner).to be_nil
    end
  end

  describe "#display" do
    it "outputs column headers" do
      expect { board.display }.to output(/1 2 3 4 5 6 7/).to_stdout
    end

    it "renders a piece as its symbol" do
      board.drop(0, :X)
      expect { board.display }.to output(/X/).to_stdout
    end

    it "renders empty cells as spaces" do
      expect { board.display }.to output(/^\| \| \| \| \| \| \| \|$/).to_stdout
    end

    it "renders a separator row" do
      expect { board.display }.to output(/---------------/).to_stdout
    end
  end
end
