abstract class Brush{
  PVector position;
  boolean isActivated;
  boolean isSelected;
  Flock f;
  float r;
  
  Brush(float x, float y, Flock flock){
    f = flock;
    position = new PVector(x,y);
    isActivated = false;
    isSelected = false;
    r=20;
  }
  
  void run(){
    if (isActivated)
    {
      render();
      update();
    }
  }
  
  abstract void update();
  abstract void render();
  
  void mousePressed(){
    if (isActivated)
    {
      PVector mouse = new PVector(mouseX,mouseY);
      isSelected = (mouse.dist(position) <= r) ? true : false;
    }
  }
  void mouseReleased(){
    if (isActivated)
      isSelected = false;
  }
  void mouseDragged(){
    if (isSelected) position.set(mouseX,mouseY);
  }
}

class Source extends Brush {
  
  Source(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void update(){
    switch(f.boidType){
      case TRIANGLE : f.addBoid(new TriangleBoid(position.x,position.y)); break;
      case LETTER : f.addBoid(new LetterBoid(position.x,position.y)); break;
      case CIRCLE : f.addBoid(new CircleBoid(position.x,position.y)); break;
      case BUBBLE : f.addBoid(new BubbleBoid(position.x,position.y)); break;
      case LINE : f.addBoid(new LineBoid(position.x,position.y)); break;
      case CURVE : f.addBoid(new CurveBoid(position.x,position.y)); break;
    }
    controller.getController("N").setValue(f.boids.size());
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    ellipse(position.x,position.y,r,r);
  }
}

class Magnet extends Brush {

  Magnet(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void update(){
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

class Obstacle extends Brush {


  Obstacle(float x, float y, Flock flock){
    super(x,y,flock);
  }
  
  void update(){     
    for (Boid b: f.boids){
      if (b.position.dist(position) < 5*r){
        PVector n = PVector.sub(position,b.position);
        float angle = PVector.angleBetween(n,b.velocity);
        b.velocity.rotate(PI);
        b.velocity.rotate(2*angle);
        PVector v = n.copy();
        v.setMag(-5*r);
        b.position = PVector.add(position,v);
      }
    }      
  }
  
  void render(){
    noStroke();
    fill(100,20);
    ellipse(position.x,position.y,10*r,10*r);
  }
}