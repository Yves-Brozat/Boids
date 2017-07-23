/*
YVES BROZAT - BOIDS : MODELE PHYSIQUE DE SYSTEME PARTICULAIRE

IDEES : 
- Creer des bangs (WALL puis NO_BORDER, MASSE = 0 puis normal, FORCE = 0, SPEED = 0, ...) pour une interaction ponctuelle (type break) ou répétitive (type beat)
- Creer des decoupes ronde, triangle et carre pour remplacer les borders de la fenetre et contenir les éléments
- Sablier
- Ajouter slider pour régler la taille des zones de forces de groupe
- Création de chemins à suivre (droite, courbe, cercle)
- Ressorts entre particules pour creer des tissus
- Ajout slider visuel particule : influence de la proximité sur la taille des particules
- Améliorer lettres de grande taille (avec scale() p.e au lieu de textSize())
- Creer des constantes pour les valeurs initiales (toutes celles dans les sliders)

EN COURS :
- Plug les controller<>variables
- Garder en mémoire la position d'origine pour pouvoir y retourner
- Separer le GUI sur une autre fenetre
- Creer des forces environnementales, sur tout l'écran ou par zone : type vent, gravité, tourbillon (coriolis ?), poussée d'Archimede, milieux visqueux 
- Utiliser la donnée du nombre de voisins proches (pour un changement visuel, une fusion ou une fission)

FAIT :
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

enum BoidType {TRIANGLE, LETTER, CIRCLE, LINE, CURVE;}
enum BorderType {WALLS, LOOPS, NOBORDER;}
enum SourceType {O,I;}
enum MagnetType {PLUS,MINUS;}
enum ObstacleType {O,I,U;}

ControlP5 controller;
OscP5 osc;
ControlFrame cf;
int controllerSize = 200;
color backgroundColor;

boolean isRecording = false;
Flock flock;

void settings(){
  size(1366 - controllerSize,703,P3D);
}

void setup(){ 
  flock = new Flock(); 
  cf = new ControlFrame(this, controllerSize, 703, "Controls");
  surface.setLocation(controllerSize,0);
  osc = new OscP5(this,12000);
}

void draw(){
  background(backgroundColor);
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
      PVector center = new PVector(0.5*width,0.5*height);
      PVector angle = new PVector(-sin(theta),cos(theta));
      float r = 0.5*height;
      for (int i = 0; i<flock.sources.size(); i++){
        flock.sources.get(i).position.set(center.x + angle.x * r/8*(2*i+1)+r/8*sin(millis()/1000+i), center.y + angle.y * r/8*(2*i+1)+r/8*sin(millis()/1000+i));
      }
      for (int i = 0; i<flock.magnets.size(); i++){
        flock.magnets.get(i).position.set(center.x + angle.x * r/8*(2*i+1)+r/8*sin(millis()/1000+i), center.y + angle.y * r/8*(2*i+1)+r/8*sin(millis()/1000+i));
      }
      for (int i = 0; i<flock.obstacles.size(); i++){
        flock.obstacles.get(i).position.set(center.x + angle.x * r/8*(2*i+1)+r/8*sin(millis()/1000+i), center.y + angle.y * r/8*(2*i+1)+r/8*sin(millis()/1000+i));
      }
      
    }
  }
}