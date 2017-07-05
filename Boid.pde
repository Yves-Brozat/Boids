abstract class Boid {

  //Dynamic parameters
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector sumForces;
  
  //Visual parameters
  color c;
  float randomBrightness;
  float randomRed, randomGreen, randomBlue;
  float size;
  float r;
  ArrayList<PVector> history;  
  int trailLength;
  int maxConnections;
  
  //Forces parameters
  boolean[] forcesToggle;
  float separation;
  float alignment;
  float cohesion;
  float attraction;
  float repulsion;
  float friction;
  float gravity;
  int gravity_Angle;
  
  //Global physical parameters
  boolean[] paramToggle;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float density;  // Personal density of the particle
  float k_density;  // Global coefficient to increase/decrease density of all particles
  int lifetime;
  int lifespan;
  
  float xoff, yoff;
  float xnoiseScale, ynoiseScale;
  
  Boid(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector();    
    acceleration = new PVector();
    sumForces = new PVector(); 
    
    c = controller.get(ColorWheel.class,"particleColor").getRGB();
    randomBrightness = random(-controller.getController("contrast").getValue(),controller.getController("contrast").getValue());
    randomRed = random(0,controller.getController("red").getValue());
    randomGreen = random(0,controller.getController("green").getValue());
    randomBlue = random(0,controller.getController("blue").getValue());
    size = controller.getController("size").getValue();
    r = 1;
    history = new ArrayList<PVector>();  
    trailLength = (int)controller.getController("trailLength").getValue();    
    maxConnections = (int)controller.getController("N_connections").getValue();
    
    forcesToggle = new boolean[8];
    for (int i = 0; i < forcesToggle.length; i++) 
      forcesToggle[i] = controller.get(CheckBox.class,"forceToggle").getState(i);
    separation = controller.getController("separation").getValue();
    alignment = controller.getController("alignment").getValue();
    cohesion = controller.getController("cohesion").getValue();
    attraction = controller.getController("attraction").getValue();
    repulsion = controller.getController("repulsion").getValue();
    friction = controller.getController("friction").getValue();
    gravity = controller.getController("gravity").getValue();
    gravity_Angle = (int)controller.getController("gravity_Angle").getValue();
       
    paramToggle = new boolean[3];
    for (int i = 0; i < paramToggle.length; i++) 
      paramToggle[i] = controller.get(CheckBox.class,"parametersToggle").getState(i);
    maxforce = controller.getController("maxforce").getValue();    
    maxspeed = controller.getController("maxspeed").getValue();    
    density = 1.0;
    k_density = controller.getController("k_density").getValue();
    lifetime = 0;
    lifespan = (int)controller.getController("lifespan").getValue();
    
    xoff = int(random(0,10));
    yoff = (random(0,10));
    xnoiseScale = controller.getController("noise").getValue()*0.01;
    ynoiseScale = 2*xnoiseScale;
  }

  void run(ArrayList<Boid> boids) {
    savePosition();
    applyFlock(boids);
    if(forcesToggle[5]) applyFriction();
    if(forcesToggle[6]) applyGravity();
    if(forcesToggle[7]) applyNoise();
    update();
    borders();
    if(position.x > controllerSize)
      render(boids);
    if(paramToggle[2]) lifetime++;
  }

  boolean isDead(){
    if (paramToggle[2]) return (lifetime > lifespan) ? true : false;
    else return false;
  }
  
  
  void applyNoise(){
    xoff += xnoiseScale;
    yoff += ynoiseScale;
    float x = map(noise(xoff),0,1,-1,1);
    float y = map(noise(yoff),0,1,-1,1);
    position.add(x,y); 
  }
  
  void applyGravity(){
    PVector g = new PVector(cos(radians(gravity_Angle+90)),sin(radians(gravity_Angle+90)));
    g.mult(gravity);
    g.mult(0.1*density*r*r);
    sumForces.add(g);
  }
  
  void applyFriction(){
     PVector fri = new PVector(velocity.x,velocity.y);
     fri.normalize();
     float f = -0.1*velocity.mag()*r*r;
     fri.mult(f);
     fri.mult(friction);
     sumForces.add(fri);   
  }
  
  void applyRepulsion(PVector v){
    PVector rep = PVector.sub(position,v);
    float d = rep.magSq();
    rep.setMag(20000*density*r*r/d);
    rep.mult(repulsion);
    if(forcesToggle[4]) sumForces.add(rep);
  }
  
  void applyAttraction(PVector v){
    PVector mis = PVector.sub(v,position);
    float d = mis.mag();
    mis.setMag(100*density*r*r/d);
    mis.mult(attraction);
    if(forcesToggle[3])  sumForces.add(mis);
  }
  
  void applyFlock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion

    // Arbitrarily weight these forces
    sep.mult(separation);
    ali.mult(alignment);
    coh.mult(cohesion);
    // Add the force vectors to acceleration
    if(forcesToggle[0])  sumForces.add(sep);
    if(forcesToggle[1])  sumForces.add(ali);
    if(forcesToggle[2])  sumForces.add(coh);
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
    float masse = density * r * r * k_density;  //density : initial density of the particular boid. k_density : coefficient on slider "density" to change weight of all boids
    acceleration = PVector.mult(sumForces,1/masse);  // Newton's 2nd law  
    velocity.add(acceleration);
    if (paramToggle[1]) velocity.limit(maxspeed);  // Limit speed
    position.add(velocity); 
    sumForces.mult(0);  // Reset forces to 0 each cycle
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
    if(keyPressed){
      switch(key){
        case 'é'  : reflect(2,boids);  break;
        case '"'  : reflect(3,boids);  break;
        case '\'' : reflect(4,boids);  break;
        case '('  : reflect(5,boids);  break;
        case '-'  : reflect(6,boids);  break;
        case 'è'  : reflect(7,boids);  break;
        case '_'  : reflect(8,boids);  break;
        case 'ç'  : reflect(9,boids);  break;
      }
    }
    draw(boids);
  }
  
  void reflect(int n, ArrayList<Boid> boids){
    Boid b = this;
    for (int i=0;i<n-1;i++){ 
      pushMatrix();
      translate(0.5*(controllerSize+width),0.5*height);     
      rotate(2*PI*(i+1)/n);
      translate(-0.5*(controllerSize+width),-0.5*height);
      b.draw(boids);
      popMatrix();
    }
  }

  void draw(ArrayList<Boid> boids){
    int alpha = 255;
    if (paramToggle[2]) alpha = (int)map(lifetime,0,lifespan,255,1);
    c = color(controller.get(ColorWheel.class,"particleColor").r() + randomBrightness + randomRed - randomGreen - randomBlue,
              controller.get(ColorWheel.class,"particleColor").g() + randomBrightness - randomRed + randomGreen - randomBlue,
              controller.get(ColorWheel.class,"particleColor").b() + randomBrightness - randomRed - randomGreen + randomBlue,
              alpha);
  }
  
  void borders() {
    switch (borderType)
    {
      case WALLS :
      if (position.x < controllerSize-r) {
        velocity.x *= -1;
        position.x = controllerSize-r;
      }
      if (position.x > width+r) {
        velocity.x *= -1;
        position.x = width+r;
      }
      if (position.y < -r) {
        velocity.y *= -1;
        position.y = -r;
      }
      if (position.y > height+r) {
        velocity.y *= -1;
        position.y = height+r;
      }
      break;
    
      case LOOPS : 
      if (position.x < controllerSize-r) position.x = width+r;
      if (position.y < -r) position.y = height+r;
      if (position.x > width+r) position.x = controllerSize + r;
      if (position.y > height+r) position.y = -r;
      break;
      
      case NOBORDER : 
      break;
    }
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < desiredseparation)) {
        PVector diff = PVector.sub(position, other.position); // Calculate vector pointing away from neighbor
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      steer.setMag(maxspeed);
      steer.sub(velocity);   // Implement Reynolds: Steering = Desired - Velocity
      if (paramToggle[0]) steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
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
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
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
          Float f1 = new Float(PVector.dist(b1.position,position));
          Float f2 = new Float(PVector.dist(b2.position,position));
          
          return f1.compareTo(f2);
         
        }
    });
  }
}

