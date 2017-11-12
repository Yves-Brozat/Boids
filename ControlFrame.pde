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
        if(y <= 20 && y >= -800)
          controllerFlock[i].getGroup("acc").setPosition(controllerFlock[i].getGroup("acc").getPosition()[0],y-20*event.getCount());
        else if (y > 20)
          controllerFlock[i].getGroup("acc").setPosition(0,20);
        else if (y < -800)
          controllerFlock[i].getGroup("acc").setPosition(0,-800);
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
      controller.getGroup("Sources").setSize(200,320);
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
   c.getController("cloud_spreading").setValue(preset.getFloat("cloud_spreading"));
   c.getController("shining_frequence").setValue(preset.getFloat("shining_frequence"));
   c.getController("shining_phase").setValue(preset.getFloat("shining_phase"));
   c.getController("strength_noise").setValue(preset.getFloat("strength_noise"));
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
   if(preset.getBoolean("connectionsDisplayed"))  c.get(Button.class,"show links").setOn();
   else  c.get(Button.class,"show links").setOff();    
   if(preset.getBoolean("random_r"))  c.get(Button.class,"random r").setOn();
   else  c.get(Button.class,"random r").setOff(); 
   c.get(DropdownList.class,"Select a type").setValue(preset.getInt("boidType"));
   c.get(DropdownList.class,"Select a connection").setValue(preset.getInt("connectionsType"));
   c.get(RadioButton.class,"Borders type").activate(preset.getInt("borderType"));
   c.get(RadioButton.class,"boidMove").activate(preset.getInt("boidMove")); 
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
   if(preset.getBoolean("is Spinning"))  c.get(Button.class,"is Spinning").setOn();
   else  c.get(Button.class,"is Spinning").setOff();    
   
  }
  
  //---------------------------------------------------------------------------------------------------------------------  
  //-------------------------------------------------------GUI-----------------------------------------------------------
  //---------------------------------------------------------------------------------------------------------------------  
  
  public void gui() {
    
    CallbackListener toFront = new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        theEvent.getController().bringToFront();
        ((DropdownList)theEvent.getController()).open();
      }
    };

    CallbackListener close = new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        ((DropdownList)theEvent.getController()).close();
      }
    };
    
    ControlFont font = new ControlFont(pfont,12);

    controller = new ControlP5(this);
    controller.setFont(font);
    controllerFlock = new ControlP5[3];
    for (int j = 0; j<controllerFlock.length; j++){
      controllerFlock[j] = new ControlP5(this);
      controllerFlock[j].setFont(font);
    } 
    
    
    Group c0 = controller.addGroup("Colors").setBackgroundColor(color(0, 64)).setBackgroundHeight(280).setBarHeight(20);
    c0.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controller.addColorWheel("backgroundColor",10,10,180).setLabel("Background Color").setRGB(color(0)).plugTo(parent, "backgroundColor").moveTo(c0).getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM).toUpperCase(false);
    controller.addBang("Black&White").setLabel("Black & White").setPosition(10,210).setSize(85,20).moveTo(c0).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controller.addButton("Show brushes").setPosition(105,210).setSize(85,20).setSwitch(true).setOff().moveTo(c0).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controller.addDropdownList("Select a blendMode").setPosition(25,250).setSize(150,100).setBarHeight(20).setItemHeight(15).close().moveTo(c0).onEnter(toFront).onLeave(close)
              .addItem("blend",0).addItem("add",1).addItem("subtract",2).addItem("darkest",3).addItem("lightest",4).addItem("difference",5).addItem("exclusion",6).addItem("multiply",7).addItem("screen",8).addItem("replace",9)
              .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    //Group 1 : Sources  
    Group c1 = controller.addGroup("Sources").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(20);
    c1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controller.addBang("add src").setLabel("+").setPosition(10,10).setSize(20,20).moveTo(c1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controller.addCheckBox("src_activation").setPosition(10,35).setSize(15,15).setItemsPerRow(4).setSpacingColumn(30).moveTo(c1);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Source "+i).setPosition(10,90).setSize(180,220).setBackgroundColor(color(0, 64)).setBarHeight(15).hide().moveTo(c1);
      s1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      for (int j = 0; j<controllerFlock.length; j++) 
        controller.addButton("s"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("Flock "+j).setSwitch(true).setOff().moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false); 
      controller.addSlider("src"+i+"_size").setPosition(5,35).setSize(100,15).setLabel("Size").setRange(1,600).setValue(20).moveTo(s1).getCaptionLabel().toUpperCase(false);  
      controller.addSlider("src"+i+"_outflow").setPosition(5,55).setSize(100,15).setLabel("Outflow").setRange(1,20).setNumberOfTickMarks(20).showTickMarks(false).setValue(3).moveTo(s1).getCaptionLabel().toUpperCase(false);
      controller.addSlider("src"+i+"_strength").setPosition(5,75).setSize(100,15).setLabel("Strength").setRange(0,10).setValue(1).moveTo(s1).getCaptionLabel().toUpperCase(false); 
      controller.addSlider("lifespan " + i).setPosition(5,95).setSize(100,15).setLabel("Lifespan").setRange(0,1000).setNumberOfTickMarks(21).showTickMarks(false).setValue(100).moveTo(s1).getCaptionLabel().toUpperCase(false);
      RadioButton rb_src_type = controller.addRadioButton("src"+i+"_type").setPosition(15,120).setSize(20,20).setItemsPerRow(1).setSpacingColumn(25).addItem("0 ("+i+")", 0).addItem("| ("+i+")", 1).activate(0).moveTo(s1);
      rb_src_type.getItem(0).setLabel("O");
      rb_src_type.getItem(1).setLabel("/");      
      controller.addButton("randomStrength " + i).setPosition(5,170).setSize(60,20).setLabel("Random V").setSwitch(true).moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controller.addButton("randomAngle " + i).setPosition(70,170).setSize(60,20).setLabel("Random A").setSwitch(true).moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controller.addButton("ejected " + i).setPosition(5,195).setSize(105,20).setLabel("Ejected").setSwitch(true).moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);      
      controller.addKnob("src"+i+"_angle").setPosition(60,120).setResolution(100).setRange(0,360).setLabel("Angle").setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(20).moveTo(s1).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE,ControlP5.CENTER).toUpperCase(false);
    }
    DropdownList ddl_source = controller.addDropdownList("Select a source").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(15).close().onEnter(toFront).onLeave(close).moveTo(c1);
    ddl_source.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      
    //Group 2 : Magnets  
    Group c2 = controller.addGroup("Magnets").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(20);  
    c2.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controller.addBang("add mag").setLabel("+").setPosition(10,10).setSize(20,20).moveTo(c2).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controller.addCheckBox("mag_activation").setPosition(10,35).setSize(15,15).setItemsPerRow(4).setSpacingColumn(30).moveTo(c2);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Magnet "+i).setPosition(10,90).setBackgroundColor(color(0, 64)).setSize(180,60).setBarHeight(15).hide().moveTo(c2);
      s1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      for (int j = 0; j<controllerFlock.length; j++) 
        controller.addButton("m"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("Flock "+j).setSwitch(true).setOff().moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false); 
      controller.addSlider("mag"+i+"_strength").setPosition(5,35).setSize(100,15).setLabel("Strength").setRange(-100,100).setNumberOfTickMarks(21).showTickMarks(false).setValue(0).moveTo(s1).getCaptionLabel().toUpperCase(false);
    }
    controller.addDropdownList("Select a magnet").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(15).close().onEnter(toFront).onLeave(close).moveTo(c2)
                                                 .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);

    //Group 3 : Obstacles  
    Group c3 = controller.addGroup("Obstacles").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(20);
    c3.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controller.addBang("add obs").setLabel("+").setPosition(10,10).setSize(20,20).moveTo(c3).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);;
    controller.addCheckBox("obs_activation").setPosition(10,35).setSize(15,15).setItemsPerRow(4).setSpacingColumn(30).moveTo(c3);
    for(int i = 0; i<8; i++){
      Group s1 = controller.addGroup("Obstacle "+i).setPosition(10,90).setBackgroundColor(color(0, 64)).setSize(180,135).hide().setBarHeight(15).moveTo(c3);
      s1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      for (int j = 0; j<controllerFlock.length; j++) 
        controller.addButton("o"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("Flock "+j).setSwitch(true).setOff().moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false); 
      controller.addSlider("obs"+i+"_size").setPosition(5,35).setSize(100,15).setLabel("Size").setRange(5,100).setValue(0).moveTo(s1).getCaptionLabel().toUpperCase(false);
      controller.addKnob("obs"+i+"_angle").setPosition(60,70).setResolution(100).setLabel("Angle").setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(25).moveTo(s1).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).toUpperCase(false);
      RadioButton rb_obs_type = controller.addRadioButton("obs"+i+"_type").setPosition(5,60).setSize(20,20).setItemsPerRow(1).setSpacingColumn(30).addItem("O ("+i+")", 0).addItem("/ ("+i+")", 1).addItem("U ("+i+")", 2).activate(0).moveTo(s1);
      rb_obs_type.getItem(0).setLabel("O");
      rb_obs_type.getItem(1).setLabel("/");
      rb_obs_type.getItem(2).setLabel("U");
  }
    controller.addDropdownList("Select a obstacle").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(15).close().onEnter(toFront).onLeave(close).moveTo(c3)
                                                   .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    //Accordion
    controller.addAccordion("accDefault").setPosition(0,20).setWidth(this.w).setMinItemHeight(50).setCollapseMode(Accordion.MULTI)
                .addItem(c1).addItem(c2).addItem(c3).addItem(c0).open(3).bringToFront(c0);
                
    for (int j = 0; j<controllerFlock.length; j++){
      
      //Group 1 : Global parameters
      Group g1 = controllerFlock[j].addGroup("Global physical parameters").setBackgroundColor(color(0, 64)).setBackgroundHeight(190).setBarHeight(20);
      g1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
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
      
      //Group 2 : Flowfield      
      Group ff = controllerFlock[j].addGroup("Flowfield").setBackgroundColor(color(0, 64)).setBackgroundHeight(130).setBarHeight(20);
      ff.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addButton("show flowfield").setPosition(10,10).setLabel("show").setSize(35,35).setSwitch(true).setOff().moveTo(ff);      
      controllerFlock[j].addButton("toggle flowfield").setPosition(10,60).setLabel("").setSize(10,10).setSwitch(true).setOff().moveTo(ff);      
      controllerFlock[j].addSlider("ff_strength").setPosition(30,60).setLabel("strength").setRange(0.01,4).setValue(1.0).moveTo(ff);  
      controllerFlock[j].addSlider("ff_speed").setPosition(30,75).setLabel("speed").setRange(0,10).setValue(1.0).moveTo(ff);  
      
      //Group 5 : Forces
      Group g5 = controllerFlock[j].addGroup("Forces").setBackgroundColor(color(0, 64)).setBackgroundHeight(230).setBarHeight(20); 
      g5.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
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
      
       
      //Group 6 : Particle design
      Group g6 = controllerFlock[j].addGroup("Particles design").setBackgroundColor(color(0, 64)).setBackgroundHeight(530).setBarHeight(20);
      g6.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addButton("is Spinning").setPosition(20,40).setSize(45,45).setSwitch(true).setOff().moveTo(g6); 
      controllerFlock[j].addSlider("spin speed").setPosition(72,65).setSize(110,20).setRange(0.1,10).setValue(1.0).moveTo(g6).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0); 
      
      Group radius = controllerFlock[j].addGroup("Radius").setPosition(10,105).setBackgroundColor(color(0, 64)).setBackgroundHeight(290).setWidth(180).moveTo(g6);
      controllerFlock[j].addButton("random r").setPosition(10,10).setSize(45,45).setSwitch(true).setOff().moveTo(radius); 
      controllerFlock[j].addSlider("size").setPosition(62,25).setSize(110,20).setRange(0.1,500).setValue(2.0).moveTo(radius).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0); 
      controllerFlock[j].addRadioButton("boidMove").setPosition(10,65).setSize(15,15).setItemsPerRow(1).setSpacingRow(40).moveTo(radius)
                                                   .addItem("Constant",CONSTANT).addItem("Cloudy",CLOUDY).addItem("Shiny",SHINY).addItem("Noisy",NOISY).activate(CONSTANT); 
      controllerFlock[j].addSlider("cloud_spreading").setPosition(20,140).setSize(100,15).setLabel("spreading").setRange(10,500).moveTo(radius);
      controllerFlock[j].addSlider("shining_frequence").setPosition(20,195).setSize(100,10).setLabel("frequence").setRange(0.01,1).moveTo(radius);
      controllerFlock[j].addSlider("shining_phase").setPosition(20,210).setSize(100,10).setLabel("phase").setNumberOfTickMarks(17).setRange(0,16).moveTo(radius);
      controllerFlock[j].addSlider("strength_noise").setPosition(20,250).setSize(100,15).setLabel("noise").setRange(0.01,0.1).moveTo(radius);
      
      Group density = controllerFlock[j].addGroup("Density").setPosition(10,395).setBackgroundColor(color(0, 64)).setBackgroundHeight(30).setWidth(180).moveTo(g6);
     
      Group trail = controllerFlock[j].addGroup("Trail").setPosition(10,425).setBackgroundColor(color(0, 64)).setBackgroundHeight(60).setWidth(180).moveTo(g6);
      controllerFlock[j].addSlider("trailLength").setLabel("length").setPosition(10,10).setRange(0,1000).setValue(0).moveTo(trail); 
      
      controllerFlock[j].addDropdownList("Select a type").setPosition(10,10).setSize(180,100).setBarHeight(15).onEnter(toFront).onLeave(close).close()
                .addItem("Radial Gradiant 1", RADIAL_GRADIANT_1).addItem("Radial Gradiant 2", RADIAL_GRADIANT_2).addItem("Radial Gradiant 3", RADIAL_GRADIANT_3).addItem("Radial Gradiant 4", RADIAL_GRADIANT_4)
                .addItem("Spray", SPRAY).addItem("Polished", POLISHED).addItem("Pearl", PEARL).addItem("Glass", GLASS).addItem("Wave", WAVE).addItem("Hair", HAIR)
                .addItem("Circle", CIRCLE).addItem("Triangle", TRIANGLE).addItem("Letter", LETTER).addItem("Pixel", PIXEL)
                .addItem("Leaf", LEAF).addItem("Bird", BIRD).moveTo(g6);
      
      //Group Connections design        
      Group connex = controllerFlock[j].addGroup("Connections design").setBackgroundColor(color(0, 64)).setBackgroundHeight(100).setBarHeight(20);
      connex.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addButton("show links").setPosition(10,10).setLabel("show").setSize(35,35).setSwitch(true).setOff().moveTo(connex);
      controllerFlock[j].addSlider("N_links").setPosition(35,55).setSize(100,15).setRange(1,30).setNumberOfTickMarks(30).showTickMarks(false).setValue(3).moveTo(connex);
      controllerFlock[j].addSlider("d_max").setPosition(35,75).setSize(100,15).setRange(1,500).setValue(100).moveTo(connex); 
      controllerFlock[j].addDropdownList("Select a connection").setPosition(55,20).setSize(135,100).onEnter(toFront).onLeave(close).setBarHeight(15).close()
                .addItem("Mesh", 0).addItem("Queue", 1).moveTo(connex);
      
      //Group 7 Symmetry
      Group g7 = controllerFlock[j].addGroup("Symmetry").setBackgroundColor(color(0, 64)).setBackgroundHeight(60).setBarHeight(20);  
      g7.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addSlider("symmetry").setPosition(10,10).setSize(120,30).setNumberOfTickMarks(12).setRange(1,12).setValue(1).moveTo(g7);
      
      //Group 8 : Colors
      Group g8 = controllerFlock[j].addGroup("Colors").setBackgroundColor(color(0, 64)).setBackgroundHeight(280).setBarHeight(20);  
      g8.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addColorWheel("particleColor",10,10,180).setRGB(color(255)).moveTo(g8).setSaturation(100);           
      controllerFlock[j].addSlider("contrast").setPosition(10,220).setRange(0,200).setValue(0).moveTo(g8);
      controllerFlock[j].addSlider("red").setPosition(10,230).setRange(0,200).setValue(0).moveTo(g8);
      controllerFlock[j].addSlider("green").setPosition(10,240).setRange(0,200).setValue(0).moveTo(g8);
      controllerFlock[j].addSlider("blue").setPosition(10,250).setRange(0,200).setValue(0).moveTo(g8);
      controllerFlock[j].addSlider("alpha").setPosition(10,260).setRange(0,255).setValue(100).moveTo(g8); 
     
      //Preset
      Group g_preset = controllerFlock[j].addGroup("Preset").setPosition(0,30).setBackgroundColor(color(0,64)).setBackgroundHeight(70).setWidth(200).setBarHeight(20);  
      g_preset.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addBang("load").setPosition(130,25).setSize(20,20).moveTo(g_preset);
      controllerFlock[j].addBang("save").setPosition(160,25).setSize(20,20).moveTo(g_preset);
      DropdownList ddl = controllerFlock[j].addDropdownList("Select a preset").setPosition(10,25).setSize(110,100).setBarHeight(20).onEnter(toFront).onLeave(close).setItemHeight(15).close().moveTo(g_preset);
      for (int i = 0; i< presetNames.fichiers.length;i++)
        ddl.addItem(presetNames.fichiers[i],i);
        
      //Accordion
      controllerFlock[j].addAccordion("acc").setPosition(0,20).setWidth(this.w).setMinItemHeight(20).setCollapseMode(Accordion.MULTI)
                .addItem(g1).addItem(ff).addItem(g5).addItem(g6).addItem(connex).addItem(g7).addItem(g8).open(0,7).addItem(g_preset).bringToFront(g_preset);     
    }
    
    for (int j = 0; j<controllerFlock.length; j++){
      controller.addTab("Flock "+j);
      controllerFlock[j].get(Accordion.class, "acc").moveTo(controller.getTab("Flock "+j));
      controller.getTab("Flock "+j).getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER).toUpperCase(false);
    } 
    controller.getTab("default").setLabel("Tools").getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER).toUpperCase(false);

  }
  
  //---------------------------------------------------------------------------------------------------------------------  
  //--------------------------------------------------ControlEvent-------------------------------------------------------
  //---------------------------------------------------------------------------------------------------------------------
  
  void controlEvent(ControlEvent theEvent) { 

    //=====================================DEFAULT TAB=====================================================
    
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
    if(theEvent.isFrom(controller.getController("Select a blendMode"))){
      blendMode = int(controller.get(DropdownList.class,"Select a blendMode").getValue());
    }
    
    //Sources
     if(theEvent.isFrom(controller.getController("add src"))){ 
       addSource();
     }
     if (theEvent.isFrom(controller.get(CheckBox.class,"src_activation"))){
        for (int i = 0; i<controller.get(CheckBox.class,"src_activation").getArrayValue().length; i++)
          sources.get(i).isActivated = controller.get(CheckBox.class,"src_activation").getState(i);
     }
     for (int i = 0; i<sources.size(); i++){
        if(theEvent.isFrom(controller.get(RadioButton.class,"src"+i+"_type")))
          sources.get(i).type = int(theEvent.getValue());
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
       if(theEvent.isFrom(controller.get(Button.class,"randomStrength "+ i))){
         s.randomStrength = controller.get(Button.class,"randomStrength " + i).isOn();
       }
       if(theEvent.isFrom(controller.get(Button.class,"randomAngle "+ i))){
         s.randomAngle = controller.get(Button.class,"randomAngle " + i).isOn();
       }
       if(theEvent.isFrom(controller.get(Button.class,"ejected "+ i))){
         s.ejected = controller.get(Button.class,"ejected " + i).isOn();
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
       if(theEvent.isFrom(controller.get(RadioButton.class,"obs"+i+"_type")))
         o.type = int(theEvent.getValue());

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
     if(theEvent.isFrom(controller.get(Button.class,"Show brushes"))){
       for (Brush b : brushes){  
         b.isVisible = controller.get(Button.class,"Show brushes").isOn();
       }
       controller.get(Button.class,"Show brushes").setLabel(
         controller.get(Button.class,"Show brushes").isOn() ? "Hide brushes" : "Show brushes");
     }
 
     //=====================================FLOCK TAB=====================================================
          
    for (int j = 0; j<controllerFlock.length; j++){
     
     //== FLOCK PARAMETERS ==
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
      
      //Generative parameters
      if(theEvent.isFrom(controllerFlock[j].getController("grid"))) flocks[j].grid = true;
      if(theEvent.isFrom(controllerFlock[j].getController("kill"))) flocks[j].killAll();
      if(theEvent.isFrom(controllerFlock[j].getController("N"))) flocks[j].NChange = true;
      if (theEvent.isFrom(controllerFlock[j].get(RadioButton.class,"Borders type"))) {
        flocks[j].borderType = int(theEvent.getValue());
      }     
      
      //Flowfield
      if(theEvent.isFrom(controllerFlock[j].get(Button.class,"show flowfield"))){
        flocks[j].flowfield.isVisible = controllerFlock[j].get(Button.class,"show flowfield").isOn();
        controllerFlock[j].get(Button.class,"show flowfield").setLabel(
           controllerFlock[j].get(Button.class,"show flowfield").isOn() ? "hide" : "show");
      }      
      if(theEvent.isFrom(controllerFlock[j].get(Button.class,"toggle flowfield")))
        flocks[j].flowfield.isActivated = controllerFlock[j].get(Button.class,"toggle flowfield").isOn();
      if(theEvent.isFrom(controllerFlock[j].getController("ff_strength")))
        flocks[j].flowfield.strength = controllerFlock[j].getController("ff_strength").getValue();
      if(theEvent.isFrom(controllerFlock[j].getController("ff_speed")))
        flocks[j].flowfield.speed = controllerFlock[j].getController("ff_speed").getValue();
      
      //Forces toggles
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
      
      //Particle design
      if(theEvent.isFrom(controllerFlock[j].get(DropdownList.class,"Select a type"))){
        flocks[j].boidType = int(controllerFlock[j].get(DropdownList.class, "Select a type").getValue());
        flocks[j].boidTypeChange = true;
      }
      
      //Connections design
      if(theEvent.isFrom(controllerFlock[j].get(Button.class,"show links"))){
        flocks[j].connectionsDisplayed = controllerFlock[j].get(Button.class,"show links").isOn();
        controllerFlock[j].get(Button.class,"show links").setLabel(
           controllerFlock[j].get(Button.class,"show links").isOn() ? "hide" : "show");
      }
      if(theEvent.isFrom(controllerFlock[j].get(DropdownList.class,"Select a connection"))){
        flocks[j].connectionsType = int(controllerFlock[j].get(DropdownList.class,"Select a connection").getValue());
      }
      if(theEvent.isFrom(controllerFlock[j].getController("N_links"))) 
        flocks[j].maxConnections = (int)controllerFlock[j].getController("N_links").getValue();      
      if(theEvent.isFrom(controllerFlock[j].getController("d_max"))) { 
        flocks[j].d_max = (int)controllerFlock[j].getController("d_max").getValue(); 
        flocks[j].d_maxSq = flocks[j].d_max*flocks[j].d_max;
      }      
      //Symmetry
      if(theEvent.isFrom(controllerFlock[j].getController("symmetry"))) 
        flocks[j].symmetry = (int)controllerFlock[j].getController("symmetry").getValue();
     
     
     //== BOIDS PARAMETERS ==    
     for (Boid b : flocks[j].boids){
       
       //Forces
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
        if(theEvent.isFrom(controllerFlock[j].getController("origin")))       b.origin = controllerFlock[j].getController("origin").getValue();

       //Particles design 
        if(theEvent.isFrom(controllerFlock[j].getController("is Spinning")))     b.isSpinning = controllerFlock[j].get(Button.class,"is Spinning").getBooleanValue();
        if(theEvent.isFrom(controllerFlock[j].getController("spin speed")))     b.spinSpeed = theEvent.getController().getValue();        
        if(theEvent.isFrom(controllerFlock[j].getController("random r")))     b.random_r = controllerFlock[j].get(Button.class,"random r").getBooleanValue();
        if(theEvent.isFrom(controllerFlock[j].getController("size")))     b.size = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].get(RadioButton.class,"boidMove"))) b.boidMove = int(controllerFlock[j].get(RadioButton.class,"boidMove").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("cloud_spreading")))     b.cloud_spreading = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("shining_frequence")))     b.shining_frequence = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("shining_phase")))     b.shining_phase = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("strength_noise")))     b.strength_noise = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("trailLength")))     b.trailLength = (int)controllerFlock[j].getController("trailLength").getValue();

       //Colors 
        if(theEvent.isFrom(controllerFlock[j].getController("alpha")))     b.alpha = (int)controllerFlock[j].getController("alpha").getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("contrast")))     b.randomBrightness = random(-controllerFlock[j].getController("contrast").getValue(),controllerFlock[j].getController("contrast").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("red")))     b.randomRed = random(0,controllerFlock[j].getController("red").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("green")))     b.randomGreen = random(0,controllerFlock[j].getController("green").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("blue")))     b.randomBlue = random(0,controllerFlock[j].getController("blue").getValue());
        if(theEvent.isFrom(controllerFlock[j].get(ColorWheel.class,"particleColor"))){
          b.red = controllerFlock[j].get(ColorWheel.class,"particleColor").r();
          b.green = controllerFlock[j].get(ColorWheel.class,"particleColor").g();
          b.blue = controllerFlock[j].get(ColorWheel.class,"particleColor").b();
        }
      }
    }
  }
}