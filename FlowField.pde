class FlowField{
  
  PVector[][] field;
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
   cols = width/r;
   rows = height/r;
   field = new PVector[cols][rows];
   zoff = 0;   
   img = texture[0];  
   noiseSeed((int)random(10000));
  }
  
  PVector noiseField(int x, int y){
    float noiseX = map(noise(noise*x,noise*y,zoff),0,1,-strength,strength);
    float noiseY = map(noise(1000+noise*x,noise*y,zoff),0,1,-strength,strength);
    return new PVector(noiseX,noiseY);
  }
  
  void update(){
    switch(type){
      case NOISE :
      for (int i = 0; i<cols; i++){
        for (int j = 0; j<rows; j++)
          field[i][j] = noiseField(i,j);
      }
      zoff+=0.001*speed;
      break;
      
      case IMAGE : 
      for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
          field[i][j] = new PVector(width/2-i*r,height/2-j*r);
          field[i][j].normalize();
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
            field[i][j] = new PVector(cos(theta),sin(theta));
          }
        }
      }
      break;
    }
  }
  
  PVector getVector(PVector pos){
    int column = int(constrain(pos.x/r,0,cols-1));
    int row = int(constrain(pos.y/r,0,rows-1));
    return field[column][row].copy();
  }
  
  void draw(){
    for (int i = 0; i<cols; i++){
      for (int j = 0; j<rows; j++){
        stroke(255,50);
        pushMatrix();
        translate((0.5+i)*r,(0.5+j)*r);
        line(0,0,0.5*r*field[i][j].x,0.5*r*field[i][j].y);
        popMatrix();
      }
    }
  }
 
 void updateRes(int res){
   r = res;
   cols = width/r;
   rows = height/r;
   field = new PVector[cols][rows];
   update();
 }
 
 void run(){
   update();
   if (isVisible) this.draw();
 }
}