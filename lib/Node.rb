class Node
  
  def initialize(char)
    @value = char
    @revealed = false
  end
  
  def reveal
    @revealed = true
  end

  def revealed?
    return @revealed
  end

  def reveal_if(char)
    reveal if @value == char
  end
end
