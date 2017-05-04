import controlP5.*;

ControlP5 controller;

Flock flock;
String[] alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
PVector missionPoint; 
float s = 1.0;
float a = 1.0;
float c = 1.0;
float m = 0.01;
float maxforce = 0.03;    // Maximum steering force
float maxspeed = 2;    // Maximum speed
int N = 0;
float masse = 1;

int controllerSize = 200;
enum BoidType {TRIANGLE, LETTER, CIRCLE, LINE;}
enum BorderType {WALLS, BOUCLES, NOBORDER;}
BoidType boidType;
BorderType borderType;

void setup() {
  fullScreen(P2D, SPAN);
  flock = new Flock();
  missionPoint = new PVector(controllerSize/2 + width/2,height/2);
  boidType = BoidType.LINE;
  borderType = BorderType.WALLS;
  
  controller = new ControlP5(this);
  controller.addSlider("m")
            .setPosition(50,50)
            .setRange(0.01,4);
  controller.addSlider("s")
            .setPosition(50,100)
            .setRange(0.01,4);
  controller.addSlider("a")
            .setPosition(50,150)
            .setRange(0.01,4);
  controller.addSlider("c")
            .setPosition(50,200)
            .setRange(0.01,4);          
  controller.addSlider("maxforce")
            .setPosition(50,300)
            .setRange(0.01,1);           
  controller.addSlider("maxspeed")
            .setPosition(50,350)
            .setRange(0.01,10);
  controller.addSlider("N")
            .setPosition(50,400)
            .setRange(0,1000);
  controller.addSlider("masse")
            .setPosition(50,450)
            .setRange(0.1,2);
            
  controller.addButton("triangle")
            .setPosition(50,height-50);
  controller.addButton("letter")
            .setPosition(50,height-70);
  controller.addButton("circle")
            .setPosition(50,height-90);
  controller.addButton("line")
            .setPosition(50,height-110);
  controller.addButton("walls")
            .setPosition(50,height-150);
  controller.addButton("boucles")
            .setPosition(50,height-170);
  controller.addButton("no_border")
            .setPosition(50,height-190);
}
public void triangle(){  boidType = BoidType.TRIANGLE; }
public void letter(){  boidType = BoidType.LETTER; }
public void circle(){  boidType = BoidType.CIRCLE; }
public void line(){  boidType = BoidType.LINE; }
public void walls() { borderType = BorderType.WALLS; }
public void boucles() { borderType = BorderType.BOUCLES; }
public void no_border() { borderType = BorderType.NOBORDER; }

void draw() {
  background(0);
  fill(30,67,100);
  rect(controllerSize-4,0,4,height);
  ellipse(missionPoint.x,missionPoint.y,10,10);
  flock.run();
  
  if (flock.boids.size() < N)
    flock.addBoid(new Boid(random(controllerSize,width),random(0,height)));
  else if (flock.boids.size() > N)
    flock.boids.remove(flock.boids.size()-1);
}

void keyPressed()
{
  if (key == 'a')
  {
    for (int i = 0; i < 10; i++) {
    flock.addBoid(new Boid(controllerSize,random(0,height)));   
    flock.addBoid(new Boid(width,random(0,height)));
    flock.addBoid(new Boid(random(controllerSize,width),0));
    flock.addBoid(new Boid(random(controllerSize,width),height));
  }
  }
}
// Add a new boid into the System
void mouseReleased() {
  if (mouseX>controllerSize)
  {
    //m = 0.001;
    //s=4;
  }
}

void mousePressed()
{
  if (mouseX>controllerSize){
    //m=1.0;
  }
}

void mouseDragged()
{
  if (mouseX>controllerSize)
    missionPoint.set(mouseX,mouseY);
}