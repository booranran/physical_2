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

void initDice() {
  for (int i=0; i<6; i++) {
    // data 폴더에 dice1.png ~ dice6.png가 있어야 합니다.
    diceTexture[i] = loadImage("dice"+(i+1)+".png");
  }
  // 각 숫자에 맞는 회전 각도 설정
  targetAngles[0] = new PVector(-HALF_PI, 0); // 1
  targetAngles[1] = new PVector(0, -HALF_PI); // 2
  targetAngles[2] = new PVector(HALF_PI, 0);  // 3
  targetAngles[3] = new PVector(0, HALF_PI);  // 4
  targetAngles[4] = new PVector(0, 0);        // 5
  targetAngles[5] = new PVector(PI, 0);       // 6
}

void startRoll() {
  if (rolling) return;
  rolling = true;
  rollEnded = false;
  fallY = -200;
  velocityY = 0;

  // 초기 랜덤 회전
  angleX = random(PI);
  angleY = random(PI);
  currentAngle.set(0, 0);

  showDice = true; // 주사위 보이게 설정
}

void drawDiceOverlay() {
  pushStyle();
  pushMatrix();
  translate(messageX, messageY, 0); // 화면 중앙으로 이동
  ambientLight(150, 150, 150);
  directionalLight(255, 255, 255, -0.5, 0.5, -1);

  // 회전 적용
  if (rolling) {
    rotateX(angleX);
    rotateY(angleY);
  } else {
    rotateX(currentAngle.x);
    rotateY(currentAngle.y);
  }

  noStroke();
  drawTextureCube(50); // 큐브 그리기
  popMatrix();
  popStyle();

  handleDicePhysics(); // 물리 계산 업데이트
}

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
      //int nextPosition = p.position + diceNumber;

      //if (nextPosition >= 24) {
      //  p.lap++;
      //  println(">>" + p.lap + "바퀴째 돌파!");
      //}
      //if (p.lap >= 2) {
      //  p.position = 0; // 골인 지점(Start/Goal)에 멈춤
      //  // (여기서 골인 팝업 등은 functions.pde의 processBoardIndex에서 처리됨)
      //} else {
      //  // 4. 아직 완주 안 했으면 -> 나머지 연산(%)으로 0~23 사이 위치 유지
      //  p.position = nextPosition % 24;
      //}
      
      movePlayer(diceNumber);

      println(p.name + " 위치 이동 -> " + p.position + " (" + boardMap[p.position] + ")");

      systemStatus = "주사위 " + diceNumber + " 전송 완료";

      if (myClient.active()) {
        myClient.write(diceNumber); // 숫자 그대로 전송 (예: 3)
        println("아두이노로 " + diceNumber + " 전송 완료!");
      } else {
        println("아두이노 연결 안 됨, 전송 실패");
      }
    }
  }

  if (rollEnded && showDice) {
    if (!diceEndTimerStarted) {
      diceEndTime = millis();
      diceEndTimerStarted = true;
    }

    if (millis() - diceEndTime > 1500) {
      showDice = false;
      diceEndTimerStarted = false;  // 다음 주사위 굴림을 위해 초기화

      println(">> 이동중");

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
