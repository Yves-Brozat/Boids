abstract class Brush{
  PVector position;
  PVector velocity;
  boolean isActivated;
  boolean isSelected;
  Flock f;
  float r;
  
  Brush(float x, float y, Flock flock){
    f = flock;
    position = new PVector(x,y);
    velocity = new PVector();
    isActivated = false;
    isSelected = false;
    r=20;
  }
  
  void run(){
    if (isActivated)
    {
      render();
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
  
  Source(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void apply(){
    PVector pos = new PVector(position.x + random(-r,r),position.y + random(-r,r));
    switch(f.boidType){
      case TRIANGLE : f.addBoid(new TriangleBoid(pos.x,pos.y)); break;
      case LETTER : f.addBoid(new LetterBoid(pos.x,pos.y)); break;
      case CIRCLE : f.addBoid(new CircleBoid(pos.x,pos.y)); break;
      case BUBBLE : f.addBoid(new BubbleBoid(pos.x,pos.y)); break;
      case LINE : f.addBoid(new LineBoid(pos.x,pos.y)); break;
      case CURVE : f.addBoid(new CurveBoid(pos.x,pos.y)); break;
    }
    controller.getController("N").setValue(f.boids.size());
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    ellipse(position.x,position.y,2*r,2*r);
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