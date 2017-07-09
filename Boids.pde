/*
YVES BROZAT - BOIDS : MODELE PHYSIQUE DE SYSTEME PARTICULAIRE

EN COURS :
- Creer des forces environnementales, sur tout l'écran ou par zone : type vent, gravité, tourbillon (coriolis ?), poussée d'Archimede, milieux visqueux 
- Creer des autres objets (des brosses ?) type Attractor, Repulsor, Source, Blackhole pour interaction de tracking
- Réflexion sur la couleur : aléatoire, changement de teinte via 2 sliders sur l'ensemble des couleurs
- Idem pour repousser les éléments (interaction de tracking)
- Creer un interupteur noir/blanc
- Utiliser la donnée du nombre de voisins proches (pour un changement visuel, une fusion ou une fission)

IDEES : 
- Creer des bangs (WALL puis NO_BORDER, MASSE = 0 puis normal, FORCE = 0, SPEED = 0, ...) pour une interaction ponctuelle (type break) ou répétitive (type beat)
- Creer des decoupes ronde, triangle et carre pour remplacer les borders de la fenetre et contenir les éléments
- Sablier
- Ajouter slider pour régler la taille des zones de forces de groupe
- Création de chemins à suivre (droite, courbe, cercle)
- Ressorts entre particules pour creer des tissus
- Garder en mémoire la position d'origine pour pouvoir y retourner
- Reorganiser l'accordeon : Extraire "Visuel particule", "Visuel Connection", "Source", 
- Ajout slider source : taille, orientation (velocity.heading() initiale), force (vitesse initiale), débit (nombre de particule créée par cycle)
- Ajout slider visuel particule : influence de la proximité sur la taille des particules
- Améliorer lettres de grande taille (avec scale() p.e au lieu de textSize())

*/

import controlP5.*;
import netP5.*;
import oscP5.*;
import java.util.Collections.*;

ControlP5 controller;
OscP5 osc;
Flock flock;

int controllerSize = 200;
boolean isRecording = false;

enum BoidType {TRIANGLE, LETTER, CIRCLE, BUBBLE, LINE, CURVE;}
enum BorderType {WALLS, LOOPS, NOBORDER;}
enum SourceType {O,I;}

BorderType borderType;
ArrayList<String> alphabet;

void setup() {
  size(1366,703,P2D);
  osc = new OscP5(this,12000);
  setAlphabet();
  flock = new Flock();
  gui();  
}

