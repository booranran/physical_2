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
