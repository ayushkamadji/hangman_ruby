require_relative 'Node'

class Board

  def initialize(word)
    initialize_secret_nodes(word.downcase)
    @played_chars = []
  end

  def update_board(char)
    @secret_nodes.each { |node| node.reveal_if(char) }
    @played_chars << char
  end

  def solved?
    return @secret_nodes.all? do |node|
      node.revealed?
    end
  end

  private

  def initialize_secret_nodes(word)
    @secret_nodes = []
    word.chars.each do |char|
      @secret_nodes << Node.new(char)
    end
  end
end
