import processing.serial.*;

//Serial myPort;
String resultMessage = "";
int resultShowTime = -1;
int resultHoldDuration = 2000;
String systemStatus = "아두이노 연결 대기 중";

String lastRFID = "없음";
String lastColor = "없음";
color currentColor = color(240);
int errorCount = 0;

boolean newDataFlag = false;
boolean showDice = true;

HashMap<String, RfidInfo> uidNameMap = new HashMap<String, RfidInfo>(); //rfid uid 저장

boolean defalutPopup = true;


//취직 관련 변수
String[] jobs = {"개발자", "미용사", "스타트업 CEO", "알바"};
int[] salary = {2000, 1500, 3000, 1000};


boolean showHiredPopup = false;
boolean showMarriagePopup = false;
boolean showInvestPopup = false;

String investInput = "";
boolean isEnteringInvestment = false;

int currentInvestItem = 0;


boolean showHomePopup = false;

int purchasedHomePrice = 0;  // 구매한 집 가격 저장
String purchasedHomeName = "";  // 구매한 집 이름 저장

ArrayList<Button> homeButtons = new ArrayList<Button>();
boolean isSelectingHome = false;

boolean[] homePurchased = new boolean[4];
String[] homeOptions = {"아파트", "주택", "빌라", "펜트하우스"};
int[] homePrice = {50000, 60000, 45000, 100000};

//월급 관련 변수
int salaryCount = 0;
final int salaryLimit = 3;

//랜덤 관련 변수
boolean showEventPopup = false;

//골 관련 변수

boolean showGoalPopup = false;

ArrayList<String> goalMessages = new ArrayList<String>();
int goalMsgIndex = 0;
int goalMsgStartTime = 0;
int goalMsgInterval = 2000;  // 2초 간격

Button yesButton, noButton;
Button rollButton;

PFont font;
Player[] players;
int currentPlayer = 0;

Player p;
