class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 controller;
  ControlP5[] controllerFlock;
  float selectedPreset = 0;


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
  }

  void draw() {
    background(100);
  }
  
  void keyPressed(){
    if(key == ' ')  isRecording = !isRecording;
  }
  
  void mouseWheel(MouseEvent event){
    if (controller.getTab("default").isActive()){
      int y = int(controller.getGroup("accDefault").getPosition()[1]);
      if(y <= 20 && y >= -200)
        controller.getGroup("accDefault").setPosition(controller.getGroup("accDefault").getPosition()[0],y-20*event.getCount());
      else if (y > 20)
        controller.getGroup("accDefault").setPosition(0,20);
      else if (y < -200)
       controller.getGroup("accDefault").setPosition(0,-200);
    }
    for (int i = 0; i< controllerFlock.length; i++){  
      if (controller.getTab("Flock "+i).isActive()){
        int y = int(controllerFlock[i].getGroup("acc").getPosition()[1]);
        if(y <= 20 && y >= -400)
          controllerFlock[i].getGroup("acc").setPosition(controllerFlock[i].getGroup("acc").getPosition()[0],y-20*event.getCount());
        else if (y > 20)
          controllerFlock[i].getGroup("acc").setPosition(0,20);
        else if (y < -400)
         controllerFlock[i].getGroup("acc").setPosition(0,-400);
      }
    }
  }
  
    void addSource(){
    if(sources.size()<8){
      Source s = new Source(0.5*parent.width,0.5*parent.height);
      sources.add(s);
      for (int i =0; i< sources.size()-1; i++){
        controller.getGroup("Source "+i).hide();
      }
      int i = sources.size()-1;  
      controller.getGroup("Source "+i).show();
      controller.get(CheckBox.class,"src_activation").addItem("S"+i,i).activate(i);
      controller.get(DropdownList.class,"Select a source").addItem("Source "+i,i).setValue(i);
      controller.getGroup("Sources").setSize(200,300);
      controller.getGroup("accDefault").close();
      controller.getGroup("accDefault").open();
    }
 }
 
 void addSource(PVector pos){
    addSource();
    sources.get(sources.size()-1).position = pos;
 }
 
  void addMagnet(){
    if(magnets.size()<8){
      Magnet m = new Magnet(0.5*parent.width,0.5*parent.height);
      magnets.add(m);
      for (int i =0; i< magnets.size()-1; i++){
        controller.getGroup("Magnet "+i).hide();
      }
      int i = magnets.size()-1;  
      controller.getGroup("Magnet "+i).show();
      controller.get(CheckBox.class,"mag_activation").addItem("M"+i,i).activate(i);
      controller.get(DropdownList.class,"Select a magnet").addItem("Magnet "+i,i).setValue(i);
      controller.getGroup("Magnets").setSize(200,160);
      controller.getGroup("accDefault").close();
      controller.getGroup("accDefault").open();
    }
  }
    
  void addObstacle(){
    if(obstacles.size()<8){
      Obstacle m = new Obstacle(0.5*parent.width,0.5*parent.height);
      obstacles.add(m);
      for (int i =0; i< obstacles.size()-1; i++){
        controller.getGroup("Obstacle "+i).hide();
      }
      int i = obstacles.size()-1;  
      controller.getGroup("Obstacle "+i).show();
      controller.get(CheckBox.class,"obs_activation").addItem("O"+i,i).activate(i);
      controller.get(DropdownList.class,"Select a obstacle").addItem("Obstacle "+i,i).setValue(i);
      controller.getGroup("Obstacles").setSize(200,235);
      controller.getGroup("accDefault").close();
      controller.getGroup("accDefault").open();
    }
  }
   
 void updateControllerValues(JSONObject preset, ControlP5 c){
   c.getController("maxforce").setValue(preset.getFloat("maxforce"));
   c.getController("maxspeed").setValue(preset.getFloat("maxspeed"));
   boolean[] pt = preset.getJSONArray("parametersToggle").getBooleanArray();
   c.get(CheckBox.class, "parametersToggle").deactivateAll();
   for (int i=0; i< pt.length; i++){
     if (pt[i])
       c.get(CheckBox.class, "parametersToggle").activate(i);
   }
   c.getController("friction").setValue(preset.getFloat("friction"));
   c.getController("origin").setValue(preset.getFloat("origin"));
   c.getController("noise").setValue(preset.getFloat("noise"));
   c.getController("separation").setValue(preset.getFloat("separation"));
   c.getController("alignment").setValue(preset.getFloat("alignment"));
   c.getController("cohesion").setValue(preset.getFloat("cohesion"));
   c.getController("sep_r").setValue(preset.getFloat("sep_r"));
   c.getController("ali_r").setValue(preset.getFloat("ali_r"));
   c.getController("coh_r").setValue(preset.getFloat("coh_r"));
   c.getController("trailLength").setValue(preset.getFloat("trailLength"));
   c.getController("gravity").setValue(preset.getFloat("gravity"));
   c.getController("gravity_Angle").setValue(preset.getFloat("gravity_angle"));
   c.getController("alpha").setValue(preset.getFloat("alpha"));
   c.get(ColorWheel.class,"particleColor").setRGB(color(preset.getInt("red"),preset.getInt("green"),preset.getInt("blue")));
   c.getController("contrast").setValue(preset.getInt("randomBrightness"));
   c.getController("red").setValue(preset.getInt("randomRed"));
   c.getController("green").setValue(preset.getInt("randomGreen"));
   c.getController("blue").setValue(preset.getInt("randomBlue"));
   c.getController("size").setValue(preset.getFloat("size"));
   if (preset.getBoolean("isolationIsActive")) c.get(Button.class, "isolation").setOn();
   else c.get(Button.class, "isolation").setOff();
   
   c.get(RadioButton.class,"Visual").activate(preset.getInt("boidType"));
   c.get(RadioButton.class,"Borders type").activate(preset.getInt("borderType"));
   boolean[] ft = preset.getJSONArray("forceToggle").getBooleanArray();
   c.get(CheckBox.class, "forceToggle").deactivateAll();
   for (int i=0; i< ft.length; i++){
     if (ft[i]) c.get(CheckBox.class, "forceToggle").activate(i);
   }
    boolean[] fft = preset.getJSONArray("flockForceToggle").getBooleanArray();
   c.get(CheckBox.class, "flockForceToggle").deactivateAll();
   for (int i=0; i< fft.length; i++){
     if (fft[i]) c.get(CheckBox.class, "flockForceToggle").activate(i);
   }
   c.getController("symmetry").setValue(preset.getInt("symmetry"));
   c.getController("d_max").setValue(preset.getFloat("d_max"));
   c.getController("N_links").setValue(preset.getFloat("maxConnections"));
  }
  
  public void gui()
  {
    controller = new ControlP5(this);
    controllerFlock = new ControlP5[3];
    for (int j = 0; j<controllerFlock.length; j++){
      controllerFlock[j] = new ControlP5(this);
      controller.addTab("Flock "+j);
    } 
    
    Group c0 = controller.addGroup("Colors").setBackgroundColor(color(0, 64)).setBackgroundHeight(250).setBarHeight(15);
    controller.addColorWheel("backgroundColor",10,10,180).setRGB(color(0)).plugTo(parent, "backgroundColor").moveTo(c0).setSaturation(100);
    controller.addBang("Black&White").setPosition(10,210).setSize(20,20).moveTo(c0);
    controller.addButton("show brushes").setPosition(80,210).setSize(100,20).setSwitch(true).setOff().moveTo(c0);

    //Group 1 : Sources  
    Group c1 = controller.addGroup("Sources").setBackgroundColor(color(0, 64)).setBackgroundHeight(50);  
    controller.addBang("add src").setPosition(10,10).setSize(20,20).moveTo(c1);
    controller.addCheckBox("src_activation").setPosition(50,40).setSize(15,15).setItemsPerRow(4).setSpacingColumn(20).moveTo(c1);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Source "+i).setPosition(10,90).setSize(180,200).setBackgroundColor(color(0, 64)).hide().moveTo(c1);
      for (int j = 0; j<controllerFlock.length; j++) 
        controller.addButton("s"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("flock "+j).setSwitch(true).setOff().moveTo(s1); 
      controller.addSlider("src"+i+"_size").setPosition(5,35).setSize(100,15).setLabel("size").setRange(1,400).setValue(20).moveTo(s1);  
      controller.addSlider("src"+i+"_outflow").setPosition(5,55).setSize(100,15).setLabel("outflow").setValue(3).moveTo(s1);
      controller.addSlider("src"+i+"_strength").setPosition(5,75).setSize(100,15).setLabel("strength").setRange(0,10).setValue(1).moveTo(s1); 
      controller.addSlider("lifespan " + i).setPosition(5,95).setSize(100,15).setLabel("lifespan").setRange(1,1000).setValue(100).moveTo(s1);
      controller.addRadioButton("src"+i+"_type").setPosition(15,120).setSize(20,20).setItemsPerRow(1).setSpacingColumn(25).addItem("0 ("+i+")", 0).addItem("| ("+i+")", 1).activate(0).moveTo(s1);
      controller.addButton("randomStrength " + i).setPosition(5,170).setSize(50,20).setLabel("random v").setSwitch(true).moveTo(s1);
      controller.addButton("randomAngle " + i).setPosition(60,170).setSize(50,20).setLabel("random a").setSwitch(true).moveTo(s1);
      controller.addKnob("src"+i+"_angle").setPosition(120,125).setResolution(100).setRange(0,360).setLabel("angle").setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(25).moveTo(s1);
    }
    controller.addDropdownList("Select a source").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(15).close().moveTo(c1);
      
    //Group 2 : Magnets  
    Group c2 = controller.addGroup("Magnets").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(15);  
    controller.addBang("add mag").setPosition(10,10).setSize(20,20).moveTo(c2);
    controller.addCheckBox("mag_activation").setPosition(50,40).setSize(15,15).setItemsPerRow(4).setSpacingColumn(20).moveTo(c2);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Magnet "+i).setPosition(10,90).setBackgroundColor(color(0, 64)).setSize(180,60).hide().moveTo(c2);
      for (int j = 0; j<controllerFlock.length; j++) 
        controller.addButton("m"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("flock "+j).setSwitch(true).setOff().moveTo(s1); 
      controller.addSlider("mag"+i+"_strength").setPosition(5,35).setSize(100,15).setLabel("strength").setRange(-100,100).setValue(0).moveTo(s1);
    }
    controller.addDropdownList("Select a magnet").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(15).close().moveTo(c2);

    //Group 3 : Obstacles  
    Group c3 = controller.addGroup("Obstacles").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(15);  
    controller.addBang("add obs").setPosition(10,10).setSize(20,20).moveTo(c3);
    controller.addCheckBox("obs_activation").setPosition(50,40).setSize(15,15).setItemsPerRow(4).setSpacingColumn(20).moveTo(c3);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Obstacle "+i).setPosition(10,90).setBackgroundColor(color(0, 64)).setSize(180,135).hide().moveTo(c3);
      for (int j = 0; j<controllerFlock.length; j++) 
        controller.addButton("o"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("flock "+j).setSwitch(true).setOff().moveTo(s1); 
      controller.addSlider("obs"+i+"_size").setPosition(5,35).setSize(100,15).setLabel("size").setRange(-100,100).setValue(0).moveTo(s1);
      controller.addKnob("obs"+i+"_angle").setPosition(90,60).setResolution(100).setLabel("angle").setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(25).moveTo(s1);
      controller.addRadioButton("obs"+i+"_type").setPosition(5,60).setSize(20,20).setItemsPerRow(1).setSpacingColumn(30).addItem("O ("+i+")", 0).addItem("/ ("+i+")", 1).addItem("U ("+i+")", 2).activate(0).moveTo(s1);
    }
    controller.addDropdownList("Select a obstacle").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(15).close().moveTo(c3);
      
    //Accordion
    controller.addAccordion("accDefault").setPosition(0,20).setWidth(this.w).setMinItemHeight(50).setCollapseMode(Accordion.MULTI)
                .addItem(c0).addItem(c1).addItem(c2).addItem(c3).open(0,1,2,3);
                
    for (int j = 0; j<controllerFlock.length; j++){
      
      //Group 1 : Global parameters
      Group g1 = controllerFlock[j].addGroup("Global physical parameters").setBackgroundColor(color(0, 64)).setBackgroundHeight(190);
      controllerFlock[j].addSlider("N").setPosition(115,20).setSize(50,130).setNumberOfTickMarks(6).snapToTickMarks(false).setRange(0,1000).moveTo(g1);
      controllerFlock[j].getController("N").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
      controllerFlock[j].addSlider("k_density").setPosition(30,60).setRange(0.1,2).setValue(1.0).hide().moveTo(g1);
      controllerFlock[j].addSlider("X").setPosition(25,20).setSize(60,10).setNumberOfTickMarks(31).showTickMarks(false).setRange(0,30).moveTo(g1);
      controllerFlock[j].getController("X").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
      controllerFlock[j].getController("X").getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(2);
      controllerFlock[j].addSlider("Y").setPosition(15,30).setSize(10,60).setNumberOfTickMarks(31).showTickMarks(false).setSliderMode(Slider.FIX).setRange(0,30).moveTo(g1);
      controllerFlock[j].getController("Y").getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);
      controllerFlock[j].getController("Y").getValueLabel().align(ControlP5.CENTER, ControlP5.TOP).setPaddingX(10);
      controllerFlock[j].addBang("grid").setPosition(30,35).setSize(55,55).moveTo(g1);
      controllerFlock[j].getController("grid").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
      controllerFlock[j].addBang("kill").setPosition(115,150).setSize(50,20).moveTo(g1);
      controllerFlock[j].getController("kill").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
      Group borders = controllerFlock[j].addGroup("Borders").setPosition(10,115).setBackgroundColor(color(0, 30)).setBackgroundHeight(58).setWidth(75).moveTo(g1);  
      controllerFlock[j].addRadioButton("Borders type").setPosition(5,5).setSize(15,15).moveTo(borders)
                .addItem("walls", 0).addItem("loops", 1).addItem("no_border", 2).activate(2);
      
      //Group 5 : Forces
      Group g5 = controllerFlock[j].addGroup("Forces").setBackgroundColor(color(0, 64)).setBackgroundHeight(230);                      
      controllerFlock[j].addCheckBox("forceToggle").setPosition(10,10).setSize(9,9).setItemsPerRow(1).moveTo(g5)
                .addItem("f",0).addItem("g",1).addItem("n",2).addItem("o",3).addItem(" ",4);
      controllerFlock[j].addSlider("friction").setPosition(30,10).setRange(0.01,4).moveTo(g5);
      controllerFlock[j].addSlider("gravity").setPosition(30,20).setRange(0.01,4).setValue(1.0).moveTo(g5);  
      controllerFlock[j].addSlider("noise").setPosition(30,30).setRange(0.01,10).setValue(1.0).moveTo(g5);
      controllerFlock[j].addSlider("origin").setPosition(30,40).setRange(0.01,4).setValue(1.0).moveTo(g5);
      Group f = controllerFlock[j].addGroup("Flock").setBackgroundColor(color(0, 64)).setBackgroundHeight(65).setPosition(30,60).setWidth(100).moveTo(g5);  
      controllerFlock[j].addCheckBox("flockForceToggle").setPosition(0,0).setSize(9,9).setItemsPerRow(1).moveTo(f)
                .addItem("s",0).addItem("a",1).addItem("c",2);
      controllerFlock[j].addSlider("separation").setPosition(20,0).setSize(80,9).setRange(0.01,4).setValue(1.5).moveTo(f);
      controllerFlock[j].addSlider("alignment").setPosition(20,10).setSize(80,9).setRange(0.01,4).setValue(1.0).moveTo(f);
      controllerFlock[j].addSlider("cohesion").setPosition(20,20).setSize(80,9).setRange(0.01,4).setValue(1.0).moveTo(f);
      controllerFlock[j].addSlider("sep_r").setPosition(20,32).setSize(80,9).setRange(1,1000).setValue(50).moveTo(f);
      controllerFlock[j].addSlider("ali_r").setPosition(20,42).setSize(80,9).setRange(1,1000).setValue(100).moveTo(f);
      controllerFlock[j].addSlider("coh_r").setPosition(20,52).setSize(80,9).setRange(1,1000).setValue(100).moveTo(f);
      controllerFlock[j].addKnob("gravity_Angle").setPosition(70,135).setResolution(100).setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(20).moveTo(g5);
      
      controllerFlock[j].addCheckBox("parametersToggle").setPosition(10,200).setSize(9,9).setItemsPerRow(1).addItem("F",0).addItem("S",1).moveTo(g5);                       
      controllerFlock[j].addSlider("maxforce").setPosition(30,200).setRange(0.01,1).setValue(1).moveTo(g5);
      controllerFlock[j].addSlider("maxspeed").setPosition(30,210).setRange(0.01,20).setValue(20).moveTo(g5);
      
       
      //Group 6 : Visual parameters
      Group g6 = controllerFlock[j].addGroup("Visual parameters").setBackgroundColor(color(0, 64)).setBackgroundHeight(152);  
      controllerFlock[j].addSlider("symmetry").setPosition(10,10).setRange(1,12).setValue(1).moveTo(g6);
      controllerFlock[j].addSlider("trailLength").setPosition(10,22).setRange(0,100).setValue(0).moveTo(g6); 
      controllerFlock[j].addSlider("alpha").setPosition(10,34).setRange(20,255).setValue(100).moveTo(g6); 
      controllerFlock[j].addRadioButton("Visual").setPosition(10,52).setSize(15,15).setItemsPerRow(2).setSpacingColumn(85).moveTo(g6)
                .addItem("triangle", 0).addItem("line", 1).addItem("circle", 2).addItem("curve", 3).addItem("letter", 4).addItem("pixel", 5);
      Group part = controllerFlock[j].addGroup("Particules").setPosition(10,117).setBackgroundColor(color(0, 64)).setBackgroundHeight(33).setWidth(90).moveTo(g6);
      controllerFlock[j].addSlider("size").setPosition(0,5).setSize(50,10).setRange(0.1,100).setValue(2.0).moveTo(part); 
      controllerFlock[j].addButton("isolation").setPosition(0,15).setSize(35,10).setSwitch(true).setOff().moveTo(part); 
              
      Group connex = controllerFlock[j].addGroup("Connections").setPosition(110,117).setBackgroundColor(color(0, 64)).setBackgroundHeight(33).setWidth(90).moveTo(g6);
      controllerFlock[j].addSlider("N_links").setPosition(0,5).setSize(50,10).setRange(1,30).setValue(3).moveTo(connex);
      controllerFlock[j].addSlider("d_max").setPosition(0,16).setSize(50,10).setRange(1,500).setValue(100).moveTo(connex); 
    
      
      //Group 7 : Colors
      Group g7 = controllerFlock[j].addGroup("Colors").setBackgroundColor(color(0, 64)).setBackgroundHeight(270);  
      controllerFlock[j].addColorWheel("particleColor",10,10,180).setRGB(color(255)).moveTo(g7).setSaturation(100);           
      controllerFlock[j].addSlider("contrast").setPosition(10,220).setRange(0,200).setValue(0).moveTo(g7);
      controllerFlock[j].addSlider("red").setPosition(10,230).setRange(0,200).setValue(0).moveTo(g7);
      controllerFlock[j].addSlider("green").setPosition(10,240).setRange(0,200).setValue(0).moveTo(g7);
      controllerFlock[j].addSlider("blue").setPosition(10,250).setRange(0,200).setValue(0).moveTo(g7);
      
      //Preset
      Group g_preset = controllerFlock[j].addGroup("preset").setPosition(0,30).setBackgroundColor(color(0,64)).setBackgroundHeight(70).setWidth(200);       
      controllerFlock[j].addBang("load").setPosition(130,25).setSize(20,20).moveTo(g_preset);
      controllerFlock[j].addBang("save").setPosition(160,25).setSize(20,20).moveTo(g_preset);
      DropdownList ddl = controllerFlock[j].addDropdownList("Select a preset").setPosition(10,25).setSize(110,100).setBarHeight(20).setItemHeight(15).close().moveTo(g_preset);
      for (int i = 0; i< presetNames.fichiers.length;i++)
        ddl.addItem(presetNames.fichiers[i],i);
        
      //Accordion
      controllerFlock[j].addAccordion("acc").setPosition(0,20).setWidth(this.w).setMinItemHeight(20).setCollapseMode(Accordion.MULTI)
                .addItem(g_preset).addItem(g1).addItem(g5).addItem(g6).addItem(g7).open(0,4,5,6).moveTo(controller.getTab("Flock "+j));     
    }
  }
  
  
  //ControlP5
  void controlEvent(ControlEvent theEvent) { 

    //Colors
    if(theEvent.isFrom(controller.getController("Black&White"))){
      if(controller.get(ColorWheel.class,"backgroundColor").getRGB() != -16777216){
        for (int j = 0; j<controllerFlock.length; j++)
          controllerFlock[j].get(ColorWheel.class,"particleColor").setRGB(color(255));
        controller.get(ColorWheel.class,"backgroundColor").setRGB(color(0));
      }
      else{
        for (int j = 0; j<controllerFlock.length; j++)
          controllerFlock[j].get(ColorWheel.class,"particleColor").setRGB(color(0));
        controller.get(ColorWheel.class,"backgroundColor").setRGB(color(255));
      }
    }
    
    //SOURCES
     if(theEvent.isFrom(controller.getController("add src"))){ 
       addSource();
     }
     if (theEvent.isFrom(controller.get(CheckBox.class,"src_activation"))){
        for (int i = 0; i<controller.get(CheckBox.class,"src_activation").getArrayValue().length; i++)
          sources.get(i).isActivated = controller.get(CheckBox.class,"src_activation").getState(i);
     }
     for (int i = 0; i<sources.size(); i++){
        if(theEvent.isFrom(controller.get(RadioButton.class,"src"+i+"_type"))){
          switch(int(theEvent.getValue())){
            case (0) : sources.get(i).type = SourceType.O; break;
            case (1) : sources.get(i).type = SourceType.I; break;
          }
        }
      }
     for (int i = 0; i< sources.size(); i++){
       Source s = sources.get(i);
      for(int j = 0; j<controllerFlock.length; j++){
         if(theEvent.isFrom(controller.getController("s"+i+"_f"+j)))
           s.apply[j] = controller.get(Button.class,"s"+i+"_f"+j).isOn();
       }
       if(theEvent.isFrom(controller.getController("src"+i+"_size"))) { 
         s.r = controller.getController("src"+i+"_size").getValue(); 
         s.rSq = s.r*s.r; 
       }
       if(theEvent.isFrom(controller.getController("src"+i+"_outflow"))){ 
         s.outflow = (int)controller.getController("src"+i+"_outflow").getValue();
       }
       if(theEvent.isFrom(controller.getController("lifespan "+ i))){
         s.lifespan = (int)controller.getController("lifespan "+ i).getValue();
       }
       if(theEvent.isFrom(controller.getController("src"+i+"_angle")) || theEvent.isFrom(controller.getController("src"+i+"_strength"))){
         s.angle = radians(controller.getController("src"+i+"_angle").getValue());
         s.strength = controller.getController("src"+i+"_strength").getValue();
         s.vel = new PVector(s.strength*cos(s.angle+HALF_PI),s.strength*sin(s.angle+HALF_PI));
       }
       if(theEvent.isFrom(controller.getController("randomStrength "+ i))){
         s.randomStrength = controller.get(Button.class,"randomStrength " + i).isOn();
       }
       if(theEvent.isFrom(controller.getController("randomAngle "+ i))){
         s.randomAngle = controller.get(Button.class,"randomAngle " + i).isOn();
       }
     }
     if(theEvent.isFrom(controller.get(DropdownList.class,"Select a source"))){ 
       for (int i =0; i< sources.size(); i++){
          controller.getGroup("Source "+i).hide();
        }
       controller.getGroup("Source "+ int(controller.get(DropdownList.class,"Select a source").getValue())).show();
     }
     
     //Magnets
     if(theEvent.isFrom(controller.getController("add mag"))) {
       addMagnet();    
     }
     if (theEvent.isFrom(controller.get(CheckBox.class,"mag_activation"))){
       for (int i = 0; i<controller.get(CheckBox.class,"mag_activation").getArrayValue().length; i++)
         magnets.get(i).isActivated = controller.get(CheckBox.class,"mag_activation").getState(i);
     }
     for (int i = 0; i<magnets.size(); i++){
       if(theEvent.isFrom(controller.getController("mag"+i+"_strength"))) 
         magnets.get(i).strength = controller.getController("mag"+i+"_strength").getValue();
       for(int j = 0; j<controllerFlock.length; j++){
         if(theEvent.isFrom(controller.getController("m"+i+"_f"+j)))
            magnets.get(i).apply[j] = controller.get(Button.class,"m"+i+"_f"+j).isOn();
       }
     }
     if(theEvent.isFrom(controller.get(DropdownList.class,"Select a magnet"))){ 
       for (int i =0; i< magnets.size(); i++){
          controller.getGroup("Magnet "+i).hide();
        }
       controller.getGroup("Magnet "+ int(controller.get(DropdownList.class,"Select a magnet").getValue())).show();
     }
     
     //Obstacles
     if(theEvent.isFrom(controller.getController("add obs"))){
       addObstacle();
     }
     if (theEvent.isFrom(controller.get(CheckBox.class,"obs_activation"))){
       for (int i = 0; i<controller.get(CheckBox.class,"obs_activation").getArrayValue().length; i++)
         obstacles.get(i).isActivated = controller.get(CheckBox.class,"obs_activation").getState(i);
     }
     for (int i = 0; i<obstacles.size(); i++){
       Obstacle o = obstacles.get(i);
       if(theEvent.isFrom(controller.get(RadioButton.class,"obs"+i+"_type"))){
         switch(int(theEvent.getValue())){
           case (0) : o.type = ObstacleType.O; break;
           case (1) : o.type = ObstacleType.I; break;
           case (2) : o.type = ObstacleType.U; break;
         }
       }
       for(int j = 0; j<controllerFlock.length; j++){
         if(theEvent.isFrom(controller.getController("o"+i+"_f"+j)))
           o.apply[j] = controller.get(Button.class,"o"+i+"_f"+j).isOn();
       }
       if(theEvent.isFrom(controller.getController("obs"+i+"_size"))) { o.r = controller.getController("obs"+i+"_size").getValue(); o.rSq = o.r*o.r; }
       if(theEvent.isFrom(controller.getController("obs"+i+"_angle"))) o.angle = radians(controller.getController("obs"+i+"_angle").getValue());
     }
     if(theEvent.isFrom(controller.get(DropdownList.class,"Select a obstacle"))){ 
       for (int i =0; i< obstacles.size(); i++){
          controller.getGroup("Obstacle "+i).hide();
        }
       controller.getGroup("Obstacle "+ int(controller.get(DropdownList.class,"Select a obstacle").getValue())).show();
     }
     
     //Brushes
     if(theEvent.isFrom(controller.get(Button.class,"show brushes"))){
       for (Brush b : brushes){  
         b.isVisible = controller.get(Button.class,"show brushes").isOn();
       }
       controller.get(Button.class,"show brushes").setLabel(
         controller.get(Button.class,"show brushes").isOn() ? "hide brushes" : "show brushes");
     }
       
    for (int j = 0; j<controllerFlock.length; j++){
      
     //Preset
      if(theEvent.isFrom(controllerFlock[j].getController("load"))){
        if(preset.size() > int(selectedPreset)){
          flocks[j].loadPreset(preset.get(int(selectedPreset)), controllerFlock[j]);
          println("Preset #"+int(selectedPreset)+" loaded");
        }
        else println("Preset can't be load : the arraylist of presets contains "+preset.size()+" preset and the selected one is the " + int(selectedPreset));
      }
      if(theEvent.isFrom(controllerFlock[j].getController("save"))){
        cp5.get(Textfield.class, "save as").show();
        cp5.get(Textfield.class, "save as").keepFocus(true);
        cp5TabToSave = j;
      }
      if(theEvent.isFrom(controllerFlock[j].get(DropdownList.class, "Select a preset"))){
        selectedPreset = controllerFlock[j].get(DropdownList.class, "Select a preset").getValue();
        println("Preset #" + int(selectedPreset) + " selected");
      }
      
      //RadioButton
      if(theEvent.isFrom(controllerFlock[j].get(RadioButton.class,"Visual"))){
        flocks[j].boidType = int(theEvent.getValue());
        flocks[j].boidTypeChange = true;
      }  
      if (theEvent.isFrom(controllerFlock[j].get(RadioButton.class,"Borders type"))) {
        flocks[j].borderType = int(theEvent.getValue());
      }
   
      
      //CheckBox
      if (theEvent.isFrom(controllerFlock[j].get(CheckBox.class,"forceToggle"))){
        for (int i = 0; i<controllerFlock[j].get(CheckBox.class,"forceToggle").getArrayValue().length; i++)
          flocks[j].forcesToggle[i] = controllerFlock[j].get(CheckBox.class,"forceToggle").getState(i);
      }  
      if (theEvent.isFrom(controllerFlock[j].get(CheckBox.class,"flockForceToggle"))){
        for (int i = 0; i<controllerFlock[j].get(CheckBox.class,"flockForceToggle").getArrayValue().length; i++)
          flocks[j].flockForcesToggle[i] = controllerFlock[j].get(CheckBox.class,"flockForceToggle").getState(i);
      }
      if (theEvent.isFrom(controllerFlock[j].get(CheckBox.class,"parametersToggle"))){
        for (int i = 0; i<controllerFlock[j].get(CheckBox.class,"parametersToggle").getArrayValue().length; i++){
          for (Boid b : flocks[j].boids)
            b.paramToggle[i] = controllerFlock[j].get(CheckBox.class,"parametersToggle").getState(i);
        }
      }      
    
     if(theEvent.isFrom(controllerFlock[j].getController("grid"))) flocks[j].grid = true;
     if(theEvent.isFrom(controllerFlock[j].getController("kill"))) flocks[j].killAll();
     if(theEvent.isFrom(controllerFlock[j].getController("N"))) flocks[j].NChange = true;
     if(theEvent.isFrom(controllerFlock[j].getController("symmetry"))) flocks[j].symmetry = (int)controllerFlock[j].getController("symmetry").getValue();
     if(theEvent.isFrom(controllerFlock[j].getController("N_links"))) flocks[j].maxConnections = (int)controllerFlock[j].getController("N_links").getValue();      
     if(theEvent.isFrom(controllerFlock[j].getController("d_max"))) { 
       flocks[j].d_max = (int)controllerFlock[j].getController("d_max").getValue(); 
       flocks[j].d_maxSq = flocks[j].d_max*flocks[j].d_max;
     }  
     
     for (Boid b : flocks[j].boids){
        if(theEvent.isFrom(controllerFlock[j].getController("maxforce")))     b.maxforce = controllerFlock[j].getController("maxforce").getValue();    
        if(theEvent.isFrom(controllerFlock[j].getController("maxspeed")))     b.maxspeed = controllerFlock[j].getController("maxspeed").getValue();    
        if(theEvent.isFrom(controllerFlock[j].getController("k_density")))     b.k_density = controllerFlock[j].getController("k_density").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("separation")))     b.separation = controllerFlock[j].getController("separation").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("alignment")))     b.alignment = controllerFlock[j].getController("alignment").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("cohesion")))     b.cohesion = controllerFlock[j].getController("cohesion").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("sep_r")))    { b.sep_r = controllerFlock[j].getController("sep_r").getValue(); b.sep_rSq = b.sep_r*b.sep_r; }
        if(theEvent.isFrom(controllerFlock[j].getController("ali_r")))   { b.ali_r = controllerFlock[j].getController("ali_r").getValue(); b.ali_rSq = b.ali_r*b.ali_r; }
        if(theEvent.isFrom(controllerFlock[j].getController("coh_r")))    { b.coh_r = controllerFlock[j].getController("coh_r").getValue(); b.coh_rSq = b.coh_r*b.coh_r; }
        if(theEvent.isFrom(controllerFlock[j].getController("gravity")) || theEvent.isFrom(controllerFlock[j].getController("gravity_Angle"))){
          float angle = radians(cf.controllerFlock[j].getController("gravity_Angle").getValue()+90);
          float mag = cf.controllerFlock[j].getController("gravity").getValue();
          b.g = new PVector(mag*cos(angle),mag*sin(angle));  
        }
        if(theEvent.isFrom(controllerFlock[j].getController("friction")))     b.friction = controllerFlock[j].getController("friction").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("noise")))        b.noise = controllerFlock[j].getController("noise").getValue(); 
        if(theEvent.isFrom(controllerFlock[j].getController("origin")))     b.origin = controllerFlock[j].getController("origin").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("trailLength")))     b.trailLength = (int)controllerFlock[j].getController("trailLength").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("alpha")))     b.alpha = (int)controllerFlock[j].getController("alpha").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("contrast")))     b.randomBrightness = random(-controllerFlock[j].getController("contrast").getValue(),controllerFlock[j].getController("contrast").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("red")))     b.randomRed = random(0,controllerFlock[j].getController("red").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("green")))     b.randomGreen = random(0,controllerFlock[j].getController("green").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("blue")))     b.randomBlue = random(0,controllerFlock[j].getController("blue").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("size")))     b.size = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("isolation"))) b.isolationIsActive = controllerFlock[j].get(Button.class, "isolation").isOn();
        if(theEvent.isFrom(controllerFlock[j].get(ColorWheel.class,"particleColor"))){
          b.red = controllerFlock[j].get(ColorWheel.class,"particleColor").r();
          b.green = controllerFlock[j].get(ColorWheel.class,"particleColor").g();
          b.blue = controllerFlock[j].get(ColorWheel.class,"particleColor").b();
        }
      }
    }
  }
}