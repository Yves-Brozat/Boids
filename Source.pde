class Source {
  
  PVector position;
  boolean isActivated;
  boolean isSelected;
  Flock f;
  float r;
  
  Source(float x, float y, Flock flock){
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
      f.addBoid(new Boid(position.x,position.y));
      sliderN.setValue(f.boids.size());
    }
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    ellipse(position.x,position.y,r,r);
  }
  
  void mousePressed(){
    PVector mouse = new PVector(mouseX,mouseY);
    if (mouse.dist(position) <= r) isSelected = true;
  }
  void mouseReleased(){
    isSelected = false;
  }
  void mouseDragged(){
    if (isSelected) position.set(mouseX,mouseY);
  }
}