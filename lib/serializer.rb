require 'json'
require_relative 'board'
require_relative 'special'
require_relative 'piece'
require_relative 'player'
require_relative 'computer'
require_relative 'game'

class Serializer
  def initialize(board, player, piece, special, computer, game)
    @board = board
    @player = player
    @piece = piece
    @special = special
    @computer = computer
    @game = game
  end

  # Makes path to saved games in parent directory from the current lib directory to store game state
  def save_game
    puts 'Enter a filename for your saved game:'
    file_name = gets.chomp.strip

    save_folder_path = File.expand_path('../saved_games', __dir__)
    Dir.mkdir(save_folder_path) unless Dir.exist?(save_folder_path)
    File.open(File.join(save_folder_path, "#{file_name}.json"), 'w') do |file|
      file.puts(JSON.dump({
                            chessboard: @board.chessboard,
                            display: @board.display,

                            white_pins: @piece.white_pins,
                            black_pins: @piece.black_pins,
                            white_checks: @piece.white_checks,
                            black_checks: @piece.black_checks,
                            king_white_checks: @piece.king_white_checks,
                            king_black_checks: @piece.king_black_checks,
                            black_protected: @piece.black_protected,
                            white_protected: @piece.white_protected,

                            a1_rook: @special.a1_rook,
                            h1_rook: @special.h1_rook,
                            white_king: @special.white_king,
                            a8_rook: @special.a8_rook,
                            h8_rook: @special.h8_rook,
                            black_king: @special.black_king,

                            round: @game.round,
                            selected_possible_moves: @game.selected_possible_moves,
                            notation_moves: @game.notation_moves,
                            white_attacks: @game.white_attacks,
                            black_attacks: @game.black_attacks,
                            all_white_moves: @game.all_white_moves,
                            all_black_moves: @game.all_black_moves,
                            mode: @game.mode,
                            printed_ai_move: @game.printed_ai_move
                          }))
    end
    puts 'Game saved successfully!'
    exit
  end

  # Loads instance variables
  def load_game
    puts "\nSaved files:"
    save_folder_path = File.join(File.expand_path('..', __dir__), 'saved_games')
    Dir.children(save_folder_path).each { |file| puts file.slice(0..-6) }
    puts ' '
    puts 'Enter the filename you would like to load:'

    loop do
      file_name = gets.chomp.strip
      file_path = File.join(save_folder_path, "#{file_name}.json")

      if File.exist?(file_path)
        json = JSON.load_file(file_path)
        @board.chessboard = json['chessboard']
        @board.display = json['display']

        @piece.white_pins = json['white_pins']
        @piece.black_pins = json['black_pins']
        @piece.white_checks = json['white_checks']
        @piece.black_checks = json['black_checks']
        @piece.king_white_checks = json['king_white_checks']
        @piece.king_black_checks = json['king_black_checks']
        @piece.black_protected = json['black_protected']
        @piece.white_protected = json['white_protected']
        @piece.chessboard = json['chessboard']

        @special.a1_rook = json['a1_rook']
        @special.h1_rook = json['h1_rook']
        @special.white_king = json['white_king']
        @special.a8_rook = json['a8_rook']
        @special.h8_rook = json['h8_rook']
        @special.black_king = json['black_king']
        @special.chessboard = json['chessboard']

        @game.round = json['round']
        @game.selected_possible_moves = json['selected_possible_moves']
        @game.notation_moves = json['notation_moves']
        @game.white_attacks = json['white_attacks']
        @game.black_attacks = json['black_attacks']
        @game.all_white_moves = json['all_white_moves']
        @game.all_black_moves = json['all_black_moves']
        @game.mode = json['mode']
        @game.printed_ai_move = json['printed_ai_move']
        @game.chessboard = json['chessboard']

        @computer.chessboard = json['chessboard']
        break
      else
        puts 'File not found, please enter the name of a saved file:'
      end
    end
  end
end
