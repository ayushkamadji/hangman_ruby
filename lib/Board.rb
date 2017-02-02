require_relative 'Node'

class Board

  def initialize(word)
    @word = word
    initialize_secret_nodes(word.downcase)
    @played_chars = []
  end

  def update_board(char)
    raise InvalidUpdate.new("That's not a valid character") unless ('a'..'z').include?(char)
    raise InvalidUpdate.new("Character is already played") if @played_chars.include?(char)
    @secret_nodes.each { |node| node.reveal_if(char) }
    @played_chars << char
  end

  def solved?
    return @secret_nodes.all? do |node|
      node.revealed?
    end
  end

  def misses
    return wrong_chars
  end

  # View 
  def display
    @secret_nodes.each do |node|
      if node.revealed?
        print "#{node} "
      else
        print "_ "
      end
    end
    print "\n"
  end

  private

  def initialize_secret_nodes(word)
    @secret_nodes = []
    word.chars.each do |char|
      @secret_nodes << Node.new(char)
    end
  end

  def wrong_chars
    chars = @played_chars.select do |char|
      !@word.include?(char)
    end
    return chars.join(', ')
  end

end

class InvalidUpdate < Exception
  attr_reader :message

  def initialize(message)
    @message = message
  end
end
  
