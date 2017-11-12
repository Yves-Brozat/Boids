abstract class Boid {

  int index;  
  int lifetime;
  int lifespan;
  boolean mortal;
  
  //Dynamic parameters
  PVector position0;
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector sumForces;
  
  //Forces parameters
  float separation;
  float alignment;
  float cohesion;
  float sep_r, sep_rSq;
  float ali_r, ali_rSq;
  float coh_r, coh_rSq;
  float friction;
  float origin;  
  float xoff, yoff;
  float noise;
  PVector g;
  boolean[] paramToggle;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  
  //Particle design
  float r;
  boolean random_r;
  float random;
  float size; //static
  int boidMove;
  float cloud_spreading;  //static or brushable
  float shining_frequence;  //static or brushable
  float shining_phase;  //static or brushable
  float roff;
  float strength_noise;  //static or brushable  
  float density;  // Personal density of the particle
  float k_density;  // Global coefficient to increase/decrease density of all particles 
  float trailLength;  //static or brushable
  ArrayList<PVector> history; 
  boolean isSpinning;
  float spinSpeed = 1;
  
  //Colors
  color c;
  float alpha;
  int red,green,blue;
  float randomBrightness;
  float randomRed, randomGreen, randomBlue;  
  
  Boid(float x, float y, float vx, float vy, int i) {
    index = i;
    lifetime = 0;
    lifespan = 100;    
    mortal = true;    
    position = new PVector(x, y);
    position0 = position.copy();
    velocity = new PVector(vx,vy);    
    acceleration = new PVector();
    sumForces = new PVector(); 
    
    r = 1;
    history = new ArrayList<PVector>();  
    density = 1.0;
   
    xoff = random(0,10);
    yoff = random(0,10);
    roff = random(0,10);
    random = random(0,1);
    init();
  }
  
  void init(){
    paramToggle = new boolean[2];
    for (int j = 0; j < paramToggle.length; j++) 
      paramToggle[j] = cf.controllerFlock[index].get(CheckBox.class,"parametersToggle").getState(j);
    maxforce = cf.controllerFlock[index].getController("maxforce").getValue();    
    maxspeed = cf.controllerFlock[index].getController("maxspeed").getValue();    
    k_density = cf.controllerFlock[index].getController("k_density").getValue();
    float angle = radians(cf.controllerFlock[index].getController("gravity_Angle").getValue()+90);
    float mag = cf.controllerFlock[index].getController("gravity").getValue();
    g = new PVector(mag*cos(angle),mag*sin(angle));
    noise = cf.controllerFlock[index].getController("noise").getValue();
    size = cf.controllerFlock[index].getController("size").getValue();   
    random_r = cf.controllerFlock[index].get(Button.class, "random r").isOn();
    boidMove = int(cf.controllerFlock[index].get(RadioButton.class, "boidMove").getValue());
    cloud_spreading = cf.controllerFlock[index].get(Slider.class,"cloud_spreading").getValue();    
    shining_frequence = cf.controllerFlock[index].get(Slider.class,"shining_frequence").getValue();    
    shining_phase = cf.controllerFlock[index].get(Slider.class,"shining_phase").getValue();    
    strength_noise = cf.controllerFlock[index].get(Slider.class,"strength_noise").getValue();    
    trailLength = cf.controllerFlock[index].get(Slider.class,"trailLength").getValue();    
    separation = cf.controllerFlock[index].getController("separation").getValue();
    alignment = cf.controllerFlock[index].getController("alignment").getValue();
    cohesion = cf.controllerFlock[index].getController("cohesion").getValue();
    sep_r = cf.controllerFlock[index].getController("sep_r").getValue();
    sep_rSq = sep_r*sep_r;
    ali_r = cf.controllerFlock[index].getController("ali_r").getValue();
    ali_rSq = ali_r*ali_r;
    coh_r = cf.controllerFlock[index].getController("coh_r").getValue();
    coh_rSq = coh_r*coh_r;
    friction = cf.controllerFlock[index].getController("friction").getValue();
    origin = cf.controllerFlock[index].getController("origin").getValue();    
    red = cf.controllerFlock[index].get(ColorWheel.class,"particleColor").r(); 
    green =cf.controllerFlock[index].get(ColorWheel.class,"particleColor").g(); 
    blue = cf.controllerFlock[index].get(ColorWheel.class,"particleColor").b();
    c = cf.controllerFlock[index].get(ColorWheel.class,"particleColor").getRGB();
    alpha = cf.controllerFlock[index].getController("alpha").getValue();
    randomBrightness = random(-cf.controllerFlock[index].getController("contrast").getValue(),cf.controllerFlock[index].getController("contrast").getValue());
    randomRed = random(0,cf.controllerFlock[index].getController("red").getValue());
    randomGreen = random(0,cf.controllerFlock[index].getController("green").getValue());
    randomBlue = random(0,cf.controllerFlock[index].getController("blue").getValue());
    isSpinning = cf.controllerFlock[index].get(Button.class, "is Spinning").isOn();
  }
  
  boolean isDead(){
    if (mortal) return (lifetime > lifespan) ? true : false;
    else return false;
  }
  
  void applyOrigin(){
    PVector fo = seek(position0);
    fo.mult(origin);
    sumForces.add(fo);
  }
  
  void applyNoise(){
    xoff += 0.01;
    yoff += 0.02;
    float x = map(noise(xoff),0,1,-noise,noise);
    float y = map(noise(yoff),0,1,-noise,noise);
    position.add(x,y); 
  }
  
  void applyGravity(){
    PVector fg = PVector.mult(g,0.1*density*r*r);
    sumForces.add(fg);
  }
  
  void applyFriction(){
     PVector fri = velocity.copy();
     fri.normalize();
     fri.mult(-0.01*velocity.magSq()*r*r*friction);
     sumForces.add(fri);   
  }
  
  void applyAttraction(PVector v, float k){
    PVector att = PVector.sub(v,position);
    if (k > 0) att.div(k);
    else if(k < 0) att.div(-k);
    float d = att.magSq();
    if (d > 10) att.setMag(k*density*r*r/d);
    else att.setMag(0);
    sumForces.add(att);
  }
  
  // Save old position in history
  void savePosition(){    
    while (history.size() > trailLength) {
      history.remove(0);
    }
    history.add(new PVector(position.x,position.y));    
  }
  
  // Method to update position
  void update() {
    //float masse = density * r * r * k_density;  //density : initial density of the particular boid. k_density : coefficient on slider "density" to change weight of all boids
    acceleration = PVector.mult(sumForces,1);  // Newton's 2nd law  
    velocity.add(acceleration);
    if (paramToggle[1]) velocity.limit(maxspeed);  // Limit speed
    position.add(velocity); 
    sumForces.mult(0);  // Reset forces to 0 each cycle
    if(mortal) lifetime++;
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    float d = desired.magSq();
    desired.normalize();
    if (d < 40000)
      desired.mult(map(d,0,40000,0,maxspeed));
    else 
      desired.mult(maxspeed);
    desired.sub(velocity); // Steering = Desired minus Velocity
    if (paramToggle[0]) desired.limit(maxforce);  // Limit to maximum steering force
    return desired;
  }

  void follow(FlowField flow){
    PVector desired = flow.getVector(position);
    desired.mult(flow.strength);
    desired.sub(velocity);
    if (paramToggle[0])  desired.limit(maxforce);
    sumForces.add(desired);
  }
  
  color getColor(){
    float a = alpha;
    if (mortal) a = map(lifetime,0,lifespan,alpha,20);
    return color(red + randomBrightness + randomRed - randomGreen - randomBlue,
              green + randomBrightness - randomRed + randomGreen - randomBlue,
              blue + randomBrightness - randomRed - randomGreen + randomBlue,
              a);
  }
  
  float getR(ArrayList<Boid> boids){
    float r = 1;
    switch(boidMove){
      case CONSTANT : 
      r = 1;
      break;
      case CLOUDY : 
      r = proximityTo(boids, cloud_spreading*cloud_spreading);
      break;
      case SHINY : 
      if (mortal)  {
        r = 0.5*(1+sin(shining_frequence*frameCount+shining_phase*PI*lifetime/lifespan));
      }
      else {
        float phase = map(shining_phase, 0 ,16, 0, PI);
        r = 0.5*(1+sin(shining_frequence*frameCount+phase*boids.indexOf(this)));
      }
      break;
      case NOISY : 
      roff += strength_noise;
      r = noise(roff);
      break;
    }
    if (random_r) r *= random;
    return r;
  }
  
  float proximityTo(ArrayList<Boid> boids, float d_Sq){
    float isolation = 0;
    for (int i = 0; i< boids.size(); i++){
      float dist_Sq = distSq(position,boids.get(i).position);
      if ( dist_Sq < d_Sq && dist_Sq > 0){
        isolation += d_Sq - dist_Sq;
      }
    }
    float _r = map(isolation, 0, d_Sq, 1/size, 1);
    _r = constrain(_r, 1/size, 1); 
    return _r;
  }
  
  void draw(ArrayList<Boid> boids){
    c = getColor();
    float angle = (isSpinning ? (0.01*spinSpeed*frameCount)%TWO_PI : velocity.heading() + HALF_PI);
    r = getR(boids);
    draw(position.x, position.y, r*size, angle, alpha);
    if(history.size() > 0){
      for (int i=0; i< history.size(); i++)
        draw(history.get(i).x, history.get(i).y, map(i,0,history.size(),0,r*size), angle, map(i,0,history.size(),0,alpha));
    }
  }
  
  abstract void draw(float x, float y, float r, float theta, float alpha);
  
  void sortNeighboors(ArrayList<Boid> boids){  
    java.util.Collections.sort(boids,  new java.util.Comparator<Boid>() {
      public int compare(Boid b1, Boid b2)
      {
        Float f1 = new Float(distSq(b1.position,position));
        Float f2 = new Float(distSq(b2.position,position));          
        return f1.compareTo(f2);         
      }
    });
  }
  
  ArrayList<Boid> getSorted(ArrayList<Boid> boids){
    ArrayList<Boid> neighboors = new ArrayList<Boid>();
    for(int i = 0; i<boids.size(); i++)
      neighboors.add(boids.get(i));
    sortNeighboors(neighboors);
    neighboors.remove(0); //Remove itself
    return neighboors;   
  }
  
  void updateParameters(JSONObject preset){
    maxforce = preset.getFloat("maxforce");
    maxspeed = preset.getFloat("maxspeed");
    paramToggle = preset.getJSONArray("parametersToggle").getBooleanArray();
    friction = preset.getFloat("friction");
    noise = preset.getFloat("noise");
    origin = preset.getFloat("origin");
    separation = preset.getFloat("separation");
    alignment = preset.getFloat("alignment");
    cohesion = preset.getFloat("cohesion");
    sep_r = preset.getFloat("sep_r");
    ali_r = preset.getFloat("ali_r");
    coh_r = preset.getFloat("coh_r");
    cloud_spreading = preset.getFloat("cloud_spreading");
    shining_frequence = preset.getFloat("shining_frequence");
    shining_phase = preset.getFloat("shining_phase");
    strength_noise = preset.getFloat("strength_noise");
    trailLength = preset.getFloat("trailLength");
    g = vector(preset.getFloat("gravity"),preset.getFloat("gravity_angle"));
    alpha = preset.getFloat("alpha");
    red = preset.getInt("red");
    green = preset.getInt("green");
    blue = preset.getInt("blue");
    randomBrightness = preset.getInt("randomBrightness");
    randomRed = preset.getInt("randomRed");
    randomGreen = preset.getInt("randomGreen");
    randomBlue = preset.getInt("randomBlue");
    boidMove = preset.getInt("boidMove");
    size = preset.getFloat("size");
    random_r = preset.getBoolean("random_r");
    isSpinning = preset.getBoolean("is Spinning");
  }
}

