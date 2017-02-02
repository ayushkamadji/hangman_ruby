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
    print "Load Game\n"
    print "Exit\n"
  when :loadgame
    print "New Game \n"
    print "Load Game <\n"
    print "Exit\n"
  when :exit
    print "New Game\n"
    print "Load Game\n"
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

def key_to_selection(cur_menu)
  case read_char
  when "\e[A" then return move_up(cur_menu)
  when "\e[B" then return move_down(cur_menu)
  when "\r" then return :go
  end
end

def move_up(cur_menu)
  case cur_menu
  when :newgame then return :newgame
  when :loadgame then return :newgame
  when :exit then return :loadgame
  end
end

def move_down(cur_menu)
  case cur_menu
  when :newgame then return :loadgame
  when :loadgame then return :exit
  when :exit then return :exit
  end
end

def attempt_save(g)
  print $clear
  puts "Exiting. Would you like to save? (y/n or x to cancel)"
  input = nil
  until input == 'n' || input == 'y' || input == 'x'
    input = read_char
    case input
    when 'x'
      return false
    when 'n'
      return true
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
    back_to_menu = false
    unless g.game_over?
      back_to_menu = attempt_save(g)
    end
    break if back_to_menu 
  end
end

def loadgame
  file = select_file
  game = YAML.load(file)
  file.close
  return game
end

def select_file
  save_dir = File.join(Dir.pwd, "saves")
  entries = Dir.entries(save_dir)
  entries.select! do |entry|
    entry =~ /game\d*/
  end

  print $clear + "\e[?25h"
  entries.each { |entry| puts entry }
  puts "Type in the savefile name :"

  sf_name = File.join(save_dir, gets.strip)
  return File.open(sf_name)
end

until exit_command
print_menu(current_menu)

  until selector == :go
    selector = key_to_selection(current_menu)

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
  when :loadgame
    game = loadgame
    start_game(game)
    selector = :newgame
    current_menu = :newgame
  when :exit
    print "\e[?25h"
    exit_command = true
  end
end

end
