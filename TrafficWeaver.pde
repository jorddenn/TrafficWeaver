ArrayList<Car> cars = new ArrayList<Car>();
Line[] lines = new Line[21];

//max desnity = 129 
int density = 3;

int[] slot = {1000, 1000, 1000, 1000};

int speed = 5;

void setup(){
  size(500, 1000);
  
  for (int r = 0; r < lines.length; r += 3){
    lines[r] = new Line (145, 0 + r * 50, 5);
    lines[r + 1] = new Line (245, 0 + r * 50, 5);
    lines[r + 2] = new Line (345, 0 + r * 50, 5);
  }
}

void generateCars(){
  for (int i = 0; i < slot.length; i++){
    if ((random(33*4) < density) && (slot[i] > (125 / speed))){
      cars.add(new Car(75 + 100*i, 0 - 125, speed));
      slot[i] = 0;
    }
    slot[i]++;
  }
}

void removeCars(){
  for (Car cur: cars){
    if (cur.y > height){
      cur = null;
    }
  }
}

void draw(){
  background(100);
  fill(255, 255, 0);
  noStroke();
  rect(45, 0, 10, height);
  rect(445, 0, 10, height);
  
  removeCars();
  generateCars();
  
  for (int i = 0; i < cars.size(); i++){
    cars.get(i).update();
    cars.get(i).show();
  }
  
  for (int r = 0; r < lines.length; r++){
    lines[r].update();
    lines[r].show();
  }
}
