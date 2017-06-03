abstract class Boid {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float masse;
  color c;
  PVector sumForces;
  float r;
  String letter;
  ArrayList<PVector> history;
  int lifetime;


  Boid(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D();    
    acceleration = new PVector();
    masse = 1.0;
    c = 255;
    sumForces = new PVector(); 
    r = random(0,2.0);
    letter = alphabet.get(int(random(alphabet.size())));
    history = new ArrayList<PVector>();   
    lifetime = 0;
  }

  void run(ArrayList<Boid> boids) {
    savePosition();
    applyFlock(boids);
    applyGravity();
    applyFriction();
    update();
    borders();
    render(boids);
    lifetime++;
  }

  boolean isDead(){
    return (lifetime > LIFETIME) ? true : false;
  }
  
  void applyGravity(){
    PVector g = new PVector(cos(radians(gravity_Angle+90)),sin(radians(gravity_Angle+90)));
    g.mult(gravity);
    g.mult(masse);
    sumForces.add(g);
  }
  
  void applyFriction(){
     PVector friction = new PVector(velocity.x,velocity.y);
     friction.normalize();
     float c = -velocity.mag()*r*r;
     friction.mult(c);
     friction.mult(FRICTION);
     sumForces.add(friction);
     
  }
  
  void applyRepulsion(PVector v){
    PVector rep = mission(v.rotate(PI));
    sumForces.add(rep);
  }
  void applyAttraction(PVector v){
    PVector mis = mission(v);
    mis.mult(attraction);
    sumForces.add(mis);
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
    sumForces.add(sep);
    sumForces.add(ali);
    sumForces.add(coh);
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
    float newMasse = masse * MASSE;  //masse : initial masse of the particular boid. MASSE : coefficient on slider "masse" to change weight of all boids
    // Newton's 2nd law
    acceleration = PVector.mult(sumForces,1/newMasse);    
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    // Update position
    position.add(velocity);
    // Reset forces to 0 each cycle
    sumForces.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  abstract void render(ArrayList<Boid> boids); 
    //float theta = velocity.heading() + radians(90);
    //c = color(map(lifetime,0,LIFETIME,255,0));
    
    //switch(boidType)
    //{
    //  case TRIANGLE : //TRIANGLE EXAMPLE 
    //  r = size;
    //  for ( int i=0; i< history.size(); i++)
    //  {
    //    pushMatrix();
    //    translate(history.get(i).x, history.get(i).y);
    //    rotate(theta);
    //    fill(c,100/history.size()*(i+1));
    //    noStroke();
    //    beginShape(TRIANGLES);
    //    vertex(0, -r*2);
    //    vertex(-r, r*2);
    //    vertex(r, r*2);
    //    endShape();
    //    popMatrix();
    //  }
    //  break;
      
    //  case LETTER : //LETTRES SILOUHETTES
    //  for ( int i=0; i< history.size(); i++)
    //  {
    //    pushMatrix(); 
    //    translate(history.get(i).x, history.get(i).y);
    //    rotate(theta);
    //    //r = map(mag.position.dist(history.get(i)),1,height,0,2);
    //    //r = constrain(r,0,1);
    //    fill(c,100/history.size()*(i+1));
    //    noStroke();
    //    textSize(10*r*size+1);
    //    text(letter,0,0);
    //    popMatrix();
    //  }
    //  break;
      
    //  case CIRCLE : //FUMEE
    //  for ( int i=0; i< history.size(); i++)
    //  {
    //    pushMatrix();
    //    //r = map(mag.position.dist(history.get(i)),1,height,2,0);
    //    //r = constrain(r,0,1);
    //    fill(c,100/history.size()*(i+1));
    //    noStroke();
    //    ellipse(history.get(i).x, history.get(i).y,10*r*size,10*r*size);
    //    popMatrix();
    //  }
    //  break;
      
    //  case BUBBLE : 
    //  for ( int i=0; i< history.size(); i++)
    //  {
    //    pushMatrix();
    //    r = random(0,1);
    //    fill(c,100/history.size()*(i+1));
    //    noStroke();
    //    ellipse(history.get(i).x, history.get(i).y,25*r*size,25*r*size);
    //    popMatrix();
    //  }
    //  break;
      
    //  case LINE : 
    //  r = 2.0;
    //  for ( int i=0; i<history.size()-1; i++){
    //    for (Boid other : boids) {    
    //      if (other.history.size() >= history.size())
    //      {
    //        float d = PVector.dist(history.get(i), other.history.get(i));
    //        //int count = 0;
    //        if ((d > 0) && (d < 20*size)) {
    //          //count++;            // Keep track of how many
    //          stroke(c,100/history.size()*(i+1));
    //          strokeWeight(1);
    //          line(history.get(i).x,history.get(i).y,other.history.get(i).x,other.history.get(i).y);
    //        }
    //      }   
    //    }
    //  }
    //  break;
      
    //  case CURVE : 
    //  r = 2.0;
    //  for ( int i=0; i<history.size()-1; i++){
    //    beginShape();
    //    curveVertex(history.get(i).x,history.get(i).y);
    //    for (Boid other : boids) {
    //    if (other.history.size() >= history.size())
    //      {
    //        float f = PVector.dist(history.get(i), other.history.get(i));
    //        //int count = 0;
    //        if ((f > 0) && (f < 20*size)) {
    //          //count++;            // Keep track of how many
    //          stroke(c,100/history.size()*(i+1));
    //          noFill();
    //          strokeWeight(1);
    //          curveVertex(other.history.get(i).x,other.history.get(i).y);
    //          //line(history.get(i).x,history.get(i).y,other.history.get(i).x,other.history.get(i).y);
    //        }
    //      } 
    //    }
    //    endShape();
    //  }
    //}

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
    
    /*//SETTINGS POUR SILOUHETTE 
    if (position.x > width+r) {
      position.x = width-r;
      velocity.x = -velocity.x;
    }  
    if (position.y > height+r) position.y = -r;
    if (position.dist(missionPoint) < rayon) velocity.y = -0.8*velocity.y;
    */
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 100;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
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
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
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
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
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
  
  PVector mission (PVector attractivePoint) {
    return seek(attractivePoint);
  }  
}

class TriangleBoid extends Boid {
  
  TriangleBoid(float x, float y){
    super(x,y);
  }
  
  void render(ArrayList<Boid> boids){
    float theta = velocity.heading() + radians(90);
    c = color(map(lifetime,0,LIFETIME,255,0));
    r = size;
    for ( int i=0; i< history.size(); i++)
    {
      pushMatrix();
      translate(history.get(i).x, history.get(i).y);
      rotate(theta);
      fill(c,100/history.size()*(i+1));
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
  
  LetterBoid(float x, float y){
    super(x,y);
  }
  
  void render(ArrayList<Boid> boids){
    float theta = velocity.heading() + radians(90);
    c = color(map(lifetime,0,LIFETIME,255,0));
    for ( int i=0; i< history.size(); i++)
    {
      pushMatrix(); 
      translate(history.get(i).x, history.get(i).y);
      rotate(theta);
      //r = map(mag.position.dist(history.get(i)),1,height,0,2);
      //r = constrain(r,0,1);
      fill(c,100/history.size()*(i+1));
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
    c = color(map(lifetime,0,LIFETIME,255,0));
    for ( int i=0; i< history.size(); i++)
    {
      pushMatrix();
      //r = map(mag.position.dist(history.get(i)),1,height,2,0);
      //r = constrain(r,0,1);
      fill(c,100/history.size()*(i+1));
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
    c = color(map(lifetime,0,LIFETIME,255,0));
    for ( int i=0; i< history.size(); i++)
    {
      pushMatrix();
      r = random(0,1);
      fill(c,100/history.size()*(i+1));
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
    c = color(map(lifetime,0,LIFETIME,255,0));
    for ( int i=0; i<history.size()-1; i++){
      for (Boid other : boids) {    
        if (other.history.size() >= history.size()){
          float d = PVector.dist(history.get(i), other.history.get(i));
          //int count = 0;
          if ((d > 0) && (d < 20*size)) {
            //count++;            // Keep track of how many
            stroke(c,100/history.size()*(i+1));
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
    c = color(map(lifetime,0,LIFETIME,255,0));
    for ( int i=0; i<history.size()-1; i++){
      beginShape();
      curveVertex(history.get(i).x,history.get(i).y);
      for (Boid other : boids) {
      if (other.history.size() >= history.size())
        {
          float f = PVector.dist(history.get(i), other.history.get(i));
          //int count = 0;
          if ((f > 0) && (f < 20*size)) {
            //count++;            // Keep track of how many
            stroke(c,100/history.size()*(i+1));
            noFill();
            strokeWeight(1);
            curveVertex(other.history.get(i).x,other.history.get(i).y);
            //line(history.get(i).x,history.get(i).y,other.history.get(i).x,other.history.get(i).y);
          }
        } 
      }
      endShape();
    }
  } 
}