// Yes, the name is inspired by Iron Man. :D

class arcGenerator {

  float xLoc, yLoc, radius, thickness, startAngle, endAngle, arcCount, pScale;

  //***************************************************GENERAL ARC BLUEPRINT**************************************************
  arcGenerator(float xLoc_, float yLoc_, float radius_, float thickness_, float startAngle_, float endAngle_, float arcCount_)
  {
    xLoc = xLoc_;
    yLoc = yLoc_;
    radius = radius_;
    thickness = thickness_;
    startAngle = startAngle_;
    endAngle = endAngle_;
    arcCount = arcCount_;
  }

  //*********************************************DISPLAY THE WHOLE ARC USING RGB SAME COLORS********************************* 
  void display(float angle, float scale_, int r_, int g_, int b_)
  {
    //blendMode(REPLACE);
    pushMatrix();
    translate(xLoc, yLoc);
    if (scale_ > pScale)
      pScale = scale_;
    scale(pScale);
    noFill();
    stroke(r_*pScale, g_*pScale, b_*pScale, 600); 
    //strokeCap(ROUND);
    strokeWeight(thickness);
    for (int i = 0; i < arcCount; i++)
    {
      rotate(angle);
      float nextR = i * 2.5 * thickness;

      arc(0, 0, radius - nextR, radius - nextR, startAngle, endAngle);
    }
    popMatrix();
    pScale -= 0.08;
  }
  //***************************************FOR DISPLAYING EACH ARC RING WITH A DIFFERENT COLOR (if(mixed) is true)************
  void altDisplay(float angle, float scale_, int[] c)
  {
    pushMatrix();
    translate(xLoc, yLoc);
    noFill();
    if (scale_ > pScale)
      pScale = scale_;
    scale(pScale);
    strokeCap(SQUARE);
    strokeWeight(thickness);
    for (int i = 0; i < arcCount; i++)
    {
      rotate(angle);
      stroke(c[(3*i)]*pScale, c[1+(3*i)]*pScale, c[2+(3*i)]*pScale); 
      float nextR = i * 2.5 * thickness;
      arc(0, 0, radius - nextR, radius - nextR, startAngle, endAngle);
    }
    popMatrix();
    pScale -= 0.08;
  }
}
//*****************************************PREVIOUS ATTEMPT, THE IDEA TO USE STROKE WEIGHT HIT ME LATER, PUN INTENDED****************
/*class arcGenerator {
 
 float x, y;
 float r, t, gap;
 float startAngle, endAngle;
 float angle = 0;
 float scaleAcc = 0;
 int[] colors;
 int arcCount;
 byte flip = 1;
 
 arcGenerator(float xLoc, float yLoc, float radius, float thickness, float gap_, float startAngle_, float endAngle_, int[] colors_, int arcCount_)
 {
 x = xLoc;
 y = yLoc;
 t = thickness;
 gap = gap_;
 r = radius;
 startAngle = startAngle_;
 endAngle = endAngle_;
 colors = colors_;
 arcCount = arcCount_;
 
 }
 
 void display(float rotation, float scale)
 {
 angle = rotation;
 scaleAcc = scale;
 float cAmp = 1 * scaleAcc;
 
 pushMatrix();
 
 translate(x, y);
 scale(scaleAcc);
 for(int i = 0; i < arcCount; i++)
 {
 generateArc(0, 0, r - (i * (t + gap)), t, startAngle, endAngle, angle * flip, cAmp * colors[(3*i)], cAmp *colors[1+(3*i)], cAmp *colors[2+(3*i)]);
 flip *= -1;
 }
 popMatrix();
 }
 
 void generateArc(float xLoc, float yLoc, float radius, float thickness, float startAngle, float endAngle, float rotation, float r, float g, float b)
 {
 pushMatrix();
 translate(xLoc, yLoc);
 rotate(rotation);
 fill(r, g, b, 600);
 arc(0, 0, radius, radius, startAngle + PI/36, endAngle - PI/36);
 fill(background);
 arc(0, 0, radius - thickness, radius - thickness, startAngle, endAngle);
 
 popMatrix();
 }
 
 }*/
