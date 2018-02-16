class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 controllerVisual;
  ControlP5 controllerEffect;
  ControlP5 controllerTool;
  ControlP5 controllerInput;
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
    
    controllerVisual = new ControlP5(this);
    controllerEffect = new ControlP5(this);
    controllerTool = new ControlP5(this);
    controllerInput = new ControlP5(this);
    controllerFlock = new ControlP5[N_FLOCK_MAX];   
    for (int j = 0; j<controllerFlock.length; j++){
      controllerFlock[j] = new ControlP5(this);
    } 
    
    gui();  
  }
  

  
  void draw() {
    background(100);
  }
  
  void keyPressed(){
    if(key == ' ')  isRecording = !isRecording;
    if(key == 's'){
      java.util.Date dNow = new java.util.Date( );
      java.text.SimpleDateFormat ft = new java.text.SimpleDateFormat ("yyyy_MM_dd_hhmmss_S");
      for (int i = 0; i< flocks.size(); i++)
        flocks.get(i).layer.save("Screenshot/"+this.getClass().getName()+"_"+ft.format(dNow)+  ".png");

      println("Screenshot Done.");
    }
  }
  
  void mouseWheel(MouseEvent event){
    if (controllerVisual.getTab("Tools").isActive()){
      int y = int(controllerTool.getGroup("acc").getPosition()[1]);
      int maxH = 400;
      if(y < 40 && y > -maxH)
        controllerTool.getGroup("acc").setPosition(controllerTool.getGroup("acc").getPosition()[0],y-20*event.getCount());
      else if (y == 40){
        if (event.getCount() > 0) controllerTool.getGroup("acc").setPosition(controllerTool.getGroup("acc").getPosition()[0],y-20*event.getCount());
      }
      else if (y == -maxH){
        if (event.getCount() < 0) controllerTool.getGroup("acc").setPosition(controllerTool.getGroup("acc").getPosition()[0],y-20*event.getCount());
      }
      else if (y < -maxH)
        controllerTool.getGroup("acc").setPosition(0,-maxH);
      else if (y > 40)
        controllerTool.getGroup("acc").setPosition(0,40);
    }
    for (int i = 0; i< controllerFlock.length; i++){  
      if (controllerVisual.get(RadioButton.class, "Flocks activation").getState(i)){
        int y = int(controllerFlock[i].getGroup("acc").getPosition()[1]);
        int maxH = 1100;
        if(y < 140 && y > -maxH)
          controllerFlock[i].getGroup("acc").setPosition(controllerFlock[i].getGroup("acc").getPosition()[0],y-20*event.getCount());
        else if (y == 140){
          if (event.getCount() > 0) controllerFlock[i].getGroup("acc").setPosition(controllerFlock[i].getGroup("acc").getPosition()[0],y-20*event.getCount());
        }
        else if (y == -maxH){
          if (event.getCount() < 0) controllerFlock[i].getGroup("acc").setPosition(controllerFlock[i].getGroup("acc").getPosition()[0],y-20*event.getCount());
        }
        else if (y < -maxH)
          controllerFlock[i].getGroup("acc").setPosition(0,-maxH);
        else if (y > 140)
          controllerFlock[i].getGroup("acc").setPosition(0,50);
        
        controllerVisual.getGroup("Flock manager").bringToFront();
      }
    }
    
    controllerVisual.getGroup("Tabs bar").bringToFront();
  }
  
  void addFlock(){
    if(flocks.size() < N_FLOCK_MAX){
      int i = flocks.size();
      Flock f = new Flock(i);
      flocks.add(f);
      
      String sendername = "Processing Spout "+i;
      senders.add(new Spout(parent));
      senders.get(senders.size()-1).createSender(sendername, OUTPUT_WIDTH, OUTPUT_HEIGHT);
    
      for (int index =0; index< flocks.size()-1; index++){
          controllerFlock[index].get(Accordion.class, "acc").hide();
      }
      controllerFlock[i].get(Accordion.class, "acc").show();
      
      controllerVisual.get(RadioButton.class,"Flocks activation").addItem("Visual "+i,i).activate(i);
    }
  }
  
  void addSource(){
    if(sources.size()<N_SRC_MAX){
      Source s = new Source(0.5*parent.width,0.5*parent.height, sources.size());
      sources.add(s);
      for (int i =0; i< sources.size()-1; i++){
        controllerTool.getGroup("Source "+i).hide();
      }
      int i = sources.size()-1;  
      controllerTool.getGroup("Source "+i).show();
      controllerTool.getGroup("Source "+i).open();
      controllerTool.get(CheckBox.class,"src_activation").addItem("S"+i,i).activate(i);
      controllerTool.get(DropdownList.class,"Select a source").addItem("Source "+i,i).setValue(i);
      controllerTool.getGroup("Sources").setSize(200,320);
      controllerTool.get(Accordion.class,"acc").updateItems();
    }
  }
    
  void addFlowfield(){
    if(flowfields.size()<8){
      FlowField ff = new FlowField(flowfields.size());
      flowfields.add(ff);
      for (int i =0; i< flowfields.size()-1; i++){
        controllerTool.getGroup("Flowfield "+i).hide();
      }
      int i = flowfields.size()-1;  
      controllerTool.get(Group.class,"Flowfield "+i).show();
      controllerTool.get(Group.class,"Flowfield "+i).open();
      controllerTool.get(CheckBox.class,"ff_activation").addItem("F"+i,i).activate(i);
      controllerTool.get(DropdownList.class,"Select a flowfield").addItem("Flowfield "+i,i).setValue(i);
      controllerTool.getGroup("Flowfields").setSize(200,320);
      controllerTool.get(Accordion.class,"acc").updateItems();
    }
 }
 
 void addSource(PVector pos){
    addSource();
    sources.get(sources.size()-1).position = pos;
 }
 
  void addMagnet(){
    if(magnets.size()<8){
      Magnet m = new Magnet(0.5*parent.width,0.5*parent.height, magnets.size());
      magnets.add(m);
      for (int i =0; i< magnets.size()-1; i++){
        controllerTool.getGroup("Magnet "+i).hide();
      }
      int i = magnets.size()-1;  
      controllerTool.getGroup("Magnet "+i).show();
      controllerTool.getGroup("Magnet "+i).open();
      controllerTool.get(CheckBox.class,"mag_activation").addItem("M"+i,i).activate(i);
      controllerTool.get(DropdownList.class,"Select a magnet").addItem("Magnet "+i,i).setValue(i);
      controllerTool.getGroup("Magnets").setSize(200,160);
      controllerTool.get(Accordion.class,"acc").updateItems();
    }
  }
    
  void addObstacle(){
    if(obstacles.size()<8){
      Obstacle m = new Obstacle(0.5*parent.width,0.5*parent.height, obstacles.size());
      obstacles.add(m);
      for (int i =0; i< obstacles.size()-1; i++){
        controllerTool.getGroup("Obstacle "+i).hide();
      }
      int i = obstacles.size()-1;  
      controllerTool.getGroup("Obstacle "+i).show();
      controllerTool.getGroup("Obstacle "+i).open();
      controllerTool.get(CheckBox.class,"obs_activation").addItem("O"+i,i).activate(i);
      controllerTool.get(DropdownList.class,"Select a obstacle").addItem("Obstacle "+i,i).setValue(i);
      controllerTool.getGroup("Obstacles").setSize(200,255);
      controllerTool.get(Accordion.class,"acc").updateItems();
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
   c.get(ColorWheel.class,"particleColor").setSaturation(1.0);
   c.getController("contrast").setValue(preset.getInt("randomBrightness"));
   c.getController("red").setValue(preset.getInt("randomRed"));
   c.getController("green").setValue(preset.getInt("randomGreen"));
   c.getController("blue").setValue(preset.getInt("randomBlue"));
   c.getController("size").setValue(preset.getFloat("size"));
   if(preset.getBoolean("connectionsDisplayed"))  c.get(Button.class,"show links").setOn();
   else  c.get(Button.class,"show links").setOff();   
   if(preset.getBoolean("particlesDisplayed"))  c.get(Button.class,"show particles").setOn();
   else  c.get(Button.class,"show particles").setOff();   
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
   c.getController("spin_speed").setValue(preset.getFloat("spin_speed"));
   
  }
  
  //---------------------------------------------------------------------------------------------------------------------  
  //-------------------------------------------------------GUI-----------------------------------------------------------
  //---------------------------------------------------------------------------------------------------------------------  
  
  public void gui() {
    
    int l = int(0.1*GUI_WIDTH);
    
    CallbackListener toFront = new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        theEvent.getController().bringToFront();
        ((DropdownList)theEvent.getController()).open();
        ((DropdownList)theEvent.getController()).setOpen(true);
      }
    };

    CallbackListener close = new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        ((DropdownList)theEvent.getController()).setOpen(false);
        ((DropdownList)theEvent.getController()).close();
      }
    };
    
    ControlFont font = new ControlFont(pfont,12);
    
    //----------------------------------------------INPUT TAB----------------------------------------------------------------------
      controllerInput.setFont(font);
      
      Group g_audio = controllerInput.addGroup("Audio Input").setPosition(0,30).setBackgroundColor(color(0,64)).setBackgroundHeight(70).setWidth(GUI_WIDTH).setBarHeight(20);
      g_audio.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerInput.addButton("testAudio").setPosition(10,10).setLabel("Test").setSize(35,35).setSwitch(true).setOff().moveTo(g_audio).getCaptionLabel().toUpperCase(false);
   //   controllerInput.addSlider("Magnet").setLabel("Magnet").setPosition(10,50).setSize(110,20).setRange(0.1,10).moveTo(g_audio).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).toUpperCase(false).setPaddingX(0); 
      
      Group g_midi = controllerInput.addGroup("Midi Input").setPosition(0,30).setBackgroundColor(color(0,64)).setBackgroundHeight(70).setWidth(GUI_WIDTH).setBarHeight(20);  
      g_midi.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      
      Group g_osc = controllerInput.addGroup("Osc Input").setPosition(0,30).setBackgroundColor(color(0,64)).setBackgroundHeight(70).setWidth(GUI_WIDTH).setBarHeight(20);  
      g_osc.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);

      controllerInput.addAccordion("acc").setPosition(0,40).setWidth(this.w).setMinItemHeight(20).setCollapseMode(Accordion.MULTI)
                .addItem(g_audio).addItem(g_midi).addItem(g_osc);   


