// [functions.pde] nextTurn 함수 수정

Player nextTurn() {
  int attempts = 0;

  // 1. 다음 플레이어 찾기
  do {
    currentPlayer = (currentPlayer + 1) % players.length;
    p = players[currentPlayer];
    attempts++;
  } while (p.isFinished && attempts < players.length);

  // 2. 모든 플레이어 완주 체크
  boolean allFinished = true;
  for (Player player : players) {
    if (!player.isFinished) {
      allFinished = false;
      break;
    }
  }

  if (allFinished) {
    println(">> [GAME OVER] 모든 플레이어 완주!");
    displayRanking();
    showGoalPopup = true;
    return p;
  }

  // -----------------------------------------------------------
  // ★ [통합 정산] 3턴마다 월급(확률/제한 적용) & 교육비 처리
  // -----------------------------------------------------------
  if (!p.isFinished) {
    p.turnCount++;

    // 3턴마다 (3, 6, 9...) 정산
    if (p.turnCount % 3 == 0) {
      String eventMsg = "[정기 결산] ";
      boolean eventHappened = false;

      // 1) 월급 지급 로직 (processSalary 내용 통합)
      // 직업이 있고 & 월급 횟수 제한을 넘지 않았을 때
      if (p.isHired && salaryCount < salaryLimit) {
        boolean getPaid = true;

        // 스타트업 CEO는 50% 확률로 월급 실패
        if (p.currentJob.equals("스타트업 CEO")) {
          if (random(1) >= 0.5) getPaid = false;
        }

        if (getPaid) {
          p.money += p.currentSalary;
          salaryCount++; // 월급 횟수 증가 (전체 공유 변수라면 주의 필요)
          eventMsg += p.currentJob + " 월급 +" + p.currentSalary + "원 ";
        } else {
          eventMsg += "스타트업 월급 실패 "; // CEO 실패 시 메시지
        }
        eventHappened = true;
      }

      // 2) 교육비 차감 (자녀가 있을 경우)
      if (p.childCount > 0) {
        int eduFee = p.childCount * 1000;
        p.money -= eduFee;

        // 월급 메시지가 있으면 줄바꿈이나 구분자 추가
        if (eventHappened) eventMsg += "| ";
        eventMsg += "교육비 -" + eduFee + "원";
        eventHappened = true;
      }

      // 이벤트가 하나라도 있었다면 팝업 띄우기
      if (eventHappened) {
        resultMessage = eventMsg;
        resultShowTime = millis();
        isTurnChange = false; // 팝업 보는 동안 턴 넘어가지 않게 잠금
      }
    }
  }

  println(">> 턴 변경: " + p.name + " (현재 " + (currentPlayer+1) + "P)");
  return p;
}

void displayRanking() {
  goalMessages.clear();
  goalMsgIndex = 0;
  goalMsgStartTime = millis();

  goalMessages.add("=== [최종 경기 결과] ===");

  int maxScore = -999999999;
  String winnerName = "";

  // 모든 플레이어의 점수를 띄워주고 1등을 찾음
  for (Player player : players) {
    goalMessages.add(player.name + ": " + player.finalScore + "원");

    if (player.finalScore > maxScore) {
      maxScore = player.finalScore;
      winnerName = player.name;
    }
  }

  goalMessages.add("--------------------------------");
  goalMessages.add("최종 우승: " + winnerName + "!");
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
  p = arrivedPlayer; // 현재 포커스를 도착한 사람으로 잠시 맞춤
  processBoardIndex(p.position);
}

