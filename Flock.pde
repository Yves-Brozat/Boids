class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

  void setSize(int n) {
    if (flock.boids.size() < n)
      flock.addBoid(new Boid(random(controllerSize,width),random(0,height)));
    else if (flock.boids.size() > n)
      flock.boids.remove(flock.boids.size()-1);
  }
}