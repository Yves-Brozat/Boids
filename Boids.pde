import controlP5.*;

ControlP5 controller;
Accordion accordion;
Flock flock;
int controllerSize = 200;

//Forces parameters
float separation = 1.0;
float alignment = 1.0;
float cohesion = 1.0;
float attraction = 0.01;
PVector missionPoint; 

//Global physical parameters
int N = 1; // Number of boid
float maxforce = 0.03;    // Maximum steering force
float maxspeed = 2;    // Maximum speed
float masse = 1;

//Visual parameters
int trailLength = 10;
int lineSize = 30;
enum BoidType {TRIANGLE, LETTER, CIRCLE, LINE;}
BoidType boidType;
enum BorderType {WALLS, BOUCLES, NOBORDER;}
BorderType borderType;
String[] alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};

void setup() {
  fullScreen(P2D, SPAN);
  flock = new Flock();
  missionPoint = new PVector(controllerSize/2 + width/2,height/2);
  
  gui();
  
}

void draw() {
  background(0);
  drawLayout();
  flock.run(); 
}

void mouseDragged()
{
  if (mouseX>controllerSize)
    missionPoint.set(mouseX,mouseY);
}

public void gui()
{
  controller = new ControlP5(this);
  
  //Group 1 : Global parameters
  Group g1 = controller.addGroup("Global physical parameters")
                       .setBackgroundColor(color(0, 64))
                       .setBackgroundHeight(150)
                       ;
                       
  controller.addSlider("N")
            .setPosition(10,10)
            .setRange(0,1000)
            .moveTo(g1)
            ;
  controller.addSlider("maxforce")
            .setPosition(10,20)
            .setRange(0.01,1)
            .moveTo(g1)
            ;           
  controller.addSlider("maxspeed")
            .setPosition(10,30)
            .setRange(0.01,10)
            .moveTo(g1)
            ;
  controller.addSlider("masse")
            .setPosition(10,40)
            .setRange(0.1,2)
            .moveTo(g1)
            ;
  
  //Group 2 : Forces
  Group g2 = controller.addGroup("Forces")
                       .setBackgroundColor(color(0, 64))
                       .setBackgroundHeight(150)
                       ;                      
                       
  controller.addSlider("attraction")
            .setPosition(10,10)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("separation")
            .setPosition(10,20)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("alignment")
            .setPosition(10,30)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("cohesion")
            .setPosition(10,40)
            .setRange(0.01,4)
            .moveTo(g2)
            ;          

  //Group 3 : Visual parameters
  Group g3 = controller.addGroup("Visual parameters")
                       .setBackgroundColor(color(0, 64))
                       .setBackgroundHeight(150)
                       ;  
  
  controller.addRadioButton("Visual")
            .setPosition(10,10)
            .setItemWidth(20)
            .setItemHeight(20)
            .addItem("triangle", 0)
            .addItem("letter", 1)
            .addItem("circle", 2) 
            .addItem("line", 3)
            .setColorLabel(color(255))
            .activate(0)
            .moveTo(g3)
            ;
 
  controller.addSlider("trailLength")
            .setPosition(10,100)
            .setRange(1,20)
            .moveTo(g3)
            ; 
  
  controller.addSlider("lineSize")
            .setPosition(80,72)
            .setSize(70,20)
            .setRange(10,100)
            .moveTo(g3)
            ;
            
  //Group 4 : Borders parameters
  Group g4 = controller.addGroup("Borders")
                       .setBackgroundColor(color(0, 64))
                       .setBackgroundHeight(150)
                       ;  
 
  controller.addRadioButton("Borders type")
            .setPosition(10,10)
            .setItemWidth(20)
            .setItemHeight(20)
            .addItem("walls", 0)
            .addItem("boucles", 1)
            .addItem("no_border", 2)
            .setColorLabel(color(255))
            .activate(2)
            .moveTo(g4)
            ;
            
            
  accordion = controller.addAccordion("acc")
                        .setPosition(0,0)
                        .setWidth(controllerSize)
                        .addItem(g1)
                        .addItem(g2)
                        .addItem(g3)
                        .addItem(g4)
                        ;
                        
  accordion.open(0,1,2,3);
  accordion.setCollapseMode(Accordion.MULTI);
}

public void drawLayout() {
  noStroke();
  fill(30,67,100);
  //rect(controllerSize-4,0,4,height);
  ellipse(missionPoint.x,missionPoint.y,10,10);
}

void controlEvent(ControlEvent theEvent) { 
  println (theEvent.getName() + " " + theEvent.getValue() + " " );
  if (theEvent.getName() == "Borders type") {
    switch(int(theEvent.getValue())) {
      case(0):borderType = BorderType.WALLS;break;
      case(1):borderType = BorderType.BOUCLES;break;
      case(2):borderType = BorderType.NOBORDER;break;
    }
  }
  
  if (theEvent.getName() == "Visual") {
    switch(int(theEvent.getValue())) {
      case(0):boidType = BoidType.TRIANGLE;break;
      case(1):boidType = BoidType.LETTER;break;
      case(2):boidType = BoidType.CIRCLE;break;
      case(3):boidType = BoidType.LINE;
    }
  }
}