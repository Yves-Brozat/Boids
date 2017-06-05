/*
YVES BROZAT - BOIDS : MODELE PHYSIQUE DE SYSTEME PARTICULAIRE

EN COURS :
- Creer des forces environnementales, sur tout l'écran ou par zone : type vent, gravité, tourbillon (coriolis ?), poussée d'Archimede, milieux visqueux 
- Creer des autres objets (des brosses ?) type Attractor, Repulsor, Source, Blackhole pour interaction de tracking

IDEES : 
- Creer des bangs (WALL puis NO_BORDER, MASSE = 0 puis normal, FORCE = 0, SPEED = 0, ...) pour une interaction ponctuelle (type break) ou répétitive (type beat)
- Creer des decoupes ronde, triangle et carre pour remplacer les borders de la fenetre et contenir les éléments
- Idem pour repousser les éléments (interaction de tracking)
- Ajouter slider pour régler la taille des zones de forces de groupe
- Utiliser la donnée du nombre de voisins proches (pour un changement visuel, une fusion ou une fission)
- Création de chemins à suivre (droite, courbe, cercle)
- Creer un interupteur noir/blanc
- Réflexion sur la couleur : aléatoire, changement de teinte via 2 sliders sur l'ensemble des couleurs
*/

import controlP5.*;
import netP5.*;
import oscP5.*;

ControlP5 controller;

CheckBox src;
CheckBox mag;
CheckBox obs;
Accordion accordion;
Flock flock;

int controllerSize = 200;
int backgroundColor;

enum BoidType {TRIANGLE, LETTER, CIRCLE, BUBBLE, LINE, CURVE;}
enum BorderType {WALLS, LOOPS, NOBORDER;}
BorderType borderType;
ArrayList<String> alphabet;

void setup() {
  size(1366,703,P2D);
  setAlphabet();
  flock = new Flock();
  gui();  
}

void draw() {
  background(backgroundColor);
  flock.run(); 
}

void mouseDragged(){
  flock.mouseDragged();
}

void mousePressed(){
  flock.mousePressed();
}

void mouseReleased(){
  flock.mouseReleased();
}

