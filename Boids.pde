/*
YVES BROZAT - BOIDS : MODELE PHYSIQUE DE SYSTEME PARTICULAIRE

IDEES : 
- Creer des bangs (WALL puis NO_BORDER, MASSE = 0 puis normal, FORCE = 0, SPEED = 0, ...) pour une interaction ponctuelle (type break) ou répétitive (type beat)
- Création de chemins à suivre (droite, courbe, cercle)
- Ressorts entre particules pour creer des tissus
- Ajout slider visuel particule : influence de la proximité sur la taille des particules
- Améliorer lettres de grande taille (avec scale() p.e au lieu de textSize())
- Creer une fonction grow dans boids 
- Boucler les interactions par rapport aux murs (avec un %)
- Séparer reception data, traitement et affichage
- Créer deux groupes dans l'onglet Default : 
    * Ajouter une brosse 
       - Buttons : flock 1 flock 2 flock 3
       - Button : only when dragged
       - Menu déroulant : type (obstacle, magnet, source, spring, gravity, black hole, noise, speed, slow, friction, go back, ...)
       - Group : hidden sauf quand le type est choisi. -> Paramètres propres au type.
- Utiliser thread("nameOfTheFunctionToExecuteOnTheSeparatedThread") pour gérer tout ce qui n'est pas de la visualisation

EN COURS :

- Sablier
- Creer des forces environnementales, sur tout l'écran ou par zone : type vent, gravité, tourbillon (coriolis ?), poussée d'Archimede, milieux visqueux 
- Utiliser la donnée du nombre de voisins proches (pour un changement visuel, une fusion ou une fission)

FAIT :
- Creer des constantes pour les valeurs initiales (toutes celles dans les sliders) -> Fait avec un .json
- Creer des decoupes ronde, triangle et carre pour remplacer les borders de la fenetre et contenir les éléments
- Ajouter slider pour régler la taille des zones de forces de groupe
- Garder en mémoire la position d'origine pour pouvoir y retourner
- Separer le GUI sur une autre fenetre
- Plug les controller<>variables : abandonné car fonctionne a la creation du boid mais pas de maj quand il est deja cree
- Eviter les erreurs de modifications simultanées du tableau "flock.boids"
- Réflexion sur la couleur : aléatoire, changement de teinte via 2 sliders sur l'ensemble des couleurs
- Creer des autres objets (des brosses ?) type Attractor, Repulsor, Source, Blackhole pour interaction de tracking
- Idem pour repousser les éléments (interaction de tracking)
- Creer un interupteur noir/blanc
- Ajout slider source : taille, orientation (velocity.heading() initiale), force (vitesse initiale), débit (nombre de particule créée par cycle)
- Chaque source produit des particules qui ont une esperance de vie propre a la source
- Reorganiser l'accordeon : Extraire "Visuel particule", "Visuel Connection", "Source", 

CONFIG : (123 boids)

maxforce = 0.03;
maxspeed = 10.0;
no border
Source 0 : O, size = 10.0, outflow = 2, strength = 0, lifespan = 50
Source 1 : O, size = 50.0, outflow 1, strength = 1, lifespan 20
Magnet 0 : -, strength = 0.5
Obstacle 0 : O, size = 3
noise = 4
summetry = 2
trailength = 20
color = light green
contrast = 187
red = 119
green = 16
blue = 62

A FAIRE : 

r*sin(t/T + phi*i) se transforme en r+r/2*sin(t/T+phi*i)
r/8*(2*i+1)+r/8*sin(t/t+phi*i)
tester avec petits ronds immobiles


*/

import controlP5.*;
import netP5.*;
import oscP5.*;
import java.util.Collections.*;

final int TRIANGLE = 0;
final int LINE = 1;
final int CIRCLE = 2;
final int CURVE = 3;
final int LETTER = 4;
final int PIXEL = 5;

final int WALLS = 0;
final int LOOPS = 1;
final int NOBORDER = 2;

enum SourceType {O,I;}
enum ObstacleType {O,I,U;}

