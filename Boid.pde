abstract class Boid {

  //Dynamic parameters
  PVector position0;
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector sumForces;
  boolean mortal;
  
  //Visual parameters
  color c;
  float alpha;
  int red,green,blue;
  float randomBrightness;
  float randomRed, randomGreen, randomBlue;
  float r;
  ArrayList<PVector> history;  
  float trailLength;  //static or brushable
  float symmetry;  //static
  
  //Forces parameters
  float separation;
  float alignment;
  float cohesion;
  float sep_r, sep_rSq;
  float ali_r, ali_rSq;
  float coh_r, coh_rSq;
  float friction;
  float origin;
  PVector g;
  
  //Global physical parameters
  boolean[] paramToggle;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float density;  // Personal density of the particle
  float k_density;  // Global coefficient to increase/decrease density of all particles
  int lifetime;
  int lifespan;
  
  float xoff, yoff;
  float noise;
  
  Boid(float x, float y, float vx, float vy) {
    position = new PVector(x, y);
    position0 = position.copy();
    velocity = new PVector(vx,vy);    
    acceleration = new PVector();
    sumForces = new PVector(); 
    mortal = true;
    
    red = controller.get(ColorWheel.class,"particleColor").r(); 
    green =controller.get(ColorWheel.class,"particleColor").g(); 
    blue = controller.get(ColorWheel.class,"particleColor").b();
    c = controller.get(ColorWheel.class,"particleColor").getRGB();
    alpha = controller.getController("alpha").getValue();
    randomBrightness = random(-controller.getController("contrast").getValue(),controller.getController("contrast").getValue());
    randomRed = random(0,controller.getController("red").getValue());
    randomGreen = random(0,controller.getController("green").getValue());
    randomBlue = random(0,controller.getController("blue").getValue());
    r = 1;
    history = new ArrayList<PVector>();  
    trailLength = controller.getController("trailLength").getValue();    
    symmetry = controller.getController("symmetry").getValue();
    
    separation = controller.getController("separation").getValue();
    alignment = controller.getController("alignment").getValue();
    cohesion = controller.getController("cohesion").getValue();
    sep_r = controller.getController("sep_r").getValue();
    sep_rSq = sep_r*sep_r;
    ali_r = controller.getController("ali_r").getValue();
    ali_rSq = ali_r*ali_r;
    coh_r = controller.getController("coh_r").getValue();
    coh_rSq = coh_r*coh_r;
    friction = controller.getController("friction").getValue();
    origin = controller.getController("origin").getValue();
    g = g();
       
    paramToggle = new boolean[2];
    for (int i = 0; i < paramToggle.length; i++) 
      paramToggle[i] = controller.get(CheckBox.class,"parametersToggle").getState(i);
    maxforce = controller.getController("maxforce").getValue();    
    maxspeed = controller.getController("maxspeed").getValue();    
    density = 1.0;
    k_density = controller.getController("k_density").getValue();
    lifetime = 0;
    lifespan = 100;
    
    xoff = random(0,10);
    yoff = random(0,10);
    noise = controller.getController("noise").getValue();
  }
    
  boolean isDead(){
    if (mortal) return (lifetime > lifespan) ? true : false;
    else return false;
  }
  
  void applyOrigin(){
    PVector fo = seek(position0);
    fo.setMag(maxforce);
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
  
  PVector g(){
    float angle = radians(controller.getController("gravity_Angle").getValue()+90);
    float mag = controller.getController("gravity").getValue();
    PVector gravity = new PVector(mag*cos(angle),mag*sin(angle));
    return gravity;
  }
  
  void applyFriction(){
     PVector fri = velocity.copy();
     fri.normalize();
     fri.mult(-0.01*velocity.magSq()*r*r*friction);
     sumForces.add(fri);   
  }
  
  void applyRepulsion(PVector v, float k){
    PVector rep = PVector.sub(position,v).mult(k);
    float d = rep.magSq();
    rep.setMag(density*r*r/d);
    sumForces.add(rep);
  }
  
  void applyAttraction(PVector v, float k){
    PVector mis = PVector.sub(v,position).mult(k);
    float d = mis.magSq();
    mis.setMag(density*r*r/d);
    sumForces.add(mis);
  }
  
  void applySep(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    sep.mult(separation);
    sumForces.add(sep);
  }
  
  void applyAli(ArrayList<Boid> boids) {
    PVector ali = align(boids);      // Alignment
    ali.mult(alignment);
    sumForces.add(ali);
  }
  void applyCoh(ArrayList<Boid> boids) {
    PVector coh = cohesion(boids);   // Cohesion
    coh.mult(cohesion);
    sumForces.add(coh);
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
    desired.setMag(maxspeed); // Scale to maximum speed
    PVector steer = PVector.sub(desired, velocity); // Steering = Desired minus Velocity
    if (paramToggle[0]) steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render(ArrayList<Boid> boids){
    reflect(symmetry,boids);
    draw(boids);
  }
  
  void reflect(float n, ArrayList<Boid> boids){
    if ((int)n > 1){  
      PVector center = new PVector(0.5*width,0.5*height);
      float section = TWO_PI/(int)n; 
      Boid b = this;
      for (int i=0; i<n-1; i++){ 
        pushMatrix();
        translate(center.x,center.y);     
        rotate(section*(i+1));
        translate(-center.x,-center.y);
        b.draw(boids);
        popMatrix();
      }
    }
  }

  void draw(ArrayList<Boid> boids){
    float a = alpha;
    if (mortal) a = map(lifetime,0,lifespan,alpha,20);
    c = color(red + randomBrightness + randomRed - randomGreen - randomBlue,
              green + randomBrightness - randomRed + randomGreen - randomBlue,
              blue + randomBrightness - randomRed - randomGreen + randomBlue,
              a);
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = distSq(position, other.position);
      if ((d > 0) && (d < sep_rSq)) {
        PVector diff = PVector.sub(position, other.position); // Calculate vector pointing away from neighbor
        diff.normalize();
        diff.div(sqrt(d));        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.magSq() > 0) {
      steer.setMag(maxspeed);
      steer.sub(velocity);   // Implement Reynolds: Steering = Desired - Velocity
      if (paramToggle[0]) steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = distSq(position, other.position);
      if ((d > 0) && (d < ali_rSq)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.setMag(maxspeed);
      PVector steer = PVector.sub(sum, velocity);      // Implement Reynolds: Steering = Desired - Velocity
      if (paramToggle[0]) steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = distSq(position, other.position);
      if ((d > 0) && (d < coh_rSq)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
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
}

//============================================================================
//---SUB-CLASSES--------------------------------------------------------------
//============================================================================

abstract class Particle extends Boid {
  
  float size; //static
  boolean isolationIsActive;
    
  Particle(float x, float y, float vx, float vy){
    super(x,y,vx,vy);
    size = controller.getController("size").getValue();   
    isolationIsActive = controller.get(Button.class, "isolation").isOn();
  }
  
  abstract void draw(float x, float y, float r, float theta, float alpha);
  
  void draw(ArrayList<Boid> boids){
    super.draw(boids);
    float angle = velocity.heading() + HALF_PI;
    if (isolationIsActive){
      ArrayList<Boid> neighboors = new ArrayList<Boid>();
      for(int i = 0; i<boids.size(); i++)
        neighboors.add(boids.get(i));
      sortNeighboors(neighboors);
      neighboors.remove(0); //Remove itself
      float isolation = 0;
      int count = 0;
      while(count<10 && count<neighboors.size()){
        isolation += distSq(position,neighboors.get(count).position);
        count++;
      }
      r = max(map(isolation,0,100000,4,0.25),1/size);
    }
    else
      r = 1;
    draw(position.x, position.y, r*size, angle, alpha);
    if(history.size() > 0){
      for ( int i=0; i< history.size(); i++)
        draw(history.get(i).x, history.get(i).y, size, angle, map(i,0,history.size(),0,alpha));
    }
  }
}

class TriangleBoid extends Particle {
   
  TriangleBoid(float x, float y, float vx, float vy){
    super(x,y,vx,vy);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix();
    translate(x, y);
    rotate(theta);
    fill(c,alpha);
    noStroke();
    beginShape(TRIANGLES);
    vertex(0, -r);
    vertex(-r, r);
    vertex(r, r);
    endShape();
    popMatrix();
  }
}

class LetterBoid extends Particle {
  
  String letter;    
  
  LetterBoid(float x, float y, float vx, float vy){
    super(x,y,vx,vy);
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

class CircleBoid extends Particle {
  
  CircleBoid(float x, float y, float vx, float vy){
    super(x,y,vx,vy);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix();
    fill(c,alpha);
    noStroke();
    ellipse(x, y, 2*r, 2*r);
    popMatrix();
  } 
}

abstract class Connection extends Boid{
  
  float d_max, d_maxSq;
  int maxConnections;
  
  Connection(float x, float y, float vx, float vy){
    super(x,y,vx,vy);
    d_max = controller.getController("d_max").getValue();
    d_maxSq = d_max*d_max;
    maxConnections = (int)controller.getController("N_links").getValue();
  }
  
  abstract void draw(PVector origin, PVector neighboor, float alpha);
  
  //Draw connexions between 3 closest particles
  void draw(ArrayList<Boid> boids){
    super.draw(boids);
    ArrayList<Boid> neighboors = new ArrayList<Boid>();
    for(int i = 0; i<boids.size(); i++)
      neighboors.add(boids.get(i));
    sortNeighboors(neighboors);
    neighboors.remove(0); //Remove itself
    if(neighboors.size()>maxConnections){
      for (int i = 0; i<maxConnections; i++){
        float d = distSq(position,neighboors.get(i).position);
        if ((d > 0) && (d < d_maxSq)){
          draw(position,neighboors.get(i).position,alpha);
          if (neighboors.get(i).history.size() >= history.size()){
            for ( int j=0; j<history.size(); j++)  
              draw(history.get(j), neighboors.get(i).history.get(j), alpha/history.size()*(j+1));
          }
        }
      }
    }
  }
}

class LineBoid extends Connection {
  
  LineBoid(float x, float y, float vx, float vy){
    super(x,y,vx,vy);
  }
  
  void draw(PVector origin, PVector neighboor, float alpha){
      stroke(c,alpha);
      strokeWeight(1);
      line(origin.x, origin.y, neighboor.x, neighboor.y);
  }
}

class CurveBoid extends Connection {

  CurveBoid(float x, float y, float vx, float vy){
    super(x,y,vx,vy);
  }
  
  void draw(ArrayList<Boid> boids){
    super.draw(boids);
    for ( int i=0; i<history.size(); i++){
      float a = alpha/history.size()*(i+1);
      beginShape();
      curveVertex(history.get(i).x,history.get(i).y);
      for (Boid other : boids){
        if (other.history.size() >= history.size()){    
          float scope = distSq(history.get(i), other.history.get(i)); 
          if ((scope > 0) && (scope < d_maxSq)) {
            //count++;            // Keep track of how many            
            stroke(c,a);
            noFill();
            strokeWeight(1);
            curveVertex(other.history.get(i).x,other.history.get(i).y);
          }  
        }
      }
      endShape();
    }
  }
    
  void draw(PVector origin, PVector neighboor, float alpha){ 
  } 
} 