class Magnet {
  
  PVector position;
  boolean isActivated;
  boolean isSelected;
  Flock f;
  float r;
  
  Magnet(float x, float y, Flock flock){
    f = flock;
    position = new PVector(x,y);
    isActivated = false;
    isSelected = false;
    r = 20;
  }
  
  void run(){
    if (isActivated)
    {
      render();
      for (Boid b : f.boids) {
        b.applyAttraction(position);
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
  
  void mousePressed(){
    PVector mouse = new PVector(mouseX,mouseY);
    isSelected = (mouse.dist(position) <= r) ? true : false;    
  }
  void mouseReleased(){
    isSelected = false;
  }
  void mouseDragged(){
    if (isSelected) position.set(mouseX,mouseY);
  }
}