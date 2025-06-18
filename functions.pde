void mousePressed() {
  if (showMarriagePopup) {
    if (yesButton.isMouseOver()) {
      int gift = int(random(5, 21)) * 10000;
      int cost = int(random(1, 31)) * 10000;
      money += (gift - cost);
      isMarried = true;
      resultMessage = "결혼 완료! 축의금 " + gift + "원, 비용 " + cost + "원";
      resultShowTime = millis();  // 현재 시간 저장
      showMarriagePopup = false;
      go = true;
      myPort.write("GO\n");
      println("GO 전송 (결혼)");
    } else if (noButton.isMouseOver()) {
      resultMessage = "결혼 취소";
      resultShowTime = millis();
      showMarriagePopup = false;
      go = true;
      myPort.write("GO\n");
      println("GO 전송 (결혼)");
    }
  }

  Button selectedButton = null;

  if (showHiredPopup) {
    for (Button btn : jobButtons) {
      if (btn.isMouseOver()) {
        currentJob = btn.label;
        isHired = true;
        UR_Hired = true;
        currentSalary = salary[btn.idx];

        resultMessage = currentJob + "로 취업! 월급: " + currentSalary + "원";
        resultShowTime = millis();
        showHiredPopup = false;
        go = true;
      myPort.write("GO\n");
      println("GO 전송 (취업)");
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
      go = true;
      myPort.write("GO\n");
      println("GO 전송 (투자)");
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
      go = true;
      myPort.write("GO\n");
      println("GO 전송 (부동산)");
    }
  }

  if (isSelectingHome) {
    for (Button btn : homeButtons) {
      if (btn.isMouseOver()) {
        int price = homePrice[btn.idx];
        if (canAfford(price)) {
          money -= price;
          resultMessage = btn.label + " 구매 완료! -" + price + "원";
        } else {
          resultMessage = "돈이 부족합니다! 구매 실패.";
        }
        resultShowTime = millis();
        isSelectingHome = false;
        go = true;
      myPort.write("GO\n");
      println("GO 전송 (부동산)");
        homeButtons.clear();
        break;
      }
    }
  }
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
      money -= stock;

      if (currentInvestItem == 1) {
        isInvest_01 = true;
        UR_Invest_01 = true;
        investAmount_01 = stock;
      } else if (currentInvestItem == 2) {
        isInvest_02 = true;
        UR_Invest_02 = true;
        investAmount_02 = stock;
      }

      resultMessage = "투자완료! 투자금: " + stock;
      resultShowTime = millis();

      isEnteringInvestment = false;
      go = true;
      myPort.write("GO\n");
      println("GO 전송 (투자)");
      currentInvestItem = 0;  // 초기화
    }
  }
}

void processSalary() { //턴 마다 돌리면 됨
  if (!isHired || salaryCount >= salaryLimit) {
    return;  // 직업 없거나 최대치 받음
  }

  if (currentJob.equals("스타트업 CEO")) {
    if (random(1) < 0.5) {
      money += currentSalary;
      resultMessage = currentJob + " 월급 지급! +" + currentSalary + "원";
    } else {
      resultMessage = currentJob + " 월급 지급 실패!";
    }
  } else {
    money += currentSalary;
    resultMessage = currentJob + " 월급 지급! +" + currentSalary + "원";
  }

  salaryCount++;
  resultShowTime = millis();
}

void displayGoalResult() {
  goalMessages.clear();
  goalMsgIndex = 0;
  goalMsgStartTime = millis();
  goalMessages.add("나의의 현재 자산은: " + money + "원");

  //투자 결과 (각 투자금에 대해 50% 확률 +50, 나머지 -50)
  int investResult = 0;
  if (isInvest_01) {
    if (random(1) < 0.5) {
      investResult += investAmount_01 * 0.5;  // 50% 수익
    } else {
      investResult -= investAmount_01 * 0.5;
    }
  }
  if (isInvest_02) {
    if (random(1) < 0.5) {
      investResult += investAmount_02 * 0.5;
    } else {
      investResult -= investAmount_02 * 0.5;
    }
  }
  goalMessages.add("당신의 투자 결과는: " + investResult + "원");

  // 부동산 가치 (각 부동산에 대해 30% +30, 20% -30)
  int homeResult = 0;
  if (isHome_01) {
    float r = random(1);
    if (r < 0.3) homeResult += 300;
    else if (r < 0.5) homeResult -= 300;
  }
  if (isHome_02) {
    float r = random(1);
    if (r < 0.3) homeResult += 300;
    else if (r < 0.5) homeResult -= 300;
  }
  goalMessages.add("당신의 부동산 가치는: " + homeResult + "원");

  UR_Goal = true;
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
  return money >= price;
}

void showResult(String msg) {
  resultMessage = msg;
  resultShowTime = millis();
}