//============================================================================
//---SUB-CLASSES--------------------------------------------------------------
//============================================================================

class TriangleBoid extends Boid {
   
  TriangleBoid(float x, float y, float vx, float vy, int i){
    super(x,y,vx,vy,i);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix();
    translate(x, y);
    rotate(theta);
    fill(c,alpha);
    noStroke();
    beginShape(TRIANGLES);
    vertex(0, -0.73*r);
    vertex(-r, r);
    vertex(r, r);
    endShape();
    popMatrix();
  }
}

class PixelBoid extends Boid {

  PixelBoid(float x, float y, float vx, float vy, int i){
    super(x,y,vx,vy,i);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    if(0 <= y && y < height && 0 <= x && x < width){
      color pixelColor = (c & 0xffffff) | ((int)alpha << 24);  // color pixelColor = color(c,alpha); doesn't work
      pixels[width*int(y) + int(x)] = pixelColor;
    }
  }
}

class LetterBoid extends Boid {
  
  String letter;    
  
  LetterBoid(float x, float y, float vx, float vy, int i){
    super(x,y,vx,vy,i);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix(); 
    translate(x, y);
    rotate(theta);
    fill(c,alpha);
    noStroke();
    textSize(2*r);
    text(letter,0,0);
    popMatrix();
  }
}

