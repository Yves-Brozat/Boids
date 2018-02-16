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
  ArrayList<Float> history_angle; 
  boolean isSpinning;
  float spinSpeed;
  float angle;
  
  //Colors
  color c;
  float alpha;
  int red,green,blue;
  float randomBrightness;
  float randomRed, randomGreen, randomBlue;  
  
  Boid(float x, float y, float vx, float vy, int i) {
    index = i;
    lifetime = 0;
    lifespan = int(cf.controllerFlock[index].getController("lifespan").getValue());    
    mortal = cf.controllerFlock[index].get(Toggle.class, "Immortal").getState();    
    position = new PVector(x, y);
    position0 = position.copy();
    velocity = new PVector(vx,vy);    
    acceleration = new PVector();
    sumForces = new PVector(); 
    
    r = 1;
    history = new ArrayList<PVector>();  
    angle = 0;
    history_angle = new ArrayList<Float>();  
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
    spinSpeed = cf.controllerFlock[index].getController("spin_speed").getValue();
  }
  
  boolean isDead(){
    if (mortal) return (lifetime > lifespan);
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
    if (d > 1) att.setMag(k*density*r*r/d);
    else att.setMag(0);
    sumForces.add(att);
  }
  
  // Save old position in history
  void savePosition(){    
    while (history.size() > trailLength) {
      history.remove(0);
      history_angle.remove(0);
    }
    history.add(new PVector(position.x,position.y));    
    history_angle.add(angle);    
  }
  
  // Method to update position
  void update() {
    //float masse = density * r * r * k_density;  //density : initial density of the particular boid. k_density : coefficient on slider "density" to change weight of all boids
    acceleration = PVector.mult(sumForces,1);  // Newton's 2nd law  
    velocity.add(acceleration);
    if (paramToggle[1]) velocity.limit(maxspeed);  // Limit speed
    position.add(velocity); 
    sumForces.mult(0);  // Reset forces to 0 each cycle
    if(mortal && lifetime <= lifespan) lifetime++;
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
    desired.sub(PVector.mult(velocity,DISPLAY_SCALE));
    if (paramToggle[0])  desired.limit(maxforce);
    sumForces.add(desired);
  }
  
  color getColor(){
    float a = mortal ? constrain(map(lifetime,0,lifespan,alpha, 0), 0, alpha) : alpha;
    color c = color(red + randomBrightness + randomRed - randomGreen - randomBlue,
              green + randomBrightness - randomRed + randomGreen - randomBlue,
              blue + randomBrightness - randomRed - randomGreen + randomBlue,
              a);

    return c;
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
  
  void draw(PGraphics f, ArrayList<Boid> boids){
    c = getColor();
    angle = (isSpinning ? random*TWO_PI+(0.02*spinSpeed*frameCount)%TWO_PI : velocity.heading() + HALF_PI);
    r = getR(boids);
    draw(f, position.x, position.y, r*size, angle, alpha);
    if(history.size() > 0){
      for (int i=0; i< history.size(); i++)
        draw(f, history.get(i).x, history.get(i).y, map(i,0,history.size(),0,r*size), history_angle.get(i), map(i,0,history.size(),0,alpha));
    }
  }
  
  abstract void draw(PGraphics f, float x, float y, float r, float theta, float alpha);
  
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
    spinSpeed = preset.getFloat("spin_speed");
  }
}

//============================================================================
//---SUB-CLASSES--------------------------------------------------------------
//============================================================================

class TriangleBoid extends Boid {
   
  TriangleBoid(float x, float y, float vx, float vy, int i){
    super(x,y,vx,vy,i);
  }
  
  void draw(PGraphics f, float x, float y, float r, float theta, float alpha){
    f.pushMatrix();
    f.translate(x, y);
    f.rotate(theta);
    f.fill(c,alpha);
    f.noStroke();
    f.beginShape(TRIANGLES);
    f.vertex(0, -0.73*r);
    f.vertex(-r, r);
    f.vertex(r, r);
    f.endShape();
    f.popMatrix();
  }
}

class PixelBoid extends Boid {

  PixelBoid(float x, float y, float vx, float vy, int i){
    super(x,y,vx,vy,i);
  }
  
  void draw(PGraphics f, float x, float y, float r, float theta, float alpha){
    if(0 <= y && y < f.height && 0 <= x && x < f.width){
      color pixelColor = (c & 0xffffff) | ((int)alpha << 24);  // color pixelColor = color(c,alpha); doesn't work
      f.pixels[f.width*int(y) + int(x)] = pixelColor;
    }
  }
}

class LetterBoid extends Boid {
  
  String letter;    
  
  LetterBoid(float x, float y, float vx, float vy, int i){
    super(x,y,vx,vy,i);
  }
  
  void draw(PGraphics f, float x, float y, float r, float theta, float alpha){
    f.pushMatrix(); 
    f.translate(x, y);
    f.rotate(theta);
    f.fill(c,alpha);
    f.noStroke();
    f.textSize(2*r);
    f.text(letter,0,0);
    f.popMatrix();
  }
}

class CircleBoid extends Boid {
  
  CircleBoid(float x, float y, float vx, float vy, int i){
    super(x,y,vx,vy,i);
  }
  
  void draw(PGraphics f, float x, float y, float r, float theta, float alpha){
    f.fill(c,alpha);
    f.noStroke();
    f.ellipse(x, y, 2*r, 2*r);
  } 
}

class ImageBoid extends Boid {
  
  PImage image;
  
  ImageBoid(float x, float y, float vx, float vy, int i, PImage img){
    super(x,y,vx,vy,i);    
    image = img;
  }
  
  void draw(PGraphics f, float x, float y, float r, float theta, float alpha){
    f.pushMatrix();
    f.imageMode(CENTER);
    f.tint(c,alpha);
    f.translate(x,y);
    f.rotate(theta - HALF_PI);
    f.image(image,0,0,2*r,2*r);
    f.popMatrix();
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
  
  void draw(PGraphics f, float x, float y, float r, float theta, float alpha){
    f.pushMatrix();
    f.imageMode(CENTER);
    f.translate(x,y);
    f.rotate(theta - HALF_PI);
    f.tint(c,alpha);
    int animationSpeed = int(constrain(map(velocity.magSq(),0, 25, 10, 1),1,10));
    if (frameCount%animationSpeed == 0)
      frame = (frame+1) % images.length;
    f.image(images[frame], 0, 0, r, r);
    f.popMatrix();
  } 
}