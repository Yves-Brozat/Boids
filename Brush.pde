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
  
  Source(float x, float y, Flock flock){
    super(x,y,flock);
    outflow = 1;
    vel = new PVector(0,0);
    angle = 0;
    type = SourceType.O;
  }
  
  void apply(){
    PVector pos = new PVector();
    switch(type){
      case O : pos.set(position.x + random(-r,r),position.y + random(-r,r));  break;
      case I : 
      float z = random(-10*r,10*r);
      pos.set(position.x + z*cos(angle),position.y + z*sin(angle));  break;
    }
    for(int i = 0; i<outflow; i++)  
      f.addBoid(pos.x,pos.y,vel.x,vel.y);
    controller.getController("N").setValue(f.boids.size());
  }
  
  PVector vel(int i){
    float r = controller.getController("src"+i+"_strength").getValue();
    PVector velocity = new PVector(r*cos(angle+0.5*PI),r*sin(angle+0.5*PI));
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

  Magnet(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void apply(){
    for (Boid b : f.boids) 
      b.applyAttraction(position);
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    rectMode(CENTER);
    rect(position.x,position.y,r,r);
  }
}

class Repulsor extends Brush {

  Repulsor(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void apply(){
    for (Boid b : f.boids) 
      b.applyRepulsion(position);
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


  Obstacle(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void apply(){     
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
  }
  
  void render(){
    noStroke();
    fill(controller.get(ColorWheel.class,"backgroundColor").getRGB());
    ellipse(position.x,position.y,10*r,10*r);
    noFill();
    stroke(controller.get(ColorWheel.class,"particleColor").getRGB(),40);
    ellipse(position.x,position.y,r,r);
  }
}

class BowlObstacle extends Brush {

  float e = 5.0;
  float angle = 0;

  BowlObstacle(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void apply(){     
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
  }
 
  void render(){
    noFill();
    stroke(100,20);
    strokeWeight(e);
    arc(position.x, position.y, 10*r, 10*r, angle, angle + PI);
  }
}

class WallObstacle extends Brush {

  float e = 20.0;
  float angle = PI/3;

  WallObstacle(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void apply(){  
    for (Boid b: f.boids){
      if ((b.position.x - position.x)*sin(angle) < (b.position.y - position.y)*cos(angle) + e 
       && (b.position.x - position.x)*sin(angle) > (b.position.y - position.y)*cos(angle) - e
       && (b.position.x - position.x)*cos(angle) < -(b.position.y - position.y)*sin(angle) + 5*r
       && (b.position.x - position.x)*cos(angle) > -(b.position.y - position.y)*sin(angle) - 5*r )
      {
        PVector n = new PVector(sin(angle),-cos(angle));
        float a = b.velocity.heading() - n.heading();
        b.velocity.rotate(PI-2*a);
        b.sumForces.add(velocity);        
        if ((b.position.x - position.x)*sin(angle) > (b.position.y - position.y)*cos(angle))
          b.position.add(e*sin(angle),-e*cos(angle));
        else
          b.position.add(-e*sin(angle),e*cos(angle));
      }
    }    
  }
  
  void render(){
    noStroke();
    fill(controller.get(ColorWheel.class,"backgroundColor").getRGB());
    rectMode(CENTER);
    pushMatrix();
    translate(position.x,position.y);
    rotate(angle);
    rect(0,0, 10*r, 2*e);
    noFill();
    stroke(controller.get(ColorWheel.class,"particleColor").getRGB(),40);
    strokeWeight(1);
    rect(0,0,10,10);
    popMatrix();
  }
  
  void update(){
    super.update();
    //angle+=0.05;
  }
}