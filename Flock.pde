class Flock {
  int index;
  PGraphics layer;

  ArrayList<Boid> boids; // An ArrayList for all the boids  
  ArrayList<Boid> deathList;
  ArrayList<Boid> bornList; 
  int boidType;
  int borderType;
  int connectionsType;
  
  ArrayList<String> alphabet;
  boolean boidTypeChange;
  boolean NChange;
  boolean grid;
  boolean square;
  boolean drawMode;
  int gridX, gridY;
  boolean connectionsDisplayed;
  boolean particlesDisplayed;
  boolean colorReactive;
    
  boolean[] forcesToggle;
  boolean[] flockForcesToggle;

  float symmetry;  //static
  
  float d_max, d_maxSq;
  int maxConnections;
    
  Flock(int i) {
    
    index = i;
    layer = createGraphics(OUTPUT_WIDTH, OUTPUT_HEIGHT,P2D);
    layer.beginDraw();
    layer.clear();
    layer.endDraw();
    NChange = false;
    grid = false;
    square = false;
    drawMode = false;
    gridX = 0;
    gridY = 0;
    connectionsDisplayed = false;
    particlesDisplayed = true;
    boidTypeChange = false;
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
    deathList = new ArrayList<Boid>(); 
    bornList = new ArrayList<Boid>();
    
    setAlphabet();
    
    loadPreset(preset.get(0),cf.controllerFlock[index]);
    d_maxSq = d_max*d_max;
    
    colorReactive = true;
  }
  
  void run() {
    removeDeads();
    update();
    savePosition();
    applyForces();
    render();
    borders();
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
    PVector[] separationForces = separate(boidsToSeparate); 
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
  
  void reflectParticles(ArrayList<Boid> boids, float n){
    for(Boid b : boids){
      if ((int)n > 1){  
        PVector center = new PVector(0.5*layer.width,0.5*layer.height);
        float section = TWO_PI/(int)n; 
        for (int i=0; i<n-1; i++){ 
          layer.pushMatrix();
          layer.translate(center.x,center.y);     
          layer.rotate(section*(i+1));
          layer.translate(-center.x,-center.y);
          b.draw(layer,boids);
          layer.popMatrix();
        }
      }
    }
  }
  
  void reflectConnections(ArrayList<Boid> boids, float n){
    if ((int)n > 1){  
      PVector center = new PVector(0.5*layer.width,0.5*layer.height);
      float section = TWO_PI/(int)n; 
      for (int i=0; i<n-1; i++){ 
        layer.pushMatrix();
        layer.translate(center.x,center.y);     
        layer.rotate(section*(i+1));
        layer.translate(-center.x,-center.y);
        drawConnections(boids);
        layer.popMatrix();
      }
    }
  } 
  
  void drawParticles(){
    if (boidType == PIXEL){
      loadPixels();
      reflectParticles(boids, symmetry);
      for(Boid b : boids){        
        b.draw(layer, boids);        
     }
      updatePixels();
    }
    else
    {
      reflectParticles(boids, symmetry);
      for(Boid b : boids){
        if(index == 0 && colorReactive){
          //b.c = map(audioInput.left.level(),0.001,0.03,strength,-strength);
        }
        b.draw(layer, boids);
      }         
    }
  }
  
  void drawQueue(ArrayList<Boid> boidsToConnect){
    layer.noFill();
    layer.strokeWeight(1);
    layer.beginShape();
    for (int i=0; i<boidsToConnect.size(); i++) {
      Boid bi = boidsToConnect.get(i);
      layer.stroke(bi.getColor(), bi.alpha);
      layer.curveVertex(bi.position.x, bi.position.y);
    }
    layer.endShape();
  }
  
  void drawMesh(ArrayList<Boid> boidsToConnect){
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
        Boid bj = boidsToConnect.get(j);
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
    layer.stroke(bi.getColor(), a);
    layer.strokeWeight(1);
    layer.line(bi.position.x, bi.position.y, bj.position.x, bj.position.y);
    
    if (bj.history.size() >= bi.history.size()){
      for ( int j=0; j<bi.history.size(); j++){
        layer.stroke(bi.c, a/bi.history.size()*(j+1));
        layer.line(bi.history.get(j).x, bi.history.get(j).y, bj.history.get(j).x, bj.history.get(j).y);
      }
    }     
  }
  
  void drawConnections(ArrayList<Boid> boidsToConnect){
    switch(connectionsType){
      case MESH : drawMesh(boidsToConnect); break;
      case QUEUE : drawQueue(boidsToConnect); break;
    }
    
  }
  
  void render(){
    layer.beginDraw();
    if (!drawMode)  layer.clear();
    if (particlesDisplayed)  drawParticles();
    if (connectionsDisplayed){
      reflectConnections(boids,symmetry);
      drawConnections(boids);
    }
    layer.endDraw();
    image(layer, 0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT);
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
    
    if (square){
      int size = int(map(cf.controllerFlock[index].getController("square_size").getValue(), 0, 100, 0, min(0.5*layer.width, 0.5*layer.height)));
      int N = int(cf.controllerFlock[index].getController("square_N").getValue());
      createSquare(size, N);
      square = false;
    }
    
    for (Boid b : deathList) boids.remove(b);
    for (Boid b : bornList) boids.add(b);
    
    deathList.clear();
    bornList.clear();
    
    //Update the controller as a feedback
    cf.controllerFlock[index].getController("Particles").setValue(boids.size());
    //Skip the updated controller's event not due to user interaction
    NChange = false;
  }
  
  void borders(){
    switch (borderType)
    {
      case WALLS :
      for(Boid b : boids){
        if (b.position.x < -b.r*b.size) {
          b.velocity.x *= -1;
          b.position.x = -b.r*b.size;
        }
        if (b.position.x > layer.width+b.r*b.size) {
          b.velocity.x *= -1;
          b.position.x = layer.width+b.r*b.size;
        }
        if (b.position.y < -b.r*b.size) {
          b.velocity.y *= -1;
          b.position.y = -b.r*b.size;
        }
        if (b.position.y > layer.height+b.r*b.size) {
          b.velocity.y *= -1;
          b.position.y = layer.height+b.r*b.size;
        }
      }
      break;
    
      case LOOPS : 
      for(Boid b : boids){
        if (b.position.x < -b.r*b.size) b.position.x = layer.width+b.r*b.size;
        if (b.position.y < -b.r*b.size) b.position.y = layer.height+b.r*b.size;
        if (b.position.x > layer.width+b.r*b.size) b.position.x = -b.r*b.size;
        if (b.position.y > layer.height+b.r*b.size) b.position.y = -b.r*b.size;
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
      case PIXEL : bornList.add(new PixelBoid(x, y, vx, vy, index)); break;
      case LEAF : bornList.add(new AnimationBoid(x, y, vx, vy, index, texture_Leaf)); break;
      case BIRD : bornList.add(new AnimationBoid(x, y, vx, vy, index, texture_Bird)); break;
      default : bornList.add(new ImageBoid(x, y, vx, vy, index, texture[boidType-6])); break;
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
  
  void clearLayer(){
  }
  
  void mouseDragged(){
    if(cf.controllerFlock[index].get(Button.class,"  Draw"+"\n"+"particles").isOn()){
      addBoid(mouseX*DISPLAY_SCALE,mouseY*DISPLAY_SCALE, 0, 0);
    }
  }
  
  void mouseClicked(){
    if(cf.controllerFlock[index].get(Button.class,"  Draw"+"\n"+"particles").isOn()){
      addBoid(mouseX*DISPLAY_SCALE,mouseY*DISPLAY_SCALE, 0, 0);
    }    
  }
  
  void createGrid(int x, int y){
    for(int i = 0; i<x; i++){
      for(int j = 0; j<y; j++){
        addBoid(map(i,0,x,0,layer.width)+map(0.5,0,x,0,layer.width),map(j,0,y,0,layer.height)+map(0.5,0,y,0,layer.height),0,0);
        bornList.get(bornList.size()-1).xoff = 0.01*i+0.1*j;
        bornList.get(bornList.size()-1).yoff = 0.1*i+0.01*j;       
      }
    }
  }
  
  void createSquare(int r, int N){
    int n = N/4;
    PVector[] corners = new PVector[4];
    corners[0] = new PVector(0.5*layer.width - r, 0.5*layer.height - r);  //0 - 1
    corners[1] = new PVector(0.5*layer.width + r, 0.5*layer.height - r);  //
    corners[2] = new PVector(0.5*layer.width + r, 0.5*layer.height + r);  //3 - 2
    corners[3] = new PVector(0.5*layer.width - r, 0.5*layer.height + r);
    
    for (int i = 0; i<n; i++)
      addBoid(map(i,0,n,corners[0].x, corners[1].x), map(i,0,n,corners[0].y, corners[1].y), 0, 0);
    for (int i = 0; i<n; i++)
      addBoid(map(i,0,n,corners[1].x, corners[2].x), map(i,0,n,corners[1].y, corners[2].y), 0, 0);
    for (int i = 0; i<n; i++)
      addBoid(map(i,0,n,corners[2].x, corners[3].x), map(i,0,n,corners[2].y, corners[3].y), 0, 0);
    for (int i = 0; i<n; i++)
      addBoid(map(i,0,n,corners[3].x, corners[0].x), map(i,0,n,corners[3].y, corners[0].y), 0, 0);      
  }
  
  void setSize() {
    int f = boids.size() - (int)cf.controllerFlock[index].getController("Particles").getValue();
    while(f < 0){      
      addBoid(random(0,layer.width),random(0,layer.height),random(-3,3),random(-3,3));
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
    connectionsType = preset.getInt("connectionsType");
    forcesToggle = preset.getJSONArray("forceToggle").getBooleanArray();
    flockForcesToggle = preset.getJSONArray("flockForceToggle").getBooleanArray();
    symmetry = preset.getInt("symmetry");
    d_max = map(preset.getFloat("d_max"), 0, 100, 0, OUTPUT_WIDTH);
    maxConnections = preset.getInt("maxConnections");
    connectionsDisplayed = preset.getBoolean("connectionsDisplayed");
    particlesDisplayed = preset.getBoolean("particlesDisplayed");
  }
  
  void loadPreset(JSONObject preset, ControlP5 c){
    for (Boid b : boids) b.updateParameters(preset);
    cf.updateControllerValues(preset, c);
    this.updateParameters(preset);
  }
  

}