OscP5 osc;
ControlFrame cf;
List_directory presetNames;
ControlP5 cp5;
int cp5TabToSave = 0;
ArrayList<JSONObject> preset;
color backgroundColor;

boolean isRecording = false;
Flock[] flocks;
ArrayList<Brush> brushes; 
ArrayList<Magnet> magnets;
ArrayList<Obstacle> obstacles;
ArrayList<Source> sources;
//PImage sablier;


void settings(){
  //sablier = loadImage("Sablier.png"); 
  cf = new ControlFrame(this, 200, 703, "Controls");
  presetNames = new List_directory("","json");
  preset = new ArrayList<JSONObject>();
  for (int i = 0; i<presetNames.fichiers.length; i++)
    preset.add(loadJSONObject(presetNames.fichiers[i]));
  size(1366 - cf.w,703,P3D);
}

void setup(){ 
  brushes = new ArrayList<Brush>();
  magnets = new ArrayList<Magnet>();
  obstacles = new ArrayList<Obstacle>();
  sources = new ArrayList<Source>();
  flocks = new Flock[3];
  for (int i = 0 ; i< flocks.length; i++)
    flocks[i] = new Flock(i);

  surface.setLocation(cf.w,0);
  osc = new OscP5(this,12000);
  //sablier.resize(400,703);
  cp5 = new ControlP5(this);
  cp5.addTextfield("save as").setPosition(0.5*width,0.5*height).setSize(100,20).setFocus(true).hide();

}
void savePreset(int i, String name){
   JSONObject newPreset = new JSONObject();
   newPreset.setFloat("maxforce",cf.controllerFlock[i].getController("maxforce").getValue());
   newPreset.setFloat("maxspeed",cf.controllerFlock[i].getController("maxspeed").getValue());
   newPreset.setFloat("friction",cf.controllerFlock[i].getController("friction").getValue());
   newPreset.setFloat("separation",cf.controllerFlock[i].getController("separation").getValue());
   newPreset.setFloat("alignment",cf.controllerFlock[i].getController("alignment").getValue());
   newPreset.setFloat("cohesion",cf.controllerFlock[i].getController("cohesion").getValue());
   newPreset.setFloat("noise",cf.controllerFlock[i].getController("noise").getValue());
   newPreset.setFloat("origin",cf.controllerFlock[i].getController("origin").getValue());
   newPreset.setFloat("sep_r",cf.controllerFlock[i].getController("sep_r").getValue());
   newPreset.setFloat("ali_r",cf.controllerFlock[i].getController("ali_r").getValue());
   newPreset.setFloat("coh_r",cf.controllerFlock[i].getController("coh_r").getValue());
   newPreset.setFloat("trailLength",cf.controllerFlock[i].getController("trailLength").getValue());
   newPreset.setFloat("gravity",cf.controllerFlock[i].getController("gravity").getValue());
   newPreset.setFloat("gravity_angle",cf.controllerFlock[i].getController("gravity_Angle").getValue());
   newPreset.setFloat("size",cf.controllerFlock[i].getController("size").getValue());
   newPreset.setFloat("alpha",cf.controllerFlock[i].getController("alpha").getValue());
   newPreset.setFloat("d_max",cf.controllerFlock[i].getController("d_max").getValue());
   newPreset.setFloat("maxConnections",cf.controllerFlock[i].getController("N_links").getValue());
   newPreset.setInt("red",cf.controllerFlock[i].get(ColorWheel.class,"particleColor").r());
   newPreset.setInt("green",cf.controllerFlock[i].get(ColorWheel.class,"particleColor").g());
   newPreset.setInt("blue",cf.controllerFlock[i].get(ColorWheel.class,"particleColor").b());
   newPreset.setInt("randomRed",int(cf.controllerFlock[i].getController("red").getValue()));
   newPreset.setInt("randomGreen",int(cf.controllerFlock[i].getController("green").getValue()));
   newPreset.setInt("randomBlue",int(cf.controllerFlock[i].getController("blue").getValue()));
   newPreset.setInt("randomBrightness",int(cf.controllerFlock[i].getController("contrast").getValue()));
   newPreset.setInt("symmetry",int(cf.controllerFlock[i].getController("symmetry").getValue()));
   newPreset.setBoolean("isolationIsActive",cf.controllerFlock[i].get(Button.class,"isolation").isOn());
   
   JSONArray parametersToggle = new JSONArray();
   for (int j = 0; j< cf.controllerFlock[i].get(CheckBox.class, "parametersToggle").getArrayValue().length; j++)
     parametersToggle.setBoolean(j,cf.controllerFlock[i].get(CheckBox.class, "parametersToggle").getState(j));
   newPreset.setJSONArray("parametersToggle", parametersToggle);
   
   JSONArray forceToggle = new JSONArray();
   for (int j = 0; j< cf.controllerFlock[i].get(CheckBox.class,"forceToggle").getArrayValue().length; j++)
     forceToggle.setBoolean(j,cf.controllerFlock[i].get(CheckBox.class, "forceToggle").getState(j));
   newPreset.setJSONArray("forceToggle", forceToggle);
   
   JSONArray flockForceToggle = new JSONArray();
   for (int j = 0; j< cf.controllerFlock[i].get(CheckBox.class, "flockForceToggle").getArrayValue().length; j++)
     flockForceToggle.setBoolean(j,cf.controllerFlock[i].get(CheckBox.class, "flockForceToggle").getState(j));
   newPreset.setJSONArray("flockForceToggle", flockForceToggle);
   
   for (int j = 0; j< cf.controllerFlock[i].get(RadioButton.class, "Visual").getArrayValue().length; j++){
     if (cf.controllerFlock[i].get(RadioButton.class, "Visual").getState(j)) 
       newPreset.setInt("boidType",j);
   }
   for (int j = 0; j< cf.controllerFlock[i].get(RadioButton.class, "Borders type").getArrayValue().length; j++){
     if (cf.controllerFlock[i].get(RadioButton.class, "Borders type").getState(j)) 
       newPreset.setInt("borderType",j);
   }
   
   saveJSONObject(newPreset,"data" + "/"+name+".json");    
   DropdownList ddl = cf.controllerFlock[i].get(DropdownList.class, "Select a preset");
   ddl.addItem("/"+name+".json", ddl.getArrayValue().length);
   preset.add(newPreset);
 }
   
