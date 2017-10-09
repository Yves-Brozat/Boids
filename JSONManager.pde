class Presetter {
  
  JSONObject preset;
  Flock flock;
  
  Presetter(String name, Flock f){
    preset = loadJSONObject("data/"+ name +".json");
    flock = f;
  }
  
  void savePreset(String name){
  }
  
  
  void loadPreset(String name){
    preset = loadJSONObject("data/"+ name +".json");
  }
  
  void updateParameters(){
    updateParameters(flock);
    for (Boid b : flock.boids){
      updateParameters(b);
    }
  }
  
  void updateParameters(Flock f){
    f.boidType = preset.getInt("boidType");
    f.borderType = preset.getInt("borderType");
    f.forcesToggle = preset.getJSONArray("forcesToggle").getBooleanArray();
    f.flockForcesToggle = preset.getJSONArray("flockForcesToggle").getBooleanArray();
    f.symmetry = preset.getInt("symmetry");
    f.d_max = preset.getFloat("d_max");
    f.maxConnections = preset.getInt("maxConnections");
  }
  
  void updateParameters(Boid b){
    b.maxforce = preset.getFloat("maxforce");
    b.maxspeed = preset.getFloat("maxspeed");
    b.paramToggle = preset.getJSONArray("parametersToggle").getBooleanArray();
    b.friction = preset.getFloat("friction");
    b.noise = preset.getFloat("noise");
    b.origin = preset.getFloat("origin");
    b.separation = preset.getFloat("separation");
    b.alignment = preset.getFloat("alignment");
    b.cohesion = preset.getFloat("cohesion");
    b.sep_r = preset.getFloat("sep_r");
    b.ali_r = preset.getFloat("ali_r");
    b.coh_r = preset.getFloat("coh_r");
    b.trailLength = preset.getFloat("trailLength");
    b.g = vector(preset.getFloat("gravity"),preset.getFloat("gravity_angle"));
    b.alpha = preset.getFloat("alpha");
    b.red = preset.getInt("red");
    b.green = preset.getInt("green");
    b.blue = preset.getInt("blue");
    b.randomBrightness = preset.getInt("randomBrightness");
    b.randomRed = preset.getInt("randomRed");
    b.randomGreen = preset.getInt("randomGreen");
    b.randomBlue = preset.getInt("randomBlue");
    b.size = preset.getFloat("size");
    b.isolationIsActive = preset.getBoolean("isolationIsActive");
  }
  
  void updateControllerValues(ControlP5 c){
   c.getController("maxforce").setValue(preset.getFloat("maxforce"));
   c.getController("maxspeed").setValue(preset.getFloat("maxspeed"));
   c.get(CheckBox.class, "parametersToggle").setArrayValue(preset.getJSONArray("parametersToggle").getFloatArray());
   c.getController("friction").setValue(preset.getFloat("friction"));
   c.getController("origin").setValue(preset.getFloat("origin"));
   c.getController("separation").setValue(preset.getFloat("separation"));
   c.getController("alignment").setValue(preset.getFloat("alignment"));
   c.getController("cohesion").setValue(preset.getFloat("cohesion"));
   c.getController("sep_r").setValue(preset.getFloat("sep_r"));
   c.getController("ali_r").setValue(preset.getFloat("ali_r"));
   c.getController("coh_r").setValue(preset.getFloat("coh_r"));
   c.getController("trailLength").setValue(preset.getFloat("trailLength"));
   c.getController("gravity").setValue(preset.getFloat("gravity"));
   c.getController("gravity_angle").setValue(preset.getFloat("gravity_angle"));
   c.getController("alpha").setValue(preset.getFloat("alpha"));
   c.get(ColorWheel.class,"particleColor").setValue(color(preset.getInt("red"),preset.getInt("green"),preset.getInt("blue")));
   c.getController("contrast").setValue(preset.getInt("randomBrightness"));
   c.getController("red").setValue(preset.getInt("maxforce"));
   c.getController("green").setValue(preset.getInt("randomGreen"));
   c.getController("blue").setValue(preset.getInt("randomBlue"));
   c.getController("size").setValue(preset.getFloat("size"));
   c.get(Button.class, "isolation").setValue(preset.getFloat("isolationIsActive"));
   
   c.get(RadioButton.class,"Visual").activate(preset.getInt("boidType"));
   c.get(RadioButton.class,"Borders type").activate(preset.getInt("borderType"));
   c.get(CheckBox.class, "forceToggle").setArrayValue(preset.getJSONArray("forcesToggle").getFloatArray());
   c.get(CheckBox.class, "flockForceToggle").setArrayValue(preset.getJSONArray("flockForcesToggle").getFloatArray());
   c.getController("symmetry").setValue(preset.getInt("symmetry"));
   c.getController("d_max").setValue(preset.getFloat("d_max"));
   c.getController("N_links").setValue(preset.getFloat("maxConnections"));

  }
}