void draw() {
  background(controller.get(ColorWheel.class,"backgroundColor").getRGB());
  flock.run();
  
  strokeWeight(1);
  stroke(255,0,0);
  if(isRecording){
    saveFrame("output/accelerometer_####.png");
    fill(255,0,0);
  }
  else  noFill();
  ellipse(width-15,15,10,10);
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

void keyPressed(){
  if (key == ' ') isRecording = !isRecording;
}

public void gui()
{
  controller = new ControlP5(this);
  
  //Group 1 : Global parameters
  Group g1 = controller.addGroup("Global physical parameters").setBackgroundColor(color(0, 64)).setBackgroundHeight(250);
  controller.addCheckBox("parametersToggle").setPosition(10,10).setSize(9,9).setItemsPerRow(1).addItem("F",0).addItem("S",1).addItem("L",2).moveTo(g1);                       
  controller.addSlider("maxforce").addListener(flock).setPosition(30,10).setRange(0.01,1).setValue(1).moveTo(g1);
  controller.addSlider("maxspeed").addListener(flock).setPosition(30,20).setRange(0.01,20).setValue(20).moveTo(g1);
  controller.addSlider("lifespan").addListener(flock).setPosition(30,30).setRange(1,1000).setValue(300).moveTo(g1);
  controller.addSlider("N").setPosition(30,40).setRange(0,1000).moveTo(g1);
  controller.addSlider("k_density").addListener(flock).setPosition(30,50).setRange(0.1,2).setValue(1.0).moveTo(g1);          
  controller.addSlider("trailLength").addListener(flock).setPosition(30,60).setRange(0,20).setValue(0).moveTo(g1); 
  controller.addSlider("size").addListener(flock).setPosition(30,70).setRange(0.1,10).setValue(1.0).moveTo(g1); 
  controller.addBang("grid").addListener(flock).setPosition(10,85).setSize(20,20).moveTo(g1);
  controller.addCheckBox("Brushes").setPosition(10,124).setSize(15,15).setItemsPerRow(4).moveTo(g1)
            .addItem("S 1", 0).addItem("S 2", 1).addItem("S 3", 2).addItem("Source", 3)      
            .addItem("M1", 0).addItem("M2", 1).addItem("M3", 2).addItem("Magnet", 3)      
            .addItem("R1", 0).addItem("R2", 1).addItem("R3", 2).addItem("Repulsor", 3)      
            .addItem("O1", 0).addItem("O2", 1).addItem("O3", 2).addItem("O", 3)      
            .addItem("/1", 0).addItem("/2", 1).addItem("/3", 2).addItem("/", 3)      
            .addItem("U1", 0).addItem("U2", 1).addItem("U3", 2).addItem("U", 3);
  
  //Group 2 : Sources  
  Group g2 = controller.addGroup("Sources").setBackgroundColor(color(0, 64)).setBackgroundHeight(200);  
  controller.addBang("add").addListener(flock).setPosition(10,10).setSize(20,20).moveTo(g2);
  controller.addCheckBox("src_activation").addListener(flock).setPosition(40,12).setSize(15,15).setItemsPerRow(4).setSpacingColumn(20).moveTo(g2);
  controller.addAccordion("acc_sources").setPosition(10,60).setWidth(controllerSize-10).setMinItemHeight(55).setCollapseMode(Accordion.SINGLE).moveTo(g2);
  for(int i = 0; i<8; i++){
    Group s1 = controller.addGroup("Source "+i).setBackgroundColor(color(0, 64)).setBackgroundHeight(55).hide();
    controller.addRadioButton("src"+i+"_type").addListener(flock).setPosition(0,5).setSize(10,10).setItemsPerRow(2).setSpacingColumn(25).addItem("0 ("+i+")", 0).addItem("| ("+i+")", 1).activate(0).moveTo(s1);
    controller.addSlider("src"+i+"_size").addListener(flock).setPosition(0,21).setSize(50,10).setRange(10,100).setValue(20).moveTo(s1);  
    controller.addSlider("src"+i+"_outflow").addListener(flock).setPosition(0,32).setSize(50,10).setRange(1,30).setValue(1).moveTo(s1);
    controller.addSlider("src"+i+"_strength").addListener(flock).setPosition(0,43).setSize(50,10).setRange(0,10).setValue(1).moveTo(s1);
    controller.addKnob("src"+i+"_angle").addListener(flock).setPosition(145,21).setResolution(100).setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(9).moveTo(s1);
    controller.get(Accordion.class,"acc_sources").addItem(s1);
  }
  
  //Group 3 : Forces
  Group g3 = controller.addGroup("Forces").setBackgroundColor(color(0, 64)).setBackgroundHeight(130);                       
  controller.addCheckBox("forceToggle").setPosition(10,10).setSize(9,9).setItemsPerRow(1).moveTo(g3)
            .addItem("s",0).addItem("a",1).addItem("c",2).addItem("A",3).addItem("r",4).addItem("f",5).addItem("g",6).addItem("n",7);
  controller.addSlider("separation").addListener(flock).setPosition(30,10).setRange(0.01,4).setValue(1.5).moveTo(g3);
  controller.addSlider("alignment").addListener(flock).setPosition(30,20).setRange(0.01,4).setValue(1.0).moveTo(g3);
  controller.addSlider("cohesion").addListener(flock).setPosition(30,30).setRange(0.01,4).setValue(1.0).moveTo(g3);
  controller.addSlider("attraction").addListener(flock).setPosition(30,40).setRange(0.01,4).moveTo(g3);
  controller.addSlider("repulsion").addListener(flock).setPosition(30,50).setRange(0.01,4).moveTo(g3);          
  controller.addSlider("friction").addListener(flock).setPosition(30,60).setRange(0.01,4).moveTo(g3);
  controller.addSlider("gravity").addListener(flock).setPosition(30,70).setRange(0.01,4).setValue(1.0).moveTo(g3);  
  controller.addSlider("noise").addListener(flock).setPosition(30,80).setRange(0.01,4).setValue(1.0).moveTo(g3);
  controller.addKnob("gravity_Angle").addListener(flock).setPosition(50,95).setResolution(100).setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(10).moveTo(g3);

  //Group 4 : Visual parameters
  Group g4 = controller.addGroup("Visual parameters").setBackgroundColor(color(0, 64)).setBackgroundHeight(110);  
  controller.addRadioButton("Visual").addListener(flock).setPosition(10,10).setSize(15,15).moveTo(g4)
            .addItem("triangle", 0).addItem("letter", 1).addItem("circle", 2) .addItem("bubble",3).addItem("line", 4).addItem("curve", 5).activate(4);
  controller.addSlider("N_connections").addListener(flock).setPosition(80,10).setSize(50,10).setRange(1,30).setValue(3).moveTo(g4);
  controller.addSlider("symmetry").addListener(flock).setPosition(80,25).setSize(50,10).setRange(1,12).setValue(2).moveTo(g4);
  controller.addBang("brushes").addListener(flock).setPosition(80,70).setSize(20,20).moveTo(g4);
  
  //Group 5 : Colors
  Group g5 = controller.addGroup("Colors").setBackgroundColor(color(0, 64)).setBackgroundHeight(200);  
  controller.addColorWheel("particleColor",5,10,90).setRGB(color(255)).moveTo(g5);           
  controller.addColorWheel("backgroundColor",105,10,90).setRGB(color(0)).moveTo(g5);
  controller.addBang("Black&White").setPosition(10,120).setSize(10,10).moveTo(g5);
  controller.addSlider("contrast").addListener(flock).setPosition(10,150).setRange(0,200).setValue(50).moveTo(g5);
  controller.addSlider("red").addListener(flock).setPosition(10,160).setRange(0,200).setValue(0).moveTo(g5);
  controller.addSlider("green").addListener(flock).setPosition(10,170).setRange(0,200).setValue(0).moveTo(g5);
  controller.addSlider("blue").addListener(flock).setPosition(10,180).setRange(0,200).setValue(0).moveTo(g5);
  
  //Group 6 : Borders parameters
  Group g6 = controller.addGroup("Borders").setBackgroundColor(color(0, 64)).setBackgroundHeight(150);  
  controller.addRadioButton("Borders type").setPosition(10,10).setSize(20,20).moveTo(g6)
            .addItem("walls", 0).addItem("loops", 1).addItem("no_border", 2).activate(1);
  
  //Accordion
  controller.addAccordion("acc").setPosition(0,0).setWidth(controllerSize).setCollapseMode(Accordion.MULTI)
            .addItem(g1).addItem(g2).addItem(g3).addItem(g4).addItem(g5).addItem(g6).open(0,1,2,3,4);
}


//OSC
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/accelerometer")==true) {
    if(theOscMessage.checkTypetag("fff")) {
      //float x = theOscMessage.get(0).floatValue();
      float y = theOscMessage.get(1).floatValue();
      float z = theOscMessage.get(2).floatValue();
      //println(x + " " + y + " " + z);
      
      float value = map(y,0,125,-1,1);
      value = constrain(value,-1,1);
      float theta;
      if( z > 62.5)
        theta = 0.5*PI + asin(value);
      else 
        theta = 1.5*PI - asin(value);
        
      controller.getController("gravity_Angle").setValue(degrees(theta));
      PVector center = new PVector(0.5*(width+controllerSize),0.5*height);
      PVector angle = new PVector(-sin(theta),cos(theta));
      float r = 0.5*height;
      float r_temp = r-(0.05*millis())%r;
      for (int i = 1; i<4; i++){
        flock.brushes.get(i).position.set(center.x + angle.x * i*r_temp, center.y + angle.y * i*r_temp);
        flock.brushes.get(i+4).position.set(center.x + angle.x * i*r_temp, center.y + angle.y * i*r_temp);
        flock.brushes.get(i+8).position.set(center.x + angle.x * i*r_temp, center.y + angle.y * i*r_temp);
      }
      
      flock.brushes.get(0).position.set(center.x + angle.x * r, center.y + angle.y * r);
      flock.brushes.get(4).position.set(center.x + angle.x * r, center.y + angle.y * r);
      flock.brushes.get(8).position.set(center.x + angle.x * r, center.y + angle.y * r);
    }
  }
}