void YB(){
  if (frameCount == 50){
    cf.addSource(new PVector(0.3*width,0.3*height));  //Flock 0
    cf.addSource(new PVector(0.5*width,0.3*height));  //Flock 1
    cf.addSource(new PVector(0.5*width,0.7*height));  //Flock 1
  }
  if (frameCount >= 50 && frameCount<200){
    sources.get(0).position.add(1,1);  //0
    sources.get(1).position.add(0,1);  //1
    sources.get(2).position.add(0,-1);  //1
  }
  if (frameCount == 200){
    cf.addSource(new PVector(0.43*width, 0.52*height));  //0
    sources.get(1).position.set(0.5*width,0.5*height);  //1
    sources.get(2).position.set(0.5*width,0.5*height);  //1
  }
  if (frameCount >= 200 && frameCount<350){
    sources.get(0).position.add(1,-1); //0
    sources.get(3).position.add(0,1);  //0
    float r = height/8;
    float t = frameCount - 200;
    sources.get(1).position.set(0.5*width+r*cos(3*HALF_PI+PI/150*t),0.4*height-r*sin(3*HALF_PI+PI/150*t));  //1
    sources.get(2).position.set(0.5*width+r*cos(3*HALF_PI+PI/150*t),0.6*height+r*sin(3*HALF_PI+PI/150*t));  //1
  }
  if(frameCount == 350){
    for (int i = 0; i< sources.size(); i++)
      sources.get(i).isActivated = false;
    sources.clear();
  }
}

void draw(){
  background(backgroundColor);
  //image(sablier,300,0);
  for (int i = 0; i< flocks.length; i++)
    flocks[i].run();
  for (Brush b : brushes)
     b.run(); 
  //YB();
  
  if(isRecording){
    saveFrame("output/accelerometer_####.png");
    fill(255,0,0);
  }
  else
    noFill();
  strokeWeight(1);
  stroke(255,0,0);
  ellipse(width-15,15,10,10);
  textAlign(RIGHT);
  textSize(12);
  if(cf.controller.get(ColorWheel.class,"backgroundColor").getRGB() != -16777216)
    fill(0);
  else fill(255);
  text(frameRate,width-30,15);
}