class CircleBoid extends Boid {
  
  CircleBoid(float x, float y, float vx, float vy, int i){
    super(x,y,vx,vy,i);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    fill(c,alpha);
    noStroke();
    ellipse(x, y, 2*r, 2*r);
  } 
}

class ImageBoid extends Boid {
  
  PImage image;
  
  ImageBoid(float x, float y, float vx, float vy, int i, PImage img){
    super(x,y,vx,vy,i);    
    image = img;
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix();
    imageMode(CENTER);
    tint(c,alpha);
    translate(x,y);
    rotate(theta - HALF_PI);
    image(image,0,0,2*r,2*r);
    popMatrix();
  } 
}

class AnimationBoid extends Boid {
  
  PImage[] images;
  int frame;
  
  AnimationBoid(float x, float y, float vx, float vy, int index, PImage[] img){
    super(x,y,vx,vy,index);
    images = img;

    frame = int(random(0,images.length));
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix();
    imageMode(CENTER);
    translate(x,y);
    rotate(theta - HALF_PI);
    tint(c,alpha);
    int animationSpeed = int(constrain(map(velocity.magSq(),0, 25, 10, 1),1,10));
    if (frameCount%animationSpeed == 0)
      frame = (frame+1) % images.length;
    image(images[frame], 0, 0, r, r);
    popMatrix();
  } 
}

