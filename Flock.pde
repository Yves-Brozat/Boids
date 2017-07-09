class Flock implements ControlListener{
  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Brush> brushes;  
  BoidType boidType;
  ArrayList<Source> sources;

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
    brushes = new ArrayList<Brush>();
    sources = new ArrayList<Source>();
    
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
    for(Source s : sources){
      if(!s.isActivated){
        setSize();
        break;
      }
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }
  
  void addSource(){
    if(sources.size()<8){
      Source s = new Source(0.5*(width+controllerSize),0.5*height,this);
      sources.add(s);
      brushes.add(s);
      int i = sources.size()-1;  
      controller.getGroup("Source "+i).show();
      controller.get(CheckBox.class,"src_activation").addItem("S"+i,i).activate(i);
      s.isActivated = true;
    }
 }
  
  void createGrid(){
    for(int i = 0; i<29; i++){
      for(int j = 0; j<19; j++){
        switch(boidType){
          case TRIANGLE : addBoid(new TriangleBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height),0,0)); break;
          case LETTER : addBoid(new LetterBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height),0,0)); break;
          case CIRCLE : addBoid(new CircleBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height),0,0)); break;
          case BUBBLE : addBoid(new BubbleBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height),0,0)); break;
          case LINE : addBoid(new LineBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height),0,0)); break;
          case CURVE : addBoid(new CurveBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height),0,0)); break;
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
        case TRIANGLE : addBoid(new TriangleBoid(random(controllerSize,width),random(0,height),random(0,10),random(0,10))); break;
        case LETTER : addBoid(new LetterBoid(random(controllerSize,width),random(0,height),random(0,10),random(0,10))); break;
        case CIRCLE : addBoid(new CircleBoid(random(controllerSize,width),random(0,height),random(0,10),random(0,10))); break;
        case BUBBLE : addBoid(new BubbleBoid(random(controllerSize,width),random(0,height),random(0,10),random(0,10))); break;
        case LINE : addBoid(new LineBoid(random(controllerSize,width),random(0,height),random(0,10),random(0,10))); break;
        case CURVE : addBoid(new CurveBoid(random(controllerSize,width),random(0,height),random(0,10),random(0,10))); break;
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
     if(theEvent.isFrom("grid")) this.createGrid();
     
     for (Boid b : boids){
      if(theEvent.isFrom("size"))     b.size = theEvent.getController().getValue();     
      if(theEvent.isFrom("trailLength"))     b.trailLength = (int)theEvent.getController().getValue();
      if(theEvent.isFrom("separation"))     b.separation = controller.getController("separation").getValue();
      if(theEvent.isFrom("alignment"))     b.alignment = controller.getController("alignment").getValue();
      if(theEvent.isFrom("cohesion"))     b.cohesion = controller.getController("cohesion").getValue();
      if(theEvent.isFrom("attraction"))     b.attraction = controller.getController("attraction").getValue();
      if(theEvent.isFrom("gravity") || theEvent.isFrom("gravity_Angle"))     b.g = b.g();
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
      if(theEvent.isFrom("symmetry")) b.symmetry = (int)controller.getController("symmetry").getValue();
     }
     
     //SOURCES
     if(theEvent.isFrom("add")) this.addSource();
     if (theEvent.isFrom(controller.get(CheckBox.class,"src_activation"))){
        for (int i = 0; i<controller.get(CheckBox.class,"src_activation").getArrayValue().length; i++)
          sources.get(i).isActivated = controller.get(CheckBox.class,"src_activation").getState(i);
     }
     for (int i = 0; i<sources.size(); i++){
       if(theEvent.isFrom("src"+i+"_size")) sources.get(i).r = controller.getController("src"+i+"_size").getValue();
       if(theEvent.isFrom("src"+i+"_outflow")) sources.get(i).outflow = (int)controller.getController("src"+i+"_outflow").getValue();
       if(theEvent.isFrom("src"+i+"_strength") || theEvent.isFrom("src"+i+"_angle")) sources.get(i).vel = sources.get(i).vel(i);
     }
     
     //BRUSHES
     for (Brush b : brushes){
       if(theEvent.isFrom("brushes")) b.isVisible = !b.isVisible;
       
     }    
  }
}