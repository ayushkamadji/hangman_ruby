require 'io/console'
require 'yaml'
require_relative '../lib/Game'

$clear = "\e[2J\e[1;1H\e[?25l"
exit_command = false
current_menu = :newgame
selector = :newgame

def print_menu(s)
  print $clear
  puts "Welcome to Hangman"
  print "\n\n"
  case s
  when :newgame
    print "New Game <\n"
    print "Exit\n"
  when :exit
    print "New Game\n"
    print "Exit <\n"
  end
end

def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end

def key_to_selection
  case read_char
  when "\e[A" then return :newgame
  when "\e[B" then return :exit
  when "\r" then return :go
  end
end

def attempt_save(g)
  print $clear
  puts "Would you like to save? (y/n)"
  input = nil
  until input == 'n' || input == 'y'
    input = read_char
    case input
    when 'n'
      return false
    when 'y'
      return create_save_file(g)
    end
  end
end

def create_save_file(g)
  Dir.mkdir("saves") unless Dir.exist? "saves"

  number = 1
  while File.exists?("saves/game#{number}")
    number += 1
  end

  begin 
    File.open("saves/game#{number}" , 'w') do |f|
      f.puts g.to_yaml
    end
    return true
  rescue
    puts "Unable to save"
    return false
  end
end

def start_game(g)
  until g.game_over?
    g.start
    saved = false
    unless g.game_over?
      saved = attempt_save(g)
    end
    break if saved
  end
end


until exit_command
print_menu(current_menu)

  until selector == :go
    selector = key_to_selection

    unless selector == :go || selector == nil
      current_menu = selector
      print_menu(current_menu) 
    end
  end

if selector == :go
  case current_menu
  when :newgame
    game = Game.new
    start_game(game)
    selector = :newgame
    current_menu = :newgame
  when :exit
    print "\e[?25h"
    exit_command = true
  end
end

end
