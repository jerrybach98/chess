# Chess CLI Game
A command-line interface (CLI) chess game written in Ruby, offering multiplayer PVP or single-player against a computer AI.

**Live Demo: [Replit Demo](https://replit.com/@jerrybach98/...)**

## Tech Stack
- **Language:** Ruby
- **Testing:** RSpec

## How to play:
* **Modes:** Users can compete against each other or against a computer AI.
* **Move Input:** Input moves using chess notation for piece selection then destination.
* **Saving:** The game allows users to save their progress at any point by typing 'save'.
* **Castling:** King's castling is supported; players can select the king and enter the castle coordinates.

## Lessons Learned:
* **Complex CLI Game:** Building an advanced command-line game with multiple features.
* **Structured Approach:** Breaking down the game into logical steps and maintaining a structured approach.
* **Pseudocoding:** Emphasizing the importance of pseudocoding for better planning.
* **Code Organization:** Applying cumulative knowledge and experience from past projects.
* **RSpec Testing:** Implementing RSpec testing for basic unit coverage and preventing self-testing redundancy.
* **Code Reusability:** Emphasizing the importance of method chaining and code reusability.
* **ANSI Escape Codes:** Understanding how ANSI escape codes interact with the terminal.
* **ASCII Codes:** Implementing ASCII codes for converting numbers and letters on the chessboard.


## Further ehancements
**Draw Criteria:** Adding more draw criteria, such as Threefold repetition, Fifty-move rule, and detecting dead positions.
**Advanced AI:** Implementing more advanced AI with recursion and breadth-first search for min-max strategies.
**Board Flipping:** Enabling board flipping for both perspectives.
**Code Refactoring:** Reducing redundant code for black and white pieces, further modularizing the code.
**Pawn Promotion:** Enhancing pawn promotion by allowing choices beyond the default Queen.
**En Passant:** Implementing the en passant rule for a more comprehensive gameplay experience.