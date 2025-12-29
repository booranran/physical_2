Player nextTurn() {
  int attempts = 0; // 무한루프 방지용
  int originalPlayer = currentPlayer;

  // 다음 플레이어가 아직 게임 중(안 끝남)일 때까지 계속 찾기
  do {
    currentPlayer = (currentPlayer + 1) % players.length;
    p = players[currentPlayer];
    attempts++;
  } while (p.isFinished && attempts < players.length); // 끝난 사람은 패스!

  // 2. 모든 플레이어가 골인했는지 확인
  boolean allFinished = true;
  
  for (Player player : players) {
    if (!player.isFinished) {
      allFinished = false;
      break;
    }
  }

  if (allFinished) {
    println(">> [GAME OVER] 모든 플레이어 완주! 게임을 종료합니다.");
    // 여기서 최종 랭킹을 보여주거나 게임 종료 화면으로 전환
    showGoalPopup = true; // 최종 결과창 유지
    return p;
  }


  if (p.isFinished) {
    // 이론상 여기까지 오면 안 되지만(위 do-while에서 걸러짐), 혹시 모르니 체크
    println(">> 에러: 모든 플레이어가 끝난 것 같은데 루프를 탈출함.");
    return p;
  } else {
    println(">> 턴 변경: " + p.name + " (현재 " + (currentPlayer+1) + "P)");
    return p;
  }
}

void initBoardPositions() {
  // 1. 레이아웃 설정 (Monopoly 코드와 동일한 8x6 구조)
  int sidebarWidth = 320; // 사이드바 너비 (왼쪽 여백)
  int cornerSize = 110;   // 코너 크기
  int cellW = 100;        // 일반 칸 너비
  int cellH = 100;        // 일반 칸 높이 (필요시)

  // 전체 보드 크기: 820 x 620
  int boardW = (cornerSize * 2) + (cellW * 6);
  int boardH = (cornerSize * 2) + (cellW * 4);

  // 화면 내 위치 잡기 (왼쪽 사이드바를 제외한 나머지 공간의 중앙)
  int startX = sidebarWidth + (width - sidebarWidth - boardW) / 2;
  int startY = (height - boardH) / 2;

  // 2. 24개 칸 좌표 계산
  for (int i = 0; i < 24; i++) {
    float bx = 0, by = 0;
    float bw = 0, bh = 0;

    if (i == 0) {
      // [0] 좌상단 (Start)
      bx = startX;
      by = startY;
      bw = cornerSize;
      bh = cornerSize;
    } else if (i >= 1 && i <= 6) {
      // [1~6] 상단 (좌->우)
      bx = startX + cornerSize + (i - 1) * cellW;
      by = startY;
      bw = cellW;
      bh = cornerSize;
    } else if (i == 7) {
      // [7] 우상단 코너
      bx = startX + boardW - cornerSize;
      by = startY;
      bw = cornerSize;
      bh = cornerSize;
    } else if (i >= 8 && i <= 11) {
      // [8~11] 우측 (상->하)
      bx = startX + boardW - cornerSize;
      by = startY + cornerSize + (i - 8) * cellW; // cellH 대신 정사각형 가정 cellW 사용
      bw = cornerSize;
      bh = cellW;
    } else if (i == 12) {
      // [12] 우하단 코너
      bx = startX + boardW - cornerSize;
      by = startY + boardH - cornerSize;
      bw = cornerSize;
      bh = cornerSize;
    } else if (i >= 13 && i <= 18) {
      // [13~18] 하단 (우->좌)
      bx = (startX + boardW - cornerSize) - cellW - (i - 13) * cellW;
      by = startY + boardH - cornerSize;
      bw = cellW;
      bh = cornerSize;
    } else if (i == 19) {
      // [19] 좌하단 코너
      bx = startX;
      by = startY + boardH - cornerSize;
      bw = cornerSize;
      bh = cornerSize;
    } else if (i >= 20 && i <= 23) {
      // [20~23] 좌측 (하->상)
      bx = startX;
      by = (startY + boardH - cornerSize) - cellW - (i - 20) * cellW;
      bw = cornerSize;
      bh = cellW;
    }
    // 중심 좌표 저장
    boardPositions[i] = new PVector(bx + bw / 2.0, by + bh / 2.0);
  }
}