//--------------------------------------------VISUAL TAB----------------------------------------------------------------------
    
    controllerVisual.setFont(font);
    
    Group g_visual = controllerVisual.addGroup("Flock manager").setBackgroundColor(color(100)).setPosition(0,39).setSize(GUI_WIDTH,100).setBarHeight(0);
    g_visual.getCaptionLabel().hide();
    controllerVisual.addBang("add flock").setLabel("+").setPosition(l,l).setSize(3*l,3*l).moveTo(g_visual).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerVisual.addRadioButton("Flocks activation").setPosition(5*l,l).setSize(l,l).moveTo(g_visual);                
    
    //--------------------------------------------FLOCK TAB----------------------------------------------------------------------
    
    for (int j = 0; j<controllerFlock.length; j++){
      controllerFlock[j].setFont(font);

      //Group 1 : Model
      Group g_model = controllerFlock[j].addGroup("Model").setBackgroundColor(color(0, 64)).setBackgroundHeight(480).setBarHeight(20);
      g_model.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addSlider("Particles").setPosition(115,20).setSize(50,130).setNumberOfTickMarks(11).snapToTickMarks(false).setRange(0,3000).moveTo(g_model);
      controllerFlock[j].getController("Particles").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).toUpperCase(false).setPaddingX(0);
      controllerFlock[j].addBang("kill").setPosition(115,150).setSize(50,20).moveTo(g_model);
      controllerFlock[j].getController("kill").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
      
      controllerFlock[j].addSlider("X").setPosition(25,20).setSize(60,10).setNumberOfTickMarks(31).showTickMarks(false).setRange(0,30).moveTo(g_model);
      controllerFlock[j].getController("X").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
      controllerFlock[j].getController("X").getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(2);
      controllerFlock[j].addSlider("Y").setPosition(15,30).setSize(10,60).setNumberOfTickMarks(31).showTickMarks(false).setSliderMode(Slider.FIX).setRange(0,30).moveTo(g_model);
      controllerFlock[j].getController("Y").getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);
      controllerFlock[j].getController("Y").getValueLabel().align(ControlP5.CENTER, ControlP5.TOP).setPaddingX(10);
      controllerFlock[j].addBang("grid").setPosition(30,35).setSize(55,55).moveTo(g_model);
      controllerFlock[j].getController("grid").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

      controllerFlock[j].addSlider("k_density").setPosition(30,60).setRange(0.1,2).setValue(1.0).hide().moveTo(g_model);
      controllerFlock[j].addButton("  Draw"+"\n"+"particles").setPosition(15,115).setSize(70,30).setSwitch(true).setOff().moveTo(g_model).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP).toUpperCase(false); 
      controllerFlock[j].addBang("Erase").setPosition(15,150).setSize(70,30).moveTo(g_model).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addToggle("Immortal").setPosition(70,200).setSize(50,20).setMode(ControlP5.SWITCH).setValue(false).moveTo(g_model).getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(10).toUpperCase(false);
      controllerFlock[j].addSlider("lifespan").setPosition(15,230).setSize(100,15).setLabel("Lifespan").setRange(0,1000).setNumberOfTickMarks(21).showTickMarks(false).setValue(SRC_LIFESPAN).moveTo(g_model).hide().getCaptionLabel().toUpperCase(false);      
      
      Group g_square = controllerFlock[j].addGroup("Square").setPosition(10,300).setBarHeight(15).setBackgroundColor(color(0, 30)).setSize(180,58).moveTo(g_model);  
      g_square.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addBang("square").setLabel("+").setPosition(10,10).setSize(30,30).moveTo(g_square).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addSlider("square_size").setLabel("Size").setPosition(50,10).setSize(100, 15).setRange(0,100).setValue(33).setNumberOfTickMarks(13).showTickMarks(false).moveTo(g_square).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("square_N").setLabel("N").setPosition(50,30).setSize(100, 15).setRange(0,10000).setValue(2000).setNumberOfTickMarks(11).showTickMarks(false).moveTo(g_square).getCaptionLabel().toUpperCase(false);
      
      Group g_borders = controllerFlock[j].addGroup("Borders").setPosition(10,400).setBarHeight(15).setBackgroundColor(color(0, 30)).setSize(180,58).moveTo(g_model);  
      g_borders.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addRadioButton("Borders type").setPosition(5,5).setSize(15,15).moveTo(g_borders)
                .addItem("[ - ]  Bouncing Window", WALLS).toUpperCase(false)
                .addItem(">-> Looping Window", LOOPS).toUpperCase(false)
                .addItem("<-> No walls", NOBORDER).toUpperCase(false).activate(2); 
       
      //Group 5 : Forces
      Group g_forces = controllerFlock[j].addGroup("Forces").setBackgroundColor(color(0, 64)).setBackgroundHeight(300).setBarHeight(20); 
      g_forces.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addCheckBox("forceToggle").setPosition(10,10).setSize(14,14).setItemsPerRow(1).moveTo(g_forces)
                .addItem("f",0).addItem("g",1).addItem("n",2).addItem("o",3).addItem(" ",4).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("friction").setLabel("Friction").setPosition(25,10).setSize(100,14).setRange(0.01,4).moveTo(g_forces).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("gravity").setLabel("Gravity").setPosition(25,25).setSize(100,14).setRange(0.01,4).setValue(1.0).moveTo(g_forces).getCaptionLabel().toUpperCase(false);  
      controllerFlock[j].addSlider("noise").setLabel("Noise").setPosition(25,40).setSize(100,14).setRange(0.01,10).setValue(1.0).moveTo(g_forces).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("origin").setLabel("Origin").setPosition(25,55).setSize(100,14).setRange(0.01,4).setValue(1.0).moveTo(g_forces).getCaptionLabel().toUpperCase(false);
      Group f = controllerFlock[j].addGroup("Flock").setBackgroundColor(color(0, 64)).setBarHeight(14).setBackgroundHeight(95).setPosition(25,85).setWidth(100).moveTo(g_forces);  
      f.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addCheckBox("flockForceToggle").setPosition(0,0).setSize(14,14).setItemsPerRow(1).moveTo(f)
                .addItem("s",0).addItem("a",1).addItem("c",2);
      controllerFlock[j].addSlider("separation").setLabel("Separation").setPosition(15,0).setSize(85,14).setRange(0.01,4).setValue(1.5).moveTo(f).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("alignment").setLabel("Alignment").setPosition(15,15).setSize(85,14).setRange(0.01,4).setValue(1.0).moveTo(f).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("cohesion").setLabel("Cohesion").setPosition(15,30).setSize(85,14).setRange(0.01,4).setValue(1.0).moveTo(f).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("sep_r").setPosition(15,50).setSize(85,14).setRange(1,1000).setValue(50).moveTo(f).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("ali_r").setPosition(15,65).setSize(85,14).setRange(1,1000).setValue(100).moveTo(f).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("coh_r").setPosition(15,80).setSize(85,14).setRange(1,1000).setValue(100).moveTo(f).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addKnob("gravity_Angle").setLabel("Gravity angle").setPosition(70,195).setResolution(100).setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(20).moveTo(g_forces).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).toUpperCase(false);
      
      controllerFlock[j].addCheckBox("parametersToggle").setPosition(10,250).setSize(14,14).setItemsPerRow(1).addItem("F",0).addItem("S",1).moveTo(g_forces);                       
      controllerFlock[j].addSlider("maxforce").setLabel("Max force").setPosition(25,250).setSize(100,14).setRange(0.01,1).setValue(1).moveTo(g_forces).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("maxspeed").setLabel("Max speed").setPosition(25,265).setSize(100,14).setRange(0.01,20).setValue(20).moveTo(g_forces).getCaptionLabel().toUpperCase(false);
      
       
      //Group 6 : Particle design
      Group g_particle = controllerFlock[j].addGroup("Particles design").setBackgroundColor(color(0, 64)).setBackgroundHeight(150+290).setBarHeight(20);
      g_particle.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addButton("show particles").setPosition(10,10).setLabel("Show").setSize(35,35).setSwitch(true).setOff().moveTo(g_particle).getCaptionLabel().toUpperCase(false);
      
      Group g_radius = controllerFlock[j].addGroup("Radius").setPosition(10,105).setBackgroundColor(color(0, 64)).setBackgroundHeight(290).setBarHeight(15).setWidth(180).moveTo(g_particle);
      g_radius.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addButton("random r").setLabel("Random"+'\n'+'\t'+ "r").setPosition(10,10).setSize(45,45).setSwitch(true).setOff().moveTo(g_radius).getCaptionLabel().toUpperCase(false); 
      controllerFlock[j].addSlider("size").setPosition(62,25).setSize(110,20).setRange(1,100).setNumberOfTickMarks(50).showTickMarks(false).setValue(2.0).moveTo(g_radius).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).toUpperCase(false).setPaddingX(0); 
      controllerFlock[j].addRadioButton("boidMove").setPosition(10,65).setSize(15,15).setItemsPerRow(1).setSpacingRow(40).moveTo(g_radius)
                                                   .addItem("Constant",CONSTANT).addItem("Cloudy",CLOUDY).addItem("Shiny",SHINY).addItem("Noisy",NOISY).activate(CONSTANT); 
      controllerFlock[j].addSlider("cloud_spreading").setPosition(20,140).setSize(90,15).setLabel("Spreading").setRange(10,500).moveTo(g_radius).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("shining_frequence").setPosition(20,195).setSize(90,15).setLabel("Frequence").setRange(0.01,1).moveTo(g_radius).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("shining_phase").setPosition(20,211).setSize(90,15).setLabel("Phase").setNumberOfTickMarks(17).showTickMarks(false).setRange(0,16).moveTo(g_radius).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("strength_noise").setPosition(20,250).setSize(90,15).setLabel("Noise").setRange(0.01,0.1).moveTo(g_radius).getCaptionLabel().toUpperCase(false);
      
      Group g_density = controllerFlock[j].addGroup("Density").setPosition(10,395).setBackgroundColor(color(0, 64)).setBarHeight(15).setBackgroundHeight(30).setWidth(180).moveTo(g_particle).hide();
      g_density.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);

      Group g_spin = controllerFlock[j].addGroup("Spin").setPosition(10,455).setBackgroundColor(color(0, 64)).setBarHeight(15).setBackgroundHeight(70).setWidth(180).moveTo(g_particle);
      g_spin.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addButton("is Spinning").setLabel("Spin").setPosition(10,10).setSize(45,45).setSwitch(true).setOff().moveTo(g_spin).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false); 
      controllerFlock[j].addSlider("spin_speed").setLabel("Spin speed").setPosition(62,25).setSize(110,20).setRange(0.1,10).setValue(1.0).moveTo(g_spin).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).toUpperCase(false).setPaddingX(0); 
      
      DropdownList ddl_type = controllerFlock[j].addDropdownList("Select a type").setPosition(52,20).setSize(135,100).setBarHeight(20).setItemHeight(20).setHeight(20*20).close().onClick(toFront).onLeave(close).moveTo(g_particle); 
      ddl_type.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      ddl_type.addItem("Circle", CIRCLE).addItem("Triangle", TRIANGLE).addItem("Letter", LETTER).addItem("Pixel", PIXEL).addItem("Leaf", LEAF).addItem("Bird", BIRD);
      for (int i = 0; i< texture_list.fichiers.length;i++){
        String name_i = texture_list.fichiers[i].substring("/texture/texture_XX_".length(),texture_list.fichiers[i].length()-".png".length());
        ddl_type.addItem(name_i,i+6);
      }
      controllerFlock[j].addAccordion("acc_partdesign").setPosition(10,65).setWidth(180).setMinItemHeight(20).setCollapseMode(Accordion.MULTI)
                .addItem(g_radius).addItem(g_density).addItem(g_spin).open(0).moveTo(g_particle);
      
      //Group Connections design        
      Group connex = controllerFlock[j].addGroup("Connections design").setBackgroundColor(color(0, 64)).setBackgroundHeight(100).setBarHeight(20);
      connex.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addButton("show links").setPosition(10,10).setLabel("Show").setSize(35,35).setSwitch(true).setOff().moveTo(connex).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("N_links").setPosition(35,55).setSize(100,15).setRange(1,30).setNumberOfTickMarks(30).showTickMarks(false).setValue(3).moveTo(connex).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("d_max").setPosition(35,75).setSize(100,15).setRange(1,100).setValue(50.0).moveTo(connex).getCaptionLabel().toUpperCase(false); 
      controllerFlock[j].addDropdownList("Select a connection").setPosition(52,20).setSize(135,100).onClick(toFront).onLeave(close).setBarHeight(20).setItemHeight(20).close()
                .addItem("Mesh", 0).addItem("Queue", 1).moveTo(connex).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      
      //Group 7 Effects
      Group g_effect = controllerFlock[j].addGroup("Effects").setBackgroundColor(color(0, 64)).setBackgroundHeight(130).setBarHeight(20);  
      g_effect.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addSlider("symmetry").setLabel("Symmetry").setPosition(20,30).setSize(160,30).setNumberOfTickMarks(12).setRange(1,12).setValue(1).moveTo(g_effect).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).toUpperCase(false);
      controllerFlock[j].addButton("Painting mode").setPosition(20,90).setSize(160,30).setSwitch(true).setOff().moveTo(g_effect).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false); 

      Group trail = controllerFlock[j].addGroup("Mark").setPosition(10,60).setBackgroundColor(color(0, 30)).setBarHeight(15).setBackgroundHeight(70).setWidth(180).moveTo(g_effect).hide();
      trail.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addSlider("trailLength").setLabel("Length").setPosition(10,10).setSize(100,15).setRange(0,1000).setValue(0).moveTo(trail).getCaptionLabel().toUpperCase(false); 
     
      //Group 8 : Colors
      Group g_color = controllerFlock[j].addGroup("Colors").setBackgroundColor(color(0, 64)).setBackgroundHeight(285).setBarHeight(20);  
      g_color.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addColorWheel("particleColor",10,10,180).setLabel("Particle color").moveTo(g_color).getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM).setColor(color(0,0,1)).toUpperCase(false);
      controllerFlock[j].get(ColorWheel.class, "particleColor").setSaturation(1.0);
      controllerFlock[j].addSlider("contrast").setPosition(10,200).setSize(100,14).setRange(0,200).setValue(0).moveTo(g_color).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("red").setPosition(10,215).setSize(100,14).setRange(0,200).setValue(0).moveTo(g_color).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("green").setPosition(10,230).setSize(100,14).setRange(0,200).setValue(0).moveTo(g_color).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("blue").setPosition(10,245).setSize(100,14).setRange(0,200).setValue(0).moveTo(g_color).getCaptionLabel().toUpperCase(false);
      controllerFlock[j].addSlider("alpha").setPosition(10,260).setSize(100,14).setRange(0,255).setValue(100).moveTo(g_color).getCaptionLabel().toUpperCase(false); 
     
      //Preset
      Group g_preset = controllerFlock[j].addGroup("Preset").setPosition(0,30).setBackgroundColor(color(0,64)).setBackgroundHeight(70).setWidth(200).setBarHeight(20);  
      g_preset.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addBang("load").setLabel("Load").setPosition(130,25).setSize(25,25).moveTo(g_preset).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerFlock[j].addBang("save").setLabel("Save").setPosition(165,25).setSize(25,25).moveTo(g_preset).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      DropdownList ddl = controllerFlock[j].addDropdownList("Select a preset").setPosition(10,25).setSize(110,200).setBarHeight(25).onClick(toFront).onLeave(close).setItemHeight(20).close().moveTo(g_preset);
      ddl.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      for (int i = 0; i< presetNames.fichiers.length;i++){
        String name_i = presetNames.fichiers[i].substring("/preset/".length(),presetNames.fichiers[i].length()-".json".length());
        ddl.addItem(name_i,i);
      }
      ddl.setHeight(20*9);
        
      //Accordion
      controllerFlock[j].addAccordion("acc").setPosition(0,140).setWidth(this.w).setMinItemHeight(20).setCollapseMode(Accordion.MULTI).moveTo(controllerVisual.getTab("default")).hide()
                .addItem(g_model).addItem(g_particle).addItem(connex).addItem(g_color).addItem(g_forces).addItem(g_effect).addItem(g_preset).open(0,6);     
      g_radius.addListener(new GroupListener(g_radius,g_particle,controllerFlock[j].get(Accordion.class, "acc")));
      g_density.addListener(new GroupListener(g_density,g_particle,controllerFlock[j].get(Accordion.class, "acc")));
      g_spin.addListener(new GroupListener(g_spin,g_particle,controllerFlock[j].get(Accordion.class, "acc")));
      //ddl_type.addListener(new DdlListener(ddl_type,g6,controllerFlock[j].get(Accordion.class, "acc")));
      
  }
  
  
     //--------------------------------------------MOTION TAB----------------------------------------------------------------------
    
    controllerTool.setFont(font); 
    
    Group c0 = controllerTool.addGroup("Display").setBackgroundColor(color(0, 64)).setBackgroundHeight(350).setBarHeight(20);
    c0.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addDropdownList("Select a blendMode").setPosition(25,10).setSize(150,100).setBarHeight(30).setItemHeight(20).setHeight(20*11).close().moveTo(c0).onClick(toFront).onLeave(close)
              .addItem("Blend",0).addItem("Add",1).addItem("Subtract",2).addItem("Darkest",3).addItem("Lightest",4).addItem("Difference",5).addItem("Exclusion",6).addItem("Multiply",7).addItem("Screen",8).addItem("Replace",9)
              .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM).toUpperCase(false);
    controllerTool.addButton("Show tools").setPosition(25,50).setSize(150,30).setSwitch(true).setOff().moveTo(c0).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addBang("Black&White").setLabel("Black & White").setPosition(25,90).setSize(150,30).moveTo(c0).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addColorWheel("backgroundColor",10,140,180).setLabel("Background Color").setRGB(color(BACKGROUND_COLOR)).plugTo(parent, "backgroundColor").moveTo(c0).getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM).toUpperCase(false);
    controllerTool.get(ColorWheel.class, "backgroundColor").setSaturation(1.0);
    
    //Group 1 : Sources  
    Group c1 = controllerTool.addGroup("Sources").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(20);
    c1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addBang("add src").setLabel("+").setPosition(10,10).setSize(20,20).moveTo(c1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addCheckBox("src_activation").setPosition(10,35).setSize(15,15).setItemsPerRow(4).setSpacingColumn(30).moveTo(c1);
    for(int i = 0; i<8; i++){
      Group s1 = controllerTool.addGroup("Source "+i).setPosition(10,90).setSize(180,220).setBackgroundColor(color(0, 64)).setBarHeight(15).hide().close().moveTo(c1);
      s1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      for (int j = 0; j<controllerFlock.length; j++) 
        controllerTool.addButton("s"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("Flock "+j).setSwitch(true).setOn().moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false); 
      controllerTool.addSlider("src"+i+"_size").setPosition(5,35).setSize(100,15).setLabel("Size").setRange(50/parent.width,100).setValue(0.).moveTo(s1).getCaptionLabel().toUpperCase(false);  
      controllerTool.addSlider("src"+i+"_outflow").setPosition(5,55).setSize(100,15).setLabel("Outflow").setRange(1,20).setNumberOfTickMarks(20).showTickMarks(false).setValue(SRC_OUTFLOW).moveTo(s1).getCaptionLabel().toUpperCase(false);
      controllerTool.addSlider("src"+i+"_strength").setPosition(5,75).setSize(100,15).setLabel("Strength").setRange(0,10).setValue(0).moveTo(s1).getCaptionLabel().toUpperCase(false); 
      controllerTool.addSlider("lifespan " + i).setPosition(5,95).setSize(100,15).setLabel("Lifespan").setRange(0,1000).setNumberOfTickMarks(21).showTickMarks(false).setValue(SRC_LIFESPAN).moveTo(s1).getCaptionLabel().toUpperCase(false);
      RadioButton rb_src_type = controllerTool.addRadioButton("src"+i+"_type").setPosition(15,120).setSize(20,20).setItemsPerRow(1).setSpacingColumn(25).addItem("0 ("+i+")", 0).addItem("| ("+i+")", 1).activate(0).moveTo(s1);
      rb_src_type.getItem(0).setLabel("O");
      rb_src_type.getItem(1).setLabel("/");      
      controllerTool.addButton("randomStrength " + i).setPosition(5,170).setSize(60,20).setLabel("Random V").setSwitch(true).setOn().moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerTool.addButton("randomAngle " + i).setPosition(70,170).setSize(60,20).setLabel("Random A").setSwitch(true).setOn().moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      controllerTool.addButton("ejected " + i).setPosition(5,195).setSize(105,20).setLabel("Ejected").setSwitch(true).moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);      
      controllerTool.addKnob("src"+i+"_angle").setPosition(60,120).setResolution(100).setRange(0,360).setLabel("Angle").setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(20).moveTo(s1).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE,ControlP5.CENTER).toUpperCase(false);
    }
    DropdownList ddl_source = controllerTool.addDropdownList("Select a source").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(20).close().onClick(toFront).onLeave(close).moveTo(c1);
    ddl_source.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER + 10).toUpperCase(false);
      
    //Group 2 : Magnets  
    Group c2 = controllerTool.addGroup("Magnets").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(20);  
    c2.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addBang("add mag").setLabel("+").setPosition(10,10).setSize(20,20).moveTo(c2).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addCheckBox("mag_activation").setPosition(10,35).setSize(15,15).setItemsPerRow(4).setSpacingColumn(30).moveTo(c2);
    for(int i = 0; i<8; i++){
      Group s1 = controllerTool.addGroup("Magnet "+i).setPosition(10,90).setBackgroundColor(color(0, 64)).setSize(180,60).setBarHeight(15).hide().close().moveTo(c2);
      s1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      for (int j = 0; j<controllerFlock.length; j++) 
        controllerTool.addButton("m"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("Flock "+j).setSwitch(true).setOn().moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false); 
      controllerTool.addSlider("mag"+i+"_strength").setPosition(5,35).setSize(100,15).setLabel("Strength").setRange(-100,100).setNumberOfTickMarks(21).showTickMarks(false).setValue(0).moveTo(s1).getCaptionLabel().toUpperCase(false);
    }
    controllerTool.addDropdownList("Select a magnet").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(20).close().onClick(toFront).onLeave(close).moveTo(c2)
                                                 .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);

    //Group 3 : Obstacles  
    Group c3 = controllerTool.addGroup("Obstacles").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(20);
    c3.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addBang("add obs").setLabel("+").setPosition(10,10).setSize(20,20).moveTo(c3).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addCheckBox("obs_activation").setPosition(10,35).setSize(15,15).setItemsPerRow(4).setSpacingColumn(30).moveTo(c3);
    for(int i = 0; i<8; i++){
      Group s1 = controllerTool.addGroup("Obstacle "+i).setPosition(10,90).setBackgroundColor(color(0, 64)).setSize(180,155).hide().close().setBarHeight(15).moveTo(c3);
      s1.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      for (int j = 0; j<controllerFlock.length; j++) 
        controllerTool.addButton("o"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("Flock "+j).setSwitch(true).setOn().moveTo(s1).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false); 
      controllerTool.addSlider("obs"+i+"_size").setPosition(5,35).setSize(100,15).setLabel("Size").setRange(1,150).setValue(20).moveTo(s1).getCaptionLabel().toUpperCase(false);
      controllerTool.addSlider("obs"+i+"_e").setPosition(5,55).setSize(100,15).setLabel("Thickness").setRange(1,100).setValue(50).moveTo(s1).getCaptionLabel().toUpperCase(false);
      controllerTool.addKnob("obs"+i+"_angle").setPosition(60,85).setResolution(100).setLabel("Angle").setRange(0,360).setAngleRange(2*PI).setStartAngle(0.5*PI).setRadius(25).moveTo(s1).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).toUpperCase(false);
      RadioButton rb_obs_type = controllerTool.addRadioButton("obs"+i+"_type").setPosition(5,90).setSize(20,20).setItemsPerRow(1).setSpacingColumn(30).addItem("O ("+i+")", 0).addItem("/ ("+i+")", 1).addItem("U ("+i+")", 2).activate(0).moveTo(s1);
      rb_obs_type.getItem(0).setLabel("O");
      rb_obs_type.getItem(1).setLabel("/");
      rb_obs_type.getItem(2).setLabel("U");
  }
    controllerTool.addDropdownList("Select a obstacle").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(20).close().onClick(toFront).onLeave(close).moveTo(c3)
                                                   .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    
    //Group 2 : Flowfield  
    Group ff = controllerTool.addGroup("Flowfields").setBackgroundColor(color(0, 64)).setBackgroundHeight(50).setBarHeight(20);
    ff.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addBang("add ff").setLabel("+").setPosition(10,10).setSize(20,20).moveTo(ff).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
    controllerTool.addCheckBox("ff_activation").setPosition(10,35).setSize(15,15).setItemsPerRow(4).setSpacingColumn(30).moveTo(ff);
    
    for(int i = 0; i<8; i++){    
      Group ff_i = controllerTool.addGroup("Flowfield "+i).setPosition(10,90).setBackgroundColor(color(0, 64)).setSize(180,155).hide().close().setBarHeight(15).moveTo(ff);
      ff_i.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
      for (int j = 0; j<controllerFlock.length; j++) 
        controllerTool.addButton("f"+i+"_f"+j).setPosition(5+57*j,10).setSize(55,20).setLabel("Flock "+j).setSwitch(true).setOn().moveTo(ff_i).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);      
      controllerTool.addSlider("ff_strength"+i).setPosition(5,60).setSize(100,15).setLabel("Strength").setRange(0.01,10).setValue(5.0).moveTo(ff_i).getCaptionLabel().toUpperCase(false);  
      controllerTool.addSlider("ff_speed"+i).setPosition(5,80).setSize(100,15).setLabel("Speed").setRange(0,10).setValue(1.0).moveTo(ff_i).getCaptionLabel().toUpperCase(false);  
      controllerTool.addSlider("ff_noise"+i).setPosition(5,100).setSize(100,15).setLabel("Noise").setRange(0,0.2).setValue(0.05).moveTo(ff_i).getCaptionLabel().toUpperCase(false);  
      controllerTool.addSlider("ff_resolution"+i).setPosition(5,120).setSize(100,15).setLabel("Resolution").setRange(1,100).setValue(10).moveTo(ff_i).getCaptionLabel().toUpperCase(false);  
    }
    controllerTool.addDropdownList("Select a flowfield").setPosition(40,10).setSize(150,100).setBarHeight(20).setItemHeight(20).close().onClick(toFront).onLeave(close).moveTo(ff)
                                                   .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).toUpperCase(false);
        
    
     //Accordion
    controllerTool.addAccordion("acc").setPosition(0,40).setWidth(this.w).setMinItemHeight(50).setCollapseMode(Accordion.MULTI)
        .addItem(c0).addItem(c1).addItem(c2).addItem(c3).addItem(ff).open(0);
    for(int i = 0; i< 8; i++){
      controllerTool.get(Group.class,"Source "+i).addListener(
        new GroupListener(controllerTool.get(Group.class,"Source "+i),c1,controllerTool.get(Accordion.class,"acc")));
      controllerTool.get(Group.class,"Magnet "+i).addListener(
        new GroupListener(controllerTool.get(Group.class,"Magnet "+i),c2,controllerTool.get(Accordion.class,"acc")));
      controllerTool.get(Group.class,"Obstacle "+i).addListener(
        new GroupListener(controllerTool.get(Group.class,"Obstacle "+i),c3,controllerTool.get(Accordion.class,"acc")));
      controllerTool.get(Group.class,"Flowfield "+i).addListener(
        new GroupListener(controllerTool.get(Group.class,"Flowfield "+i),ff,controllerTool.get(Accordion.class,"acc")));
    }
    
  //--------------------------------------------EFFECT TAB----------------------------------------------------------------------
    
    //controllerEffect.setFont(font); 
    
    //     //Accordion
    //controllerEffect.addAccordion("acc").setPosition(0,40).setWidth(this.w).setMinItemHeight(50).setCollapseMode(Accordion.MULTI)
    //    .addItem(c0).addItem(c1).addItem(c2).addItem(c3).addItem(ff).open(0);   
               

  
                 
  //----------------------------------------------TABS PANNEL--------------------------------------------------------------------
    
    
    controllerVisual.getTab("default").bringToFront().setWidth(46).setHeight(39).setLabel("Visuals").getCaptionLabel().align(ControlP5.CENTER-10, ControlP5.CENTER).toUpperCase(false);
    
    controllerVisual.addTab("Tools").bringToFront().setWidth(46).setHeight(39).setLabel("Tools").getCaptionLabel().align(ControlP5.CENTER-10, ControlP5.CENTER).toUpperCase(false);
    controllerTool.get(Accordion.class, "acc").moveTo(controllerVisual.getTab("Tools"));

    controllerVisual.addTab("Effect").bringToFront().setWidth(46).setHeight(39).hide().getCaptionLabel().align(ControlP5.CENTER-10, ControlP5.CENTER).toUpperCase(false);
   // controllerEffect.get(Accordion.class, "acc").moveTo(controllerVisual.getTab("Effect"));

    controllerVisual.addTab("Input").bringToFront().setWidth(46).setHeight(39).getCaptionLabel().align(ControlP5.CENTER-10, ControlP5.CENTER).toUpperCase(false);
    controllerInput.get(Accordion.class, "acc").moveTo(controllerVisual.getTab("Input"));

    controllerVisual.getTab("default").setActive(true);
    controllerVisual.getTab("Tools").setActive(false);
    controllerVisual.getTab("Input").setActive(false);
        
    controllerVisual.addGroup("Tabs bar").setSize(GUI_WIDTH, 40).setBackgroundColor(color(100)).getCaptionLabel().hide();

  }
  
  //---------------------------------------------------------------------------------------------------------------------  
  //--------------------------------------------------ControlEvent-------------------------------------------------------
  //---------------------------------------------------------------------------------------------------------------------
  
  

  void controlEvent(ControlEvent theEvent) { 
    
    //=====================================VISUAL TAB=====================================================

    if(theEvent.isFrom(controllerVisual.getController("add flock"))){ 
       addFlock();
     }
     if (theEvent.isFrom(controllerVisual.get(RadioButton.class,"Flocks activation"))){
       
       for (int j =0; j< flocks.size(); j++){
         if(controllerVisual.get(RadioButton.class,"Flocks activation").getState(j))
            controllerFlock[j].get(Accordion.class, "acc").show();
         else
            controllerFlock[j].get(Accordion.class, "acc").hide();
      }
     }
     
    //=====================================INPUT TAB=====================================================
    
    if(theEvent.isFrom(controllerInput.get(Button.class,"testAudio"))){ 
       if(controllerInput.get(Button.class,"testAudio").isOn()){
         audioInput.enableMonitoring();
       }
       else audioInput.disableMonitoring();
       
     if(theEvent.isFrom(controllerInput.getController("Magnet"))){
       magnets.get(0).strength = controllerInput.getController("Magnet").getValue();
     }
    }
    
    //=====================================TOOLS TAB=====================================================
    
    //Display
    if(theEvent.isFrom(controllerTool.getController("Black&White"))){
      if(controllerTool.get(ColorWheel.class,"backgroundColor").getRGB() != -16777216){
        for (int j = 0; j<controllerFlock.length; j++)
          controllerFlock[j].get(ColorWheel.class,"particleColor").setRGB(color(255));
        controllerTool.get(ColorWheel.class,"backgroundColor").setRGB(color(0));
      }
      else{
        for (int j = 0; j<controllerFlock.length; j++)
          controllerFlock[j].get(ColorWheel.class,"particleColor").setRGB(color(0));
        controllerTool.get(ColorWheel.class,"backgroundColor").setRGB(color(255));
      }
    }
    if(theEvent.isFrom(controllerTool.getController("Select a blendMode"))){
        blendMode = int(controllerTool.get(DropdownList.class,"Select a blendMode").getValue());
    }     
   //Brushes
   if(theEvent.isFrom(controllerTool.get(Button.class,"Show tools"))){
     for (Brush b : brushes){  
       b.isVisible = controllerTool.get(Button.class,"Show tools").isOn(); }
     for (FlowField ff : flowfields){  
       ff.isVisible = controllerTool.get(Button.class,"Show tools").isOn(); }
     controllerTool.get(Button.class,"Show tools").setLabel(
       controllerTool.get(Button.class,"Show tools").isOn() ? "Hide tools" : "Show tools");
   }
     
    //Sources
     if(theEvent.isFrom(controllerTool.getController("add src"))){ 
       addSource();
     }
     if (theEvent.isFrom(controllerTool.get(CheckBox.class,"src_activation"))){
        for (int i = 0; i<controllerTool.get(CheckBox.class,"src_activation").getArrayValue().length; i++)
          sources.get(i).isActivated = controllerTool.get(CheckBox.class,"src_activation").getState(i);
     }
     for (int i = 0; i<sources.size(); i++){
        if(theEvent.isFrom(controllerTool.get(RadioButton.class,"src"+i+"_type")))
          sources.get(i).type = int(theEvent.getValue());
      }
     for (int i = 0; i< sources.size(); i++){
       Source s = sources.get(i);
      for(int j = 0; j<controllerFlock.length; j++){
         if(theEvent.isFrom(controllerTool.getController("s"+i+"_f"+j)))
           s.apply[j] = controllerTool.get(Button.class,"s"+i+"_f"+j).isOn();
       }
       if(theEvent.isFrom(controllerTool.getController("src"+i+"_size"))) { 
         s.r = map(controllerTool.getController("src"+i+"_size").getValue(),0,100,0,parent.width); 
         s.rSq = s.r*s.r; 
       }
       if(theEvent.isFrom(controllerTool.getController("src"+i+"_outflow"))){ 
         s.outflow = (int)controllerTool.getController("src"+i+"_outflow").getValue();
       }
       if(theEvent.isFrom(controllerTool.getController("lifespan "+ i))){
         s.lifespan = (int)controllerTool.getController("lifespan "+ i).getValue();
       }
       if(theEvent.isFrom(controllerTool.getController("src"+i+"_angle")) || theEvent.isFrom(controllerTool.getController("src"+i+"_strength"))){
         s.angle = radians(controllerTool.getController("src"+i+"_angle").getValue());
         s.strength = controllerTool.getController("src"+i+"_strength").getValue();
         s.vel = new PVector(s.strength*cos(s.angle+HALF_PI),s.strength*sin(s.angle+HALF_PI));
       }
       if(theEvent.isFrom(controllerTool.get(Button.class,"randomStrength "+ i))){
         s.randomStrength = controllerTool.get(Button.class,"randomStrength " + i).isOn();
       }
       if(theEvent.isFrom(controllerTool.get(Button.class,"randomAngle "+ i))){
         s.randomAngle = controllerTool.get(Button.class,"randomAngle " + i).isOn();
       }
       if(theEvent.isFrom(controllerTool.get(Button.class,"ejected "+ i))){
         s.ejected = controllerTool.get(Button.class,"ejected " + i).isOn();
       }
     }
     if(theEvent.isFrom(controllerTool.get(DropdownList.class,"Select a source"))){ 
       for (int i =0; i< sources.size(); i++){
          controllerTool.getGroup("Source "+i).hide();
          controllerTool.getGroup("Source "+i).close();
        }
       controllerTool.getGroup("Source "+ int(theEvent.getValue())).show();
       controllerTool.getGroup("Source "+ int(theEvent.getValue())).open();
     }
     
     //Magnets
     if(theEvent.isFrom(controllerTool.getController("add mag"))) {
       addMagnet();    
     }
     if (theEvent.isFrom(controllerTool.get(CheckBox.class,"mag_activation"))){
       for (int i = 0; i<controllerTool.get(CheckBox.class,"mag_activation").getArrayValue().length; i++)
         magnets.get(i).isActivated = controllerTool.get(CheckBox.class,"mag_activation").getState(i);
     }
     for (int i = 0; i<magnets.size(); i++){
       if(theEvent.isFrom(controllerTool.getController("mag"+i+"_strength"))) 
         magnets.get(i).strength = controllerTool.getController("mag"+i+"_strength").getValue();
       for(int j = 0; j<controllerFlock.length; j++){
         if(theEvent.isFrom(controllerTool.getController("m"+i+"_f"+j)))
            magnets.get(i).apply[j] = controllerTool.get(Button.class,"m"+i+"_f"+j).isOn();
       }
     }
     if(theEvent.isFrom(controllerTool.get(DropdownList.class,"Select a magnet"))){ 
       for (int i =0; i< magnets.size(); i++){
          controllerTool.getGroup("Magnet "+i).hide();
        }
       controllerTool.getGroup("Magnet "+ int(controllerTool.get(DropdownList.class,"Select a magnet").getValue())).show();
     }
     
     //Obstacles
     if(theEvent.isFrom(controllerTool.getController("add obs"))){
       addObstacle();
     }
     if (theEvent.isFrom(controllerTool.get(CheckBox.class,"obs_activation"))){
       for (int i = 0; i<controllerTool.get(CheckBox.class,"obs_activation").getArrayValue().length; i++)
         obstacles.get(i).isActivated = controllerTool.get(CheckBox.class,"obs_activation").getState(i);
     }
     for (int i = 0; i<obstacles.size(); i++){
       Obstacle o = obstacles.get(i);
       if(theEvent.isFrom(controllerTool.get(RadioButton.class,"obs"+i+"_type")))
         o.type = int(theEvent.getValue());

       for(int j = 0; j<controllerFlock.length; j++){
         if(theEvent.isFrom(controllerTool.getController("o"+i+"_f"+j)))
           o.apply[j] = controllerTool.get(Button.class,"o"+i+"_f"+j).isOn();
       }
       if(theEvent.isFrom(controllerTool.getController("obs"+i+"_size"))) { 
         o.r = map(controllerTool.getController("obs"+i+"_size").getValue(),0,100,0,0.5*parent.width); 
         o.rSq = o.r*o.r; 
         o.e = map(controllerTool.getController("obs"+i+"_e").getValue(),0,100,0,o.r);
     }
       if(theEvent.isFrom(controllerTool.getController("obs"+i+"_angle"))) o.angle = radians(controllerTool.getController("obs"+i+"_angle").getValue());
       if(theEvent.isFrom(controllerTool.getController("obs"+i+"_e"))) o.e = map(controllerTool.getController("obs"+i+"_e").getValue(),0,100,0,o.r);
     }
     if(theEvent.isFrom(controllerTool.get(DropdownList.class,"Select a obstacle"))){ 
       for (int i =0; i< obstacles.size(); i++){
          controllerTool.getGroup("Obstacle "+i).hide();
        }
       controllerTool.getGroup("Obstacle "+ int(controllerTool.get(DropdownList.class,"Select a obstacle").getValue())).show();
     }
     
    //Flowfield
    if(theEvent.isFrom(controllerTool.getController("add ff"))){
       addFlowfield();
     }
     if (theEvent.isFrom(controllerTool.get(CheckBox.class,"ff_activation"))){
       for (int i = 0; i<controllerTool.get(CheckBox.class,"ff_activation").getArrayValue().length; i++)
         flowfields.get(i).isActivated = controllerTool.get(CheckBox.class,"ff_activation").getState(i);
     }
     for (int i = 0; i<flowfields.size(); i++){
       FlowField ff = flowfields.get(i);
       for(int j = 0; j<controllerFlock.length; j++){
         if(theEvent.isFrom(controllerTool.getController("f"+i+"_f"+j)))
           ff.apply[j] = controllerTool.get(Button.class,"f"+i+"_f"+j).isOn();
       }
       if(theEvent.isFrom(controllerTool.getController("ff_strength"+i)))
          ff.strength = controllerTool.getController("ff_strength"+i).getValue();
       if(theEvent.isFrom(controllerTool.getController("ff_speed"+i)))
         ff.speed = controllerTool.getController("ff_speed"+i).getValue();
       if(theEvent.isFrom(controllerTool.getController("ff_resolution"+i))){
         ff.isActivated = false;
         ff.updateRes(int(controllerTool.getController("ff_resolution"+i).getValue()));
       }
       if(theEvent.isFrom(controllerTool.getController("ff_noise"+i)))
         ff.noise = controllerTool.getController("ff_noise"+i).getValue();
    }
    if(theEvent.isFrom(controllerTool.get(DropdownList.class,"Select a flowfield"))){ 
       for (int i =0; i< flowfields.size(); i++){
          controllerTool.getGroup("Flowfield "+i).hide();
        }
       controllerTool.getGroup("Flowfield "+ int(controllerTool.get(DropdownList.class,"Select a flowfield").getValue())).show();
     }    
     
     

 
     //=====================================FLOCK TAB=====================================================
          
    for (int j = 0; j<flocks.size(); j++){
     
     //== FLOCK PARAMETERS ==
     //Preset
      if(theEvent.isFrom(controllerFlock[j].getController("load"))){
        if(preset.size() > int(selectedPreset)){
          flocks.get(j).loadPreset(preset.get(int(selectedPreset)), controllerFlock[j]);
          println("Preset #"+int(selectedPreset)+" loaded");
        }
        else println("Preset can't be load : the arraylist of presets contains "+preset.size()+" preset and the selected one is the " + int(selectedPreset));
      }
      if(theEvent.isFrom(controllerFlock[j].getController("save"))){
        cp5.get(Textfield.class, "save as").show();
        cp5.get(Textfield.class, "save as").keepFocus(true);
        cp5TabToSave = j;
        parent.focusGained();
      }
      if(theEvent.isFrom(controllerFlock[j].get(DropdownList.class, "Select a preset"))){
        selectedPreset = controllerFlock[j].get(DropdownList.class, "Select a preset").getValue();
        println("Preset #" + int(selectedPreset) + " selected");
      }
      
      //Generative parameters
      if(theEvent.isFrom(controllerFlock[j].getController("grid"))) flocks.get(j).grid = true;
      if(theEvent.isFrom(controllerFlock[j].getController("square"))) flocks.get(j).square = true;
      if(theEvent.isFrom(controllerFlock[j].getController("kill"))) flocks.get(j).killAll();
      if(theEvent.isFrom(controllerFlock[j].get(Toggle.class, "Immortal"))){
        for(Boid b : flocks.get(j).boids)  b.mortal = cf.controllerFlock[j].get(Toggle.class, "Immortal").getState();
        if (controllerFlock[j].get(Toggle.class, "Immortal").getState()) controllerFlock[j].getController("lifespan").show();
        else controllerFlock[j].getController("lifespan").hide();
      }
      if(theEvent.isFrom(controllerFlock[j].getController("Particles"))) flocks.get(j).NChange = true;
      if (theEvent.isFrom(controllerFlock[j].get(RadioButton.class,"Borders type")))  flocks.get(j).borderType = int(theEvent.getValue());
      if(theEvent.isFrom(controllerFlock[j].get(Button.class, "Painting mode"))){  
        flocks.get(j).drawMode = controllerFlock[j].get(Button.class,"Painting mode").isOn();
          controllerFlock[j].get(Button.class,"Painting mode").setLabel(
           controllerFlock[j].get(Button.class,"Painting mode").isOn() ? "Erase" : "Painting mode");
      }
      
      //Forces toggles
      if (theEvent.isFrom(controllerFlock[j].get(CheckBox.class,"forceToggle"))){
        for (int i = 0; i<controllerFlock[j].get(CheckBox.class,"forceToggle").getArrayValue().length; i++)
          flocks.get(j).forcesToggle[i] = controllerFlock[j].get(CheckBox.class,"forceToggle").getState(i);
      }  
      if (theEvent.isFrom(controllerFlock[j].get(CheckBox.class,"flockForceToggle"))){
        for (int i = 0; i<controllerFlock[j].get(CheckBox.class,"flockForceToggle").getArrayValue().length; i++)
          flocks.get(j).flockForcesToggle[i] = controllerFlock[j].get(CheckBox.class,"flockForceToggle").getState(i);
      }
      if (theEvent.isFrom(controllerFlock[j].get(CheckBox.class,"parametersToggle"))){
        for (int i = 0; i<controllerFlock[j].get(CheckBox.class,"parametersToggle").getArrayValue().length; i++){
          for (Boid b : flocks.get(j).boids)
            b.paramToggle[i] = controllerFlock[j].get(CheckBox.class,"parametersToggle").getState(i);
        }
      }      
      
      //Particle design
      if(theEvent.isFrom(controllerFlock[j].get(Button.class,"show particles"))){
        flocks.get(j).particlesDisplayed = controllerFlock[j].get(Button.class,"show particles").isOn();
        controllerFlock[j].get(Button.class,"show particles").setLabel(
           controllerFlock[j].get(Button.class,"show particles").isOn() ? "Hide" : "Show");
      }
      if(theEvent.isFrom(controllerFlock[j].get(DropdownList.class,"Select a type"))){
        switch (int(controllerFlock[j].get(DropdownList.class, "Select a type").getValue())){
          case 3 : 
          case 5 : 
          break;
          default : 
          flocks.get(j).boidType = int(controllerFlock[j].get(DropdownList.class, "Select a type").getValue());
          flocks.get(j).boidTypeChange = true;
          break;
        }

      }
      
      //Connections design
      if(theEvent.isFrom(controllerFlock[j].get(Button.class,"show links"))){
        flocks.get(j).connectionsDisplayed = controllerFlock[j].get(Button.class,"show links").isOn();
        controllerFlock[j].get(Button.class,"show links").setLabel(
           controllerFlock[j].get(Button.class,"show links").isOn() ? "Hide" : "Show");
      }
      if(theEvent.isFrom(controllerFlock[j].get(DropdownList.class,"Select a connection"))){
        flocks.get(j).connectionsType = int(controllerFlock[j].get(DropdownList.class,"Select a connection").getValue());
      }
      if(theEvent.isFrom(controllerFlock[j].getController("N_links"))) 
        flocks.get(j).maxConnections = (int)controllerFlock[j].getController("N_links").getValue();      
      if(theEvent.isFrom(controllerFlock[j].getController("d_max"))) { 
        flocks.get(j).d_max = (int)map(controllerFlock[j].getController("d_max").getValue(),0,100, 0, OUTPUT_WIDTH); 
        flocks.get(j).d_maxSq = flocks.get(j).d_max*flocks.get(j).d_max;
      }      
      //Symmetry
      if(theEvent.isFrom(controllerFlock[j].getController("symmetry"))) 
        flocks.get(j).symmetry = (int)controllerFlock[j].getController("symmetry").getValue();
      
      
     //== BOIDS PARAMETERS ==    
     for (Boid b : flocks.get(j).boids){
       
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
        if(theEvent.isFrom(controllerFlock[j].getController("spin_speed")))     b.spinSpeed = theEvent.getController().getValue();        
        if(theEvent.isFrom(controllerFlock[j].getController("random r")))     b.random_r = controllerFlock[j].get(Button.class,"random r").getBooleanValue();
        if(theEvent.isFrom(controllerFlock[j].getController("size")))     b.size = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].get(RadioButton.class,"boidMove"))) b.boidMove = int(controllerFlock[j].get(RadioButton.class,"boidMove").getValue());
        if(theEvent.isFrom(controllerFlock[j].getController("cloud_spreading")))     b.cloud_spreading = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("shining_frequence")))     b.shining_frequence = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("shining_phase")))     b.shining_phase = theEvent.getController().getValue();
        if(theEvent.isFrom(controllerFlock[j].getController("strength_noise")))     b.strength_noise = theEvent.getController().getValue();
        //if(theEvent.isFrom(controllerFlock[j].getController("trailLength")))     b.trailLength = (int)controllerFlock[j].getController("trailLength").getValue();

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


