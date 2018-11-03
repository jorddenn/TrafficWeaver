class Car{
  int x;
  int y;
  int speed;
  int r,g,b;
  
  Car(int x, int y, int speed){
    this.x = x;
    this.y = y;
    this.speed = speed;
    r = int(random(255));
    g = int(random(255));
    b = int(random(255));
  }
  
  Car(int x, int y){
    this.x = x;
    this.y = y;
    this.speed = 0;
    r = 255;
    g = 255;
    b = 255;
  }
  
  void update(){
    y += speed;
  }
  
  void show(){
    stroke(0);
    fill(r, g, b);
    rect(x, y, 50, 125, 5);
  }
  
  String toString(){
    return (x + ", " + y);
  }
}
