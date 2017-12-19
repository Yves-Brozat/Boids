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
  
  FlowField(int index){
   this.index = index;
   r = int(cf.controllerFlock[index].getController("ff_resolution").getValue());
   strength = cf.controllerFlock[index].getController("ff_strength").getValue();
   speed = cf.controllerFlock[index].getController("ff_speed").getValue();
   noise = cf.controllerFlock[index].getController("ff_noise").getValue();
   isVisible = cf.controllerFlock[index].get(Button.class,"show flowfield").isOn();
   isActivated = cf.controllerFlock[index].get(Button.class,"toggle flowfield").isOn();
   
   type = NOISE;
   
   initArray();
   
   zoff = 0;   
   img = texture[0];  
   noiseSeed((int)random(10000));
  }
  
  void initArray(){
    cols = width/r;
    rows = height/r;
    field = new ArrayList<ArrayList<PVector>>(cols);
    for (int i = 0; i< cols; i++){
      field.add(new ArrayList<PVector>(rows));
      for (int j = 0; j< rows; j++)
        field.get(i).add(j, new PVector());
    }
  }
  
  PVector getNoiseCell(int x, int y){
    float noiseX = map(noise(noise*x,noise*y,zoff),0,1,-strength,strength);
    float noiseY = map(noise(1000+noise*x,noise*y,zoff),0,1,-strength,strength);
    //if (noiseX*noiseX + noiseY*noiseY <1)
    return new PVector(noiseX,noiseY);
  }
  
  void setNoiseCell(int i, int j){
    if (i < field.size()){
      if (j < field.get(i).size())
        field.get(i).set(j, getNoiseCell(i,j));
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
  
  void drawCell(int i, int j){
    if (i < field.size()){
      if (j < field.get(i).size()){
        pushMatrix();
        translate((0.5+i)*r,(0.5+j)*r);
        line(0,0,0.5*r*field.get(i).get(j).x,0.5*r*field.get(i).get(j).y);
        popMatrix();
      }
    }
  }
  
  void draw(){
    stroke(255,50);
    for (int i = 0; i<cols; i++){
      for (int j = 0; j<rows; j++)
        drawCell(i,j);
    }
  }
 
 void updateRes(int res){
   field.clear();
   r = res;
   initArray();
   update();
 }
 
 void run(){
   update();
   if (isVisible) this.draw();
 }
}