import java.util.Collections;
import processing.serial.*;

Serial myPort;

void setup() {
  size(600, 400);

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[2], 9600);
  myPort.bufferUntil('\n');

  yesButton = new Button(150, 250, 100, 40, "YES", -1);
  noButton = new Button(350, 250, 100, 40, "NO", -1);

  font = loadFont("GmarketSansMedium.vlw");
  textFont(font);

  uidNameMap.put("837186A9", "TAG_MARRY_001");
  uidNameMap.put("BD950E05", "TAG_JOB_001");
  uidNameMap.put("73624496", "TAG_JOB_002");
  uidNameMap.put("D31C6A96", "TAG_INVEST_001");
  uidNameMap.put("23892303", "TAG_INVEST_002");
  uidNameMap.put("E5AE0905", "TAG_HOME_001");
  uidNameMap.put("53251696", "TAG_HOME_002");
  uidNameMap.put("B3A4CC95", "TAG_RANDOM_EVENT_001");
  uidNameMap.put("731CE995", "TAG_RANDOM_EVENT_002");
  uidNameMap.put("D3D14E96", "TAG_RANDOM_EVENT_003");
  uidNameMap.put("13D94CA9", "TAG_GOAL");

  if (showGoalPopup) {
    displayGoalResult();
  }
}

void draw() {
  // 시리얼 데이터 수신
  while (myPort != null && myPort.available() > 0) {
    println("디버그: 시리얼 데이터 존재 확인됨");

    String inData = myPort.readStringUntil('\n');
    if (inData != null) {
      inData = trim(inData);
      println("디버그: 수신된 원본 데이터 = [" + inData + "]");

      if (!inData.equals("")) {
        handleSerialData(inData);
      }
    } else {
      println("디버그: readStringUntil이 null 반환");
    }
  }


  // 기존 그리기 코드
  background(255);
  textAlign(CENTER);
  fill(0);
  textSize(20);
  text("현재 자산: " + money + "원", width/2, 100);

  if (showMarriagePopup) {
    fill(230);
    rect(100, 150, 400, 150, 10);
    fill(0);
    text("결혼하시겠습니까?", width/2, 190);
    yesButton.display();
    noButton.display();
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
}

void handleSerialData(String raw) {
  String cleaned = raw.replaceAll("\\s+", "").toUpperCase();
  println("수신: [" + cleaned + "]");

  String tagName = uidNameMap.get(cleaned);
  if (tagName != null) {
    println("태그 이벤트 처리: " + tagName);
    processTagEvent(tagName);
  } else {
    println("색상 코드 처리: " + cleaned);
    processColorEvent(cleaned);
  }
}

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
