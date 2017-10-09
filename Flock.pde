class Flock {
  int index;
  
  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Boid> deathList;
  ArrayList<Boid> bornList; 
  int boidType;
  int borderType;
  
  ArrayList<String> alphabet;
  boolean boidTypeChange;
  boolean NChange;
  boolean grid;
  int gridX, gridY;
  boolean connectionsDisplayed;
    
  boolean[] forcesToggle;
  boolean[] flockForcesToggle;

  float symmetry;  //static
  
  float d_max, d_maxSq;
  int maxConnections;
      
  Flock(int i) {
    
    index = i;
    NChange = false;
    grid = false;
    gridX = 0;
    gridY = 0;
    connectionsDisplayed = true;
    boidTypeChange = false;
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
    deathList = new ArrayList<Boid>(); 
    bornList = new ArrayList<Boid>();
    sources = new ArrayList<Source>();
    
    setAlphabet();
    
    loadPreset(preset.get(0),cf.controllerFlock[index]);
    d_maxSq = d_max*d_max;

  }
  
  //void init(){
  //  forcesToggle = new boolean[cf.controllerFlock[index].get(CheckBox.class,"forceToggle").getArrayValue().length];
  //  for (int j = 0; j < forcesToggle.length; j++) 
  //    forcesToggle[j] = cf.controllerFlock[index].get(CheckBox.class,"forceToggle").getState(j);
  //  flockForcesToggle = new boolean[cf.controllerFlock[index].get(CheckBox.class,"flockForceToggle").getArrayValue().length];
  //  for (int j = 0; j < flockForcesToggle.length; j++) 
  //    flockForcesToggle[j] = cf.controllerFlock[index].get(CheckBox.class,"flockForceToggle").getState(j);        
  //  symmetry = cf.controllerFlock[index].getController("symmetry").getValue();
    
  //  d_max = cf.controllerFlock[index].getController("d_max").getValue();
  //  maxConnections = (int)cf.controllerFlock[index].getController("N_links").getValue();
  //}
  
  void run() {
    //long t; 
    //t = System.nanoTime();
    removeDeads();
    //print("removeDeads() : " + (System.nanoTime() - t) + '\t');
    //t = System.nanoTime();
    update();
    //print("update() : " + (System.nanoTime() - t) + '\t');
    //t = System.nanoTime();
    savePosition();
    //print("savePosition() : " + (System.nanoTime() - t) + '\t');
    //t = System.nanoTime();
    applyForces();
    //println("applyForces() : " + (System.nanoTime() - t) + '\t');
    //t = System.nanoTime();
    render();
    //print("render() : " + (System.nanoTime() - t) + '\t');
    //t = System.nanoTime();
    borders();
    //print("borders() : " + (System.nanoTime() - t) + '\t');
  }
  
  void savePosition(){
    for(Boid b :boids) b.savePosition();
  }
  
  void applyForces(){
    if(forcesToggle[0]){ for(Boid b : boids) b.applyFriction(); }
    if(forcesToggle[1]){ for(Boid b : boids) b.applyGravity(); }
    if(forcesToggle[2]){ for(Boid b : boids) b.applyNoise(); }
    if(forcesToggle[3]){ for(Boid b : boids) b.applyOrigin(); }
    if(forcesToggle[4]) applyFlock(); 
  }
  
  void applyFlock(){
    if(flockForcesToggle[0]) applySeparation(boids);
    if(flockForcesToggle[1]) applyAlignment(boids); 
    if(flockForcesToggle[2]) applyCohesion(boids);
  }
  
  void applySeparation(ArrayList<Boid> boidsToSeparate){
    PVector[] separationForces = separate(boidsToSeparate);   // Separation
    for (int i = 0; i<boidsToSeparate.size(); i++){
      Boid bi = boidsToSeparate.get(i);
      PVector sep = separationForces[i];
      sep.mult(bi.separation);
      bi.sumForces.add(sep);      
    }
  }
  
  PVector[] separate(ArrayList<Boid> boidsToSeparate){
    int n = boidsToSeparate.size();
    PVector[] steer = new PVector[n];
    int count[] = new int[n];    
    for (int i = 0; i<n; i++)
      steer[i] = new PVector();
      
    for (int i = 0; i<n; i++){
      Boid bi = boidsToSeparate.get(i);
        for (int j = i+1; j<n; j++) {
        Boid bj = boids.get(j);
        float d = distSq(bi.position, bj.position);
        if ((d > 0) && (d < bi.sep_rSq)) {
          PVector diff = PVector.sub(bi.position, bj.position); // Calculate vector pointing away from neighbor
          diff.normalize();
          diff.div(sqrt(d));        // Weight by distance
          steer[i].add(diff);
          steer[j].sub(diff);
          count[i]++;            // Keep track of how many
          count[j]++;
        }
      }
      if (count[i] > 0)   steer[i].div((float)count[i]);      // Average -- divide by how many
      if (steer[i].magSq() > 0) {    // As long as the vector is greater than 0
        steer[i].setMag(bi.maxspeed);
        steer[i].sub(bi.velocity);   // Implement Reynolds: Steering = Desired - Velocity
        if (bi.paramToggle[0]) steer[i].limit(bi.maxforce);
      } 
    }
    return steer;
  }
  
  void applyAlignment(ArrayList<Boid> boidsToAlign){
    PVector[] alignmentForces = align(boidsToAlign);   // Separation
    for (int i = 0; i<boidsToAlign.size(); i++){
      Boid bi = boidsToAlign.get(i);
      PVector ali = alignmentForces[i];
      ali.mult(bi.alignment);
      bi.sumForces.add(ali);      
    }
  }
  
  PVector[] align(ArrayList<Boid> boidsToAlign) {
    int n = boidsToAlign.size();
    PVector[] sum = new PVector[n];
    PVector[] steer = new PVector[n];
    int count[] = new int[n];
    for (int i=0; i<n; i++){
      sum[i] = new PVector();
      steer[i] = new PVector();
    }
    
    for (int i=0; i<n; i++) {
      Boid bi = boidsToAlign.get(i);
      for (int j = i+1; j<n; j++) {
        Boid bj = boidsToAlign.get(j);
        float d = distSq(bi.position, bj.position);       
        if ((d > 0) && (d < bi.ali_rSq)) {
          sum[i].add(bj.velocity);
          sum[j].add(bi.velocity);
          count[i]++;
          count[j]++;
        }
      }
      if (count[i] > 0) {
        sum[i].div((float)count[i]);
        sum[i].setMag(bi.maxspeed);
        steer[i] = PVector.sub(sum[i], bi.velocity);      // Implement Reynolds: Steering = Desired - Velocity
        if (bi.paramToggle[0]) steer[i].limit(bi.maxforce);
      } 
    }   
    return steer;
  }
  
  void applyCohesion(ArrayList<Boid> boidsToCohesion){
    PVector[] cohesionForces = cohesion(boidsToCohesion);   // Separation
    for (int i = 0; i<boidsToCohesion.size(); i++){
      Boid bi = boidsToCohesion.get(i);
      PVector coh = cohesionForces[i];
      coh.mult(bi.cohesion);
      bi.sumForces.add(coh);      
    }
  }
  
  PVector[] cohesion(ArrayList<Boid> boidsToCohesion) {
    int n = boidsToCohesion.size();
    PVector sum[] = new PVector[n];  
    PVector steer[] = new PVector[n];  
    int count[] = new int[n];
    for(int i= 0; i<n; i++){
      sum[i] = new PVector();
      steer[i] = new PVector();
    }
    
    for(int i= 0; i<n; i++) {
      Boid bi = boidsToCohesion.get(i);
      for (int j = i+1; j<n; j++) { 
        Boid bj = boidsToCohesion.get(j);
        float d = distSq(bi.position, bj.position);
        if ((d > 0) && (d < bi.coh_rSq)) {
          sum[i].add(bj.position);
          sum[j].add(bi.position);
          count[i]++;
          count[j]++;
        }
      }
      if (count[i] > 0) {
        sum[i].div(count[i]);
        steer[i] = bi.seek(sum[i]);  // Steer towards the position
      } 
    }
    return steer;
  }
  
  void update(){
    for (Boid b : boids) b.update();
  }
  
  void reflect(Boid b, float n){
    if ((int)n > 1){  
      PVector center = new PVector(0.5*width,0.5*height);
      float section = TWO_PI/(int)n; 
      for (int i=0; i<n-1; i++){ 
        pushMatrix();
        translate(center.x,center.y);     
        rotate(section*(i+1));
        translate(-center.x,-center.y);
        b.draw(boids);
        popMatrix();
      }
    }
  }
 
  void drawParticles(){
    for(Boid b : boids){
      reflect(b, symmetry);
      b.draw(boids);
    }
  }
  
  void drawConnections(ArrayList<Boid> boidsToConnect){
    int n = boidsToConnect.size();
    ArrayList<Boid> boidsNear[] = new ArrayList[n];
    ArrayList<Float> distTo[] = new ArrayList[n];
    for (int i = 0; i<n; i++){
      boidsNear[i] = new ArrayList<Boid>();
      distTo[i] = new ArrayList<Float>();
    }
    
    for (int i = 0; i<n; i++){
      Boid bi = boidsToConnect.get(i);
      for (int j = i+1; j<n; j++) {
        Boid bj = boids.get(j);
        float dij = distSq(bi.position, bj.position);
        if ((dij > 0) && (dij < d_maxSq)){
          boidsNear[i].add(bj);
          distTo[i].add(dij);
          boidsNear[j].add(bi);
          distTo[j].add(dij);
        }
      }
    }
    for (int i = 0; i<n; i++){
      Boid bi = boidsToConnect.get(i);
      bi.sortNeighboors(boidsNear[i]);
      int count = 0;
      while (count < maxConnections && count < boidsNear[i].size()){
        drawLine(bi, boidsNear[i].get(count), distTo[i].get(count), boidsNear[i].get(count).alpha);        
        count++;
      }
    }   
  }
  
  void drawLine(Boid bi, Boid bj, float dist, float alpha){
    float a = map(dist,0,d_maxSq, alpha, 0); 
    stroke(bi.c, a);
    strokeWeight(1);
    line(bi.position.x, bi.position.y, bj.position.x, bj.position.y);
    
    if (bj.history.size() >= bi.history.size()){
      for ( int j=0; j<bi.history.size(); j++){
        stroke(bi.c, a/bi.history.size()*(j+1));
        line(bi.history.get(j).x, bi.history.get(j).y, bj.history.get(j).x, bj.history.get(j).y);
      }
    }     
  }
  
  void render(){
    if (boidType == PIXEL){
      loadPixels();
      drawParticles();
      updatePixels();
    }
    else
      drawParticles();
    
    if (connectionsDisplayed)
      drawConnections(boids);
  }
  
  void removeDeads(){
    //natural death
    for (Boid b : boids) {
      if (b.isDead()) removeBoid(b);
    }
    
    if (boidTypeChange){
      for (int i = boids.size()-1; i>=0; i--){
        Boid b = boids.get(i);
        this.addBoid(b.position.x,b.position.y,b.velocity.x,b.velocity.y);
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
    
    if (grid){
      createGrid(int(cf.controllerFlock[index].getController("X").getValue()),int(cf.controllerFlock[index].getController("Y").getValue()));
      grid = false;
    }
    
    for (Boid b : deathList) boids.remove(b);
    for (Boid b : bornList) boids.add(b);
    
    deathList.clear();
    bornList.clear();
    
    cf.controllerFlock[index].getController("N").setValue(boids.size());
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
      case TRIANGLE : bornList.add(new TriangleBoid(x, y, vx, vy, index)); break;
      case LETTER : 
      LetterBoid l = new LetterBoid(x, y, vx, vy, index);
      bornList.add(l); 
      l.letter = alphabet.get(int(random(alphabet.size()-1)));
      break;
      case CIRCLE : bornList.add(new CircleBoid(x, y, vx, vy, index)); break;
   //   case LINE : bornList.add(new LineBoid(x, y, vx, vy, index)); break;
   //   case CURVE : bornList.add(new CurveBoid(x, y, vx, vy, index)); break;
      case PIXEL : bornList.add(new PixelBoid(x, y, vx, vy, index)); break;
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
  
  void createGrid(int x, int y){
    for(int i = 0; i<x; i++){
      for(int j = 0; j<y; j++){
        addBoid(map(i,0,x,0,width)+map(0.5,0,x,0,width),map(j,0,y,0,height)+map(0.5,0,y,0,height),0,0);
        bornList.get(bornList.size()-1).xoff = 0.01*i+0.1*j;
        bornList.get(bornList.size()-1).yoff = 0.1*i+0.01*j;       
        bornList.get(bornList.size()-1).mortal = false; 
      }
    }
  }
  
  void setSize() {
    int f = boids.size() - (int)cf.controllerFlock[index].getController("N").getValue();
    while(f < 0){      
      addBoid(random(0,width),random(0,height),random(-3,3),random(-3,3));
      bornList.get(bornList.size()-1).mortal = false;
      f++;
    }
    while (f > 0){
      removeBoid(boids.get(f-1));
      f--;
    }
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
  
  void updateParameters(JSONObject preset){
    boidType = preset.getInt("boidType");
    borderType = preset.getInt("borderType");
    forcesToggle = preset.getJSONArray("forceToggle").getBooleanArray();
    flockForcesToggle = preset.getJSONArray("flockForceToggle").getBooleanArray();
    symmetry = preset.getInt("symmetry");
    d_max = preset.getFloat("d_max");
    maxConnections = preset.getInt("maxConnections");
  }
  
  void loadPreset(JSONObject preset, ControlP5 c){
    for (Boid b : boids) b.updateParameters(preset);
    cf.updateControllerValues(preset, c);
    this.updateParameters(preset);
  }
}