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

  boolean isgoal = true;
  boolean UR_Goal = true;


  ArrayList<String> ownedCountries = new ArrayList<String>();

  Player(int id, String name, int startMoney) {
    this.id = id;
    this.name = name;
    this.money = startMoney;
  }
}
