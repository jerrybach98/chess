# General steps / Brainstorm
  # focus on single responsibility
  # Two players can play against each other or basic AI
  # Write tests for anything typed into command line repeatedly
  # Player 1 white piece goes first

# Psuedo Code:
# Class Game
  # Make game saveable by serializing with JSON
  # announce 
    # when king is in check
  # loop game functions

# Class Board
  # set up as array (8X8)
  # Figure out how to display a visual chess board to console
    # 1-8 vertially or a-h horizontally
  # display board function
  # Populate board with unicode characters as chess pieces (black, white)

# Class Piece
  # Don't let pieces go out of bounds (stay within array)
  # A friendly piece can't replace a friendly piece
  # Pieces can be placed over enemy pieces 
  # when pawn goes to opposite side prompt user
  # Basic Legal moves
  # multiply black moves by negative 1
  # only knight can go over pieces 
  # @Board [row] [Column]
    # Pawn
      # can move 1 row [x+1][y]
      # 2 in beginning
      # attack diagonally with [x+1][y+1] [x+1][y-1]
    # Knight
      # possible_moves = [[2, 1], [1, 2], [2, -1], [1, -2], [-2, 1], [-1, 2], [-2, -1], [-1, -2]]
    # Bishop
      # Diagonal lines: increments of [1,1] [-1,-1] [-1,1] [1, -1] or range?
    # Rook
      # move up and down [x+1..7][y+1..7]
      # Castling?
    # Queen
      # Combine the moves of rook and bishop
    # King
      # If king is in pathway of a piece declare check
      # If there is no path king can move from check, declare checkmate
      # Don't let king move into path of enemy piece
      # any direction by 1

# Class Players
  # get inputs / handle invalid 
  # error message (not possible moves)
    # Out of bounds, can't move over friendly, moving king into check
  # select piece function
  # Convert A-h to array column numbers
  # -1 on row numbers to match array
  # Convert input to lowercase / case non sensitive
  # Switch D1(column + row) to 1D as board is represented as @Board[row][Column]

# Class Computer
  # build simple AI (random legal move, random piece, random location)