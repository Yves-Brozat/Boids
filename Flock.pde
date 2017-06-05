class Flock implements ControlListener{
  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Brush> brushes;
  ArrayList<Source> sources;
  ArrayList<Magnet> magnets;
  ArrayList<Obstacle> obstacles;
  BoidType boidType;

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
    boidType = BoidType.LINE;
  }

  void run() {
    for (Brush b : brushes)
      b.run();
    for (int i = 0; i<boids.size(); i++) {
      boids.get(i).run(boids); 
      if (boids.get(i).isDead()) { 
        boids.remove(i);
        controller.getController("N").setValue(boids.size());
      }
    }
    if (!sources.get(0).isActivated || !sources.get(1).isActivated || !sources.get(2).isActivated || !sources.get(3).isActivated)
      setSize();
  }

  void addBoid(Boid b) {
    boids.add(b);
    initParameters(b);
  }
  
  void initParameters(Boid b){
    b.size = controller.getController("size").getValue();
    b.trailLength = (int)controller.getController("trailLength").getValue();
    b.separation = controller.getController("separation").getValue();
    b.alignment = controller.getController("alignment").getValue();
    b.cohesion = controller.getController("cohesion").getValue();
    b.attraction = controller.getController("attraction").getValue();
    b.gravity = controller.getController("gravity").getValue();
    b.gravity_Angle = (int)controller.getController("gravity_Angle").getValue();
    b.friction = controller.getController("friction").getValue();
    b.maxforce = controller.getController("maxforce").getValue();    
    b.maxspeed = controller.getController("maxspeed").getValue();    
    b.k_density = controller.getController("k_density").getValue();
    b.lifespan = (int)controller.getController("lifespan").getValue();
  }
  
  void setSize() {
    if (flock.boids.size() < controller.getController("N").getValue()-1){
      switch(boidType){
        case TRIANGLE : flock.addBoid(new TriangleBoid(random(controllerSize,width),random(0,height))); break;
        case LETTER : flock.addBoid(new LetterBoid(random(controllerSize,width),random(0,height))); break;
        case CIRCLE : flock.addBoid(new CircleBoid(random(controllerSize,width),random(0,height))); break;
        case BUBBLE : flock.addBoid(new BubbleBoid(random(controllerSize,width),random(0,height))); break;
        case LINE : flock.addBoid(new LineBoid(random(controllerSize,width),random(0,height))); break;
        case CURVE : flock.addBoid(new CurveBoid(random(controllerSize,width),random(0,height))); break;
      }
    }
    else if (flock.boids.size() > controller.getController("N").getValue()+1)
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
  
  public void controlEvent(ControlEvent theEvent) {
    println("controlEvent : "+theEvent);
    for (Boid b : boids){
      if(theEvent.isFrom("size"))     b.size = theEvent.getController().getValue();     
      if(theEvent.isFrom("trailLength"))     b.trailLength = (int)theEvent.getController().getValue();
      if(theEvent.isFrom("separation"))     b.separation = controller.getController("separation").getValue();
      if(theEvent.isFrom("alignment"))     b.alignment = controller.getController("alignment").getValue();
      if(theEvent.isFrom("cohesion"))     b.cohesion = controller.getController("cohesion").getValue();
      if(theEvent.isFrom("attraction"))     b.attraction = controller.getController("attraction").getValue();
      if(theEvent.isFrom("gravity"))     b.gravity = controller.getController("gravity").getValue();
      if(theEvent.isFrom("gravity_Angle"))     b.gravity_Angle = (int)controller.getController("gravity_Angle").getValue();
      if(theEvent.isFrom("friction"))     b.friction = controller.getController("friction").getValue();
      if(theEvent.isFrom("maxforce"))     b.maxforce = controller.getController("maxforce").getValue();    
      if(theEvent.isFrom("maxspeed"))     b.maxspeed = controller.getController("maxspeed").getValue();    
      if(theEvent.isFrom("k_density"))     b.k_density = controller.getController("k_density").getValue();
      if(theEvent.isFrom("lifespan"))     b.lifespan = (int)controller.getController("lifespan").getValue();
     }
    
    
  }
}