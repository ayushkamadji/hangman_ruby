require_relative 'Board'

class Game
  
  def initialize
    @secret = generate_secret_word
    @board = Board.new(@secret)
    @tries = 6
  end

  def start
    until game_over?
      begin
        display
        guess = prompt_player
        break if guess.length < 1
          if guess.length == 1
            @board.update_board(guess)
            @tries -= 1 unless hit?(guess)
          else
            check_for_match(guess)
            @tries -= 1 unless hit?(guess)
          end
      rescue InvalidUpdate => e
        display_error(e)
      end
    end
    display_game_end if game_over?
  end

  def generate_secret_word
    return File.readlines('dictionary.txt').select {|word| word.length > 7 && word.length <= 14 }.sample.strip.downcase
  end

  def prompt_player
    return gets.strip.downcase
  end

  def check_for_match(string)
    if string == @secret
      string.chars.uniq.each do |char|
        begin
        @board.update_board(char)
        rescue InvalidUpdate
        end
      end
    end
  end

  def hit?(guess)
    match_whole = guess == @secret
    match_letter = @secret.include?(guess) && guess.length == 1
    return match_whole || match_letter
  end

  def game_over?
    return @board.solved? || @tries == 0
  end

  def display_error(e)
    print "\e[2J\e[1;1H"
    puts "#{e.message}. Try again."
    gets
  end

  def display
    print "\e[2J\e[1;1H\e[?25h"
    @board.display
    print "HP : "
    @tries.times { print "*" }
    print "\n"
    print "Misses: #{@board.misses}\n"
    puts "Take your guess (one character or full word) or press Enter for menu :"
  end

  def display_game_end
    print "\e[2J\e[1;1H"
    puts "\"#{@secret}\"" if @board.solved?
    puts "Gameover"
    gets
  end
end