void drawPlayers() {
  for (Player p : players) {
    p.updateAndDraw();
  }
}

void handlePlayerArrival(int playerId) {
  Player arrivedPlayer = players[playerId - 1];
  println("플레이어 " + playerId + " 골인!");
  
  // 1. 도착한 플레이어 완주 처리
  arrivedPlayer.isFinished = true;
  
  // 2. 개인 결과(자산 정산) 보여주기
  // (이 함수는 해당 플레이어의 자산을 계산해서 goalMessages를 채워줍니다)
  p = arrivedPlayer; // 현재 포커스를 도착한 사람으로 잠시 맞춤
  displayGoalResult(); 
  showGoalPopup = true;
  
  // 3. ★ 중요: 여기서 바로 턴을 넘기지 말고, 
  // "결과창 확인" 버튼을 누르거나 3초 뒤에 자동으로 넘어가게 해야 합니다.
  // main.pde의 draw()에서 resultShowTime 로직이 이걸 처리해줄 겁니다.
  
  resultMessage = arrivedPlayer.name + " 완주! 잠시 후 다음 턴으로 넘어갑니다.";
  resultShowTime = millis(); // 2초 뒤에 nextTurn() 자동 실행됨
}


void mousePressed() {

  if (rollButton != null) {
    if (rollButton.isMouseOver()) {
      println(">> ROLL 버튼 클릭됨! (현재 showDice 상태: " + showDice + ")");
      if (!showDice) {
        startRoll();
        return;
      }
    }
  } else {
    println("!! 에러: rollButton이 초기화되지 않았습니다 (null)");
  }

  if (showMarriagePopup) {
    if (yesButton.isMouseOver()) {
      int gift = int(random(5, 21)) * 10000;
      int cost = int(random(1, 31)) * 10000;
      p.money += (gift - cost);
      p.isMarried = true;
      resultMessage = "결혼 완료! 축의금 " + gift + "원, 비용 " + cost + "원";
      resultShowTime = millis();  // 현재 시간 저장
      showMarriagePopup = false;
    } else if (noButton.isMouseOver()) {
      // println(resultShowTime);
      resultMessage = "결혼 취소";
      resultShowTime = millis();
      showMarriagePopup = false;
    }
  }

  Button selectedButton = null;

  if (showHiredPopup) {
    for (Button btn : jobButtons) {
      if (btn.isMouseOver()) {
        p.currentJob = btn.label;
        p.isHired = true;
        p.UR_Hired = true;
        p.currentSalary = salary[btn.idx];

        resultMessage = p.currentJob + "로 취업! 월급: " + p.currentSalary + "원";
        resultShowTime = millis();
        showHiredPopup = false;

        jobButtons.clear();
        break;
      }
    }
  }

  if (showInvestPopup) {
    if (yesButton.isMouseOver()) {
      isEnteringInvestment = true;
      investInput = "";
      if (currentInvestItem == 0) {
        currentInvestItem = 1;  // 첫 투자
      } else if (currentInvestItem == 1) {
        currentInvestItem = 2;  // 두 번째 투자
      }

      showInvestPopup = false;
      println("YES clicked → isEnteringInvestment=" + isEnteringInvestment + ", showInvestPopup=" + showInvestPopup);
    } else if (noButton.isMouseOver()) {
      resultMessage = "투자 취소";
      resultShowTime = millis();
      showInvestPopup = false;
    }
  }

  if (showHomePopup) {
    if (yesButton.isMouseOver()) {
      isSelectingHome = true;
      showHomePopup = false;
    } else if (noButton.isMouseOver()) {
      resultMessage = "부동산 구매 취소";
      resultShowTime = millis();
      showHomePopup = false;
    }
  }

  if (isSelectingHome) {
    for (Button btn : homeButtons) {
      if (btn.isMouseOver()) {
        int price = homePrice[btn.idx];
        if (canAfford(price)) {
          p.money -= price;
          p.myHomePrice = price;
          p.myHomeName = btn.label;
          resultMessage = btn.label + " 구매 완료! -" + price + "원";
          nextTurn();
        } else {
          resultMessage = "돈이 부족합니다! 구매 실패.";
        }
        resultShowTime = millis();
        isSelectingHome = false;

        homeButtons.clear();
        break;
      }
    }
  }
}


