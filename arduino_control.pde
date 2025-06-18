//void serialEvent(Serial p) {

//  try {
//    String rawUidStr = p.readStringUntil('\n');
//    if (rawUidStr == null) return;
    
//    rawUidStr = trim(rawUidStr);
//    if (rawUidStr.equals("")) return;

//    String cleanedUid = rawUidStr.replaceAll("\\s+", "").toUpperCase();
//    println("ESP32로부터 UID 수신: " + cleanedUid);

//    String tagName = uidNameMap.get(cleanedUid);
//    if (tagName != null) {
//      processTagEvent(tagName);
//    } else {
//      println("알 수 없는 태그: " + cleanedUid);
//    }

//  } catch (Exception e) {
//    println("serialEvent 내부 에러: " + e.getMessage());
//  }
  
//  String colorCode = trim(p.readStringUntil('\n')).toUpperCase();
//  println("받은 색상: " + colorCode);
//  processColorEvent(colorCode);
//}


//태그 기반 이벤트 처리
void processTagEvent(String uid) {
  if (uid.equals("TAG_MARRY_001")) {
    showMarriagePopup = true;
  } 
  else if (uid.equals("TAG_JOB_001") || uid.equals("TAG_JOB_002")) {
    showHiredPopup = true;
  }
  else if (uid.equals("TAG_INVEST_001") && !isInvest_01) {
    showInvestPopup = true;
  } 
  else if (uid.equals("TAG_INVEST_002") && !isInvest_02) {
    showInvestPopup = true;
  }
  else if (uid.equals("TAG_HOME_001") || uid.equals("TAG_HOME_002")) {
    showHomePopup = true;
  }
  else if (uid.equals("TAG_RANDOM_EVENT_001") || uid.equals("TAG_RANDOM_EVENT_002") ||  uid.equals("TAG_RANDOM_EVENT_003")) {
    showHomePopup = true;
  }
  
  else if (uid.equals("TAG_GOAL")) {
    displayGoalResult();
    showGoalPopup = true;
  }
  
  else {
    println("알 수 없는 태그");
  }
}

//색상 기반 이벤트 처리
void processColorEvent(String colorCode) {
  switch(colorCode) {
    
    case "RED":  // 월급 색상
      if (isHired) {
        money += currentSalary;
        resultMessage = "월급 지급! +" + currentSalary + "원";
      } else {
        resultMessage = "직업이 없어 월급 없음!";
      }
      break;

    case "BLUE":  // RFID 이벤트를 트리거할 색상
      // RFID 태그 판독 대기 or 별도 이벤트
      resultMessage = "RFID 이벤트 구간 도착!";
      break;
      
    case "GREEN":  // 예: 아무 이벤트 없음
      resultMessage = "안전 구간입니다.";
      break;

    default:
      resultMessage = "특별한 이벤트 없음.";
      break;
  }

  resultShowTime = millis();
}