class GroupListener implements ControlListener{
  Group listeningGroup;
  Group modifiedGroup;
  Accordion acc;
  
  
  GroupListener(Group g1, Group g2, Accordion a){
    this.listeningGroup = g1;
    modifiedGroup = g2;
    acc = a;
  }
  
  public void controlEvent(ControlEvent theEvent){
    if (listeningGroup.isOpen()){
      modifiedGroup.setBackgroundHeight(modifiedGroup.getBackgroundHeight()+listeningGroup.getBackgroundHeight());
      acc.updateItems();
    }
    else{
      modifiedGroup.setBackgroundHeight(modifiedGroup.getBackgroundHeight()-listeningGroup.getBackgroundHeight());
      acc.updateItems();
    }
  }
}

class DdlListener implements ControlListener{
  DropdownList listeningDdl;
  Group modifiedGroup;
  Accordion acc;
  
  
  DdlListener(DropdownList ddl, Group g2, Accordion a){
    this.listeningDdl = ddl;
    modifiedGroup = g2;
    acc = a;
  }
  
  public void controlEvent(ControlEvent theEvent){
    if (listeningDdl.isOpen()){
      modifiedGroup.setBackgroundHeight(modifiedGroup.getBackgroundHeight()+listeningDdl.getHeight());
      acc.updateItems();
    }
    else{
      modifiedGroup.setBackgroundHeight(modifiedGroup.getBackgroundHeight()-listeningDdl.getHeight());
      acc.updateItems();
    }
  }
}