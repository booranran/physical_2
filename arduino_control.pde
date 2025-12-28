import processing.serial.*;
Serial myPort;

void connectArduino() {
  for (String port : Serial.list()) {
    if (port.contains("usbmodem") || port.contains("COM")) {
      try {
        if (myPort != null) myPort.stop();
        myPort = new Serial(this, port, 9600);
        myPort.bufferUntil('\n');
        systemStatus = port + " 연결 성공!";
        return;
      }
      catch(Exception e) {
        systemStatus = "연결 실패: " + port;
      }
    }
  }
  systemStatus = "연결 가능 포트 없음!";
}

void sendResetCommand() {
  if (myPort != null) {
    myPort.write("RESET\n");
    systemStatus = "시스템 리셋 명령 전송";
  }
}

void serialEvent(Serial port) {
  String rawData = port.readStringUntil('\n');
  if (rawData == null) return;

  String data = trim(rawData);
  println("[수신] " + data);

  if (data.startsWith("EVENT:RFID=")) {
    processRfidEvent(data);
    port.write("RESUME\n");
  }
}

void processRfidEvent(String data) {
  try {
    String[] parts = splitTokens(data, "=&");
    if (parts.length < 4) return;

    // RFID 태그 파싱
    String uid = parts[1];
    lastRFID = uid;

    // 색상 파싱
    String colorStr = parts[3].toUpperCase();
    lastColor = colorStr;

    // RFID 태그 기반 이벤트
    processTagEvent(uid);

    // 색상 기반 이벤트
    //processColorEvent(colorStr);

    // 색상 표시용 변환 (화면용 색상 값)
    color detectedColor = color(150); // 기본 회색
    switch(colorStr) {
    case "RED":
      detectedColor = color(255, 60, 60);
      break;
    case "GREEN":
      detectedColor = color(60, 255, 60);
      break;
    case "BLUE":
      detectedColor = color(60, 60, 255);
      break;
    }
    currentColor = detectedColor;
    lastColor = colorStr + " (" + hex(detectedColor) + ")";

    newDataFlag = true;  // 새 데이터 도착 알림용
  }
  catch (Exception e) {
    errorCount++;
    println("이벤트 처리 실패: " + data);
  }
}

//태그 기반 이벤트 처리
void processTagEvent(String uid) {
  RfidInfo event = uidNameMap.get(uid);
  println(event);
  if (uid.equals("TAG_MARRY_001")) {
    showMarriagePopup = true;
  } else if (uid.equals("TAG_JOB_001") || uid.equals("TAG_JOB_002")) {
    showHiredPopup = true;
  } else if (uid.equals("TAG_INVEST_001") && !p.isInvest_01) {
    showInvestPopup = true;
  } else if (uid.equals("TAG_INVEST_002") && !p.isInvest_02) {
    showInvestPopup = true;
  } else if (uid.equals("TAG_HOME_001") || uid.equals("TAG_HOME_002")) {
    showHomePopup = true;
  } else if (uid.equals("TAG_RANDOM_EVENT_001") || uid.equals("TAG_RANDOM_EVENT_002") ||  uid.equals("TAG_RANDOM_EVENT_003")) {
    showEventPopup = true;
  } else if (uid.equals("TAG_GOAL")) {
    displayGoalResult();
    showGoalPopup = true;
  } else {
    println("알 수 없는 태그");
  }
}
