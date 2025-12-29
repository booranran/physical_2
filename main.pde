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

  yesButton = new Button(730, 400, 100, 40, "YES", -1);
  noButton = new Button(870, 400, 100, 40, "NO", -1);
  rollButton = new Button(60, 600, 200, 60, "ROLL", -1);

  messageX = 800;
  messageY = 360;

  initDice();

  players = new Player[2];
  players[0] = new Player(1, "Player 1", 800000);
  players[1] = new Player(2, "Player 2", 800000);

  p = players[0];

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
  initBoardPositions();


  if (showGoalPopup) {
    displayGoalResult();
  }

  showDice = false;
  showGoalPopup = false;
  showEventPopup = false;
}

void draw() {

  background(255);

  if (boardImage != null) {
    // initBoardPositions에서 계산한 boardW, boardH, startX, startY 값과 동일하게
    int sidebarWidth = 320;
    int boardW = 820;
    int boardH = 620;
    int startX = sidebarWidth + (width - sidebarWidth - boardW) / 2;
    int startY = (height - boardH) / 2;

    image(boardImage, startX, startY, boardW, boardH);
  }

  // ★ [추가] 그 위에 말 그리기


  // 기존 그리기 코드

  // [main.pde]의 draw() 내부 수정

  // 1. 기본 상태 (자산 표시 & 롤 버튼)
  if (defalutPopup) {
    // ------------------------------------------------
    // [플레이어 상태창 UI 그리기]
    // ------------------------------------------------
    pushStyle();

    // 2) 플레이어 이름 (헤더)
    fill(50, 50, 150);
    textSize(28);
    textAlign(CENTER, TOP);
    text(p.name, 160, 40); // 박스 상단 중앙

    // 3) 구분선
    stroke(150);
    strokeWeight(1);
    line(30, 80, 290, 80);

    // 4) 상세 정보 (왼쪽 정렬)
    fill(0);
    textSize(18);
    textAlign(LEFT, TOP);

    int startY = 100;
    int gap = 30;

    // 자산 정보
    text("💰 자산: " + nfc(p.money) + "원", 40, startY);

    // 직업 정보
    String jobText = p.isHired ? p.currentJob : "무직 (취준생)";
    text("💼 직업: " + jobText, 40, startY + gap);

    // 월급 정보
    if (p.isHired) {
      text("💵 월급: " + nfc(p.currentSalary) + "원", 40, startY + gap*2);
    }

    // 결혼 여부
    String marryText = p.isMarried ? "기혼 💍" : "미혼";
    text("❤️ 상태: " + marryText, 40, startY + gap*3);

    popStyle();
    // ------------------------------------------------

    // 롤 버튼 표시
    if (!showDice && !showMarriagePopup && !showHiredPopup && !showInvestPopup && !showHomePopup && !showGoalPopup) {
      rollButton.display();
    }
  }

  // 2. 결혼 팝업
  if (showMarriagePopup) {

    fill(0);
    text("결혼하시겠습니까?", messageX, messageY); // 텍스트 x좌표 messageX
    yesButton.display();
    noButton.display();
    defalutPopup = false;

    if (millis() - resultShowTime > 2000) {
      resultShowTime = -1;
      defalutPopup = true;
      nextTurn();
    }
  }

  // 3. 직업(취업) 팝업
  if (showHiredPopup) {
    if (jobButtons.isEmpty()) initJobButtons();
    fill(0);
    drawJobButtons(); // (주의: 버튼 위치도 initJobButtons에서 바꿔야 함)
  }

  // 4. 투자 팝업
  if (showInvestPopup) {
    fill(0);
    text("투자 하시겠습니까?", messageX, messageY);
    yesButton.display();
    noButton.display();
  }

  // 5. 투자금 입력창
  if (isEnteringInvestment) {

    fill(0);
    text("투자금 입력: " + investInput, messageX, messageY);
  }

  // 6. 부동산 구매 팝업
  if (showHomePopup) {

    fill(0);
    text("부동산을 구매하시겠습니까?", messageX, messageY);
    yesButton.display();
    noButton.display();
  }

  // 7. 부동산 선택 창
  if (isSelectingHome) {
    if (homeButtons.isEmpty()) initHomeButtons();

    fill(0);
    for (Button btn : homeButtons) btn.display();
  }

  // 8. 랜덤 이벤트
  if (showEventPopup) {
    triggerRandomEvent();
    showEventPopup = false;
  }

  // 9. 목표(정산) 화면
  if (showGoalPopup) {
    fill(255);
    rect(0, 0, 320, height); // 왼쪽 사이드바만 하얗게 덮기
    fill(0);
    for (int i = 0; i <= goalMsgIndex && i < goalMessages.size(); i++) {
      text(goalMessages.get(i), messageX, 100 + i * 30); // x좌표 160
    }
    if (millis() - goalMsgStartTime > 1000) {
      goalMsgIndex++;
      goalMsgStartTime = millis();
    }
  }

  // 10. 결과 메시지 (하단)
  if (!resultMessage.equals("") && millis() - resultShowTime < 2000) {
    fill(0); // 글씨 색상 검정
    text(resultMessage, messageX, 400); // 위치를 조금 더 아래(400)로 내림
  }

  if (showDice) {
    drawDiceOverlay();
  }
}
