class Flock implements ControlListener{
  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Brush> brushes;  
  BoidType boidType;
  ArrayList<Source> sources;
  ArrayList<Magnet> magnets;
  ArrayList<Obstacle> obstacles;

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
    brushes = new ArrayList<Brush>();
    sources = new ArrayList<Source>();
    magnets = new ArrayList<Magnet>();
    obstacles = new ArrayList<Obstacle>();
    
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
  }

  void addBoid(float x, float y, float vx, float vy) {
    switch(boidType){
      case TRIANGLE : boids.add(new TriangleBoid(x, y, vx, vy)); break;
      case LETTER : boids.add(new LetterBoid(x, y, vx, vy)); break;
      case CIRCLE : boids.add(new CircleBoid(x, y, vx, vy)); break;
      case LINE : boids.add(new LineBoid(x, y, vx, vy)); break;
      case CURVE : boids.add(new CurveBoid(x, y, vx, vy)); break;
    }
  }
  
  void killAll(){
    for (Boid b : boids){
      b.mortal = true;
      b.lifetime = b.lifespan;
    }
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
 
 void addMagnet(){
    if(magnets.size()<8){
      Magnet m = new Magnet(0.5*(width+controllerSize),0.5*height,this);
      magnets.add(m);
      brushes.add(m);
      int i = magnets.size()-1;  
      controller.getGroup("Magnet "+i).show();
      controller.get(CheckBox.class,"mag_activation").addItem("M"+i,i).activate(i);
      m.isActivated = true;
    }
 }
    
  void addObstacle(){
    if(obstacles.size()<8){
      Obstacle m = new Obstacle(0.5*(width+controllerSize),0.5*height,this);
      obstacles.add(m);
      brushes.add(m);
      int i = obstacles.size()-1;  
      controller.getGroup("Obstacle "+i).show();
      controller.get(CheckBox.class,"obs_activation").addItem("O"+i,i).activate(i);
      m.isActivated = true;
    }
 }
  
  void createGrid(){
    for(int i = 0; i<29; i++){
      for(int j = 0; j<19; j++){
        addBoid(map(i,0,29,controllerSize,width),map(j,0,19,0,height),0,0);
        boids.get(boids.size()-1).xoff = 0.01*i+0.1*j;
        boids.get(boids.size()-1).yoff = 0.1*i+0.01*j;        
        controller.getController("N").setValue(boids.size());
      }
    }
    for (Boid b : boids) b.mortal = false;
  }
  
  void setSize() {
    while (boids.size() < controller.getController("N").getValue()-1){
      addBoid(random(controllerSize,width),random(0,height),random(-10,10),random(-10,10));
      boids.get(boids.size()-1).mortal = false;
    }
    while (boids.size() > controller.getController("N").getValue()+1)
      boids.remove(boids.size()-1);
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
     if(theEvent.isFrom("kill")) this.killAll();
     if(theEvent.isFrom("N")) this.setSize();
     
     for (Boid b : boids){
      if (b instanceof Particle){
        Particle p = (Particle)b;
        if(theEvent.isFrom("size"))     p.size = theEvent.getController().getValue();     
      }
      if (b instanceof Connection){
        Connection c = (Connection)b;
        if(theEvent.isFrom("N_links")) c.maxConnections = (int)controller.getController("N_links").getValue();      
        if(theEvent.isFrom("d_max")) c.d_max = (int)controller.getController("d_max").getValue();              
      }
      if(theEvent.isFrom("maxforce"))     b.maxforce = controller.getController("maxforce").getValue();    
      if(theEvent.isFrom("maxspeed"))     b.maxspeed = controller.getController("maxspeed").getValue();    
      if(theEvent.isFrom("k_density"))     b.k_density = controller.getController("k_density").getValue();
      if(theEvent.isFrom("separation"))     b.separation = controller.getController("separation").getValue();
      if(theEvent.isFrom("alignment"))     b.alignment = controller.getController("alignment").getValue();
      if(theEvent.isFrom("cohesion"))     b.cohesion = controller.getController("cohesion").getValue();
      if(theEvent.isFrom("gravity") || theEvent.isFrom("gravity_Angle"))     b.g = b.g();
      if(theEvent.isFrom("friction"))     b.friction = controller.getController("friction").getValue();
      if(theEvent.isFrom("noise"))        b.noise = controller.getController("noise").getValue(); 
      if(theEvent.isFrom("origin"))     b.origin = controller.getController("origin").getValue();
      if(theEvent.isFrom("symmetry")) b.symmetry = (int)controller.getController("symmetry").getValue();
      if(theEvent.isFrom("trailLength"))     b.trailLength = (int)theEvent.getController().getValue();
      if(theEvent.isFrom("contrast"))     b.randomBrightness = random(-controller.getController("contrast").getValue(),controller.getController("contrast").getValue());
      if(theEvent.isFrom("red"))     b.randomRed = random(0,controller.getController("red").getValue());
      if(theEvent.isFrom("green"))     b.randomGreen = random(0,controller.getController("green").getValue());
      if(theEvent.isFrom("blue"))     b.randomBlue = random(0,controller.getController("blue").getValue());
    }
     
     //SOURCES
     if(theEvent.isFrom("add src")) this.addSource();    
     for (int i = 0; i<sources.size(); i++){
       if(theEvent.isFrom("src"+i+"_size")) sources.get(i).r = controller.getController("src"+i+"_size").getValue();
       if(theEvent.isFrom("src"+i+"_outflow")) sources.get(i).outflow = (int)controller.getController("src"+i+"_outflow").getValue();
       if(theEvent.isFrom("src"+i+"_strength")) sources.get(i).vel = sources.get(i).vel(i);
       if(theEvent.isFrom("lifespan "+ i)){
         sources.get(i).lifespan = (int)controller.getController("lifespan "+ i).getValue();
       }
       if(theEvent.isFrom("src"+i+"_angle")){
         sources.get(i).angle = radians(controller.getController("src"+i+"_angle").getValue());
         sources.get(i).vel = sources.get(i).vel(i);
       }
     }
     
     //MAGNETS
     if(theEvent.isFrom("add mag")) this.addMagnet();    
     for (int i = 0; i<magnets.size(); i++){
       if(theEvent.isFrom("mag"+i+"_strength")) magnets.get(i).strength = controller.getController("mag"+i+"_strength").getValue();
     }
     
     //Obstacles
     if(theEvent.isFrom("add obs")) this.addObstacle();
     for (int i = 0; i<obstacles.size(); i++){
       if(theEvent.isFrom("obs"+i+"_size")) obstacles.get(i).r = controller.getController("obs"+i+"_size").getValue();
       if(theEvent.isFrom("obs"+i+"_angle")) obstacles.get(i).angle = radians(controller.getController("obs"+i+"_angle").getValue());
     }
     
     //BRUSHES
     for (Brush b : brushes){
       if(theEvent.isFrom("brushes")) b.isVisible = !b.isVisible;       
     }    
  }
}