class FlowField{
  
  PVector[][] field;
  int cols, rows;
  int resolution;
  boolean isVisible;
  boolean isActivated;
  float strength, speed;
  float xoff0, yoff0, zoff0;
  PImage img;
  int type;
  
  FlowField(int r){
   resolution = r;
   cols = width/resolution;
   rows = height/resolution;
   field = new PVector[cols][rows];
   xoff0 = random(0,10);
   yoff0 = random(0,10);
   zoff0 = 0;
   isVisible = false;
   isActivated = false;
   strength = 1;
   speed = 1;
   img = texture[RADIAL_GRADIANT_1];
   type = NOISE;
   
  }
  
  void update(){

    switch(type){
      case NOISE :
      float xoff = xoff0;
      for (int i = 0; i<cols; i++){
        float yoff = yoff0;
        for (int j = 0; j<rows; j++){
          float theta = noise(xoff,yoff,zoff0)*2*TWO_PI;
          field[i][j] = new PVector(cos(theta),sin(theta));
          yoff +=0.1;
        }
        xoff+=0.1;
      }
      zoff0+=0.001*speed;
      break;
      
      case IMAGE : 
      for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
          field[i][j] = new PVector(width/2-i*resolution,height/2-j*resolution);
          field[i][j].normalize();
        }
      }
      for (int i = 1; i < cols-1; i++) {
        for (int j = 1; j < rows-1; j++) { 
          int x = i*resolution;
          int y = j*resolution;
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
    int column = int(constrain(pos.x/resolution,0,cols-1));
    int row = int(constrain(pos.y/resolution,0,rows-1));
    return field[column][row].copy();
  }
  
  void draw(){
    for (int i = 0; i<cols; i++){
      for (int j = 0; j<rows; j++){
        stroke(255,50);
        pushMatrix();
        translate(i*resolution,j*resolution);
        rotate(field[i][j].heading());
        line(0,0,resolution,0);
        popMatrix();
      }
    }
  }
 
 void run(){
   update();
   if (isVisible) this.draw();
 }
}