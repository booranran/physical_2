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
  // 1. 맵에 등록된 태그인지 확인
  if (uidNameMap.containsKey(uid)) {
    RfidInfo info = uidNameMap.get(uid);
    
    println(">> [태그 인식 성공] " + info.name + " (인덱스: " + info.boardIndex + ")");
    
    // 2. 해당 위치의 이벤트(processBoardIndex)를 실행!
    // (functions.pde에 있는 함수를 호출합니다)
    processBoardIndex(info.boardIndex);
    
  } else {
    // 등록되지 않은 태그일 경우
    println("!! 알 수 없는 태그 (UID: " + uid + ")");
  }
}
