class SpectrumString
{

  float Sscale = 1;

  void generateString(float x_, float y_, float rad_, float scale_, int c1, int c2, int c3)
  {
    if (Sscale < scale_)
      Sscale = scale_;

    pushMatrix();
    translate(x_, y_); 
    rotate(PI/2);
    scale(Sscale);
    beginShape();

    for (int i = 0; i < bsize; i++)
    {
      float x2 = (rad_ + specVal[i]*30)*cos(i*2*PI/bsize); //* Changing the 30 here gives bizarre results, so many pretty patterns, from simple physics 
      float y2 = (rad_ + specVal[i]*30)*sin(i*2*PI/bsize); //* Try playing with mouseX
      vertex(x2, y2);
      stroke(c1, c2, c3);
      point(x2, y2);
    }
    endShape();
    popMatrix();

    Sscale -= 0.1;
  }
}

