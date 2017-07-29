abstract class Brush{
  PVector position;
  PVector velocity;
  boolean isActivated;
  boolean isSelected;
  boolean isVisible;
  Flock f;
  float r, rSq;
  
  Brush(float x, float y, Flock flock){
    f = flock;
    position = new PVector(x,y);
    velocity = new PVector();
    isActivated = false;
    isSelected = false;
    isVisible = true;
    r=20;
    rSq = r*r;
  }
  
  void run(){
    if (isActivated)
    {
      if (isVisible) render();
      update();
      apply();
    }
  }
  
  void update(){
    if (isSelected && mousePressed){
      PVector oldPosition = position.copy();
      position.set(mouseX,mouseY);
      velocity = PVector.sub(position,oldPosition);
    }
  }
  
  abstract void render();
  abstract void apply();
  
  void mousePressed(){
    if (isActivated)
    {
      PVector mouse = new PVector(mouseX,mouseY);
      isSelected = (distSq(mouse, position) <= rSq) ? true : false;      
    }
  }
  void mouseReleased(){
    if (isActivated){
      isSelected = false;
      velocity.set(0,0);
    }
  }
  void mouseDragged(){
    if (isSelected) {

    }
  }
}

class Source extends Brush {
  
  int outflow;
  float angle;
  PVector vel;
  SourceType type;
  int lifespan;
  boolean randomVel;
  
  Source(float x, float y, Flock flock){
    super(x,y,flock);
    outflow = 1;
    vel = new PVector(0,0);
    angle = 0;
    type = SourceType.O;
    lifespan = 100;
    randomVel = false;
  }
  
  void apply(){
    for(int i = 0; i<outflow; i++){  
      PVector pos = new PVector();
      switch(type){
        case O : pos.set(position.x + random(-r,r),position.y + random(-r,r));  break;
        case I : 
        float z = random(-10*r,10*r);
        pos.set(position.x + z*cos(angle),position.y + z*sin(angle));  break;
      }
      if(randomVel) f.addBoid(pos.x, pos.y, random(-3,3), random(-3,3));
      else  f.addBoid(pos.x,pos.y,vel.x,vel.y);
      f.bornList.get(f.bornList.size()-1).lifespan = lifespan;
    }
  }
  
  PVector vel(int i){
    float r = controller.getController("src"+i+"_strength").getValue();
    PVector velocity = new PVector(r*cos(angle+HALF_PI),r*sin(angle+HALF_PI));
    return velocity;
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    switch(type){
      case O : ellipse(position.x,position.y,2*r,2*r);  break;
      case I : 
      float d = min(20*r,width);
      rectMode(CENTER);
      pushMatrix();
      translate(position.x,position.y);
      rotate(angle);
      rect(0,0, d, 0.01*d);
      popMatrix();
      break;     
    }
  }
}

class Magnet extends Brush {

  MagnetType type;
  float strength;
  
  Magnet(float x, float y, Flock flock){
    super(x,y,flock);
    type = MagnetType.PLUS;
    strength = 0;
  }
  
  void apply(){
    for (Boid b : f.boids){
      switch(type){
        case PLUS : b.applyAttraction(position,strength); break;
        case MINUS : b.applyRepulsion(position,strength); break;  
      }
    }
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    rectMode(CENTER);
    rect(position.x,position.y,r,r);
  }
}

class Obstacle extends Brush {

  ObstacleType type;
  float e;
  float angle;
  
  Obstacle(float x, float y, Flock flock){
    super(x,y,flock);
    e = 50;
    angle = 0;
    type = ObstacleType.O;
  }
  
  void apply(){     
    switch(type){
      case O :
      for (Boid b: f.boids){
        if (distSq(b.position,position) < 25*rSq){
          PVector n = PVector.sub(position,b.position);
          float theta = b.velocity.heading() - n.heading();
          b.velocity.rotate(PI-2*theta);
          PVector v = n.copy();
          v.setMag(-5*r);
          b.position = PVector.add(position,v);
          b.sumForces.add(velocity);
        }
      }
      break;
      case U : 
      for (Boid b: f.boids){
        PVector a = new PVector(sin(angle),-cos(angle));
        PVector n = PVector.sub(position,b.position);
        if (n.magSq() > (5*r-e)*(5*r-e) && n.magSq() < (5*r+e)*(5*r+e) && n.x*a.x > - n.y*a.y){
          float theta = b.velocity.heading() - n.heading();
          b.velocity.rotate(PI-2*theta);
          PVector v = n.copy();
          if (n.magSq() < 25*rSq)
            v.setMag(-5*r+e);
          else
            v.setMag(-5*r-e);
          b.position = PVector.add(position,v);
          b.sumForces.add(velocity);
        }
      }
      break;
      case I :
      for (Boid b: f.boids){
        PVector n = new PVector(sin(angle),-cos(angle));
        PVector d = PVector.sub(b.position,position);
        if (d.x*n.x < -d.y*n.y + e  && d.x*n.x > -d.y*n.y - e && -d.x*n.y < -d.y*n.x + 10*r && -d.x*n.y > -d.y*n.x - 10*r )
        {          
          float theta = b.velocity.heading() - n.heading();
          b.velocity.rotate(PI-2*theta);
          b.sumForces.add(velocity);         
          float dAngle = d.y*n.x - d.x*n.y;
          if (d.x*n.x > - d.y*n.y)
            b.position = new PVector(position.x - dAngle*n.y + e*n.x, position.y + dAngle*n.x + e*n.y);
          else
            b.position = new PVector(position.x - dAngle*n.y - e*n.x, position.y + dAngle*n.x - e*n.y);
        }
      }    
      break;
    }    
  }
  
  void render(){
    switch(type){
      case O :
      noFill();
      stroke(controller.get(ColorWheel.class,"particleColor").getRGB(),40);
      ellipse(position.x,position.y,10*r,10*r);
      ellipse(position.x,position.y,r,r);
      break;
      case I :
      noFill();
      stroke(controller.get(ColorWheel.class,"particleColor").getRGB(),40);
      rectMode(CENTER);
      pushMatrix();
      translate(position.x,position.y);
      rotate(angle);
      rect(0,0, 20*r, 2*e);
      rect(0,0,10,10);
      popMatrix();
      break;
      case U :
      noFill();
      stroke(controller.get(ColorWheel.class,"particleColor").getRGB(),40);
      arc(position.x, position.y, 10*r, 10*r, angle, angle + PI);
      break;
    }
  }
}