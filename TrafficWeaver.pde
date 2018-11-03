import controlP5.*;

//control object library
ControlP5 p5;

//lists to hold everything
ArrayList<ArrayList<Point>> paths = new ArrayList<ArrayList<Point>>();
ArrayList<Point> pathPoints = new ArrayList<Point>();
ArrayList<Car> cars = new ArrayList<Car>();
Line[] lines;
int[] slot;

//variables outside of the user
int speed; 
float density;
int lanes;

//decorations
int stepR;
int stepG;
int stepB;
int newR;
int newG;
int newB;
int count = 0;
boolean shift = false;

//users car using alternate constructor
Car user = new Car(175, 800);

void setup(){
  size(500, 1100);
  
  p5 = new ControlP5(this);
  
  //name, minimum, maximum, default value (float), x, y, width, height //typical variable order
  p5.addSlider("desnity", 1, 10, 1, 10, 1005, 200, 25);
  p5.addSlider("lanes", 1, 10, 4, 10, 1037, 200, 25);
  p5.addSlider("speed", 1, 20, 5, 10, 1070, 200, 25);
  p5.addButton("left").setPosition(275, 1015).setSize(75, 25);
  p5.addButton("right").setPosition(375, 1015).setSize(75, 25);
  p5.addKnob("r", 0, 255, 255, 275, 1050, 30);
  p5.addKnob("g", 0, 255, 255, 315, 1050, 30);
  p5.addKnob("b", 0, 255, 255, 355, 1050, 30);
  p5.addToggle("shift").setPosition(405, 1050).setSize(30, 30);
 
  //set intitally but can be changed later, these are a good example
  speed = 5;
  density = 1;
  lanes = 4;
  
  //removed to a function because it needs to run mutiple times if variables change
  snlSetup();
}

void snlSetup(){
  slot = new int[lanes]; //timer used for spawning new cars, one for each lane
  lines = new Line[((height/150) + 1) * (lanes - 1)]; //height div spacing plus one for the delay in resetting //only need lane markes between 2 lanes 
  
  for (int r = 0; r < lanes - 1; r++){
    for(int t = 0; t < (height/150) + 1; t++){
      lines[(lanes - 1) * t + r] = new Line (145 + 100 * r, 0 + t * 150, speed);
    }
  }
}

void generateCars(){ //spawn cars according to the density variable //at standard speed of 5, 1 and 2 are the best
  for (int i = 0; i < lanes; i++){
    if ((random(33*4) < density) && (slot[i] > (125 / speed))){
      cars.add(new Car(75 + 100*i, 0 - 125, speed));
      slot[i] = 0;
    }
    slot[i]++;
  }
}

void removeCars(){ // remove cars once theyre offscreen
  Iterator<Car> iter = cars.iterator();

  while (iter.hasNext()) {
    Car car = iter.next();

    if (car.y > height)
        iter.remove();
  }
}

void generatePaths(ArrayList<Point> curPath, Point curPoint){//recursive pathfinding
  Car nextClosest = new Car(-100, -1000, 0);
  for(Car car : cars){ //gets the car in front of the user, in the same lane
    if (car.x == curPoint.x){
      if (car.y < curPoint.y && car.y > nextClosest.y && curPoint.y - car.y >= 175){
        nextClosest = car;
      }
    }
  }
  
  if (curPoint.y <= 0){ //if the recursion reaches the top of the screen then terminate
    curPath.add(curPoint);
    paths.add(curPath);
  }
  else if (curPoint.y - nextClosest.y > 175){ // if the car isnt within carlength plus buffer (175) move forward by speed amount
    generatePaths(curPath, new Point(curPoint.x, curPoint.y - speed));
  }
  else if (curPoint.y - nextClosest.y <= 175){ // if the car is within carlength plus buffer (175) move forward by speed amount
    curPath.add(curPoint); //add point to current path
    if (checkSides(curPoint, true)){ //branch left and right, copying a new current path for each, moving to the next lane, add another point and recursing
      ArrayList<Point> lPath = new ArrayList<Point>();
      for (Point p : curPath){
        lPath.add(new Point(p.x, p.y));
      }
      Point lPoint = new Point(curPoint.x - 100, curPoint.y);
      lPath.add(lPoint);
      generatePaths(lPath, lPoint);
    }
    if (checkSides(curPoint, false)){
      ArrayList<Point> rPath = new ArrayList<Point>();
      for (Point p : curPath){
        rPath.add(new Point(p.x, p.y));
      }
      Point rPoint = new Point(curPoint.x + 100, curPoint.y);
      rPath.add(rPoint);
      generatePaths(rPath, rPoint);
    } //if not at the top of the screen and against a car in front and cant move to either side then stuck, add point and terminate
    if (!checkSides(curPoint, false) && !checkSides(curPoint, true)){
      curPath.add(curPoint);
      paths.add(curPath);
    }
  }
  
}