//---------------------------------------------------------------------

void initJobButtons() {
  ArrayList<Integer> indices = new ArrayList<Integer>();
  for (int i = 0; i < jobs.length; i++) indices.add(i);
  Collections.shuffle(indices);
  jobButtons.add(new Button(700, 360, 100, 40, jobs[indices.get(0)], indices.get(0)));
  jobButtons.add(new Button(870, 360, 100, 40, jobs[indices.get(1)], indices.get(1)));
}

void initHomeButtons() {
  ArrayList<Integer> indices = new ArrayList<Integer>();
  for (int i = 0; i < homeOptions.length; i++) indices.add(i);
  Collections.shuffle(indices);
  homeButtons.add(new Button(700, 360, 100, 40, homeOptions[indices.get(0)], indices.get(0)));
  homeButtons.add(new Button(870, 360, 100, 40, homeOptions[indices.get(1)], indices.get(1)));
}


void keyPressed() {
  println("keyPressed triggered: " + key);
  if (isEnteringInvestment) {
    if (key >= '0' && key <= '9') {
      investInput += key;
    } else if (key == BACKSPACE && investInput.length() > 0) {
      investInput = investInput.substring(0, investInput.length()-1);
    } else if (key == ENTER || key == RETURN) {
      int stock = int(investInput);
      p.money -= stock;

      if (currentInvestItem == 1) {
        p.isInvest_01 = true;
        p.UR_Invest_01 = true;
        p.investAmount_01 = stock;
      } else if (currentInvestItem == 2) {
        p.isInvest_02 = true;
        p.UR_Invest_02 = true;
        p.investAmount_02 = stock;
      }

      resultMessage = "투자완료! 투자금: " + stock;
      resultShowTime = millis();

      isEnteringInvestment = false;

      currentInvestItem = 0;  // 초기화
    }
  }
}

void processSalary() { //턴 마다 돌리면 됨
  if (!p.isHired || salaryCount >= salaryLimit) {
    return;  // 직업 없거나 최대치 받음
  }
  if (p.currentJob.equals("스타트업 CEO")) {
    if (random(1) < 0.5) {
      p.money += p.currentSalary;
      resultMessage = p.currentJob + " 월급 지급! +" + p.currentSalary + "원";
    } else {
      resultMessage = p.currentJob + " 월급 지급 실패!";
    }
  } else {
    p.money += p.currentSalary;
    resultMessage = p.currentJob + " 월급 지급! +" + p.currentSalary + "원";
  }

  salaryCount++;
  resultShowTime = millis();
}

