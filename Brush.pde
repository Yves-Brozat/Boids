abstract class Brush{
  PVector position;
  PVector velocity;
  boolean isActivated;
  boolean isSelected;
  boolean isVisible;
  Flock f;
  float r;
  
  Brush(float x, float y, Flock flock){
    f = flock;
    position = new PVector(x,y);
    velocity = new PVector();
    isActivated = false;
    isSelected = false;
    isVisible = true;
    r=20;
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
      isSelected = (mouse.dist(position) <= r) ? true : false;      
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
      if(randomVel) f.addBoid(pos.x, pos.y, random(-5,5), random(-5,5));
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
        if (b.position.dist(position) < 5*r){
          PVector n = PVector.sub(position,b.position);
          float angle = b.velocity.heading() - n.heading();
          b.velocity.rotate(PI-2*angle);
          PVector v = n.copy();
          v.setMag(-5*r);
          b.position = PVector.add(position,v);
          b.sumForces.add(velocity.mult(1.0));
        }
      }
      break;
      case I :
      for (Boid b: f.boids){
        if ((b.position.x - position.x)*sin(angle) < (b.position.y - position.y)*cos(angle) + e 
         && (b.position.x - position.x)*sin(angle) > (b.position.y - position.y)*cos(angle) - e
         && (b.position.x - position.x)*cos(angle) < -(b.position.y - position.y)*sin(angle) + 10*r
         && (b.position.x - position.x)*cos(angle) > -(b.position.y - position.y)*sin(angle) - 10*r )
        {
          PVector n = new PVector(sin(angle),-cos(angle));
          float a = b.velocity.heading() - n.heading();
          b.velocity.rotate(PI-2*a);
          b.sumForces.add(velocity);        
          if ((b.position.x - position.x)*sin(angle) > (b.position.y - position.y)*cos(angle))
            b.position.add(0.5*e*sin(angle),-0.5*e*cos(angle));
          else
            b.position.add(-0.5*e*sin(angle),0.5*e*cos(angle));
        }
      }    
      break;
      case U : 
      for (Boid b: f.boids){
        if (b.position.dist(position) > 5*r-e && b.position.dist(position) < 5*r+e && b.position.y >= position.y){
          PVector n = PVector.sub(position,b.position);
          float angle = b.velocity.heading() - n.heading();
          b.velocity.rotate(PI-2*angle);
          PVector v = n.copy();
          v.setMag(-5*r+e);
          b.position = PVector.add(position,v);
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