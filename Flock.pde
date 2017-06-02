class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Source> sources;
  ArrayList<Magnet> magnets;

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
    magnets = new ArrayList<Magnet>(4);
    sources = new ArrayList<Source>(4);
    for (int i = 0; i< 4; i ++){
      sources.add(new Source((i+1)*0.2*width,i*0.2*height+50, this));
      magnets.add(new Magnet(width-((i+1)*0.2*width),i*0.2*height+50, this));
    }
  }

  void run() {
    for (Source s : sources)
      s.run();
    for (Magnet m : magnets)
      m.run();
    for (int i = 0; i<boids.size(); i++) {
      boids.get(i).run(boids); 
      if (boids.get(i).isDead()) { 
        boids.remove(i);
        sliderN.setValue(boids.size());
      }
    }
    if (!sources.get(0).isActivated || !sources.get(1).isActivated || !sources.get(2).isActivated || !sources.get(3).isActivated)
      setSize();
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

  void setSize() {
    if (flock.boids.size() < sliderN.getValue()-1)
      flock.addBoid(new Boid(random(controllerSize,width),random(0,height)));
    else if (flock.boids.size() > sliderN.getValue()+1)
      flock.boids.remove(flock.boids.size()-1);
  }
  
  void mouseDragged(){
  if (mouseX>controllerSize){   
    for (Source s : sources)
      s.mouseDragged();
    for (Magnet m : magnets)
      m.mouseDragged();
  }
}

void mousePressed(){
  for (Source s : sources)
    s.mousePressed();
  for (Magnet m : magnets)
    m.mousePressed();
}

void mouseReleased(){
  for (Source s : sources)
    s.mouseReleased();
  for (Magnet m : magnets)
    m.mouseReleased();
}

}