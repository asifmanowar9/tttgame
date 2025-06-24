class Game {
  List<List<String>> board;
  String currentPlayer;
  String winner;
  bool gameOver;

  Game() 
    : board = List.generate(3, (_) => List.filled(3, '')),
      currentPlayer = 'X',
      winner = '',
      gameOver = false;

  bool makeMove(int row, int col) {
    if (board[row][col] != '' || gameOver) {
      return false;
    }

    board[row][col] = currentPlayer;
    
    // Check for winner
    if (checkWinner(currentPlayer)) {
      winner = currentPlayer;
      gameOver = true;
      return true;
    }
    
    // Check for draw
    if (isBoardFull()) {
      gameOver = true;
      winner = 'Draw';
      return true;
    }
    
    // Switch player
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    return true;
  }

  bool checkWinner(String player) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == player && board[i][1] == player && board[i][2] == player) {
        return true;
      }
    }
    
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] == player && board[1][i] == player && board[2][i] == player) {
        return true;
      }
    }
    
    // Check diagonals
    if (board[0][0] == player && board[1][1] == player && board[2][2] == player) {
      return true;
    }
    if (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
      return true;
    }
    
    return false;
  }

  bool isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell == '') {
          return false;
        }
      }
    }
    return true;
  }

  void reset() {
    board = List.generate(3, (_) => List.filled(3, ''));
    currentPlayer = 'X';
    winner = '';
    gameOver = false;
  }
}