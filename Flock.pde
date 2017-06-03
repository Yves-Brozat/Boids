class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Brush> brushes;
  ArrayList<Source> sources;
  ArrayList<Magnet> magnets;
  ArrayList<Obstacle> obstacles;

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
    brushes = new ArrayList<Brush>();
    magnets = new ArrayList<Magnet>(4);
    sources = new ArrayList<Source>(4);
    obstacles = new ArrayList<Obstacle>(4);
    for (int i = 0; i< 4; i ++){
      sources.add(new Source((i+1)*0.2*width,i*0.2*height+50, this));
      magnets.add(new Magnet(width-((i+1)*0.2*width),i*0.2*height+50, this));
      obstacles.add(new Obstacle((i+1)*0.2*width,i*0.2*height+50, this));      
    }
    brushes.addAll(sources);
    brushes.addAll(magnets);
    brushes.addAll(obstacles);
  }

  void run() {
    for (Brush b : brushes)
      b.run();
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
    if (flock.boids.size() < sliderN.getValue()-1){
      switch(boidType){
        case TRIANGLE : flock.addBoid(new TriangleBoid(random(controllerSize,width),random(0,height))); break;
        case LETTER : flock.addBoid(new LetterBoid(random(controllerSize,width),random(0,height))); break;
        case CIRCLE : flock.addBoid(new CircleBoid(random(controllerSize,width),random(0,height))); break;
        case BUBBLE : flock.addBoid(new BubbleBoid(random(controllerSize,width),random(0,height))); break;
        case LINE : flock.addBoid(new LineBoid(random(controllerSize,width),random(0,height))); break;
        case CURVE : flock.addBoid(new CurveBoid(random(controllerSize,width),random(0,height))); break;
      }
    }
    else if (flock.boids.size() > sliderN.getValue()+1)
      flock.boids.remove(flock.boids.size()-1);
  }
  
  void mouseDragged(){
    if (mouseX>controllerSize){   
      for (Brush b : brushes)
        b.mouseDragged();
    }
  }

  void mousePressed(){
    for (Brush b : brushes)
      b.mousePressed();
  }
  
  void mouseReleased(){
    for (Brush b : brushes)
      b.mouseReleased();
  }
}