float angleX = 0;
float angleY = 0;
float fallY = -150;
float velocityY = 0;
boolean rolling = false;
int rollFrameCount = 0;
int diceNumber = 1;
boolean rollEnded = true;  // 멈춘 상태 플래그
int diceEndTime = 0;

PVector[] targetAngles = new PVector[6];
PVector currentAngle = new PVector(0, 0);
PVector targetAngle = new PVector(0, 0);
float easing = 0.1;

PImage[] diceTexture = new PImage[6];
boolean diceEndTimerStarted = false;  // 딜레이 타이머 시작 플래그

void handleDicePhysics() {
  if (rolling) {
    if (fallY < 0 || velocityY > 1) {
      velocityY += 1.0;
      fallY += velocityY;
      if (fallY > 0) {
        fallY = 0;
        velocityY *= -0.5;
        rollFrameCount--;
      }
      angleX += velocityY * 0.03;
      angleY += velocityY * 0.03;
      currentAngle = targetAngles[5];
    } else {
      rolling = false;
      rollEnded = false;
      diceNumber = int(random(1, 7));
      targetAngle = targetAngles[diceNumber - 1];
    }
  }

  if (!rolling && !rollEnded) {
    currentAngle.x += (targetAngle.x - currentAngle.x) * easing;
    currentAngle.y += (targetAngle.y - currentAngle.y) * easing;

    if (abs(targetAngle.x - currentAngle.x) < 0.01 && abs(targetAngle.y - currentAngle.y) < 0.01) {
      currentAngle.set(targetAngle);
      rollEnded = true;
      println("주사위 결과: " + diceNumber);
      myPort.write(diceNumber + "\n");
      systemStatus = "주사위 " + diceNumber + " 전송 완료";
    }
  }

  if (rollEnded && showDice) {
    if (!diceEndTimerStarted) {
      diceEndTime = millis();
      diceEndTimerStarted = false;
    }
    
    if (millis() - diceEndTime > 3000) {
      showDice = true;
      diceEndTimerStarted = false;  // 다음 주사위 굴림을 위해 초기화
    }
  }
}

void drawTextureCube(float s) {

  //3: 왼쪽 0: 위
  // 앞면 (z+)
  beginShape(QUADS);
  texture(diceTexture[4]); //
  vertex(-s, -s, s, 0, 0);
  vertex( s, -s, s, 1, 0);
  vertex( s, s, s, 1, 1);
  vertex(-s, s, s, 0, 1);
  endShape();

  // 뒷면 (z-)
  beginShape(QUADS);
  texture(diceTexture[5]); // 뒤
  vertex( s, -s, -s, 0, 0);
  vertex(-s, -s, -s, 1, 0);
  vertex(-s, s, -s, 1, 1);
  vertex( s, s, -s, 0, 1);
  endShape();

  // 오른쪽 (x+)
  beginShape(QUADS);
  texture(diceTexture[1]); // 오른쪽
  vertex( s, -s, s, 0, 0);
  vertex( s, -s, -s, 1, 0);
  vertex( s, s, -s, 1, 1);
  vertex( s, s, s, 0, 1);
  endShape();

  // 왼쪽 (x-)
  beginShape(QUADS);
  texture(diceTexture[3]); // 왼쪽
  vertex(-s, -s, -s, 0, 0);
  vertex(-s, -s, s, 1, 0);
  vertex(-s, s, s, 1, 1);
  vertex(-s, s, -s, 0, 1);
  endShape();

  beginShape(QUADS);
  texture(diceTexture[0]); // 위
  vertex(-s, -s, -s, 0, 0);
  vertex( s, -s, -s, 1, 0);
  vertex( s, -s, s, 1, 1);
  vertex(-s, -s, s, 0, 1);
  endShape();

  // 아랫면 (y+)
  beginShape(QUADS);
  texture(diceTexture[2]); // 아
  vertex(-s, s, s, 0, 0);
  vertex( s, s, s, 1, 0);
  vertex( s, s, -s, 1, 1);
  vertex(-s, s, -s, 0, 1);
  endShape();
}
