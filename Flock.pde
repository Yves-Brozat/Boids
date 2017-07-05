class Flock implements ControlListener{
  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Brush> brushes;  
  BoidType boidType;

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
    brushes = new ArrayList<Brush>();
    
    for (int i = 0; i< 4; i ++)
      brushes.add(new Source(i*0.25*(width-controllerSize)+controllerSize+120,0.2*height, this));
    for (int i = 0; i< 4; i ++)
      brushes.add(new Magnet(i*0.25*(width-controllerSize)+controllerSize+120,0.3*height, this));
    for (int i = 0; i< 4; i ++)
      brushes.add(new Repulsor(i*0.25*(width-controllerSize)+controllerSize+120,0.4*height, this));
    for (int i = 0; i< 4; i ++)
      brushes.add(new Obstacle(i*0.25*(width-controllerSize)+controllerSize+120,0.5*height, this));
    for (int i = 0; i< 4; i ++)
      brushes.add(new WallObstacle(i*0.25*(width-controllerSize)+controllerSize+120,0.6*height, this));
    for (int i = 0; i< 4; i ++)
      brushes.add(new BowlObstacle(i*0.25*(width-controllerSize)+controllerSize+120,0.7*height, this));
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
    
    if (!brushes.get(0).isActivated || !brushes.get(1).isActivated || !brushes.get(2).isActivated || !brushes.get(3).isActivated)
      setSize();
  }

  void addBoid(Boid b) {
    boids.add(b);
  }
  
  void createGrid(){
    for(int i = 0; i<29; i++){
      for(int j = 0; j<19; j++){
        switch(boidType){
          case TRIANGLE : addBoid(new TriangleBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height))); break;
          case LETTER : addBoid(new LetterBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height))); break;
          case CIRCLE : addBoid(new CircleBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height))); break;
          case BUBBLE : addBoid(new BubbleBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height))); break;
          case LINE : addBoid(new LineBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height))); break;
          case CURVE : addBoid(new CurveBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height))); break;
        }
        boids.get(boids.size()-1).xoff = 0.01*i+0.1*j;
        boids.get(boids.size()-1).yoff = 0.1*i+0.01*j;
        
        controller.getController("N").setValue(boids.size());
      }
    }   
  }
  
  void setSize() {
    if (flock.boids.size() < controller.getController("N").getValue()-1){
      switch(boidType){
        case TRIANGLE : addBoid(new TriangleBoid(random(controllerSize,width),random(0,height))); break;
        case LETTER : addBoid(new LetterBoid(random(controllerSize,width),random(0,height))); break;
        case CIRCLE : addBoid(new CircleBoid(random(controllerSize,width),random(0,height))); break;
        case BUBBLE : addBoid(new BubbleBoid(random(controllerSize,width),random(0,height))); break;
        case LINE : addBoid(new LineBoid(random(controllerSize,width),random(0,height))); break;
        case CURVE : addBoid(new CurveBoid(random(controllerSize,width),random(0,height))); break;
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
      if(theEvent.isFrom("contrast"))     b.randomBrightness = random(-controller.getController("contrast").getValue(),controller.getController("contrast").getValue());
      if(theEvent.isFrom("red"))     b.randomRed = random(0,controller.getController("red").getValue());
      if(theEvent.isFrom("green"))     b.randomGreen = random(0,controller.getController("green").getValue());
      if(theEvent.isFrom("blue"))     b.randomBlue = random(0,controller.getController("blue").getValue());
      if(theEvent.isFrom("N_connections")) b.maxConnections = (int)controller.getController("N_connections").getValue();
     }
    
    
  }
}