//============================================================================
//---SUB-CLASSES--------------------------------------------------------------
//============================================================================

abstract class Particle extends Boid {
  
  Particle(float x, float y){
    super(x,y);
  }
  
  abstract void draw(float x, float y, float r, float theta, float alpha);
  
  void draw(ArrayList<Boid> boids){
    super.draw(boids);
    
    ArrayList<Boid> neighboors = new ArrayList<Boid>();
    for(int i = 0; i<boids.size(); i++)
      neighboors.add(boids.get(i));
    sortNeighboors(neighboors);
    neighboors.remove(0); //Remove itself
    float isolation = 0;
    for(int i = 0; i< neighboors.size(); i++){
      if(i<10) isolation += 0.1*PVector.dist(position,neighboors.get(i).position);
    }
    draw(position.x, position.y, size*max(map(isolation,0,100,10,0),0), velocity.heading() + radians(90), 100);
   
    if(history.size() > 0){
      for ( int i=0; i< history.size(); i++)
        draw(history.get(i).x, history.get(i).y, size, velocity.heading() + radians(90), map(i,0,history.size(),0,255));
    }
  }
}

class TriangleBoid extends Particle {
  
  TriangleBoid(float x, float y){
    super(x,y);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix();
    translate(x, y);
    rotate(theta);
    fill(c,alpha);
    noStroke();
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }
}

