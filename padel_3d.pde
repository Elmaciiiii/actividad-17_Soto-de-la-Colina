// Paddle 3D en Processing con menú, aceleración, pausa, goles y saque correcto 

PVector ballPos, ballSpeed;
float ballRadius = 10;

PVector paddle1Pos, paddle2Pos;
float paddleWidth = 10, paddleHeight = 60, paddleSpeed = 5;

int score1 = 0, score2 = 0;
int maxScore = 10;       // goles para ganar
boolean gameOver = false;

// Estados del juego
boolean wPressed = false, sPressed = false, upPressed = false, downPressed = false;
boolean paused = true;   // arranca pausado
boolean inMenu = true;   // arranca en menú
int pauseFrames = 0;

// Velocidad máxima y aceleración gradual
float maxSpeed = 14;        
float speedIncreaseFactor = 1.001; 

// Quién fue el último que metió gol (para saque)
int lastScorer = 0; // 0 ninguno, 1 jugador 1, 2 jugador 2

// Botón del menú
float btnX, btnY, btnW = 220, btnH = 60;

void setup() {
  size(800, 400, P3D);
  paddle1Pos = new PVector(paddleWidth/2 + 10, height/2, 0);
  paddle2Pos = new PVector(width - paddleWidth/2 - 10, height/2, 0);
  resetBall();

  btnX = width/2;
  btnY = height/2;
}

void draw() {
  background(0);
  lights();
  pointLight(255, 255, 255, width/2, height/2, 300);

  if (inMenu) {
    showMenu();
    return;
  }

  // 🔧 Manejo de pausa
  if (paused && !gameOver) {
    if (pauseFrames > 0) {
      pauseFrames--;
      if (pauseFrames <= 0) paused = false;
    }
  }

  // Mover paletas
  if (wPressed) paddle1Pos.y -= paddleSpeed;
  if (sPressed) paddle1Pos.y += paddleSpeed;
  if (upPressed) paddle2Pos.y -= paddleSpeed;
  if (downPressed) paddle2Pos.y += paddleSpeed;

  // Limitar dentro de pantalla
  paddle1Pos.y = constrain(paddle1Pos.y, paddleHeight/2, height - paddleHeight/2);
  paddle2Pos.y = constrain(paddle2Pos.y, paddleHeight/2, height - paddleHeight/2);

  if (!paused && !gameOver) {
    ballPos.add(ballSpeed);

    // 🔥 acelerar de a poco
    ballSpeed.mult(speedIncreaseFactor);

    // Limitar velocidad máxima
    ballSpeed.x = constrain(ballSpeed.x, -maxSpeed, maxSpeed);
    ballSpeed.y = constrain(ballSpeed.y, -maxSpeed, maxSpeed);

    // Rebotes arriba/abajo
    if (ballPos.y - ballRadius < 0) {
      ballPos.y = ballRadius;
      ballSpeed.y *= -1;
    }
    if (ballPos.y + ballRadius > height) {
      ballPos.y = height - ballRadius;
      ballSpeed.y *= -1;
    }

    // Colisiones con paletas
    checkPaddleCollision();
  }

  // Puntos
  if (!gameOver) {
    if (ballPos.x + ballRadius < 0) { // punto J2
      score2++;
      lastScorer = 2;
      if (score2 >= maxScore) {
        gameOver = true;
        paused = true;
      } else {
        resetBallAndPause();
      }
    } else if (ballPos.x - ballRadius > width) { // punto J1
      score1++;
      lastScorer = 1;
      if (score1 >= maxScore) {
        gameOver = true;
        paused = true;
      } else {
        resetBallAndPause();
      }
    }
  }

  // Dibujar pelota
  pushMatrix();
  translate(ballPos.x, ballPos.y, ballPos.z);
  noStroke();
  fill(0, 200, 255);
  sphere(ballRadius);
  popMatrix();

  // Dibujar paletas
  drawPaddle(paddle1Pos, color(200, 0, 0));
  drawPaddle(paddle2Pos, color(0, 200, 0));

  // Mostrar marcador
  showScoreAndHints();
  showStartOrGameOver();
}

// --------------------------------------
// Funciones auxiliares
// --------------------------------------

void drawPaddle(PVector pos, int c) {
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  fill(c);
  noStroke();
  box(paddleWidth, paddleHeight, 20);
  popMatrix();
}

void checkPaddleCollision() {
  checkSinglePaddleCollision(paddle1Pos, true);
  checkSinglePaddleCollision(paddle2Pos, false);
}

