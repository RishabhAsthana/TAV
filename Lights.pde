// Must modify this so it uses PShape, and its memory store thing..

class Light {

  float smoothScale;

  void createSpiral(float posX, float posY, float r, float scale_, float angle_, float red, float green, float blue, int alpha)
  {
    float theta = 0;
    pushMatrix();

    translate(posX, posY);
    if (scale_ > smoothScale)
      smoothScale = scale_;
    scale(smoothScale);
    rotate(angle_);
    fill(red*smoothScale, green*smoothScale, blue*smoothScale, alpha);
    for (float i = r/2; i > 0; i -= 0.12)
    {

      ellipse(i * cos(theta), i * sin(theta), 16, 16);
      theta += 0.08;
    } 

    noFill();
    stroke(red*smoothScale, green*smoothScale, blue*smoothScale);
    strokeWeight(8);
    ellipse(0, 0, r, r);
    noStroke();


    popMatrix();
    smoothScale -= 0.08;
  }
}

