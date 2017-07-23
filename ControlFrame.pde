class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w,h);
  }

  public void setup() {
    surface.setLocation(0,0);
    gui();
    cp5 = new ControlP5(this);
  }

  void draw() {
    background(100);
  }
  
  public void gui()
  {
    controller = new ControlP5(this);
    
    //Group 1 : Global parameters
    Group g1 = controller.addGroup("Global physical parameters").setBackgroundColor(color(0, 64)).setBackgroundHeight(160);
    controller.addCheckBox("parametersToggle").setPosition(10,10).setSize(9,9).setItemsPerRow(1).addItem("F",0).addItem("S",1).moveTo(g1);                       
    controller.addSlider("maxforce").plugTo(flock.boids,"maxforce").setPosition(30,10).setRange(0.01,1).setValue(1).moveTo(g1);
    controller.addSlider("maxspeed").plugTo(flock.boids,"maxspeed").setPosition(30,20).setRange(0.01,20).setValue(20).moveTo(g1);
    controller.addSlider("N").setPosition(30,40).setRange(0,1000).moveTo(g1);
    controller.addSlider("k_density").plugTo(flock.boids,"k_density").setPosition(30,60).setRange(0.1,2).setValue(1.0).moveTo(g1);          
    controller.addBang("grid").setPosition(115,85).setSize(20,20).moveTo(g1);
    controller.addBang("kill").setPosition(140,85).setSize(20,20).moveTo(g1);
    controller.addBang("brushes").setPosition(115,120).setSize(20,20).moveTo(g1);
    Group borders = controller.addGroup("Borders").setPosition(10,95).setBackgroundColor(color(0, 64)).setBackgroundHeight(60).moveTo(g1);  
    controller.addRadioButton("Borders type").setPosition(10,10).setSize(15,15).moveTo(borders)
              .addItem("walls", 0).addItem("loops", 1).addItem("no_border", 2).activate(2);
    
    //Group 2 : Sources  
    Group g2 = controller.addGroup("Sources").setBackgroundColor(color(0, 64)).setBackgroundHeight(221);  
    controller.addBang("add src").setPosition(10,10).setSize(20,20).moveTo(g2);
    controller.addCheckBox("src_activation").setPosition(40,12).setSize(15,15).setItemsPerRow(4).setSpacingColumn(20).moveTo(g2);
    controller.addAccordion("acc_sources").setPosition(10,60).setWidth(controllerSize-10).setMinItemHeight(78).setCollapseMode(Accordion.SINGLE).moveTo(g2);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Source "+i).setBackgroundColor(color(0, 64)).setBackgroundHeight(78).hide();
      controller.addRadioButton("src"+i+"_type").setPosition(0,5).setSize(10,10).setItemsPerRow(2).setSpacingColumn(25).addItem("0 ("+i+")", 0).addItem("| ("+i+")", 1).activate(0).moveTo(s1);
      controller.addSlider("src"+i+"_size").setPosition(0,21).setSize(50,10).setRange(10,100).setValue(20).moveTo(s1);  
      controller.addSlider("src"+i+"_outflow").setPosition(0,32).setSize(50,10).setRange(1,30).setValue(1).moveTo(s1);
      controller.addSlider("src"+i+"_strength").setPosition(0,43).setSize(50,10).setRange(0,10).setValue(1).moveTo(s1); 
      controller.addSlider("lifespan " + i).setPosition(0,54).setSize(50,10).setRange(1,1000).setValue(100).moveTo(s1);
      controller.addButton("random " + i).setPosition(0,65).setSize(40,10).setSwitch(true).moveTo(s1);
      controller.addKnob("src"+i+"_angle").setPosition(145,21).setResolution(100).setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(9).moveTo(s1);
      controller.get(Accordion.class,"acc_sources").addItem(s1);
    }
    
    //Group 3 : Magnets  
    Group g3 = controller.addGroup("Magnets").setBackgroundColor(color(0, 64)).setBackgroundHeight(180);  
    controller.addBang("add mag").setPosition(10,10).setSize(20,20).moveTo(g3);
    controller.addCheckBox("mag_activation").setPosition(40,12).setSize(15,15).setItemsPerRow(4).setSpacingColumn(20).moveTo(g3);
    controller.addAccordion("acc_magnets").setPosition(10,60).setWidth(controllerSize-10).setMinItemHeight(33).setCollapseMode(Accordion.SINGLE).moveTo(g3);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Magnet "+i).setBackgroundColor(color(0, 64)).setBackgroundHeight(33).hide();
      controller.addRadioButton("mag"+i+"_type").setPosition(0,5).setSize(10,10).setItemsPerRow(2).setSpacingColumn(25).addItem("+ ("+i+")", 0).addItem("- ("+i+")", 1).activate(0).moveTo(s1);
      controller.addSlider("mag"+i+"_strength").setPosition(0,21).setSize(50,10).setRange(0,10).setValue(1).moveTo(s1);
      controller.get(Accordion.class,"acc_magnets").addItem(s1);
    }
    
    //Group 4 : Obstacles  
    Group g4 = controller.addGroup("Obstacles").setBackgroundColor(color(0, 64)).setBackgroundHeight(180);  
    controller.addBang("add obs").setPosition(10,10).setSize(20,20).moveTo(g4);
    controller.addCheckBox("obs_activation").setPosition(40,12).setSize(15,15).setItemsPerRow(4).setSpacingColumn(20).moveTo(g4);
    controller.addAccordion("acc_obstacles").setPosition(10,60).setWidth(controllerSize-10).setMinItemHeight(33).setCollapseMode(Accordion.SINGLE).moveTo(g4);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Obstacle "+i).setBackgroundColor(color(0, 64)).setBackgroundHeight(33).hide();
      controller.addRadioButton("obs"+i+"_type").setPosition(0,5).setSize(10,10).setItemsPerRow(3).setSpacingColumn(25).addItem("O ("+i+")", 0).addItem("/ ("+i+")", 1).addItem("U ("+i+")", 2).activate(0).moveTo(s1);
      controller.addSlider("obs"+i+"_size").setPosition(0,21).setSize(50,10).setRange(5,75).setValue(1).moveTo(s1);
      controller.addKnob("obs"+i+"_angle").setPosition(145,0).setResolution(100).setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(9).moveTo(s1);
      controller.get(Accordion.class,"acc_obstacles").addItem(s1);
    }
    
    //Group 5 : Forces
    Group g5 = controller.addGroup("Forces").setBackgroundColor(color(0, 64)).setBackgroundHeight(125);                       
    controller.addCheckBox("forceToggle").setPosition(10,10).setSize(9,9).setItemsPerRow(1).moveTo(g5)
              .addItem("s",0).addItem("a",1).addItem("c",2).addItem("f",3).addItem("g",4).addItem("n",5).addItem("o",6);
    controller.addSlider("separation").plugTo(flock.boids,"separation").setPosition(30,10).setRange(0.01,4).setValue(1.5).moveTo(g5);
    controller.addSlider("alignment").plugTo(flock.boids,"alignment").setPosition(30,20).setRange(0.01,4).setValue(1.0).moveTo(g5);
    controller.addSlider("cohesion").plugTo(flock.boids,"cohesion").setPosition(30,30).setRange(0.01,4).setValue(1.0).moveTo(g5);
    controller.addSlider("friction").plugTo(flock.boids,"friction").setPosition(30,40).setRange(0.01,4).moveTo(g5);
    controller.addSlider("gravity").setPosition(30,50).setRange(0.01,4).setValue(1.0).moveTo(g5);  
    controller.addSlider("noise").plugTo(flock.boids,"noise").setPosition(30,60).setRange(0.01,4).setValue(1.0).moveTo(g5);
    controller.addSlider("origin").plugTo(flock.boids,"origin").setPosition(30,70).setRange(0.01,4).setValue(1.0).moveTo(g5);
    controller.addKnob("gravity_Angle").setPosition(50,90).setResolution(100).setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(10).moveTo(g5);
  
    //Group 6 : Visual parameters
    Group g6 = controller.addGroup("Visual parameters").setBackgroundColor(color(0, 64)).setBackgroundHeight(152);  
    controller.addSlider("symmetry").plugTo(flock.boids,"symmetry").setPosition(10,10).setRange(1,12).setValue(1).moveTo(g6);
    controller.addSlider("trailLength").plugTo(flock.boids,"trailLength").setPosition(10,22).setRange(0,20).setValue(0).moveTo(g6); 
    controller.addSlider("alpha").plugTo(flock.boids,"alpha").setPosition(10,34).setRange(20,255).setValue(100).moveTo(g6); 
    controller.addRadioButton("Visual").setPosition(10,52).setSize(15,15).setItemsPerRow(2).setSpacingColumn(85).moveTo(g6)
              .addItem("triangle", 0).addItem("line", 1).addItem("circle", 2).addItem("curve", 3).addItem("letter", 4).activate(2);
    Group part = controller.addGroup("Particules").setPosition(10,117).setBackgroundColor(color(0, 64)).setBackgroundHeight(33).setWidth(90).moveTo(g6);
    controller.addSlider("size").setPosition(0,5).setSize(50,10).setRange(0.1,100).setValue(2.0).moveTo(part); 
            
    Group connex = controller.addGroup("Connections").setPosition(110,117).setBackgroundColor(color(0, 64)).setBackgroundHeight(33).setWidth(90).moveTo(g6);
    controller.addSlider("N_links").setPosition(0,5).setSize(50,10).setRange(1,30).setValue(3).moveTo(connex);
    controller.addSlider("d_max").setPosition(0,16).setSize(50,10).setRange(0.1,10).setValue(1.0).moveTo(connex); 
  
    
    //Group 7 : Colors
    Group g7 = controller.addGroup("Colors").setBackgroundColor(color(0, 64)).setBackgroundHeight(200);  
    controller.addColorWheel("particleColor",5,10,90).setRGB(color(255)).moveTo(g7);           
    controller.addColorWheel("backgroundColor",105,10,90).setRGB(color(0)).plugTo(parent, "backgroundColor").moveTo(g7);
    controller.addBang("Black&White").setPosition(10,120).setSize(10,10).moveTo(g7);
    controller.addSlider("contrast").setPosition(10,150).setRange(0,200).setValue(50).moveTo(g7);
    controller.addSlider("red").setPosition(10,160).setRange(0,200).setValue(0).moveTo(g7);
    controller.addSlider("green").setPosition(10,170).setRange(0,200).setValue(0).moveTo(g7);
    controller.addSlider("blue").setPosition(10,180).setRange(0,200).setValue(0).moveTo(g7);
    
    //Accordion
    controller.addAccordion("acc").setPosition(0,0).setWidth(controllerSize).setCollapseMode(Accordion.MULTI)
              .addItem(g1).addItem(g2).addItem(g3).addItem(g4).addItem(g5).addItem(g6).addItem(g7).open(0,4,5,6);
  }
  
  //ControlP5
  void controlEvent(ControlEvent theEvent) { 
    if(theEvent.isFrom("Visual")){
      switch(int(theEvent.getValue())) {
        case(0):flock.boidType = BoidType.TRIANGLE;break;
        case(1):flock.boidType = BoidType.LINE;break;
        case(2):flock.boidType = BoidType.CIRCLE;break;
        case(3):flock.boidType = BoidType.CURVE;break;
        case(4):flock.boidType = BoidType.LETTER;break;
      }
      flock.boidTypeChange = true;
    }  
    if (theEvent.isFrom("Borders type")) {
      switch(int(theEvent.getValue())) {
        case(0):flock.borderType = BorderType.WALLS;break;
        case(1):flock.borderType = BorderType.LOOPS;break;
        case(2):flock.borderType = BorderType.NOBORDER;break;
      }
    }
    for (int i = 0; i<flock.sources.size(); i++){
      if(theEvent.isFrom("src"+i+"_type")){
        switch(int(theEvent.getValue())){
          case (0) : flock.sources.get(i).type = SourceType.O; break;
          case (1) : flock.sources.get(i).type = SourceType.I; break;
        }
      }
    }   
    for (int i = 0; i<flock.magnets.size(); i++){
      if(theEvent.isFrom("mag"+i+"_type")){
        switch(int(theEvent.getValue())){
          case (0) : flock.magnets.get(i).type = MagnetType.PLUS; break;
          case (1) : flock.magnets.get(i).type = MagnetType.MINUS; break;
        }
      }
    }    
    for (int i = 0; i<flock.obstacles.size(); i++){
      if(theEvent.isFrom("obs"+i+"_type")){
        switch(int(theEvent.getValue())){
          case (0) : flock.obstacles.get(i).type = ObstacleType.O; break;
          case (1) : flock.obstacles.get(i).type = ObstacleType.I; break;
          case (2) : flock.obstacles.get(i).type = ObstacleType.U; break;
        }
      }
    }
    
    if (theEvent.isFrom(controller.get(CheckBox.class,"forceToggle"))){
      for (int i = 0; i<controller.get(CheckBox.class,"forceToggle").getArrayValue().length; i++){
        for (Boid b : flock.boids)
          b.forcesToggle[i] = controller.get(CheckBox.class,"forceToggle").getState(i);
      }
    }  
    if (theEvent.isFrom(controller.get(CheckBox.class,"parametersToggle"))){
      for (int i = 0; i<controller.get(CheckBox.class,"parametersToggle").getArrayValue().length; i++){
        for (Boid b : flock.boids)
          b.paramToggle[i] = controller.get(CheckBox.class,"parametersToggle").getState(i);
      }
    }
    
    if (theEvent.isFrom(controller.get(CheckBox.class,"src_activation"))){
      for (int i = 0; i<controller.get(CheckBox.class,"src_activation").getArrayValue().length; i++)
        flock.sources.get(i).isActivated = controller.get(CheckBox.class,"src_activation").getState(i);
    }
    if (theEvent.isFrom(controller.get(CheckBox.class,"mag_activation"))){
      for (int i = 0; i<controller.get(CheckBox.class,"mag_activation").getArrayValue().length; i++)
        flock.magnets.get(i).isActivated = controller.get(CheckBox.class,"mag_activation").getState(i);
    }
    if (theEvent.isFrom(controller.get(CheckBox.class,"obs_activation"))){
      for (int i = 0; i<controller.get(CheckBox.class,"obs_activation").getArrayValue().length; i++)
        flock.obstacles.get(i).isActivated = controller.get(CheckBox.class,"obs_activation").getState(i);
    }
       
    if(theEvent.isFrom("Black&White")){
      if(controller.get(ColorWheel.class,"particleColor").getRGB() != -1 || controller.get(ColorWheel.class,"backgroundColor").getRGB() != -16777216){
        controller.get(ColorWheel.class,"particleColor").setRGB(color(255));
        controller.get(ColorWheel.class,"backgroundColor").setRGB(color(0));
      }
      else{
        controller.get(ColorWheel.class,"particleColor").setRGB(color(0));
        controller.get(ColorWheel.class,"backgroundColor").setRGB(color(255));
      }
    }
  
   if(theEvent.isFrom("grid")) flock.grid = true;
   if(theEvent.isFrom("kill")) flock.killAll();
   if(theEvent.isFrom("N")) flock.NChange = true;
     
    for (Boid b : flock.boids){
      if (b instanceof Particle){
        Particle p = (Particle)b;
        if(theEvent.isFrom("size"))     p.size = theEvent.getController().getValue();     
      }
      if (b instanceof Connection){
        Connection c = (Connection)b;
        if(theEvent.isFrom("N_links")) c.maxConnections = (int)controller.getController("N_links").getValue();      
        if(theEvent.isFrom("d_max")) c.d_max = (int)controller.getController("d_max").getValue();              
      }
      if(theEvent.isFrom("gravity") || theEvent.isFrom("gravity_Angle"))     b.g = b.g();
      if(theEvent.isFrom("red"))     b.randomRed = random(0,controller.getController("red").getValue());
      if(theEvent.isFrom("green"))     b.randomGreen = random(0,controller.getController("green").getValue());
      if(theEvent.isFrom("blue"))     b.randomBlue = random(0,controller.getController("blue").getValue());
      if(theEvent.isFrom(controller.get(ColorWheel.class,"particleColor"))){
        b.red = controller.get(ColorWheel.class,"particleColor").r();
        b.green = controller.get(ColorWheel.class,"particleColor").g();
        b.blue = controller.get(ColorWheel.class,"particleColor").b();
      }
    }
     
     //SOURCES
     if(theEvent.isFrom("add src")) flock.addSource();    
     for (int i = 0; i<flock.sources.size(); i++){
       Source s = flock.sources.get(i);
       if(theEvent.isFrom("src"+i+"_size")) s.r = controller.getController("src"+i+"_size").getValue();
       if(theEvent.isFrom("src"+i+"_outflow")) s.outflow = (int)controller.getController("src"+i+"_outflow").getValue();
       if(theEvent.isFrom("src"+i+"_strength")) s.vel = s.vel(i);
       if(theEvent.isFrom("lifespan "+ i)){
         s.lifespan = (int)controller.getController("lifespan "+ i).getValue();
       }
       if(theEvent.isFrom("src"+i+"_angle")){
         s.angle = radians(controller.getController("src"+i+"_angle").getValue());
         s.vel = s.vel(i);
       }
       if(theEvent.isFrom("random "+ i)){
         s.randomVel = controller.get(Button.class,"random " + i).isOn();
       }
     }
     
     //MAGNETS
     if(theEvent.isFrom("add mag")) flock.addMagnet();    
     for (int i = 0; i<flock.magnets.size(); i++){
       if(theEvent.isFrom("mag"+i+"_strength")) flock.magnets.get(i).strength = controller.getController("mag"+i+"_strength").getValue();
     }
     
     //Obstacles
     if(theEvent.isFrom("add obs")) flock.addObstacle();
     for (int i = 0; i<flock.obstacles.size(); i++){
       Obstacle o = flock.obstacles.get(i);
       if(theEvent.isFrom("obs"+i+"_size")) o.r = controller.getController("obs"+i+"_size").getValue();
       if(theEvent.isFrom("obs"+i+"_angle")) o.angle = radians(controller.getController("obs"+i+"_angle").getValue());
     }
     
     //BRUSHES
     for (Brush b : flock.brushes){
       if(theEvent.isFrom("brushes")) b.isVisible = !b.isVisible;       
     }
  }
}