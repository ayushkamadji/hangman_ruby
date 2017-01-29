require_relative 'Board'

class Game
  
  def initialize
    @board = Board.new
    @tries = 6
  end

  def start
    until @board.solved? || @tries == 0
      guess = prompt_player
    end
  end

end