//ControlP5
void controlEvent(ControlEvent theEvent) { 
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
      Boid b = flock.boids.get(i);
      flock.addBoid(b.position.x,b.position.y,b.velocity.x,b.velocity.y);
      flock.boids.remove(i);
    }
  }  
  if (theEvent.isFrom("Borders type")) {
    switch(int(theEvent.getValue())) {
      case(0):borderType = BorderType.WALLS;break;
      case(1):borderType = BorderType.LOOPS;break;
      case(2):borderType = BorderType.NOBORDER;break;
    }
  }
  for (int i = 0; i<flock.sources.size(); i++){
    if(theEvent.isFrom("src"+i+"_type")){
      switch(int(theEvent.getValue())){
        case (0) : flock.sources.get(i).type = SourceType.O; break;
        case (1) : flock.sources.get(i).type = SourceType.I; break;
      }
    }
  }
  //if (theEvent.isFrom(controller.get(CheckBox.class,"Brushes"))){
  //  for (int i = 0; i<controller.get(CheckBox.class,"Brushes").getArrayValue().length; i++)
  //    flock.brushes.get(i).isActivated = controller.get(CheckBox.class,"Brushes").getState(i);
  //}
  if (theEvent.isFrom(controller.get(CheckBox.class,"src_activation"))){
     for (int i = 0; i<controller.get(CheckBox.class,"src_activation").getArrayValue().length; i++)
       flock.sources.get(i).isActivated = controller.get(CheckBox.class,"src_activation").getState(i);
  }
  
  if (theEvent.isFrom(controller.get(CheckBox.class,"forceToggle"))){
    for (int i = 0; i<controller.get(CheckBox.class,"forceToggle").getArrayValue().length; i++){
      for (Boid b : flock.boids)
        b.forcesToggle[i] = controller.get(CheckBox.class,"forceToggle").getState(i);
    }
  }
  
  if (theEvent.isFrom(controller.get(CheckBox.class,"parametersToggle"))){
    for (int i = 0; i<controller.get(CheckBox.class,"parametersToggle").getArrayValue().length; i++){
      for (Boid b : flock.boids)
        b.paramToggle[i] = controller.get(CheckBox.class,"parametersToggle").getState(i);
    }
  }
  
  
     
  if(theEvent.isFrom("Black&White")){
    if(controller.get(ColorWheel.class,"particleColor").getRGB() != -1 || controller.get(ColorWheel.class,"backgroundColor").getRGB() != -16777216){
      controller.get(ColorWheel.class,"particleColor").setRGB(color(255));
      controller.get(ColorWheel.class,"backgroundColor").setRGB(color(0));
    }
    else{
      controller.get(ColorWheel.class,"particleColor").setRGB(color(0));
      controller.get(ColorWheel.class,"backgroundColor").setRGB(color(255));
    }
  }
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