void checkSinglePaddleCollision(PVector paddlePos, boolean isLeft) {
  float left = paddlePos.x - paddleWidth/2;
  float right = paddlePos.x + paddleWidth/2;
  float top = paddlePos.y - paddleHeight/2;
  float bottom = paddlePos.y + paddleHeight/2;

  float closestX = constrain(ballPos.x, left, right);
  float closestY = constrain(ballPos.y, top, bottom);

  float dx = ballPos.x - closestX;
  float dy = ballPos.y - closestY;

  if (dx*dx + dy*dy <= ballRadius*ballRadius) {
    if ((isLeft && ballSpeed.x < 0) || (!isLeft && ballSpeed.x > 0)) {
      float relativeHit = (ballPos.y - paddlePos.y) / (paddleHeight/2); 
      float angleFactor = 3.0; 
      ballSpeed.y += relativeHit * angleFactor;
      ballSpeed.x *= -1.05; // rebote + leve aceleración

      if (isLeft) {
        ballPos.x = paddlePos.x + paddleWidth/2 + ballRadius + 0.1;
      } else {
        ballPos.x = paddlePos.x - paddleWidth/2 - ballRadius - 0.1;
      }
    }
  }
}

void resetBall() {
  ballPos = new PVector(width/2, height/2, 0);

  float sx = random(2.5, 4);
  float sy = random(1.5, 3) * (random(1) > 0.5 ? 1 : -1);

  if (lastScorer == 1) {
    sx = -sx; // si metió gol J1, saca J2 (pelota a la izquierda)
  } else if (lastScorer == 2) {
    sx = sx;  // si metió gol J2, saca J1 (pelota a la derecha)
  } else {
    sx = (random(1) > 0.5 ? sx : -sx); // primer saque aleatorio
  }

  ballSpeed = new PVector(sx, sy, 0);
}

void resetBallAndPause() {
  resetBall();
  paused = true;
  pauseFrames = 45;
}

void showScoreAndHints() {
  fill(255);
  textSize(20);
  textAlign(CENTER, TOP);
  text("Jugador 1: " + score1 + "   |   Jugador 2: " + score2, width/2, 8);

  textSize(14);
  textAlign(CENTER, BOTTOM);
  float hintY = height - 8;
  text("Jugador 1: W / S    |    Jugador 2: ↑ / ↓    |    R: reiniciar  •  Espacio: pausa/continuar", width/2, hintY);
}

void showStartOrGameOver() {
  fill(255, 200, 0);
  textAlign(CENTER, CENTER);
  textSize(26);
  if (gameOver) {
    String winner = score1 >= maxScore ? "Jugador 1" : "Jugador 2";
    text("🏆 " + winner + " ganó!", width/2, height/2 - 20);
    textSize(16);
    text("Presiona ESPACIO para reiniciar", width/2, height/2 + 20);
  }
}

// 🟡 Menú inicial (solo botón)
void showMenu() {
  rectMode(CENTER);
  fill(0, 200, 255);
  rect(btnX, btnY, btnW, btnH, 12);

  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Comenzar", btnX, btnY);
}

// Manejo de teclas
void keyPressed() {
  if (inMenu) {
    if (key == ' ') {
      startGame();
    }
    return;
  }

  if (key == 'w' || key == 'W') wPressed = true;
  if (key == 's' || key == 'S') sPressed = true;
  if (keyCode == UP) upPressed = true;
  if (keyCode == DOWN) downPressed = true;

  if (key == 'r' || key == 'R') {
    score1 = 0;
    score2 = 0;
    gameOver = false;
    resetBallAndPause();
  }

  if (key == ' ') {
    if (gameOver) {
      // Reiniciar si terminó
      score1 = 0;
      score2 = 0;
      gameOver = false;
      resetBallAndPause();
    } else {
      // Alternar pausa si está en juego
      paused = !paused;
    }
  }
}

void keyReleased() {
  if (key == 'w' || key == 'W') wPressed = false;
  if (key == 's' || key == 'S') sPressed = false;
  if (keyCode == UP) upPressed = false;
  if (keyCode == DOWN) downPressed = false;
}

// Mouse para botón de inicio
void mousePressed() {
  if (inMenu) {
    if (mouseX > btnX - btnW/2 && mouseX < btnX + btnW/2 &&
        mouseY > btnY - btnH/2 && mouseY < btnY + btnH/2) {
      startGame();
    }
  }
}

void startGame() {
  inMenu = false;
  score1 = 0;
  score2 = 0;
  gameOver = false;
  lastScorer = 0;
  resetBallAndPause();
}
