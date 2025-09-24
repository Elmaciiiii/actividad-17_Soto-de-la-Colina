int[][] board = new int[3][3]; 
boolean xTurn = true; 
boolean gameEnded = false; 
String winner = ""; 

void setup() { 
  size(300, 360); 
  resetGame();
  textAlign(CENTER, CENTER);
} 
 
void draw() { 
  background(255); 
  drawBoard(); 
  if (!gameEnded) { 
    drawTurnInfo(); // se muestra turno solo mientras no terminó
  }
  checkWin();
  
  if (gameEnded) {
    drawModal(); // modal al terminar
  }
} 

// Dibujar tablero y fichas
void drawBoard() { 
  stroke(0); 
  strokeWeight(4);
  for (int i = 1; i < 3; i++) { 
    line(i * 100, 0, i * 100, 300); 
    line(0, i * 100, 300, i * 100); 
  } 
  for (int i = 0; i < 3; i++) { 
    for (int j = 0; j < 3; j++) { 
      if (board[i][j] == 1) { 
        drawX(i, j); 
      } else if (board[i][j] == 2) { 
        drawO(i, j); 
      } 
    } 
  } 
} 
 
void drawX(int i, int j) { 
  stroke(200, 0, 0); 
  strokeWeight(4);
  line(i * 100 + 15, j * 100 + 15, (i + 1) * 100 - 15, (j + 1) * 100 - 15); 
  line(i * 100 + 15, (j + 1) * 100 - 15, (i + 1) * 100 - 15, j * 100 + 15); 
} 
 
void drawO(int i, int j) { 
  noFill();
  stroke(0, 0, 200); 
  strokeWeight(4);
  ellipse(i * 100 + 50, j * 100 + 50, 70, 70); 
} 

// Detectar clics
void mousePressed() { 
  if (!gameEnded && mouseY < 300) { 
    int i = mouseX / 100; 
    int j = mouseY / 100; 
    if (board[i][j] == 0) { 
      board[i][j] = xTurn ? 1 : 2; 
      xTurn = !xTurn; 
    } 
  } 
  
  // Si hay modal abierto, chequear botón reinicio
  if (gameEnded && mouseX > 100 && mouseX < 200 && mouseY > 230 && mouseY < 270) {
    resetGame();
  }
} 

// Verificar ganador o empate
void checkWin() { 
  for (int i = 0; i < 3; i++) { 
    if (board[i][0] != 0 && board[i][0] == board[i][1] && board[i][1] == board[i][2]) { 
      gameEnded = true; 
      winner = board[i][0] == 1 ? "Ganó X" : "Ganó O"; 
    } 
    if (board[0][i] != 0 && board[0][i] == board[1][i] && board[1][i] == board[2][i]) { 
      gameEnded = true; 
      winner = board[0][i] == 1 ? "Ganó X" : "Ganó O"; 
    } 
  } 
  if (board[0][0] != 0 && board[0][0] == board[1][1] && board[1][1] == board[2][2]) { 
    gameEnded = true; 
    winner = board[0][0] == 1 ? "Ganó X" : "Ganó O"; 
  } 
  if (board[0][2] != 0 && board[0][2] == board[1][1] && board[1][1] == board[2][0]) { 
    gameEnded = true; 
    winner = board[0][2] == 1 ? "Ganó X" : "Ganó O"; 
  } 
  
  // Ver empate
  boolean full = true; 
  for (int i = 0; i < 3; i++) { 
    for (int j = 0; j < 3; j++) { 
      if (board[i][j] == 0) full = false; 
    } 
  } 
  if (full && !gameEnded) { 
    gameEnded = true; 
    winner = "Empate"; 
  } 
} 

// Mostrar turno (centrado con símbolo al lado)
void drawTurnInfo() {
  noStroke();               // sin borde
  fill(245);
  rect(0, 300, 300, 60);
  
  textSize(20);
  textAlign(CENTER, CENTER);
  
  fill(0);
  text("Turno:", 130, 330);
  
  if (xTurn) {
    fill(200, 0, 0);  // rojo para X
    text("X", 170, 330);
  } else {
    fill(0, 0, 200);  // azul para O
    text("O", 170, 330);
  }
}

// Ventana modal al terminar
void drawModal() {
  // Fondo semitransparente
  fill(0, 180);
  noStroke();
  rect(0, 0, width, height);
  
  // Caja central
  fill(255);
  stroke(0);
  strokeWeight(3);
  rect(40, 100, 220, 200, 20);
  
  // Texto de ganador
  textSize(24);
  textAlign(CENTER, CENTER);
  if (winner.equals("Ganó X")) {
    fill(200, 0, 0); // rojo si gana X
    text(winner, 150, 160);
  } else if (winner.equals("Ganó O")) {
    fill(0, 0, 200); // azul si gana O
    text(winner, 150, 160);
  } else {
    fill(0); // negro para empate
    text(winner, 150, 160);
  }
  
  // Botón Reiniciar
  if (mouseX > 100 && mouseX < 200 && mouseY > 230 && mouseY < 270) {
    fill(150, 0, 0); // hover más oscuro
  } else {
    fill(200, 0, 0);
  }
  rect(100, 230, 100, 40, 10);
  fill(255);
  textSize(16);
  text("Reiniciar", 150, 250);
}

// Reiniciar partida
void resetGame() {
  for (int i = 0; i < 3; i++) { 
    for (int j = 0; j < 3; j++) { 
      board[i][j] = 0; 
    } 
  }
  xTurn = true;
  gameEnded = false;
  winner = "";
}
