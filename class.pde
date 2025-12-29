class RfidInfo {
  String name;
  int boardIndex;
  RfidInfo(String name, int boardIndex) {
    this.name = name;
    this.boardIndex = boardIndex;
  }
}


class RandomEvent {
  String description;
  int moneyChange;

  RandomEvent(String desc, int change) {
    description = desc;
    moneyChange = change;
  }
}

RandomEvent[] events = {
  new RandomEvent("길에서 지갑을 주웠다!", 1000),
  new RandomEvent("갑자기 소매치기를 당했다...", -150),
  new RandomEvent("복권에 당첨됐다!", 1500),
  new RandomEvent("과속 벌금 딱지를 끊겼다", -500),
  new RandomEvent("지인이 밥을 사줬다!", 100),
  new RandomEvent("휴대폰 액정이 깨졌다...", -200)
};

class Button {
  int x, y, w, h;
  String label;
  int idx;

  Button(int x, int y, int w, int h, String label, int idx) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.idx = idx;
  }

  void display() {
    fill(isMouseOver() ? 180 : 200);
    rect(x, y, w, h, 5);
    fill(0);
    textSize(16);
    text(label, x + w/2, y + h/2 + 5);
  }

  boolean isMouseOver() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}

class Player {
  int id;
  int money;
  String name;
  boolean isBankrupt;
  boolean isIslanded;
  int islandTurns;
  int position;
  
    // 시각화 변수
  float visualX, visualY;
  ArrayList<PVector> pathQueue; // ★ 변수 선언
  boolean isMoving = false;
  float moveSpeed = 0.1;
  
  //결혼 관련 변수
  boolean isMarried = false; //상태값
  boolean UR_Married = false; //중복 방지용

  String currentJob = "";
  int currentSalary = 0;
  boolean isHired = false; //상태값
  boolean UR_Hired = false; //중복 방지용

  //투자 관련 변수
  boolean isInvest_01 = false;
  boolean UR_Invest_01 = false;
  int investAmount_01 = 0;

  boolean isInvest_02 = false;
  boolean UR_Invest_02 = false;
  int investAmount_02 = 0;

  //주택 관련 변수
  boolean isHome_01 = false;
  boolean UR_Home_01 = false;
  boolean isHome_02 = false;
  boolean UR_Home_02 = false;
  
  int myHomePrice = 0;
  String myHomeName = "";
  
  boolean isgoal = true;
  boolean UR_Goal = true;
  boolean isFinished = false;

  Player(int id, String name, int startMoney) {
    this.id = id;
    this.name = name;
    this.money = startMoney;
    this.isFinished = false;
     // ★★★ [중요] 이 줄이 없으면 무조건 널포인트 에러 남! ★★★
    this.pathQueue = new ArrayList<PVector>(); 
    
    // 위치 초기화 (일단 0으로)
    this.visualX = 0;
    this.visualY = 0;
    
    this.myHomePrice = 0;
    this.myHomeName = "";   
  }
  
  void updateAndDraw() {
    if (pathQueue.size() > 0) {
      isMoving = true;
      PVector target = pathQueue.get(0);
      visualX = lerp(visualX, target.x, moveSpeed);
      visualY = lerp(visualY, target.y, moveSpeed);
      
      if (dist(visualX, visualY, target.x, target.y) < 2.0) {
        visualX = target.x;
        visualY = target.y;
        pathQueue.remove(0);
      }
    } else {
      if (isMoving) {
        isMoving = false;
        handlePlayerArrival(this.id); // 도착 완료 처리
      }
    }

    // 경로 그리기 (빨간 점선)
    if (pathQueue.size() > 0) {
      stroke(255, 100, 100); strokeWeight(3); noFill();
      beginShape();
      vertex(visualX, visualY);
      for (PVector p : pathQueue) vertex(p.x, p.y);
      endShape();
    }
    
    drawAvatar(); // 내 자동차 그리기
  }

  void drawAvatar() {
    rectMode(CENTER); noStroke();
    if (id == 1) fill(50, 50, 255); else fill(255, 50, 50);
    rect(visualX, visualY, 30, 20, 5);
    fill(0); textAlign(CENTER); textSize(12);
    text("P" + id, visualX, visualY);
  }
  
}
