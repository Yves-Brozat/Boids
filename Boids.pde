Flock flock;
String[] alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
PVector missionPoint; 
float s = 1.0;
float a = 1.0;
float c = 1.0;
float m = 0.001;

int rayon = 100;


void setup() {
  fullScreen(P2D, SPAN);
  flock = new Flock();
  missionPoint = new PVector(width/2,height/2);
}

void draw() {
  background(0);
  flock.run();
  
  if (s>1.0) s/=10;
}

void keyPressed()
{
  if (key == 'a')
  {
    for (int i = 0; i < 10; i++) {
    flock.addBoid(new Boid(0,random(0,height)));   
    flock.addBoid(new Boid(width,random(0,height)));
    flock.addBoid(new Boid(random(0,height),0));
    flock.addBoid(new Boid(random(0,height),height));
  }
  }
}
// Add a new boid into the System
void mouseReleased() {
  m = 0.001;
  s=100;
  rayon = 100;
}

void mousePressed()
{
  m=1.0;
}

void mouseDragged()
{
  rayon ++;
  missionPoint.set(mouseX,mouseY);
}