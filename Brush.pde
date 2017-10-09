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
    if (isSelected) {

    }
  }
}

class Source extends Brush {
  
  int outflow;
  float angle;
  float strength;
  PVector vel;
  SourceType type;
  int lifespan;
  boolean randomStrength;
  boolean randomAngle;
  
  Source(float x, float y){
    super(x,y);
    outflow = 10;
    vel = new PVector(0,0);
    angle = 0;
    strength = 0;
    type = SourceType.O;
    lifespan = 200;
    randomStrength = false;
    randomAngle = false;
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
      case O : 
      pos.set(position.x + random(-r,r),position.y + random(-r,r));  
      break;
      case I : 
      float z = random(-10*r,10*r);
      pos.set(position.x + z*cos(angle),position.y + z*sin(angle));  
      break;
    }
    return pos;
  }
  
  PVector getBoidInitVelocity(){
    PVector velocity = new PVector();
    velocity.set(vel.x,vel.y);
    if(randomAngle)
      velocity.set(strength*cos(random(0,TWO_PI)),strength*sin(random(0,TWO_PI)));
    if(randomStrength) 
      velocity.mult(random(0,1));   
    return velocity;
  }
  
  void render(){
    noFill();
    stroke(100);
    strokeWeight(1);
    switch(type){
      case O : ellipse(position.x,position.y,2*r,2*r);  break;
      case I : 
      float d = min(20*r,width);
      rectMode(CENTER);
      pushMatrix();
      translate(position.x,position.y);
      rotate(angle);
      rect(0,0, d, 0.01*d);
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

  ObstacleType type;
  float e;
  float angle;
  
  Obstacle(float x, float y){
    super(x,y);
    e = 50;
    angle = 0;
    type = ObstacleType.O;
  }
  
  void apply(){     
    switch(type){
      case O :
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
      case U : 
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
      case I :
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
      case O :
      noFill();
      stroke(125,40);
      ellipse(position.x,position.y,10*r,10*r);
      ellipse(position.x,position.y,r,r);
      break;
      case I :
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
      case U :
      noFill();
      stroke(125,40);
      arc(position.x, position.y, 10*r, 10*r, angle, angle + PI);
      break;
    }
  }
}