abstract class Brush{
  PVector position;
  PVector velocity;
  boolean isActivated;
  boolean isSelected;
  boolean isVisible;
  float r, rSq;
  boolean[] apply;
  
  Brush(float x, float y){
    position = new PVector(x,y);
    velocity = new PVector();
    isActivated = true;
    isSelected = false;
    isVisible = false;
    r=10;
    rSq = r*r;    
    apply = new boolean[flocks.length];
    for (int i = 0; i< apply.length; i++) apply[i] = false;
    brushes.add(this);
  }
  
  void run(){
    if (isActivated)
    {
      if (isVisible) render();
      update();
      apply();
    }
  }
  
  void update(){
    if (isSelected && mousePressed){
      PVector oldPosition = position.copy();
      position.set(mouseX,mouseY);
      velocity = PVector.sub(position,oldPosition);
    }
  }
  
  abstract void render();
  abstract void apply();
  
  void mousePressed(){
    if (isActivated)
    {
      PVector mouse = new PVector(mouseX,mouseY);
      isSelected = (distSq(mouse, position) <= rSq) ? true : false;      
    }
  }
  
  void mouseReleased(){
    if (isActivated){
      isSelected = false;
      velocity.set(0,0);
    }
  }
  
  void mouseDragged(){

  }
}

class Source extends Brush {
  
  int outflow;
  float angle;
  float strength;
  PVector vel;
  int type;
  int lifespan;
  boolean randomStrength;
  boolean randomAngle;
  boolean ejected;
  
  Source(float x, float y){
    super(x,y);
    outflow = 10;
    vel = new PVector(0,0);
    angle = 0;
    strength = 0;
    type = POINT;
    lifespan = 200;
    randomStrength = false;
    randomAngle = false;
    ejected = false;
  }
  
  void apply(){
    for (int i = 0; i< flocks.length; i++){
      if (apply[i]){         
        if (outflow > 0 && outflow <= 10){
          if (frameCount % (11-outflow) == 0) createBoid(i);
        }
        else if (outflow > 10){
          for(int j = 0; j<outflow - 10; j++) createBoid(i);
        }
      }
    }
  }
  
  void createBoid(int index){
    PVector pos = getBoidInitPosition(r);
    PVector vel = getBoidInitVelocity();  
    flocks[index].addBoid(pos.x,pos.y,vel.x,vel.y);
    flocks[index].bornList.get(flocks[index].bornList.size()-1).lifespan = lifespan;      
  }
  
  PVector getBoidInitPosition(float r){
    PVector pos = new PVector();
    switch(type){
      case POINT : 
      float amp = random(r);
      float heading = random(TWO_PI);
      pos.set(position.x + amp*cos(heading),position.y + amp*sin(heading));  
      break;
      case LINE : 
      float z = random(-r,r);
      float a = (ejected ? velocity.heading() + HALF_PI : angle);
      pos.set(position.x + z*cos(a),position.y + z*sin(a));  
      break;
    }
    return pos;
  }
  
  PVector getBoidInitVelocity(){
    PVector v = new PVector();
    v.set(vel.x,vel.y);
    if(randomAngle)
      v.set(strength*cos(random(0,TWO_PI)),strength*sin(random(0,TWO_PI)));
    if(ejected)
      v.set(velocity.x,velocity.y);
    if(randomStrength) 
      v.mult(random(0,1));   
    return v;
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    switch(type){
      case POINT : ellipse(position.x,position.y,2*r,2*r);  break;
      case LINE : 
      float d = min(2*r,width);
      rectMode(CENTER);
      pushMatrix();
      translate(position.x,position.y);
      float a = (ejected ? velocity.heading() + HALF_PI : angle);
      rotate(a);
      rect(0,0, d, 10);
      popMatrix();
      break;     
    }
  }
}

class Magnet extends Brush {

  float strength;
  
  Magnet(float x, float y){
    super(x,y);
    strength = 1;
  }
  
  void apply(){
    for (int i = 0; i< flocks.length; i++){
      if (apply[i]){
        for (Boid b : flocks[i].boids)
          b.applyAttraction(position,strength);
      }
    }
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    rectMode(CENTER);
    rect(position.x,position.y,r,r);
  }
}

class Obstacle extends Brush {

  int type;
  float e;
  float angle;
  
  Obstacle(float x, float y){
    super(x,y);
    e = 50;
    angle = 0;
    type = CIRCLE;
  }
  
  void apply(){     
    switch(type){
      case POINT :
      for (int i = 0; i< flocks.length; i++){
        if (apply[i]){
          for (Boid b: flocks[i].boids){
            if (distSq(b.position,position) < 25*rSq){
              PVector n = PVector.sub(position,b.position);
              float theta = b.velocity.heading() - n.heading();
              b.velocity.rotate(PI-2*theta);
              PVector v = n.copy();
              v.setMag(-5*r);
              b.position = PVector.add(position,v);
              b.sumForces.add(velocity);
            }
          }
        }
      }
      break;
      case BOWL : 
      for (int i = 0; i< flocks.length; i++){
        if (apply[i]){
          for (Boid b: flocks[i].boids){
            PVector a = new PVector(sin(angle),-cos(angle));
            PVector n = PVector.sub(position,b.position);
            if (n.magSq() > (5*r-e)*(5*r-e) && n.magSq() < (5*r+e)*(5*r+e) && n.x*a.x > - n.y*a.y){
              float theta = b.velocity.heading() - n.heading();
              b.velocity.rotate(PI-2*theta);
              PVector v = n.copy();
              if (n.magSq() < 25*rSq)
                v.setMag(-5*r+e);
              else
                v.setMag(-5*r-e);
              b.position = PVector.add(position,v);
              b.sumForces.add(velocity);
            }
          }
        }
      }
      break;
      case LINE :
      for (int i = 0; i< flocks.length; i++){
        if (apply[i]){
          for (Boid b: flocks[i].boids){
            PVector n = new PVector(sin(angle),-cos(angle));
            PVector d = PVector.sub(b.position,position);
            if (d.x*n.x < -d.y*n.y + e  && d.x*n.x > -d.y*n.y - e && -d.x*n.y < -d.y*n.x + 10*r && -d.x*n.y > -d.y*n.x - 10*r )
            {          
              float theta = b.velocity.heading() - n.heading();
              b.velocity.rotate(PI-2*theta);
              b.sumForces.add(velocity);         
              float dAngle = d.y*n.x - d.x*n.y;
              if (d.x*n.x > - d.y*n.y)
                b.position = new PVector(position.x - dAngle*n.y + e*n.x, position.y + dAngle*n.x + e*n.y);
              else
                b.position = new PVector(position.x - dAngle*n.y - e*n.x, position.y + dAngle*n.x - e*n.y);
            }
          } 
        }
      }
      break;
    }    
  }
  
  void render(){
    switch(type){
      case POINT :
      noFill();
      stroke(125,40);
      ellipse(position.x,position.y,10*r,10*r);
      ellipse(position.x,position.y,r,r);
      break;
      case LINE :
      noFill();
      stroke(125,40);
      rectMode(CENTER);
      pushMatrix();
      translate(position.x,position.y);
      rotate(angle);
      rect(0,0, 20*r, 2*e);
      rect(0,0,10,10);
      popMatrix();
      break;
      case BOWL :
      noFill();
      stroke(125,40);
      arc(position.x, position.y, 10*r, 10*r, angle, angle + PI);
      break;
    }
  }
}