boolean checkSides(Point curPoint, boolean left){ //function checks if its safe to switch lanes, turn signal AND a shoulder check
  if(curPoint.x / 100 == 0 && left) return false; //already in left most lane
  if(curPoint.x / 100 == lanes - 1 && !left) return false; //already in right most lane
  
  ArrayList<Car> lane = new ArrayList<Car>();
  
  for(Car car : cars){ // calculates the cars in the next lane, depending on direction
    if (car.x == curPoint.x - 100 && left){
      lane.add(car);
    }
    if (car.x == curPoint.x + 100 && !left){
      lane.add(car);
    }
  }
  
  if (lane.size() == 0) return true; //if the lane is found to be empty then its safe to move
  
  if ((lane.size() == 1) && (lane.get(0).y + 175 <= curPoint.y || lane.get(0).y >= curPoint.y + 125)){ //if only one car and its not in the way then move
    return true;
  }
  
  sort(lane); //the array list cars isnt sorted but order is important here
  
  for (int i = 0; i < lane.size() - 1; i++){ //if the gab between the 2 closest cars ahead and behind is big enough and the one head is far enough ahead and the one behind is far enough behind then its safe to move
    if ((lane.get(i + 1).y - lane.get(i).y > 300) && (curPoint.y > lane.get(i).y + 175) && (curPoint.y + 175 < lane.get(i + 1).y)){
      return true;
    }
  }
  
  return false; //if the only possible conditions are not met then the user cant change lanes
}

void sort(ArrayList<Car> lane){ //simple bubble sort
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

void controlEvent(ControlEvent theEvent) {// event handlers for the control buttons
  if(theEvent.isController()) { 
    print("control event from : "+theEvent.getController().getName());
    println(", value : "+theEvent.getController().getValue());
    if(theEvent.getController().getName()=="desnity") {
      density = floor(theEvent.getController().getValue());
    }
    if(theEvent.getController().getName()=="speed") {
      speed = floor(theEvent.getController().getValue());
      
      for (Car car : cars){
        car.speed = speed;
      }
      for (Line line : lines){
        line.speed = speed;
      }
    }
    if(theEvent.getController().getName()=="lanes") {
      lanes = floor(theEvent.getController().getValue());
      snlSetup();
    }
    
    if(theEvent.getController().getName()=="left") {
      if(user.x / 100 != 0){
        user.x -= 100;
      }
    }
    
    if(theEvent.getController().getName()=="right") {
      if(user.x / 100 != lanes - 1){
        user.x += 100;
      }
    }
    
    if(theEvent.getController().getName()=="r") {
      user.r = int(theEvent.getController().getValue());
    }
    
    if(theEvent.getController().getName()=="g") {
      user.g = int(theEvent.getController().getValue());
    }
    
    if(theEvent.getController().getName()=="b") {
      user.b = int(theEvent.getController().getValue());
    }
    
    if(theEvent.getController().getName()=="shift") {
      shift = (theEvent.getController().getValue() == 1.0);
    }
  }
}

void draw(){  
  surface.setSize(100 + 100 * lanes, height); // resize to fit all lanes
  background(100);
  fill(255, 255, 0);
  noStroke();
  strokeWeight(1);
  rect(45, 0, 10, height);
  rect(45 + 100 * lanes, 0, 10, height);
  
  removeCars(); // remove offscreen
  generateCars(); //make new ones
  
  for (int i = 0; i < cars.size(); i++){ //update poisitions and display
    cars.get(i).update();
    cars.get(i).show();
  }
  
  for (int r = 0; r < lines.length; r++){ //update positions and display
    lines[r].update();
    lines[r].show();
  }
  
  if (shift){ //if colour shift is on then pick a new and shift
    if (count <= 0){
      newR = int(random(255));
      newG = int(random(255));
      newB = int(random(255));
      while ((abs(user.r - newR) + abs(user.g - newG) + abs(user.b - newB)) < 250){ //tries to ensure the new colour is much different than the current for a better effect
        newR = int(random(255));
        newG = int(random(255));
        newB = int(random(255));
      }
      count = 100;
      
      stepR = (user.r - newR) / count; //smoothly steps towars the new colour over 'count' steps
      stepG = (user.g - newG) / count;
      stepB = (user.b - newB) / count;
    }
    user.r -= stepR;
    user.g -= stepG;
    user.b -= stepB;
    
    count--;
  }
  
  user.show();
  
  paths.clear(); //clear old paths
  pathPoints.clear();
  
  pathPoints.add(new Point(user.x, user.y)); //add the seed, the users position

  generatePaths(pathPoints, pathPoints.get(0)); //generate paths
  
  for (int p = 0; p < paths.size(); p++){ //draw a line, point to point for every path in paths
    stroke(140 * (p + 1), 50 * (p + 1), 80 * (p + 1)); //change the path coulour based on its index for differentiation
    strokeWeight(5);
    for (int pp = 0; pp < paths.get(p).size() - 1; pp++){
      line(paths.get(p).get(pp).x + 25 + (5 * p), paths.get(p).get(pp).y + (5 * p), paths.get(p).get(pp + 1).x + 25 + (5 * p), paths.get(p).get(pp + 1).y + (5 * p));
    }
  }
  
  //block out the bottom for the controls
  noStroke();
  fill(0);
  rect(0, 1000, width, 100);
}
