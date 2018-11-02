ArrayList<ArrayList<Point>> paths = new ArrayList<ArrayList<Point>>();
ArrayList<Point> pathPoints = new ArrayList<Point>();

ArrayList<Car> cars = new ArrayList<Car>();
Car user = new Car(175, 800);

Line[] lines;
int[] slot;

int DEEP = 0;

int speed; 
int density; //max desnity = 129
int lanes;

void setup(){
  size(500, 1000);
  speed = 5;
  density = 1;
  lanes = 4;
  
  slot = new int[lanes];
  lines = new Line[7*lanes];
  
  for (int r = 0; r < lanes; r++){
    for(int t = 0; t < 7; t++)
      lines[lanes * t + r] = new Line (145 + 100 * r, 0 + t * 150, 5);
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
  for (Car car: cars){
    if (car.y > height){
      car = null;
    }
  }
}

void generatePaths(ArrayList<Point> curPath, Point curPoint){
  //println(curPath.size());
  Car nextClosest = new Car(-100, -1000, 0);
  for(Car car : cars){
    if (car.x == curPoint.x){
      if (car.y < curPoint.y && car.y > nextClosest.y && curPoint.y - car.y >= 175){
        nextClosest = car; //<>//
      }
    }
  }
  if (curPoint.y <= 0){
    curPath.add(curPoint);
    paths.add(curPath);
  }
  else if (curPoint.y - nextClosest.y > 175){
    generatePaths(curPath, new Point(curPoint.x, curPoint.y - 5));
  }
  else if (curPoint.y - nextClosest.y <= 175){
    curPath.add(curPoint);
    paths.add(curPath);
    if (checkSides(curPoint, true)){
      ArrayList<Point> lPath = curPath;
      Point lPoint = new Point(curPoint.x - 100, curPoint.y);
      lPath.add(lPoint);
      generatePaths(lPath, lPoint);
    }
    if (checkSides(curPoint, false)){
      ArrayList<Point> rPath = curPath;
      Point rPoint = new Point(curPoint.x + 100, curPoint.y);
      rPath.add(rPoint);
      generatePaths(rPath, rPoint);
    }
  }
  
}

boolean checkSides(Point curPoint, boolean left){
  if(curPoint.y / 100 == 1 && left) return false; //already in left most lane
  if(curPoint.y / 100 == lanes && !left) return false; //already in right most lane
  
  ArrayList<Car> lane = new ArrayList<Car>();
  
  for(Car car : cars){
    if (car.x == curPoint.x - 100 && left){
      lane.add(car);
    }
    if (car.x == curPoint.x + 100 && !left){
      lane.add(car);
    }
  }
  
  sort(lane);
  
  for (int i = 0; i < lane.size() - 1; i++){
    if ((lane.get(i + 1).y - lane.get(i).y > 125) && (curPoint.y > lane.get(i).y) && (curPoint.y + 125 < lane.get(i + 1).y)){
      return true;
    }
  }
  
  return false;
}

void sort(ArrayList<Car> lane){
  for (int i = 0; i < lane.size()-1; i++){
    for (int r = 0; r < lane.size() - i - 1; r++){
      if (lane.get(r).y > lane.get(r + 1).y){
        Car temp = lane.get(r + 1);
        lane.set(r + 1, lane.get(r));
        lane.set(r, temp);
      }
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
  
  user.show();
  
  paths.clear();
  pathPoints.clear();
  
  pathPoints.add(new Point(user.x, user.y));
  
  generatePaths(pathPoints, pathPoints.get(0));
  
  for (int p = 0; p < paths.size(); p++){
    stroke(p + 10 * p);
    for (int pp = 0; pp < paths.get(p).size() - 1; pp++){
      line(paths.get(p).get(pp).x + 25, paths.get(p).get(pp).y, paths.get(p).get(pp + 1).x + 25, paths.get(p).get(pp + 1).y);
    }
  }
}