void mouseDragged(){   
  for (Brush b : brushes)
    b.mouseDragged();
}

void mousePressed(){
  for (Brush b : brushes)
    b.mousePressed();
}

void mouseReleased(){
  for (Brush b : brushes)
    b.mouseReleased();
}


void keyPressed(){
  if (!cp5.get(Textfield.class, "save as").isFocus()){
    if (key == ' ') isRecording = !isRecording;
    if (key == 's') {
      java.util.Date dNow = new java.util.Date( );
      java.text.SimpleDateFormat ft = new java.text.SimpleDateFormat ("yyyy_MM_dd_hhmmss_S");
      saveFrame("Screenshot/"+this.getClass().getName()+"_"+ft.format(dNow)+  ".png");
      text("Screenshot done",0.5*width,15);
    }
  }
}

float distSq(PVector v1, PVector v2){
  return (v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y);
}

PVector vector(float mag, float angle){
  return new PVector(mag*cos(angle), mag*sin(angle));
}

//OSC
void oscEvent(OscMessage theOscMessage) {
  //if(theOscMessage.checkAddrPattern("/capteurPosition")==true){
  //  float xRaw = theOscMessage.get(1).floatValue();
  //  float yRaw = theOscMessage.get(1).floatValue();
  //  float zRaw = theOscMessage.get(2).floatValue();
    
  //  //Calibration
  //  float xRawMin = 0;
  //  float xRawMax = 255;
  //  float yRawMin = 0;
  //  float yRawMax = 255;
  //  float zRawMin = 0;
  //  float zRawMax = 255;
    
  //  float x = map(xRaw, xRawMin, xRawMax, 0, width);
  //  float y = map(yRaw, yRawMin, yRawMax, 0, height);
  //  float z = map(zRaw, zRawMin, zRawMax, 1, 20);
    
  //  for (int i = 0; i<flock.sources.size(); i++){
  //    flock.sources.get(i).position.set(x,y);
  //  }
  //  for (int i = 0; i<flock.magnets.size(); i++){
  //    flock.magnets.get(i).position.set(x,y);
  //  }
  //  for (int i = 0; i<flock.obstacles.size(); i++){
  //    flock.obstacles.get(i).position.set(x,y);
  //  }
  
  //  for(Boid b : flock.boids){
  //    if (b instanceof Particle){
  //      Particle p = (Particle)b;
  //      p.size = z;
  //      cf.controllerFlock.getController("size").setValue(z);
  //    }
  //  }
  //}
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
        
      cf.controllerFlock[0].getController("gravity_Angle").setValue(degrees(theta));
      PVector center = new PVector(0.5*width,0.5*height);
      PVector angle = new PVector(-sin(theta),cos(theta));
      float r = 0.5*height;
      for (int i = 0; i<sources.size(); i++){
        sources.get(i).position.set(center.x + angle.x * r/8*(2*i+1)+r/8*sin(millis()/1000+i), center.y + angle.y * r/8*(2*i+1)+r/8*sin(millis()/1000+i));
      }
      for (int i = 0; i<magnets.size(); i++){
        magnets.get(i).position.set(center.x + angle.x * r/8*(2*i+1)+r/8*sin(millis()/1000+i), center.y + angle.y * r/8*(2*i+1)+r/8*sin(millis()/1000+i));
      }
      for (int i = 0; i<obstacles.size(); i++){
        obstacles.get(i).position.set(center.x + angle.x * r/8*(2*i+1)+r/8*sin(millis()/1000+i), center.y + angle.y * r/8*(2*i+1)+r/8*sin(millis()/1000+i));
      }
      
    }
  }
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    savePreset(cp5TabToSave,cp5.get(Textfield.class,"save as").getText());
    cp5.get(Textfield.class,"save as").hide();
  }
}