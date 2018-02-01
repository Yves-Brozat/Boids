class FlowField{
  
  ArrayList<ArrayList<PVector>>field;
  int cols, rows;
  int r;  //resolution
  boolean isVisible;
  boolean isActivated;
  float strength, speed, noise;
  float noiseScale;
  float zoff;
  PImage img;
  int type;
  int index;
  boolean[] apply;

  
  FlowField(int index){
   this.index = index;
   r = int(cf.controllerTool.getController("ff_resolution"+index).getValue());
   strength = cf.controllerTool.getController("ff_strength"+index).getValue();
   speed = cf.controllerTool.getController("ff_speed"+index).getValue();
   noise = cf.controllerTool.getController("ff_noise"+index).getValue();
   isVisible = cf.controllerTool.get(Button.class,"Show tools").isOn();  
   isActivated = true;
   
   type = NOISE;
   
   initArray();
   
   zoff = 0;   
   img = texture[0];  
   noiseSeed((int)random(10000));
   
   apply = new boolean[flocks.length];
   for (int i = 0; i< apply.length; i++) apply[i] = true;
  }
  
  void initArray(){
    try{
      cols = width/r;
      rows = height/r;
      field = new ArrayList<ArrayList<PVector>>(cols);
      for (int i = 0; i< cols; i++){
        field.add(new ArrayList<PVector>(rows));
        for (int j = 0; j< rows; j++)
          field.get(i).add(j, new PVector());
      }
    }
    catch (NullPointerException e) {
      println("Issue during initialisation of Flowfield");
    }
  }
  
  PVector computeNoiseCell(int x, int y){
    float noiseX = map(noise(noise*x,noise*y,zoff),0,1,-strength,strength);
    float noiseY = map(noise(1000+noise*x,noise*y,zoff),0,1,-strength,strength);
    //if (noiseX*noiseX + noiseY*noiseY <1)
    return new PVector(noiseX,noiseY);
  }
  
  void setNoiseCell(int i, int j){
    if (i < field.size()){
      if (j < field.get(i).size())
        field.get(i).set(j, computeNoiseCell(i,j));
    }
  }
  
  
  void update(){
    switch(type){
      case NOISE :
      for (int i = 0; i<cols; i++){
        for (int j = 0; j<rows; j++){
          setNoiseCell(i,j);
        }
      }
      zoff+=0.001*speed;
      break;
      
      case IMAGE : 
      for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
          field.get(i).set(j,new PVector(width/2-i*r,height/2-j*r));
          field.get(i).get(j).normalize();
        }
      }
      for (int i = 1; i < cols-1; i++) {
        for (int j = 1; j < rows-1; j++) { 
          int x = i*r;
          int y = j*r;
          int c = 0;
          if (x<img.width && y<img.height){
            c = img.pixels[x + y*img.width];
            float theta = map(brightness(c), 0, 255, 0, TWO_PI);
            field.get(i).set(j,new PVector(cos(theta),sin(theta)));
          }
        }
      }
      break;
    }
  }
  
  PVector getVector(PVector pos){
    int column = int(constrain(pos.x/r,0,cols-1));
    int row = int(constrain(pos.y/r,0,rows-1));
    return field.get(column).get(row).copy();
  }
  
  void drawCell(PGraphics pg, int i, int j){
    if (i < field.size()){
      if (j < field.get(i).size()){
        pg.pushMatrix();
        pg.translate((0.5+i)*r,(0.5+j)*r);
        pg.line(0,0,0.5*r*field.get(i).get(j).x,0.5*r*field.get(i).get(j).y);
        pg.popMatrix();
      }
    }
  }
  
  void render(PGraphics pg){
    pg.stroke(255);
    for (int i = 0; i<cols; i++){
      for (int j = 0; j<rows; j++)
        drawCell(pg,i,j);
    }
  }
 
 void updateRes(int res){
   field.clear();
   r = res;
   initArray();
   update();
 }
 
 void apply(){
   for (int i = 0; i< flocks.length; i++){
      if (apply[i]){ 
        for (Boid b : flocks[i].boids)
          b.follow(this);
      }
   }
 }
 
 
 void run(PGraphics pg){
   if (isActivated)
   {
     if (isVisible){
       pg.beginDraw();
       render(pg);
       pg.endDraw();
     }
     update();
     apply();
   }
 }
 
}