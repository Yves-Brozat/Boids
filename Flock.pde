class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Boid> deathList;
  ArrayList<Boid> bornList; 
  BoidType boidType;
  BorderType borderType;
  ArrayList<Brush> brushes; 
  ArrayList<Source> sources;
  ArrayList<Magnet> magnets;
  ArrayList<Obstacle> obstacles;
  
  ArrayList<String> alphabet;
  boolean boidTypeChange;
  boolean NChange;

  Flock() {
    NChange = false;
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
    deathList = new ArrayList<Boid>(); 
    bornList = new ArrayList<Boid>();
    brushes = new ArrayList<Brush>();
    sources = new ArrayList<Source>();
    magnets = new ArrayList<Magnet>();
    obstacles = new ArrayList<Obstacle>();
    
    boidType = BoidType.LINE;
    boidTypeChange = false;
    borderType = BorderType.NOBORDER;
    
    setAlphabet();
  }

  void run() {
    removeDeads();
    for (Brush b : brushes)
      b.run();
    savePosition();
    applyForces();
    update();
    render();
    borders();
  }
  
  void savePosition(){
    for(Boid b :boids) b.savePosition();
  }
  
  void applyForces(){
    for(Boid b : boids) b.applyForces(boids);
  }
  
  void update(){
    for (Boid b : boids) b.update();
  }
 
  void render(){
    for(Boid b : boids) b.render(boids);
  }
  
  void removeDeads(){
    //natural death
    for (Boid b : boids) {
      if (b.isDead()) removeBoid(b);
    }
    
    if (boidTypeChange){
      for (int i = boids.size()-1; i>=0; i--){
        Boid b = boids.get(i);
        flock.addBoid(b.position.x,b.position.y,b.velocity.x,b.velocity.y);
        Boid newborn = bornList.get(bornList.size()-1);
        newborn.lifespan = b.lifespan;
        newborn.lifetime = b.lifetime;
        newborn.mortal = b.mortal;
        removeBoid(b);
      }
      boidTypeChange = false;
    }
    
    if (NChange){
      setSize();
      NChange = false;
    }
      
    for (Boid b : deathList) boids.remove(b);
    for (Boid b : bornList) boids.add(b);
    
    deathList.clear();
    bornList.clear();
    
    controller.getController("N").setValue(boids.size());
  }
  
  void borders(){
    switch (borderType)
    {
      case WALLS :
      for(Boid b : boids){
        if (b.position.x < -b.r) {
          b.velocity.x *= -1;
          b.position.x = -b.r;
        }
        if (b.position.x > width+b.r) {
          b.velocity.x *= -1;
          b.position.x = width+b.r;
        }
        if (b.position.y < -b.r) {
          b.velocity.y *= -1;
          b.position.y = -b.r;
        }
        if (b.position.y > height+b.r) {
          b.velocity.y *= -1;
          b.position.y = height+b.r;
        }
      }
      break;
    
      case LOOPS : 
      for(Boid b : boids){
        if (b.position.x < -b.r) b.position.x = width+b.r;
        if (b.position.y < -b.r) b.position.y = height+b.r;
        if (b.position.x > width+b.r) b.position.x = b.r;
        if (b.position.y > height+b.r) b.position.y = -b.r;
      }
      break;
      
      case NOBORDER : 
      break;
    }
  }
  
  void addBoid(float x, float y, float vx, float vy){
     switch(boidType){
      case TRIANGLE : bornList.add(new TriangleBoid(x, y, vx, vy)); break;
      case LETTER : 
      LetterBoid l = new LetterBoid(x, y, vx, vy);
      bornList.add(l); 
      l.letter = alphabet.get(int(random(alphabet.size()-1)));
      break;
      case CIRCLE : bornList.add(new CircleBoid(x, y, vx, vy)); break;
      case LINE : bornList.add(new LineBoid(x, y, vx, vy)); break;
      case CURVE : bornList.add(new CurveBoid(x, y, vx, vy)); break;
    }
  }
  
  void removeBoid(Boid b){
    deathList.add(b);
  }
  
  void killAll(){
    for (Boid b : boids){
      b.mortal = true;
      b.lifetime = b.lifespan;
    }
  }
  void addSource(){
    if(sources.size()<8){
      Source s = new Source(0.5*width,0.5*height,this);
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
      Magnet m = new Magnet(0.5*width,0.5*height,this);
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
      Obstacle m = new Obstacle(0.5*width,0.5*height,this);
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
        addBoid(map(i,0,29,0,width),map(j,0,19,0,height),0,0);
        bornList.get(bornList.size()-1).xoff = 0.01*i+0.1*j;
        bornList.get(bornList.size()-1).yoff = 0.1*i+0.01*j;       
        bornList.get(bornList.size()-1).mortal = false; 
      }
    }
  }
  
  void setSize() {
    int f = boids.size() - (int)controller.getController("N").getValue();
    while(f < 0){      
      addBoid(random(0,width),random(0,height),random(-10,10),random(-10,10));
      bornList.get(bornList.size()-1).mortal = false;
      f++;
    }
    while (f > 0){
      removeBoid(boids.get(f-1));
      f--;
    }
  }
  
  void mouseDragged(){   
    for (Brush b : brushes)
      b.mouseDragged();
  }

  void mousePressed(){
    for (Brush b : brushes)
      b.mousePressed();
  }
  
  void mouseReleased(){
    for (Brush b : brushes)
      b.mouseReleased();
  }
  
  void setAlphabet(){
    alphabet = new ArrayList<String>();
    alphabet.add("Z");
    alphabet.add("W");
    for (int i = 0; i<2; i++){
      alphabet.add("K");
      alphabet.add("J");
      alphabet.add("X");
    }
    for (int i = 0; i<3; i++) alphabet.add("Y");
    for (int i = 0; i<4; i++) alphabet.add("Q");
    for (int i = 0; i<7; i++){
      alphabet.add("F");
      alphabet.add("H");
      alphabet.add("V");
      alphabet.add("B");
    }
    for (int i = 0; i<8; i++) alphabet.add("G");
    for (int i = 0; i<16; i++) alphabet.add("P");
    for (int i = 0; i<17; i++) alphabet.add("M");
    for (int i = 0; i<18; i++) alphabet.add("C");
    for (int i = 0; i<24; i++) alphabet.add("D");
    for (int i = 0; i<30; i++) alphabet.add("U");
    for (int i = 0; i<33; i++){
      alphabet.add("L");
      alphabet.add("O");
    }
    for (int i = 0; i<39; i++) alphabet.add("T");
    for (int i = 0; i<40; i++) alphabet.add("R");
    for (int i = 0; i<42; i++) alphabet.add("N");
    for (int i = 0; i<43; i++) alphabet.add("S");
    for (int i = 0; i<44; i++) alphabet.add("I");
    for (int i = 0; i<47; i++) alphabet.add("A");
    for (int i = 0; i<93; i++) alphabet.add("E");  
  }
}