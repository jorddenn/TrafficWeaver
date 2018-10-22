class Line{
  int x;
  int y;
  int speed;
  
  Line(int x, int y, int speed){
    this.x = x;
    this.y = y;
    this.speed = speed;
  }
  
  void update(){
    if (y > height){
      y = -75;
    }
    y += speed;
  }
  
  void show(){
    fill(255, 255, 0);
    noStroke();
    rect(x, y, 10, 75);
  }
}
