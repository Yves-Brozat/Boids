abstract class Brush{
  PVector position;
  PVector velocity;
  boolean isActivated;
  boolean isSelected;
  boolean isVisible;
  float r, rSq;
  boolean[] apply;
  int index;
  
  Brush(float x, float y, int index){
    this.index = index;
    position = new PVector(x,y);
    velocity = new PVector();
    isActivated = true;
    isSelected = false;
    isVisible = cf.controllerTool.get(Button.class,"Show tools").isOn();    
    apply = new boolean[flocks.length];
    apply[0] = true;
    for (int i = 1; i< apply.length; i++) apply[i] = false;
    brushes.add(this);
  }
  
  void run(){
    if (isActivated)
    {
      if (isVisible){
        toolLayer.beginDraw();
        render();
        toolLayer.endDraw();
      }
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
  
  void render(){
    toolLayer.noFill();
    toolLayer.stroke(100);
    // toolLayer.strokeWeight(isSelected? 2 : 1);
    toolLayer.rectMode(CENTER);
    toolLayer.textMode(CENTER);
    toolLayer.textAlign(CENTER);
    toolLayer.text(index,position.x+5,position.y+5);
  }
  
  abstract void apply();
  abstract void select();
  
  void mousePressed(){
    if (isActivated)
    {
      PVector mouse = new PVector(mouseX,mouseY);
      isSelected = (distSq(mouse, position) <= 400) ? true : false;    
      if(isSelected)  select();
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
  
  Source(float x, float y, int index){
    super(x,y,index);
    r = map(cf.controllerTool.getController("src"+index+"_size").getValue(),0,100,0,0.5*width);
    rSq = r*r;
    outflow = SRC_OUTFLOW;
    angle = radians(cf.controllerTool.getController("src"+index+"_angle").getValue());
    strength = cf.controllerTool.getController("src"+index+"_strength").getValue();
    vel = new PVector(strength*cos(angle+HALF_PI),strength*sin(angle+HALF_PI));
    lifespan = SRC_LIFESPAN;
    type = int(cf.controllerTool.get(RadioButton.class,"src"+index+"_type").getValue());
    randomStrength = cf.controllerTool.get(Button.class,"randomStrength " + index).isOn();
    randomAngle = cf.controllerTool.get(Button.class,"randomAngle " + index).isOn();
    ejected = cf.controllerTool.get(Button.class,"ejected " + index).isOn();
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
    flocks[index].bornList.get(flocks[index].bornList.size()-1).mortal = true;      
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
    super.render();
    switch(type){
      case POINT : 
      toolLayer.ellipse(position.x,position.y,2*r,2*r);
      toolLayer.rect(position.x,position.y,20,20);
      break;
      
      case LINE : 
      toolLayer.pushMatrix();
      toolLayer.translate(position.x,position.y);
      float a = (ejected ? velocity.heading() + HALF_PI : angle);
      toolLayer.rotate(a);
      toolLayer.rect(0,0, 2*r, 10);
      toolLayer.rect(0,0,20,20);
      toolLayer.popMatrix();
      break;     
    }
    
  }
  
  void select(){
    cf.controllerTool.getTab("default").bringToFront();
    cf.controllerTool.get(Accordion.class,"accDefault").open(0);
    for (int i =0; i< sources.size(); i++)
      cf.controllerTool.getGroup("Source "+i).hide();
    cf.controllerTool.getGroup("Source "+index).show();
    cf.controllerTool.getGroup("Source "+index).open();
    cf.controllerTool.get(DropdownList.class,"Select a source").setValue(index);
  }
}

class Magnet extends Brush {

  float strength;
  boolean isAudioReactive;

  Magnet(float x, float y, int index){
    super(x,y,index);
    strength = (float)cf.controllerTool.getController("mag"+index+"_strength").getValue();
    isAudioReactive = true;
  }
  
  void apply(){
    for (int i = 0; i< flocks.length; i++){
      if (apply[i]){
        for (Boid b : flocks[i].boids)
          b.applyAttraction(position,strength);
      }
    }
  }
  
  void update(){
    super.update();
    
    if(isAudioReactive){
      strength = constrain(map(audioInput.left.level(),0.001,0.05,100,-100),-100,100);
    }
  }
  
  void render(){
    super.render();
    toolLayer.pushMatrix();
    toolLayer.translate(position.x,position.y);
    toolLayer.rect(0,0,20,20);
    toolLayer.rotate(QUARTER_PI);
    toolLayer.rect(0,0,20,20);
    toolLayer.popMatrix();
  }
  
  void select(){
    cf.controllerTool.getTab("default").bringToFront();
    cf.controllerTool.get(Accordion.class,"accDefault").open(1);
    for (int i =0; i< magnets.size(); i++)
      cf.controllerTool.getGroup("Magnet "+i).hide();
    cf.controllerTool.getGroup("Magnet "+index).show();
    cf.controllerTool.getGroup("Magnet "+index).open();
    cf.controllerTool.get(DropdownList.class,"Select a magnet").setValue(index);
  }
}

class Obstacle extends Brush {

  int type;
  float e;
  float angle;
  
  Obstacle(float x, float y, int index){
    super(x,y, index);
    e = cf.controllerTool.getController("obs"+index+"_e").getValue();
    angle = radians(cf.controllerTool.getController("obs"+index+"_angle").getValue());
    type = int(cf.controllerTool.get(RadioButton.class,"obs"+index+"_type").getValue());
    r = map(cf.controllerTool.getController("obs"+index+"_size").getValue(),0,100,0,0.5*width);
    rSq= r*r;   
  }
  
  void apply(){     
    switch(type){
      case POINT :
      for (int i = 0; i< flocks.length; i++){
        if (apply[i]){
          for (Boid b: flocks[i].boids){
            if (distSq(b.position,position) < rSq){
              PVector n = PVector.sub(position,b.position);
              float theta = b.velocity.heading() - n.heading();
              b.velocity.rotate(PI-2*theta);
              PVector ray = n.copy();
              ray.setMag(-r);
              b.position = PVector.add(position,ray);
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
            if (n.magSq() > (r-e)*(r-e) && n.magSq() < (r+e)*(r+e) && n.x*a.x > - n.y*a.y){
              float theta = b.velocity.heading() - n.heading();
              b.velocity.rotate(PI-2*theta);
              PVector v = n.copy();
              if (n.magSq() < rSq)
                v.setMag(-r+e);
              else
                v.setMag(-r-e);
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
            if (d.x*n.x < -d.y*n.y + e  && d.x*n.x > -d.y*n.y - e && -d.x*n.y < -d.y*n.x + r && -d.x*n.y > -d.y*n.x - r )
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
    super.render();
    switch(type){
      case POINT :
      toolLayer.ellipse(position.x,position.y,2*r,2*r);
      toolLayer.ellipse(position.x,position.y,20,20);
      break;
      
      case LINE :
      toolLayer.pushMatrix();
      toolLayer.translate(position.x,position.y);
      toolLayer.rotate(angle);
      toolLayer.rect(0,0, 2*r, 2*e);
      toolLayer.ellipse(0,0,20,20);
      toolLayer.popMatrix();
      break;
      
      case BOWL :
      toolLayer.arc(position.x, position.y, 2*(r-e), 2*(r-e), angle, angle + PI);
      toolLayer.arc(position.x, position.y, 2*(r+e), 2*(r+e), angle, angle + PI);
      toolLayer.ellipse(position.x,position.y,20,20);
      break;
    }
  }
  
  void select(){
    cf.controllerTool.getTab("default").bringToFront();
    cf.controllerTool.get(Accordion.class,"accDefault").open(2);
    for (int i =0; i< obstacles.size(); i++)
      cf.controllerTool.getGroup("Obstacle "+i).hide();
    cf.controllerTool.getGroup("Obstacle "+index).show();
    cf.controllerTool.getGroup("Obstacle "+index).open();
    cf.controllerTool.get(DropdownList.class,"Select a obstacle").setValue(index);
  }
}