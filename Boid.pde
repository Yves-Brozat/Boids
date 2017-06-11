abstract class Boid {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float density;
  color c;
  PVector sumForces;
  float r;
  ArrayList<PVector> history;
  int lifetime;
  float size;
  int trailLength;
  
  //Forces parameters
  boolean[] forcesToggle;
  boolean[] paramToggle;
  float separation;
  float alignment;
  float cohesion;
  float attraction;
  float gravity;
  int gravity_Angle;
  float friction;
  
  //Global physical parameters
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float k_density;
  int lifespan;

  Boid(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector();    
    acceleration = new PVector();
    sumForces = new PVector(); 
    r = random(0,2.0);
    history = new ArrayList<PVector>();  
    lifetime = 0;
    density = 1.0;
    c = controller.get(ColorWheel.class,"particleColor").getRGB();
    size = controller.getController("size").getValue();
    trailLength = (int)controller.getController("trailLength").getValue();
    separation = controller.getController("separation").getValue();
    alignment = controller.getController("alignment").getValue();
    cohesion = controller.getController("cohesion").getValue();
    attraction = controller.getController("attraction").getValue();
    gravity = controller.getController("gravity").getValue();
    gravity_Angle = (int)controller.getController("gravity_Angle").getValue();
    friction = controller.getController("friction").getValue();
    maxforce = controller.getController("maxforce").getValue();    
    maxspeed = controller.getController("maxspeed").getValue();    
    k_density = controller.getController("k_density").getValue();
    lifespan = (int)controller.getController("lifespan").getValue();
    forcesToggle = new boolean[6];
    for (int i = 0; i < forcesToggle.length; i++) forcesToggle[i] = controller.get(CheckBox.class,"forceToggle").getState(i);
    paramToggle = new boolean[3];
    for (int i = 0; i < paramToggle.length; i++) paramToggle[i] = controller.get(CheckBox.class,"parametersToggle").getState(i);
  }

  void run(ArrayList<Boid> boids) {
    savePosition();
    applyFlock(boids);
    if(forcesToggle[4]) applyFriction();
    if(forcesToggle[5]) applyGravity();
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
  
  void applyGravity(){
    PVector g = new PVector(cos(radians(gravity_Angle+90)),sin(radians(gravity_Angle+90)));
    g.mult(gravity);
    g.mult(density*r*r);
    sumForces.add(g);
  }
  
  void applyFriction(){
     PVector fri = new PVector(velocity.x,velocity.y);
     fri.normalize();
     float f = -velocity.mag()*r*r;
     fri.mult(f);
     fri.mult(friction);
     sumForces.add(fri);
     
  }
  
  void applyAttraction(PVector v){
    PVector mis = seek(v);
    mis.mult(attraction);
    if(forcesToggle[3])  sumForces.add(mis);
  }
  // We accumulate a new acceleration each time based on three rules
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
    PVector v = new PVector(position.x,position.y);
    history.add(v);
  }
  
  // Method to update position
  void update() {
    // Update masse
    float masse = density * r * r * k_density;  //density : initial density of the particular boid. k_density : coefficient on slider "density" to change weight of all boids
    // Newton's 2nd law
    acceleration = PVector.mult(sumForces,1/masse);    
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    if (paramToggle[1]) velocity.limit(maxspeed);
    // Update position
    position.add(velocity);
    // Reset forces to 0 each cycle
    sumForces.mult(0);
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
    int alpha = 255;
    if (paramToggle[2]) alpha = (int)map(lifetime,0,lifespan,255,1);
    c = color(controller.get(ColorWheel.class,"particleColor").r(),
              controller.get(ColorWheel.class,"particleColor").g(),
              controller.get(ColorWheel.class,"particleColor").b(),
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
    float desiredseparation = 100;
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
}

//============================================================================
//---SUB-CLASSES--------------------------------------------------------------
//============================================================================

class TriangleBoid extends Boid {
  
  TriangleBoid(float x, float y){
    super(x,y);
  }
  
  void render(ArrayList<Boid> boids){
    super.render(boids);
    float theta = velocity.heading() + radians(90);
    r = size;
    for ( int i=0; i< history.size(); i++)
    {
      pushMatrix();
      translate(history.get(i).x, history.get(i).y);
      rotate(theta);
      fill(c,255/history.size()*(i+1));
      noStroke();
      beginShape(TRIANGLES);
      vertex(0, -r*2);
      vertex(-r, r*2);
      vertex(r, r*2);
      endShape();
      popMatrix();
    }
  } 
}

class LetterBoid extends Boid {
  
  String letter;    
  
  LetterBoid(float x, float y){
    super(x,y);
    letter = alphabet.get(int(random(alphabet.size()-1)));
  }
  
  void render(ArrayList<Boid> boids){
    super.render(boids);
    float theta = velocity.heading() + radians(90);
    for ( int i=0; i< history.size(); i++)
    {
      pushMatrix(); 
      translate(history.get(i).x, history.get(i).y);
      rotate(theta);
      //r = map(mag.position.dist(history.get(i)),1,height,0,2);
      //r = constrain(r,0,1);
      fill(c,255/history.size()*(i+1));
      noStroke();
      textSize(10*r*size+1);
      text(letter,0,0);
      popMatrix();
    }
  } 
}

class CircleBoid extends Boid {
  
  CircleBoid(float x, float y){
    super(x,y);
  }
  
  void render(ArrayList<Boid> boids){
    super.render(boids);
    for ( int i=0; i< history.size(); i++)
    {
      pushMatrix();
      //r = map(mag.position.dist(history.get(i)),1,height,2,0);
      //r = constrain(r,0,1);
      fill(c,255/history.size()*(i+1));
      noStroke();
      ellipse(history.get(i).x, history.get(i).y,10*r*size,10*r*size);
      popMatrix();
    }
  } 
}

class BubbleBoid extends Boid {
  
  BubbleBoid(float x, float y){
    super(x,y);
  }
  
  void render(ArrayList<Boid> boids){
    super.render(boids);
    for ( int i=0; i< history.size(); i++)
    {
      pushMatrix();
      r = random(0,1);
      fill(c,255/history.size()*(i+1));
      noStroke();
      ellipse(history.get(i).x, history.get(i).y,25*r*size,25*r*size);
      popMatrix();
    }
  } 
}

class LineBoid extends Boid {
  
  LineBoid(float x, float y){
    super(x,y);
  }
  
  void render(ArrayList<Boid> boids){
    super.render(boids);
    for ( int i=0; i<history.size(); i++){
      for (Boid other : boids) {    
        if (other.history.size() >= history.size()){
          float d = PVector.dist(history.get(i), other.history.get(i));
          //int count = 0;
          if ((d > 0) && (d < 20*size)) {
            //count++;            // Keep track of how many
            stroke(c,255/history.size()*(i+1));
            strokeWeight(1);
            line(history.get(i).x,history.get(i).y,other.history.get(i).x,other.history.get(i).y);
          }
        }   
      }
    }
  } 
}

class CurveBoid extends Boid {
  
  CurveBoid(float x, float y){
    super(x,y);
  }
  
  void render(ArrayList<Boid> boids){
    super.render(boids);
    for ( int i=0; i<history.size(); i++){
      beginShape();
      curveVertex(history.get(i).x,history.get(i).y);
      for (Boid other : boids) {
      if (other.history.size() >= history.size())
        {
          float f = PVector.dist(history.get(i), other.history.get(i));
          //int count = 0;
          if ((f > 0) && (f < 20*size)) {
            //count++;            // Keep track of how many
            stroke(c,255/history.size()*(i+1));
            noFill();
            strokeWeight(1);
            curveVertex(other.history.get(i).x,other.history.get(i).y);
          }
        } 
      }
      endShape();
    }
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