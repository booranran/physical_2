import java.util.Collections;
import processing.net.*;


void setup() {
  size(1280, 720, P3D);
  background(#fafafa);
  textureMode(NORMAL);

  myClient = new Client(this, "172.20.10.2", 8888);
  boardImage = loadImage("board.png"); // data 폴더에 이미지 넣어야 함

  textAlign(CENTER, CENTER);
  textSize(30);

  //connectArduino();

  yesButton = new Button(690, 400, 100, 40, "YES", -1);
  noButton = new Button(810, 400, 100, 40, "NO", -1);
  rollButton = new Button(60, 600, 200, 60, "ROLL", -1);

  messageX = 800;
  messageY = 360;

  initDice();

  players = new Player[2];
  players[0] = new Player(1, "Player 1", 800000);
  players[1] = new Player(2, "Player 2", 8000);

  p = players[0];

  font = createFont("GmarketSansMedium.otf", 48); // 48은 폰트 크기
  textFont(font);

  uidNameMap.put("41103480", new RfidInfo("TAG_BBQ_001", 1));
  uidNameMap.put("0A493680", new RfidInfo("TAG_INVEST_001", 2));
  uidNameMap.put("95363480", new RfidInfo ("TAG_CHILDBIRTH", 3));
  uidNameMap.put("1E7b3480", new RfidInfo("TAG_JOB_001", 4));
  uidNameMap.put("E3563680", new RfidInfo("TAG_PENSION_001", 5));
  uidNameMap.put("D6793480", new RfidInfo("TAG_DISASTER", 6));
  uidNameMap.put("7EF63380", new RfidInfo ("TAG_JAIL", 7));

  uidNameMap.put("719B3580", new RfidInfo ("TAG_JOB_002", 8));
  uidNameMap.put("83113580", new RfidInfo ("TAG_MARRY_001", 9));
  uidNameMap.put("9A4B3480", new RfidInfo("TAG_INVEST_002", 10));
  uidNameMap.put("FD143480", new RfidInfo ("TAG_HORSE_RACE", 11));
  uidNameMap.put("D9583680", new RfidInfo("TAG_TAX_OFFICE", 12));

  uidNameMap.put("9B553680", new RfidInfo("TAG_ROBBING", 13));
  uidNameMap.put("BA6C3680", new RfidInfo("TAG_JOB_003", 14));
  uidNameMap.put("9E483480", new RfidInfo("TAG_WALLET", 15));
  uidNameMap.put("0B343680", new RfidInfo("TAG_HOME_BUY_001", 16));
  uidNameMap.put("E23F3580", new RfidInfo("TAG_PENSION_002", 17));
  uidNameMap.put("E9253680", new RfidInfo("TAG_TWINS", 18));
  uidNameMap.put("0B653680", new RfidInfo("TAG_EVENT", 19));

  uidNameMap.put("D3103580", new RfidInfo("TAG_INVEST_003", 20));
  uidNameMap.put("12654F05", new RfidInfo("TAG_HOME_BUY_002", 21));
  uidNameMap.put("BORAN5", new RfidInfo("TAG_DIVORCE", 22));
  uidNameMap.put("BORAN6", new RfidInfo("TAG_BOOK", 23));
  uidNameMap.put("BORAN7", new RfidInfo("TAG_GOAL", 0));

  for (RfidInfo info : uidNameMap.values()) {
    if (info.boardIndex >= 0 && info.boardIndex < 24) {
      boardMap[info.boardIndex] = info.name;
    }
  }
  initBoardPositions();

  if (boardPositions[0] != null) {
    for (Player player : players) {
      player.visualX = boardPositions[0].x;
      player.visualY = boardPositions[0].y;
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

  background(#fafafa);
  //imageMode(CORNER);

  if (boardImage != null) {
    // initBoardPositions에서 계산한 boardW, boardH, startX, startY 값과 동일하게
    int sidebarWidth = 320;
    int boardW = 820;
    int boardH = 620;
    int startX = sidebarWidth + (width - sidebarWidth - boardW) / 2;
    int startY = (height - boardH) / 2;

    image(boardImage, startX, startY, boardW, boardH);
  }
  drawPlayers();

  // 기존 그리기 코드
  // [main.pde]의 draw() 내부 수정

  // 1. 기본 상태 (자산 표시 & 롤 버튼)
  if (defalutPopup) {
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
    text("자산: " + nfc(p.money) + "원", 40, startY);

    // 직업 정보
    String jobText = p.isHired ? p.currentJob : "무직 (취준생)";
    text("직업: " + jobText, 40, startY + gap);

    // 월급 정보
    if (p.isHired) {
      text("월급: " + nfc(p.currentSalary) + "원", 40, startY + gap*2);
    }

    // 결혼 여부
    String marryText = p.isMarried ? "기혼" : "미혼";
    text("상태: " + marryText, 40, startY + gap*3);

    // 1. 자녀 수
    text("자녀: " + p.childCount + "명", 40, startY + gap*4);

    // 2. 주식 투자금 (따로따로 표시)
    // 주식 1
    String stock1 = (p.investAmount_01 > 0) ? nfc(p.investAmount_01) + "원" : "미보유";
    text("주식1: " + stock1, 40, startY + gap*5);

    // 주식 2
    String stock2 = (p.investAmount_02 > 0) ? nfc(p.investAmount_02) + "원" : "미보유";
    text("주식2: " + stock2, 40, startY + gap*6);


    popStyle();
    // ------------------------------------------------

    if (p.isIslanded && resultShowTime == -1) {
      p.islandTurns--; // 1턴 차감

      // 아직 남은 턴이 있다면 (2, 1, 0) -> 스킵
      if (p.islandTurns >= 0) {
        resultMessage = p.name + "님은 수감 중입니다. (남은 턴: " + (p.islandTurns + 1) + ")";
        resultShowTime = millis(); // 메시지 띄우고 2초 뒤 nextTurn() 자동 실행
      } else {
        // 턴 다 채움 -> 석방!
        p.isIslanded = false;
      }
    }

    // 롤 버튼 표시
    if (!showDice && !showMarriagePopup && !showHiredPopup && !showInvestPopup
      && !showHomePopup && !showGoalPopup && !showRacingPopup && resultShowTime == -1) {
      rollButton.display();
    }
    if (resultShowTime != -1) {
      // 1. 메시지 큼직하게 출력 (화면 중앙 하단)
      fill(0);
      textSize(20);
      textAlign(CENTER);

      int waitTime = 2000;
      if (showGoalPopup) {
        waitTime = 8000;  // 골인(파이널) 대기 시간: 10초 (원하는 만큼 늘리세요)
        text(resultMessage, messageX, messageY + 100);
      } else {
        text(resultMessage, messageX, messageY);
      }

      // 2. 2초가 지났는지 체크
      if (millis() - resultShowTime > waitTime) {
        resultShowTime = -1;
        resultMessage = "";

        // 골인 팝업이 켜져 있었다면 끄기 (다음 사람을 위해)
        if (showGoalPopup) {
          showGoalPopup = false;
        }

        if (isTurnChange) {
          println(">> 턴 종료. 다음 플레이어로 변경.");
          nextTurn();
        } else {
          // 교육비 메시지처럼 턴을 안 넘기는 경우 -> 스위치를 다시 켜두고 게임 진행
          isTurnChange = true;
          println(">> 메시지 종료. 현재 플레이어 턴 유지.");
        }
      }
    }
    if (showDice) {
      drawDiceOverlay();
    }
  }

  // 2. 결혼 팝업
  if (showMarriagePopup) {
    fill(0);
    text("결혼하시겠습니까?", messageX, messageY);
    yesButton.display();
    noButton.display();
    defalutPopup = false;

    if (millis() - resultShowTime > 2000) {
      resultShowTime = -1;
      defalutPopup = true;
    }
  }

  // 3. 직업(취업) 팝업
  if (showHiredPopup) {
    if (jobButtons.isEmpty()) initJobButtons();
    fill(0);
    text("취업을 축하합니다! 직업을 골라주세요", messageX, messageY);
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

  if (showRacingPopup) {
    drawRacingPopup();
  }

  // 9. 목표(정산) 화면
  if (showGoalPopup) {

    fill(0);
    for (int i = 0; i <= goalMsgIndex && i < goalMessages.size(); i++) {
      text(goalMessages.get(i), messageX, messageY - 120 + i * 30); // x좌표 160
    }
    if (millis() - goalMsgStartTime > 1000) {
      goalMsgIndex++;
      goalMsgStartTime = millis();
    }
  }

  if (showDice) {
    lights();
    drawDiceOverlay();
    noLights();
  }
}