void displayGoalResult() {
  goalMessages.clear();
  goalMsgIndex = 0;
  goalMsgStartTime = millis();
  goalMessages.add("나의의 현재 자산은: " + p.money + "원");

  //투자 결과 (각 투자금에 대해 50% 확률 +50, 나머지 -50)
  int investResult = 0;
  if (p.isInvest_01) {
    if (random(1) < 0.5) {
      investResult += p.investAmount_01 * 0.5;  // 50% 수익
    } else {
      investResult -= p.investAmount_01 * 0.5;
    }
  }
  if (p.isInvest_02) {
    if (random(1) < 0.5) {
      investResult += p.investAmount_02 * 0.5;
    } else {
      investResult -= p.investAmount_02 * 0.5;
    }
  }
  goalMessages.add("당신의 투자 결과는: " + investResult + "원");

  // 부동산 가치 (각 부동산에 대해 30% +30, 20% -30)
  if (p.myHomePrice > 0) {
    int homeResult = 0;
    float r = random(1);
    if (r < 0.3) {
      homeResult = int(p.myHomePrice * 0.3);  // 30% 상승
    } else if (r < 0.5) {
      homeResult = -int(p.myHomePrice * 0.3);  // 30% 하락
    } else {
      homeResult = 0;  // 변동 없음
    }
    goalMessages.add("당신의 " + p.myHomeName + " 부동산 가치는: " + homeResult + "원");
  } else {
    goalMessages.add("구매한 부동산이 없습니다.");
  }
  //p.UR_Goal = true;
}

void triggerRandomEvent() {
  int idx = int(random(events.length));
  RandomEvent e = events[idx];

  p.money += e.moneyChange;

  resultMessage = e.description + " (" + e.moneyChange + "원)";
  resultShowTime = millis();

  println("랜덤 이벤트: " + resultMessage);
}

ArrayList<Button> jobButtons = new ArrayList<Button>();

// 버튼 출력
void drawJobButtons() {
  for (Button btn : jobButtons) {
    btn.display();
  }
}

//돈 체크
boolean canAfford(int price) {
  return p.money >= price;
}

void showResult(String msg) {
  resultMessage = msg;
  resultShowTime = millis();
}

// [추가] 위치 인덱스(0~23)에 따라 이벤트를 실행하는 함수
void processBoardIndex(int index) {
  String locationName = boardMap[index];

  if (locationName == null) {
    println("Error: 해당 인덱스에 매핑된 지역이 없습니다 (" + index + ")");
    return;
  }

  println("이벤트 실행: " + locationName);

  // 각 지역 이름에 맞춰 팝업 띄우기
  if (locationName.equals("TAG_MARRY_001")) {
    showMarriagePopup = true;
  } else if (locationName.startsWith("TAG_JOB")) {
    showHiredPopup = true;
  } else if (locationName.startsWith("TAG_INVEST")) {
    showInvestPopup = true;
  } else if (locationName.startsWith("TAG_HOME")) {
    showHomePopup = true;
  } else if (locationName.startsWith("TAG_RANDOM_EVENT") || locationName.equals("EVENT")) {
    showEventPopup = true;
  } else if (locationName.equals("TAG_GOAL")) {
    println("골 지점 이벤트 발생");
  } else if (locationName.equals("SALARY")) {
    processSalary();
  } else if (locationName.equals("ISLAND")) {
    p.isIslanded = true;
    showResult("무인도에 갇혔습니다! (3턴 휴식)");
  } else if (locationName.equals("SPACE")) {
    showResult("우주여행! (다음 턴에 원하는 곳으로 이동)");
  } else {
    // 그 외 일반 도시들 (LISBON, SEOUL 등)
    showResult(locationName + "에 도착했습니다.");
    // 만약 도시에서도 땅을 살 수 있게 하려면 아래 주석 해제
    // showHomePopup = true;
  }
}


void keyTyped() {
  if (key == '1') {
    processTagEvent("TAG_JOB_001"); // 베이징 태그
  } else if (key == '2') {
    processTagEvent("TAG_JOB_002"); // 이스탄불  태그
  } else if (key=='3') {
    processTagEvent("TAG_MARRY_001");
  } else if (key=='4') {
    processTagEvent("E3563680");
  } else if (key=='5') {
    processTagEvent("12654F05");
  } else if (key=='6') {
    processTagEvent("BORAN5");
  } else if (key=='7') {
    processTagEvent("BORAN6");
  } else if (key == '8') {
    processTagEvent("BORAN7");
  } else if (key == '9') {
    processTagEvent("TAG_GOAL");
  }
}
