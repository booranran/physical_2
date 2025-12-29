import java.util.Collections;
import processing.serial.*;

void setup() {
  size(1280, 720, P3D);
  background(#fafafa);
  textureMode(NORMAL);
  
  boardImage = loadImage("board.png"); // data 폴더에 이미지 넣어야 함


  textAlign(CENTER, CENTER);
  textSize(30);

  //connectArduino();

  yesButton = new Button(150, 250, 100, 40, "YES", -1);
  noButton = new Button(350, 250, 100, 40, "NO", -1);
  
  rollButton = new Button(width/2 - 100, 600, 200, 60, "ROLL", -1);
  initDice();

  players = new Player[2];
  players[0] = new Player(1, "Player 1", 800000);
  players[1] = new Player(2, "Player 2", 400000);

  p = players[0];

  //font = loadFont("GmarketSansMedium.vlw");
  font = createFont("GmarketSansMedium.otf", 48); // 48은 폰트 크기
  textFont(font);

  uidNameMap.put("41103480", new RfidInfo("TAG_MARRY_001", 0));
  uidNameMap.put("95363480", new RfidInfo ("TAG_JOB_001", 1));
  uidNameMap.put("1E7b3480", new RfidInfo("TAG_JOB_002", 2));
  uidNameMap.put("0A493680", new RfidInfo("TAG_INVEST_001", 3));
  uidNameMap.put("E3563680", new RfidInfo("TAG_INVEST_002", 4));
  uidNameMap.put("D6793480", new RfidInfo("TAG_HOME_001", 5));
  uidNameMap.put("7EF63380", new RfidInfo ("TAG_HOME_002", 6));
  uidNameMap.put("719B3580", new RfidInfo ("TAG_RANDOM_EVENT_001", 7));
  uidNameMap.put("83113580", new RfidInfo ("TAG_RANDOM_EVENT_002", 8));
  uidNameMap.put("9A4B3480", new RfidInfo("TAG_RANDOM_EVENT_003", 9));
  uidNameMap.put("FD143480", new RfidInfo ("TAG_GOAL", 10));
  uidNameMap.put("D9583680", new RfidInfo("LISBON", 11));
  uidNameMap.put("9B553680", new RfidInfo("MADRID", 12));
  uidNameMap.put("BA6C3680", new RfidInfo("HAWAII", 13));
  uidNameMap.put("9E483480", new RfidInfo("SYDNEY", 14));
  uidNameMap.put("0B343680", new RfidInfo("NEWYORK", 15));
  uidNameMap.put("E23F3580", new RfidInfo("TOKYO", 16));
  uidNameMap.put("E9253680", new RfidInfo("PARIS", 17));
  uidNameMap.put("0B653680", new RfidInfo("ROME", 18));
  uidNameMap.put("D3103580", new RfidInfo("SEOUL", 19));
  uidNameMap.put("12654F05", new RfidInfo("SALARY", 20));
  uidNameMap.put("BORAN5", new RfidInfo("ISLAND", 21));
  uidNameMap.put("BORAN6", new RfidInfo("EVENT", 22));
  uidNameMap.put("BORAN7", new RfidInfo("SPACE", 23));
  
  for (RfidInfo info : uidNameMap.values()) {
    if (info.boardIndex >= 0 && info.boardIndex < 24) {
      boardMap[info.boardIndex] = info.name;
    }
  }
  

  if (showGoalPopup) {
    displayGoalResult();
  }

  showDice = false;
  showGoalPopup = false;
  showEventPopup = false;
}

void draw() {

  background(255);

  // 기존 그리기 코드

  if (defalutPopup) {
    textAlign(CENTER);
    fill(0);
    textSize(20);
    text(p.name + "의 현재 자산: " + p.money + "원", width/2, 100);
    
    if (!showDice && !showMarriagePopup && !showHiredPopup && !showInvestPopup && !showHomePopup && !showGoalPopup) {
       rollButton.display();
    }
  }

  if (showMarriagePopup) {
    fill(230);
    rect(100, 150, 400, 150, 10);
    fill(0);
    text("결혼하시겠습니까?", width/2, 190);
    yesButton.display();
    noButton.display();
    defalutPopup = false;
    
    if(millis() - resultShowTime > 2000){
      resultShowTime = -1;
      defalutPopup = true;
      nextTurn();
    }

  }

  if (showHiredPopup) {
    if (jobButtons.isEmpty()) {
      initJobButtons();
    }
    fill(230);
    rect(100, 150, 400, 150, 10);
    fill(0);
    drawJobButtons();
  }

  if (showInvestPopup) {
    fill(230);
    rect(100, 150, 400, 150, 10);
    fill(0);
    text("투자 하시겠습니까?", width/2, 190);
    yesButton.display();
    noButton.display();
  }

  if (isEnteringInvestment) {
    fill(230);
    rect(100, 150, 400, 150, 10);
    fill(0);
    text("투자금 입력: " + investInput, width/2, 150);
  }

  if (showHomePopup) {
    fill(230);
    rect(100, 150, 400, 150, 10);
    fill(0);
    text("부동산을 구매 하시겠습니까?", width/2, 190);
    yesButton.display();
    noButton.display();
  }

  if (isSelectingHome) {
    if (homeButtons.isEmpty()) {
      initHomeButtons();
    }
    fill(230);
    rect(100, 150, 400, 150, 10);
    fill(0);
    for (Button btn : homeButtons) {
      btn.display();
    }
  }

  if (showEventPopup) {
    triggerRandomEvent();
    showEventPopup = false;
  }

  if (showGoalPopup) {
    fill(0);
    background(255);
    for (int i = 0; i <= goalMsgIndex && i < goalMessages.size(); i++) {
      text(goalMessages.get(i), width/2, 100 + i * 30);
    }

    if (millis() - goalMsgStartTime > 1000) {
      goalMsgIndex++;
      goalMsgStartTime = millis();
    }
  }

  if (!resultMessage.equals("") && millis() - resultShowTime < 2000) {
    text(resultMessage, width/2, 250);
  }
  
  if (showDice) {
    drawDiceOverlay();
    println("주사위 그리는 중... 프레임: " + frameCount); // 디버깅용
  }
  
}
