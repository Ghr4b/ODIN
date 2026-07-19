require_relative "spec_helper"

RSpec.describe Game do
  subject(:game) { Game.new }

  let(:player1) { game.player1 }
  let(:player2) { game.player2 }

  describe "#initialize" do
    it "has two players" do
      expect(player1).to be_a(Player)
      expect(player2).to be_a(Player)
    end

    it "has a board" do
      expect(game.board).to be_a(Board)
    end

    it "starts with player1 as current player" do
      expect(game.current_player).to eq(player1)
    end
  end

  describe "#switch_turn" do
    it "switches to the other player" do
      game.switch_turn
      expect(game.current_player).to eq(player2)
    end

    it "switches back after two turns" do
      game.switch_turn
      game.switch_turn
      expect(game.current_player).to eq(player1)
    end
  end

  describe "#play_turn" do
    it "drops a piece in the specified column" do
      game.play_turn(3)
      expect(game.board.grid[5][3]).to eq(player1.piece)
    end

    it "switches the current player after a turn" do
      game.play_turn(3)
      expect(game.current_player).to eq(player2)
    end

    it "returns false when column is full" do
      6.times { game.board.drop(3, :X) }
      expect(game.play_turn(3)).to be false
    end

    it "returns false for out-of-range column" do
      expect(game.play_turn(-1)).to be false
    end

    it "does not switch turn on invalid column" do
      game.play_turn(-1)
      expect(game.current_player).to eq(player1)
    end
  end

  describe "#game_over?" do
    it "returns false at the start" do
      expect(game.game_over?).to be false
    end

    it "returns true when a player wins" do
      allow(game.board).to receive(:winner).and_return(:X)
      expect(game.game_over?).to be true
    end

    it "returns true when board is full" do
      allow(game.board).to receive(:full?).and_return(true)
      expect(game.game_over?).to be true
    end
  end

  describe "#winner" do
    it "returns the winning player" do
      allow(game.board).to receive(:winner).and_return(:X)
      expect(game.winner).to eq(player1)
    end

    it "returns nil when no winner" do
      allow(game.board).to receive(:winner).and_return(nil)
      expect(game.winner).to be_nil
    end
  end

  describe "#play" do
    it "exits gracefully on EOF" do
      allow($stdin).to receive(:gets).and_return(nil)
      expect { game.play }.to output(/choose a column/).to_stdout
    end

    it "re-prompts on invalid column" do
      allow($stdin).to receive(:gets).and_return("0\n", "1\n", nil)
      expect { game.play }.to output(/Invalid move/).to_stdout
    end

    it "re-prompts on non-numeric input" do
      allow($stdin).to receive(:gets).and_return("abc\n", "1\n", nil)
      expect { game.play }.to output(/Invalid move/).to_stdout
    end

    it "re-prompts on column out of range" do
      allow($stdin).to receive(:gets).and_return("8\n", "1\n", nil)
      expect { game.play }.to output(/Invalid move/).to_stdout
    end

    it "re-prompts on full column" do
      6.times { game.board.drop(0, :X) }
      allow($stdin).to receive(:gets).and_return("1\n", "1\n", nil)
      expect { game.play }.to output(/Invalid move/).to_stdout
    end

    it "announces the winner" do
      allow($stdin).to receive(:gets).and_return("1\n", "2\n", "1\n", "2\n", "1\n", "2\n", "1\n", nil)
      expect { game.play }.to output(/wins!/).to_stdout
    end

    it "announces a draw when the board is full with no winner" do
      allow(game.board).to receive(:full?).and_return(true)
      allow(game.board).to receive(:winner).and_return(nil)
      allow($stdin).to receive(:gets).and_return("1\n", nil)
      expect { game.play }.to output(/draw/).to_stdout
    end
  end
end
