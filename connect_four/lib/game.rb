class Game
  attr_reader :player1, :player2, :board, :current_player

  def initialize
    @board = Board.new
    @player1 = Player.new("Player 1", :X)
    @player2 = Player.new("Player 2", :O)
    @current_player = @player1
  end

  def switch_turn
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  def play_turn(col)
    result = @board.drop(col, @current_player.piece)
    switch_turn if result
    result
  end

  def play
    loop do
      @board.display
      puts "#{@current_player.name} (#{@current_player.piece}), choose a column (1-7):"
      input = $stdin.gets
      break if input.nil?
      col = input.to_i - 1
      if col < 0 || col > 6 || @board.column_full?(col)
        puts "Invalid move, try again."
        next
      end
      play_turn(col)
      if game_over?
        @board.display
        if @board.winner
          puts "#{winner.name} wins!"
        else
          puts "It's a draw!"
        end
        break
      end
    end
  end

  def game_over?
    @board.winner != nil || @board.full?
  end

  def winner
    winning_piece = @board.winner
    return nil if winning_piece.nil?
    @player1.piece == winning_piece ? @player1 : @player2
  end
end