void drawRacingPopup() {
  fill(0);

  if (!isRacing) {
    // 1. 배팅 단계: 말 선택 화면
    // (텍스트 위치는 messageX, 200이 맞는지 확인해 보세요)
    textSize(30);
    text("우승할 말을 선택하세요! (참가비 10만원)", messageX, 200);

    if (raceButtons.isEmpty()) initRaceButtons();
    for (Button btn : raceButtons) btn.display();
  } else {
    // 2. 경주 단계: 달리는 화면
    textSize(30);
    text("달려라!!! (내 말: " + (selectedHorse+1) + "번)", messageX, 200);

    // 말 5마리 그리기
    for (int i = 0; i < 5; i++) {
      // 트랙 라인
      stroke(200);
      strokeWeight(2); // 선 두께 살짝 추가
      line(350, 250 + (i*60), 950, 250 + (i*60));

      // 말 (네모로 표시)
      noStroke();
      if (i == selectedHorse) fill(255, 0, 0); // 내 말은 빨간색
      else fill(0); // 다른 말은 검은색

      rect(horsePositions[i], 240 + (i*60), 40, 30); // 말 크기

      // 말 번호
      fill(255);
      textSize(15);
      text((i+1), horsePositions[i] + 20, 240 + (i*60) + 15);
    }

    // 로직 업데이트 호출
    updateRace();
  }
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
  if (showRacingPopup && !isRacing) { // 달리는 중에는 버튼 못 누름
    if (raceButtons.isEmpty()) initRaceButtons(); // 버튼 없으면 생성

    for (Button btn : raceButtons) {
      if (btn.isMouseOver()) {
        startRace(btn.idx); // 선택한 말로 경주 시작!
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
  jobButtons.add(new Button(700, 450, 100, 40, jobs[indices.get(0)], indices.get(0)));
  jobButtons.add(new Button(870, 450, 100, 40, jobs[indices.get(1)], indices.get(1)));
}

void initHomeButtons() {
  ArrayList<Integer> indices = new ArrayList<Integer>();
  for (int i = 0; i < homeOptions.length; i++) indices.add(i);
  Collections.shuffle(indices);
  homeButtons.add(new Button(700, 450, 100, 40, homeOptions[indices.get(0)], indices.get(0)));
  homeButtons.add(new Button(870, 450, 100, 40, homeOptions[indices.get(1)], indices.get(1)));
}

// 1. 경마 버튼 생성 함수
void initRaceButtons() {
  raceButtons.clear();
  int startX = 600; // 버튼 시작 위치 (화면 중앙 쯤)
  int startY = 250;

  for (int i = 0; i < 5; i++) {
    // 버튼 5개 생성 (라벨: 1번마, 2번마...)
    raceButtons.add(new Button(startX, startY + (i * 60), 120, 40, (i+1) + "번 말", i));
  }
}

// 2. 경주 시작 세팅 함수
void startRace(int myChoice) {
  if (p.money < 100000) {
    showResult("돈이 부족해서 배팅할 수 없습니다. (필요: 10만원)");
    showRacingPopup = false;
    return;
  }

  p.money -= 100000; // 배팅금 차감
  selectedHorse = myChoice;
  isRacing = true;
  winnerHorse = -1;

  // 말 위치 모두 0으로 초기화
  for (int i = 0; i < 5; i++) {
    horsePositions[i] = 350; // 시작 x좌표 (왼쪽)
  }
  println(">> 경주 시작! 선택한 말: " + (selectedHorse+1) + "번");
}

// 3. 경주 업데이트 함수 (매 프레임 실행)
void updateRace() {
  if (!isRacing) return;

  boolean finish = false;

  for (int i = 0; i < 5; i++) {
    // 각 말마다 랜덤 속도로 전진! (빠르기 조절 가능)
    horsePositions[i] += random(2, 10);

    // 결승선(예: x=900) 통과 체크
    if (horsePositions[i] > 950 && !finish) {
      finish = true;
      winnerHorse = i; // 우승마 확정
    }
  }

  // 누군가 결승선에 도착했다면?
  if (finish) {
    isRacing = false;

    // 결과 정산
    if (winnerHorse == selectedHorse) {
      int prize = 500000; // 5배 대박!
      p.money += prize;
      resultMessage = "축하합니다! " + (winnerHorse+1) + "번 말이 우승했습니다! (상금 +" + prize + ")";
    } else {
      resultMessage = "아쉽네요... " + (winnerHorse+1) + "번 말이 우승했습니다.";
    }
    resultShowTime = millis();
    showRacingPopup = false; // 팝업 닫기 (결과 메시지는 draw에서 보여줌)
  }
}

// functions.pde 맨 아래에 추가

void movePlayer(int steps) {
  int currentPos = p.position;
  
  // 이동할 칸 수만큼 반복하면서 경로 저장
  for (int i = 1; i <= steps; i++) {
    int nextIndex = (currentPos + i) % 24; // 24는 전체 칸 수
    
    // 각 칸의 중심 좌표 가져오기 (이미 initBoardPositions에서 계산됨)
    PVector dest = boardPositions[nextIndex];
    
    // 이동 대기열에 추가
    p.pathQueue.add(new PVector(dest.x, dest.y));
  }
  
  // 데이터상 위치는 미리 업데이트
  p.position = (currentPos + steps) % 24;
  println("이동 예약 완료: " + steps + "칸");
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

  // 1. 현재 보유 현금
  int finalTotalAsset = p.money; // 최종 자산 계산용 변수 (여기서부터 누적 시작)
  goalMessages.add("현재 보유 현금: " + p.money + "원");

  // ----------------------------------------------------------
  // 2. 투자 결과 (원금 + 수익/손실)
  // ----------------------------------------------------------
  int investProfit = 0; // 순수익/손실
  int investPrincipal = 0; // 투자 원금 합계

  if (p.isInvest_01) investPrincipal += p.investAmount_01;
  if (p.isInvest_02) investPrincipal += p.investAmount_02;

  // 1번 투자 상품
  if (p.isInvest_01) {
    if (random(1) < 0.5) investProfit += int(p.investAmount_01 * 0.5); // 50% 수익
    else investProfit -= int(p.investAmount_01 * 0.5); // 50% 손실
  }
  // 2번 투자 상품
  if (p.isInvest_02) {
    if (random(1) < 0.5) investProfit += int(p.investAmount_02 * 0.5);
    else investProfit -= int(p.investAmount_02 * 0.5);
  }

  int finalStockValue = investPrincipal + investProfit; // 주식 최종 가치
  finalTotalAsset += finalStockValue; // ★ 최종 자산에 추가

  goalMessages.add("주식 평가 금액: " + finalStockValue + "원 (손익: " + investProfit + "원)");

  // ----------------------------------------------------------
  // 3. 부동산 가치 (각 부동산에 대해 30% 상승/하락)
  // ----------------------------------------------------------
  int finalHomeValue = 0;

  if (p.myHomePrice > 0) {
    int homeFluctuation = 0;
    float r = random(1);

    if (r < 0.3) homeFluctuation = int(p.myHomePrice * 0.3);       // 30% 상승
    else if (r < 0.5) homeFluctuation = -int(p.myHomePrice * 0.3); // 30% 하락
    else homeFluctuation = 0;                                      // 유지

    finalHomeValue = p.myHomePrice + homeFluctuation;
    goalMessages.add("부동산 평가 금액: " + finalHomeValue + "원 (" + p.myHomeName + ")");
  } else {
    goalMessages.add("보유 부동산 없음: 0원");
  }

  finalTotalAsset += finalHomeValue; // ★ 최종 자산에 추가

  // ----------------------------------------------------------
  // 4. 연금 수령액 (납부액 + 이자)
  // ----------------------------------------------------------
  int finalPensionValue = 0;

  if (p.pensionTotal > 0) {
    float pensionRate = random(1.2, 1.5); // 1.2 ~ 1.5배 뻥튀기
    finalPensionValue = int(p.pensionTotal * pensionRate);

    goalMessages.add("연금 수령액: " + finalPensionValue + "원 (납부액: " + p.pensionTotal + ")");
  } else {
    goalMessages.add("연금 수령액 없음: 0원");
  }

  finalTotalAsset += finalPensionValue; // ★ 최종 자산에 추가

  // ----------------------------------------------------------
  // 5. 자녀 양육 보너스 (1명당 1500원)
  // ----------------------------------------------------------
  int childBonus = 0;

  if (p.childCount > 0) {
    // ★ 랜덤 금액 책정 (1500원 ~ 5000원 사이)
    int randomRate = int(random(1500, 5001));
    childBonus = p.childCount * randomRate;

    goalMessages.add("자녀 지원금: " + childBonus + "원 (" + p.childCount + "명, 인당 " + randomRate + "원)");
  } else {
    goalMessages.add("자녀 지원금 없음");
  }

  finalTotalAsset += childBonus; // 최종 자산에 추가

  // ----------------------------------------------------------
  // 6. 최종 합계 출력
  // ----------------------------------------------------------
  goalMessages.add("--------------------------------");
  goalMessages.add("★ 최종 총 자산: " + finalTotalAsset + "원 ★");
  p.finalScore = finalTotalAsset;
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

void processBoardIndex(int index) {
  String locationName = boardMap[index];

  if (locationName == null) {
    println("Error: 해당 인덱스에 매핑된 지역이 없습니다 (" + index + ")");
    return;
  }
  println("이벤트 실행: " + locationName);

  // ---------------------------------------------------------
  // 1. 팝업이 뜨는 이벤트들 (결혼, 취업, 투자, 부동산, 랜덤이벤트)
  // ---------------------------------------------------------
  if (locationName.equals("TAG_MARRY_001")) {
    showMarriagePopup = true;
  } else if (locationName.startsWith("TAG_JOB")) { // JOB_001, 002, 003 통합 처리
    showHiredPopup = true;
  } else if (locationName.startsWith("TAG_INVEST")) { // INVEST_001, 002, 003 통합 처리
    showInvestPopup = true;
  } else if (locationName.startsWith("TAG_HOME_BUY")) { // HOME_BUY_001, 002 통합 처리
    showHomePopup = true;
  } else if (locationName.equals("TAG_EVENT")) {
    showEventPopup = true;
  } else if (locationName.equals("TAG_HORSE_RACE")) {
    showRacingPopup = true;
  }

  // ---------------------------------------------------------
  // 2. 게임 종료 및 특수 상태 (골인, 감옥)
  // ---------------------------------------------------------
  else if (locationName.equals("TAG_GOAL")) {
    println("🎉 골 지점 도착! 완주 처리.");
    p.isFinished = true;
    displayGoalResult();
    showGoalPopup = true;
    resultMessage = p.name + " 완주! 잠시 후 다음 턴으로 넘어갑니다.";
    resultShowTime = millis();
  } else if (locationName.equals("TAG_JAIL")) {
    p.isIslanded = true; // 무인도(감옥) 상태로 변경
    p.islandTurns = 3;
    showResult("형무소에 수감되었습니다! (3턴 휴식)");
  }

  // ---------------------------------------------------------
  // 3. 새로 추가된 단순 이벤트들 (메시지만 띄움)
  // (나중에 p.money += 10000; 같은 돈 계산 로직 넣으면 됨)
  // ---------------------------------------------------------
  else if (locationName.equals("TAG_BBQ_001")) {
    showResult("바베큐 파티에 참석했습니다!");
    p.money -= 3000;
  } else if (locationName.equals("TAG_CHILDBIRTH")) {
    showResult("축하합니다! 아이가 태어났습니다.");
    p.childCount += 1;
    int bonus = 5000;
    p.money += bonus;
  } else if (locationName.startsWith("TAG_PENSION")) { // PENSION_001, 002
    int payAmount = 1500;
    p.money -= payAmount;
    p.pensionTotal += payAmount;
    showResult("연금 " + payAmount + "원을 납부했습니다. (누적: " + p.pensionTotal + "원)");
  } else if (locationName.equals("TAG_DISASTER")) {
    showResult("재난 발생! 피해 복구비가 나갑니다.");
    p.money -= 1000;
  } else if (locationName.equals("TAG_TAX_OFFICE")) {
    int taxThreshold = 500000; // 기준 금액: 50만원 (이거보다 많으면 부자)

    // 1. 부자일 경우 (세금 납부)
    if (p.money >= taxThreshold) {
      int tax = int(p.money * 0.1); // 보유 자산의 10%를 세금으로 징수
      p.money -= tax;
      showResult("고소득자 세금 납부! -" + tax + "원 (성실납세 감사)");
    }
    // 2. 서민일 경우 (환급금 수령)
    else {
      int refund = 50000; // 환급금 5만원 지급
      p.money += refund;
      showResult("연말정산 세금 환급! +" + refund + "원 (13월의 월급)");
    }
  } else if (locationName.equals("TAG_ROBBING")) {
    showResult("강도를 만났습니다! 지갑 조심하세요.");
  } else if (locationName.equals("TAG_WALLET")) {
    showResult("길에서 두툼한 지갑을 주웠습니다!");
    p.money += 3000;
  } else if (locationName.equals("TAG_TWINS")) {
    showResult("경사났네! 쌍둥이가 태어났습니다.");
    p.childCount += 2;           // 자녀 2명 추가
    int bonus = 100000;          // 축하금 10만원 (두 배!)
    p.money += bonus;
  } else if (locationName.equals("TAG_DIVORCE")) {
    showResult("이혼하게 되었습니다... (위자료 지불)");
    p.money -= 1000;
  } else if (locationName.equals("TAG_BOOK")) {
    showResult("책을 출간했습니다! 인세 수익 획득.");
    p.money += 1500;
  }
  // ---------------------------------------------------------
  // 4. 그 외 처리되지 않은 태그들
  // ---------------------------------------------------------
  else {
    showResult(locationName + "에 도착했습니다.");
  }
}


void keyTyped() {
  if (key == '1') {
    processTagEvent("D9583680"); // 베이징 태그
  } else if (key == '2') {
    processTagEvent("BORAN7");
  }
}