class LetterBoid extends Particle {
  
  String letter;    
  
  LetterBoid(float x, float y){
    super(x,y);
    letter = alphabet.get(int(random(alphabet.size()-1)));
    r = random(0,2);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix(); 
    translate(x, y);
    rotate(theta);
    fill(c,alpha);
    noStroke();
    textSize(10*this.r*r+1);
    text(letter,0,0);
    popMatrix();
  }
}

class CircleBoid extends Particle {
  
  CircleBoid(float x, float y){
    super(x,y);
    //r = random(0,2);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix();
    fill(c,alpha);
    noStroke();
    ellipse(x, y,10*this.r*r,10*this.r*r);
    popMatrix();
  } 
}

class BubbleBoid extends Particle {
  
  BubbleBoid(float x, float y){
    super(x,y);
  }
  
  void draw(float x, float y, float r, float theta, float alpha){
    pushMatrix();
    this.r = random(0,1);
    fill(c,alpha);
    noStroke();
    ellipse(x, y,25*this.r*r,25*this.r*r);
    popMatrix();
  }
}

abstract class Connection extends Boid{
   
  Connection(float x, float y){
    super(x,y);
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
        if ((PVector.dist(position,neighboors.get(i).position) > 0) && (PVector.dist(position,neighboors.get(i).position) < 20*size)){
          draw(position,neighboors.get(i).position,255);
        //if (other.history.size() >= history.size()){
        //  for ( int i=0; i<history.size(); i++)  
        //    draw(history.get(i), other.history.get(i), PVector.dist(history.get(i), other.history.get(i)),255/history.size()*(i+1));
        //}
        }
      }
    }
  }
}

class LineBoid extends Connection {
  
  LineBoid(float x, float y){
    super(x,y);
  }
  
  void draw(PVector origin, PVector neighboor, float alpha){
      stroke(c,alpha);
      strokeWeight(1);
      line(origin.x, origin.y, neighboor.x, neighboor.y);
  }
}

class CurveBoid extends Connection {
  
  CurveBoid(float x, float y){
    super(x,y);
  }
  
  void draw(ArrayList<Boid> boids){
    super.draw(boids);
    for ( int i=0; i<history.size(); i++){
      beginShape();
      curveVertex(history.get(i).x,history.get(i).y);
      for (Boid other : boids){
        if (other.history.size() >= history.size()){    
          //draw(history.get(i), other.history.get(i), PVector.dist(history.get(i), other.history.get(i)),255/history.size()*(i+1));
          float scope = PVector.dist(history.get(i), other.history.get(i)); 
          if ((scope > 0) && (scope < 20*size)) {
            //count++;            // Keep track of how many
            float alpha = 255/history.size()*(i+1);
            stroke(c,alpha);
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


    /*//EFFET BULLES DE SAVON
    r = int(map(missionPoint.dist(position),1,height/2,255,1));
    r = constrain(r,1,255);
    stroke(255-r);
    strokeWeight(r);
    point(0,0);
    */
    /*//NUAGEUX, VENT
    r = int(map(missionPoint.dist(position),1,height/2,255,50));
    r = constrain(r,50,255);
    stroke(255-r,10);
    strokeWeight(r);
    point(0,0);
    */ 