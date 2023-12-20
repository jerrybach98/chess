require 'json'
require_relative 'board'
require_relative 'special'
require_relative 'piece'
require_relative 'player'
require_relative 'computer'
require_relative 'game'
require_relative 'serializer'

board = Board.new
special = Special.new(board)
piece = Piece.new(board, special)
player = Player.new
computer = Computer.new(board, piece)
game = Game.new(board, player, piece, special, computer)
serializer = Serializer.new(board, player, piece, special, computer, game)
# Set_instance gives classes access to the serializer methods to save the game
player.set_instance(serializer)
game.set_instance(serializer)
# game.play_game

# make common chess openings to save
# edit Readme
