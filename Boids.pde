/*
YVES BROZAT - BOIDS : MODELE PHYSIQUE DE SYSTEME PARTICULAIRE

EN COURS :
- Creer des forces environnementales, sur tout l'écran ou par zone : type vent, gravité, tourbillon (coriolis ?), poussée d'Archimede, milieux visqueux 

IDEES : 
- Creer des bangs (WALL puis NO_BORDER, MASSE = 0 puis normal, FORCE = 0, SPEED = 0, ...) pour une interaction ponctuelle (type break) ou répétitive (type beat)
- Creer des autres objets (des brosses ?) type Attractor, Repulsor, Source, Blackhole pour interaction de tracking
- Creer des decoupes ronde, triangle et carre pour remplacer les borders de la fenetre et contenir les éléments
- Idem pour repousser les éléments (interaction de tracking)
- Ajouter slider pour régler la taille des zones de forces de groupe
- Utiliser la donnée du nombre de voisins proches (pour un changement visuel, une fusion ou une fission)
- Création de chemins à suivre (droite, courbe, cercle)
- Creer un interupteur noir/blanc
- Réflexion sur la couleur : aléatoire, changement de teinte via 2 sliders sur l'ensemble des couleurs*/

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
float gravity = 1.0;
int gravity_Angle = 0;
PVector missionPoint; 
float FRICTION = 0.001;

//Global physical parameters
int N = 0; // Number of boid
float maxforce = 0.03;    // Maximum steering force
float maxspeed = 2.0;    // Maximum speed
float MASSE = 1.0;


//Visual parameters
int trailLength = 1;
int lineSize = 30;
int curveSize = 30;
enum BoidType {TRIANGLE, LETTER, CIRCLE, LINE, CURVE;}
BoidType boidType;
enum BorderType {WALLS, BOUCLES, NOBORDER;}
BorderType borderType;
String[] alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};

void setup() {
  size(1366,703,P2D);
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
  controller.addSlider("MASSE")
            .setPosition(10,40)
            .setRange(0.1,2)
            .moveTo(g1)
            ;
  
  //Group 2 : Forces
  Group g2 = controller.addGroup("Forces")
                       .setBackgroundColor(color(0, 64))
                       .setBackgroundHeight(150)
                       ;                      
                       
  controller.addSlider("separation")
            .setPosition(10,10)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("alignment")
            .setPosition(10,20)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("cohesion")
            .setPosition(10,30)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
 controller.addSlider("attraction")
            .setPosition(10,50)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("gravity")
            .setPosition(10,70)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addKnob("gravity_Angle")
            .setPosition(50,90)
            .setResolution(100)
            .setRange(0,360)
            .setAngleRange(2*PI)
            .setStartAngle(0.5*PI)
            .setRadius(10)
            .moveTo(g2)
            ;
  controller.addSlider("FRICTION")
            .setPosition(10,110)
            .setRange(0.001,0.1)
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
            .addItem("curve", 4)
            .setColorLabel(color(255))
            .activate(0) //Triangle par défaut
            .moveTo(g3)
            ;
 
  controller.addSlider("trailLength")
            .setPosition(10,120)
            .setRange(1,20)
            .moveTo(g3)
            ; 
  
  controller.addSlider("lineSize")
            .setPosition(80,72)
            .setSize(70,20)
            .setRange(10,100)
            .moveTo(g3)
            ;
  controller.addSlider("curveSize")
            .setPosition(80,94)
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
            .activate(1) //Boucle par defaut
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
      case(3):boidType = BoidType.LINE;break;
      case(4):boidType = BoidType.CURVE;break;
    }
  }
}