//abstract class Connection extends Boid{
  
//  float d_max, d_maxSq;
//  int maxConnections;
  
//  Connection(float x, float y, float vx, float vy, int i){
//    super(x,y,vx,vy,i);
//    d_max = cf.controllerFlock[index].getController("d_max").getValue();
//    d_maxSq = d_max*d_max;
//    maxConnections = (int)cf.controllerFlock[index].getController("N_links").getValue();
//  }
  
//  abstract void draw(PVector origin, PVector neighboor, float alpha);
  
//  //Draw connexions between 3 closest particles
//  void draw(ArrayList<Boid> boids){
//    setColor();
//    ArrayList<Boid> neighboors = new ArrayList<Boid>();
//    for(int i = 0; i<boids.size(); i++)
//      neighboors.add(boids.get(i));
//    sortNeighboors(neighboors);
//    neighboors.remove(0); //Remove itself
//    if(neighboors.size()>maxConnections){
//      for (int i = 0; i<maxConnections; i++){
//        float d = distSq(position,neighboors.get(i).position);
//        if ((d > 0) && (d < d_maxSq)){
//          float a = map(d,0,d_maxSq, alpha, 0); 
//          draw(position,neighboors.get(i).position,a);
//          if (neighboors.get(i).history.size() >= history.size()){
//            for ( int j=0; j<history.size(); j++)  
//              draw(history.get(j), neighboors.get(i).history.get(j), a/history.size()*(j+1));
//          }
//        }
//      }
//    }
//  }
//}

//class LineBoid extends Connection {
  
//  LineBoid(float x, float y, float vx, float vy, int i){
//    super(x,y,vx,vy,i);
//  }

//  void draw(float x, float y, float r, float theta, float alpha){}

//  void draw(PVector origin, PVector neighboor, float alpha){
//      stroke(c,alpha);
//      strokeWeight(1);
//      line(origin.x, origin.y, neighboor.x, neighboor.y);
//  }
//}

//class CurveBoid extends Connection {

//  CurveBoid(float x, float y, float vx, float vy, int i){
//    super(x,y,vx,vy,i);
//  }

//  void draw(float x, float y, float r, float theta, float alpha){}
  
//  void draw(ArrayList<Boid> boids){
//    super.draw(boids);
//    for ( int j=0; j<history.size(); j++){
//      float a = alpha/history.size()*(j+1);
//      beginShape();
//      curveVertex(history.get(j).x,history.get(j).y);
//      ArrayList<Boid> neighboors = new ArrayList<Boid>();
//      for(int i = 0; i<boids.size(); i++)
//        neighboors.add(boids.get(i));
//      sortNeighboors(neighboors);
//      neighboors.remove(0); //Remove itself
//      if(neighboors.size()>maxConnections){
//        for (int i = 0; i<maxConnections; i++){
//          if (neighboors.get(i).history.size() >= history.size()){    
//            float scope = distSq(history.get(j), neighboors.get(i).history.get(j)); 
//            if ((scope > 0) && (scope < d_maxSq)) {
//              //count++;            // Keep track of how many            
//              stroke(c,a);
//              noFill();
//              strokeWeight(1);
//              curveVertex(neighboors.get(i).history.get(j).x,neighboors.get(i).history.get(j).y);
//            }  
//          }
//        }
//      }
//      endShape();
//    }
//  }
    
//  void draw(PVector origin, PVector neighboor, float alpha){ 
//  } 
//} 