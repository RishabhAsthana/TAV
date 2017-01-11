//  Refer to Nature of Code, it has this, plus a lot more fun (some advanced stuff, like neural networks, fractals, cellular automata, AI etc.

class Particle
{

  PVector location, velocity, acceleration, center, dir;
  float topspeed, damping, scale;
  int r, g, b;

  Particle(float x_, float y_, float topspeed_, float scale_)
  {
    location = new PVector(x_ + random(-50, 50), y_ + random(-50, 50));
    velocity = new PVector(random(-2, 2), random(-2, 2));
    center = new PVector(x_, y_);
    acceleration = new PVector(0, 0);
    topspeed = topspeed_;
    damping = 1;

    scale = scale_;
  }


  void update(float band)
  {
    PVector dir = PVector.sub(center, location); // This didn't exactly did what I was hoping it to do, but the results are far better than what I was trying to achieve.
    dir.normalize();
    dir.mult(band * scale);
    acceleration = dir;


    velocity.add(acceleration);
    velocity.limit(topspeed);
    velocity.mult(damping);
    location.add(velocity);
    acceleration.mult(0);
  }

  void display()
  {

    noStroke();
    ellipse(location.x, location.y, 12, 12);
    noFill();
    stroke(0);
  }


  void altRun(float band_, int r_, int g_, int b_)
  {
    update(band_);
    fill(r_, g_, b_, 100);
    //collisionSphere(radius);
    display();
  }


  void applyForce(PVector f)
  {
    PVector force = f.get();
    acceleration.add(force);
  }
}