public void gui()
{
  controller = new ControlP5(this);
  
  //Group 1 : Global parameters
  Group g1 = controller.addGroup("Global physical parameters")
                       .setBackgroundColor(color(0, 64))
                       .setBackgroundHeight(180)
                       ;
                       
  controller.addSlider("N")
            .setPosition(10,10)
            .setRange(0,1000)
            .moveTo(g1)
            ;
  controller.addSlider("maxforce")
            .addListener(flock)
            .setPosition(10,20)
            .setRange(0.01,1)
            .setValue(0.03)
            .moveTo(g1)
            ;           
  controller.addSlider("maxspeed")
            .addListener(flock)
            .setPosition(10,30)
            .setRange(0.01,20)
            .setValue(20)
            .moveTo(g1)
            ;
  controller.addSlider("k_density")
            .addListener(flock)
            .setPosition(10,40)
            .setRange(0.1,2)
            .setValue(1.0)
            .moveTo(g1)
            ;
  controller.addSlider("lifespan")
            .addListener(flock)
            .setPosition(10,50)
            .setRange(1,1000)
            .setValue(100)
            .moveTo(g1)
            ;
            
  controller.addSlider("trailLength")
            .addListener(flock)
            .setPosition(10,60)
            .setRange(0,20)
            .setValue(0)
            .moveTo(g1)
            ; 
  
  controller.addSlider("size")
            .addListener(flock)
            .setPosition(10,70)
            .setRange(0.1,10)
            .setValue(1.0)
            .moveTo(g1)
            ; 
  src = controller.addCheckBox("Sources")
            .setPosition(10,94)
            .setSize(25,25)
            .setItemsPerRow(4)
            .addItem("S1", 0)
            .addItem("S2", 1)
            .addItem("S3", 2)
            .addItem("Source", 3)      
            .moveTo(g1)
            ;
  
  mag = controller.addCheckBox("Magnets")
            .setPosition(10,120)
            .setSize(25,25)
            .setItemsPerRow(4)
            .addItem("M1", 0)
            .addItem("M2", 1)
            .addItem("M3", 2)
            .addItem("Magnet", 3)      
            .moveTo(g1)
            ;
            
 obs = controller.addCheckBox("Obstacles")
            .setPosition(10,146)
            .setSize(25,25)
            .setItemsPerRow(4)
            .addItem("O1", 0)
            .addItem("O2", 1)
            .addItem("O3", 2)
            .addItem("Obstacle", 3)      
            .moveTo(g1)
            ;
  //Group 2 : Forces
  Group g2 = controller.addGroup("Forces")
                       .setBackgroundColor(color(0, 64))
                       .setBackgroundHeight(150)
                       ;                      
                       
  controller.addSlider("separation")
            .addListener(flock)
            .setPosition(10,10)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("alignment")
            .addListener(flock)
            .setPosition(10,20)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("cohesion")
            .addListener(flock)
            .setPosition(10,30)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("attraction")
            .addListener(flock)
            .setPosition(10,50)
            .setRange(0.01,4)
            .moveTo(g2)
            ;
  controller.addSlider("gravity")
            .addListener(flock)
            .setPosition(10,70)
            .setRange(0.01,4)
            .setValue(0.01)
            .moveTo(g2)
            ;
  controller.addKnob("gravity_Angle")
            .addListener(flock)
            .setPosition(50,90)
            .setResolution(100)
            .setRange(0,360)
            .setAngleRange(2*PI)
            .setStartAngle(0.5*PI)
            .setRadius(10)
            .moveTo(g2)
            ;
  controller.addSlider("friction")
            .addListener(flock)
            .setPosition(10,130)
            .setRange(0.001,0.1)
            .moveTo(g2)
            ;

  //Group 3 : Visual parameters
  Group g3 = controller.addGroup("Visual parameters")
                       .setBackgroundColor(color(0, 64))
                       .setBackgroundHeight(250)
                       ;  
  
  controller.addRadioButton("Visual")
            .addListener(flock)
            .setPosition(10,10)
            .setItemWidth(20)
            .setItemHeight(20)
            .addItem("triangle", 0)
            .addItem("letter", 1)
            .addItem("circle", 2) 
            .addItem("bubble",3)
            .addItem("line", 4)
            .addItem("curve", 5)
            .setColorLabel(color(255))
            .activate(4) //Line par défaut
            .moveTo(g3)
            ;          
  
  controller.addColorWheel("particleColor",90,10,100)
            .setRGB(color(255))
            .moveTo(g3)
            ;
            
  controller.addColorWheel("backgroundColor",90,130,100)
            .setRGB(color(0))
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
            .addItem("loops", 1)
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

void controlEvent(ControlEvent theEvent) { 
  //println (theEvent.getName() + " " + theEvent.getValue() + " " );
  if(theEvent.isFrom("Visual")){
      switch(int(theEvent.getValue())) {
        case(0):flock.boidType = BoidType.TRIANGLE;break;
        case(1):flock.boidType = BoidType.LETTER;break;
        case(2):flock.boidType = BoidType.CIRCLE;break;
        case(3):flock.boidType = BoidType.BUBBLE;break;
        case(4):flock.boidType = BoidType.LINE;break;
        case(5):flock.boidType = BoidType.CURVE;break;
      }
      for (int i = flock.boids.size()-1; i>=0; i--){
        switch(int(theEvent.getValue())) {
          case(0):  TriangleBoid t = new TriangleBoid(flock.boids.get(i).position.x,flock.boids.get(i).position.y);  flock.addBoid(t); flock.boids.remove(i); break;
          case(1):  LetterBoid l = new LetterBoid(flock.boids.get(i).position.x,flock.boids.get(i).position.y);  flock.addBoid(l); flock.boids.remove(i);  break;
          case(2):  CircleBoid c = new CircleBoid(flock.boids.get(i).position.x,flock.boids.get(i).position.y);  flock.addBoid(c); flock.boids.remove(i);  break;
          case(3):  BubbleBoid bu = new BubbleBoid(flock.boids.get(i).position.x,flock.boids.get(i).position.y);  flock.addBoid(bu); flock.boids.remove(i);  break;
          case(4):  LineBoid li = new LineBoid(flock.boids.get(i).position.x,flock.boids.get(i).position.y);  flock.addBoid(li); flock.boids.remove(i);  break;
          case(5):  CurveBoid cu = new CurveBoid(flock.boids.get(i).position.x,flock.boids.get(i).position.y);  flock.addBoid(cu); flock.boids.remove(i);  break;
        }
      }
    }  
  if (theEvent.isFrom("Borders type")) {
    switch(int(theEvent.getValue())) {
      case(0):borderType = BorderType.WALLS;break;
      case(1):borderType = BorderType.LOOPS;break;
      case(2):borderType = BorderType.NOBORDER;break;
    }
  }
  
  if (theEvent.isFrom(src)){
    for (int i = 0; i<src.getArrayValue().length; i++){
      flock.sources.get(i).isActivated = src.getState(i);
    }
  }
  
  if (theEvent.isFrom(mag)){
    for (int i = 0; i<mag.getArrayValue().length; i++){
      flock.magnets.get(i).isActivated = mag.getState(i);
    }
  }
  
  if (theEvent.isFrom(obs)){
    for (int i = 0; i<obs.getArrayValue().length; i++){
      flock.obstacles.get(i).isActivated = obs.getState(i);
    }
  }
  
  //if(theEvent.isFrom("color")){
  //  println(controller.get(ColorWheel.class, "color").getRGB());
  //  for (Boid b : flock.boids)
  //    b.c = controller.get(ColorWheel.class, "color").getRGB();
  //}
}

void setAlphabet(){
  alphabet = new ArrayList<String>();
  alphabet.add("Z");
  alphabet.add("W");
  for (int i = 0; i<2; i++){
    alphabet.add("K");
    alphabet.add("J");
    alphabet.add("X");
  }
  for (int i = 0; i<3; i++) alphabet.add("Y");
  for (int i = 0; i<4; i++) alphabet.add("Q");
  for (int i = 0; i<7; i++){
    alphabet.add("F");
    alphabet.add("H");
    alphabet.add("V");
    alphabet.add("B");
  }
  for (int i = 0; i<8; i++) alphabet.add("G");
  for (int i = 0; i<16; i++) alphabet.add("P");
  for (int i = 0; i<17; i++) alphabet.add("M");
  for (int i = 0; i<18; i++) alphabet.add("C");
  for (int i = 0; i<24; i++) alphabet.add("D");
  for (int i = 0; i<30; i++) alphabet.add("U");
  for (int i = 0; i<33; i++){
    alphabet.add("L");
    alphabet.add("O");
  }
  for (int i = 0; i<39; i++) alphabet.add("T");
  for (int i = 0; i<40; i++) alphabet.add("R");
  for (int i = 0; i<42; i++) alphabet.add("N");
  for (int i = 0; i<43; i++) alphabet.add("S");
  for (int i = 0; i<44; i++) alphabet.add("I");
  for (int i = 0; i<47; i++) alphabet.add("A");
  for (int i = 0; i<93; i++) alphabet.add("E");  
}