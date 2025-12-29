Player nextTurn() {
  // 현재 플레이어를 다음으로 넘기는 코드
  int nextPlayerIndex = (currentPlayer + 1) % players.length;

  // 다음 플레이어가 무인도에 갇혔으면 그 다음 플레이어로 넘어감

  // 최종적으로 플레이할 플레이어로 업데이트
  currentPlayer = nextPlayerIndex;
  p = players[currentPlayer];
  println("Now it's " + p.name + "'s turn!");

  return p;
}




void mousePressed() {

  println("Mouse Clicked at: " + mouseX + ", " + mouseY);

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

        nextTurn();


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
      nextTurn();

      showInvestPopup = false;
      println("YES clicked → isEnteringInvestment=" + isEnteringInvestment + ", showInvestPopup=" + showInvestPopup);
    } else if (noButton.isMouseOver()) {
      resultMessage = "투자 취소";
      resultShowTime = millis();
      nextTurn();

      showInvestPopup = false;
    }
  }

  if (showHomePopup) {

    if (yesButton.isMouseOver()) {
      isSelectingHome = true;
      nextTurn();

      showHomePopup = false;
    } else if (noButton.isMouseOver()) {
      resultMessage = "부동산 구매 취소";
      resultShowTime = millis();
      nextTurn();

      showHomePopup = false;
    }
  }

  if (isSelectingHome) {
    for (Button btn : homeButtons) {
      if (btn.isMouseOver()) {
        int price = homePrice[btn.idx];
        if (canAfford(price)) {
          p.money -= price;
          purchasedHomePrice = price;
          purchasedHomeName = btn.label;
          resultMessage = btn.label + " 구매 완료! -" + price + "원";
          nextTurn();
        } else {
          resultMessage = "돈이 부족합니다! 구매 실패.";
          nextTurn();
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
  jobButtons.add(new Button(150, 250, 120, 40, jobs[indices.get(0)], indices.get(0)));
  jobButtons.add(new Button(350, 250, 120, 40, jobs[indices.get(1)], indices.get(1)));
}

void initHomeButtons() {
  ArrayList<Integer> indices = new ArrayList<Integer>();
  for (int i = 0; i < homeOptions.length; i++) indices.add(i);
  Collections.shuffle(indices);
  homeButtons.add(new Button(150, 250, 120, 40, homeOptions[indices.get(0)], indices.get(0)));
  homeButtons.add(new Button(350, 250, 120, 40, homeOptions[indices.get(1)], indices.get(1)));
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
  if (purchasedHomePrice > 0) {
    int homeResult = 0;
    float r = random(1);
    if (r < 0.3) {
      homeResult = int(purchasedHomePrice * 0.3);  // 30% 상승
    } else if (r < 0.5) {
      homeResult = -int(purchasedHomePrice * 0.3);  // 30% 하락
    } else {
      homeResult = 0;  // 변동 없음
    }
    goalMessages.add("당신의 " + purchasedHomeName + " 부동산 가치는: " + homeResult + "원");
  } else {
    goalMessages.add("구매한 부동산이 없습니다.");
  }

  p.UR_Goal = true;
}

void triggerRandomEvent() {
  int idx = int(random(events.length));
  RandomEvent e = events[idx];

  p.money += e.moneyChange;

  resultMessage = e.description + " (" + e.moneyChange + "원)";
  resultShowTime = millis();

  // 디버그 출력
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
  } 
  else if (locationName.startsWith("TAG_JOB")) {
    showHiredPopup = true;
  } 
  else if (locationName.startsWith("TAG_INVEST")) {
    showInvestPopup = true;
  } 
  else if (locationName.startsWith("TAG_HOME")) {
    showHomePopup = true;
  } 
  else if (locationName.startsWith("TAG_RANDOM_EVENT") || locationName.equals("EVENT")) {
    showEventPopup = true;
  } 
  else if (locationName.equals("TAG_GOAL")) {
    showGoalPopup = true;
  } 
  else if (locationName.equals("SALARY")) {
    processSalary();
  } 
  else if (locationName.equals("ISLAND")) {
    p.isIslanded = true;
    showResult("무인도에 갇혔습니다! (3턴 휴식)");
  } 
  else if (locationName.equals("SPACE")) {
    showResult("우주여행! (다음 턴에 원하는 곳으로 이동)");
  }
  else {
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
  }
}
