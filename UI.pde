/* 
 There is probably a lot better and simpler way to do this, fuck that (╯°□°)╯  ┻━┻.
 */

class UI {

  float life = 255; // For Fading away into background
  float w, h;     
  float pos, len; // For track length, time, progress bar, etc.

  //*************************************EVERY TIME RESOLUTION CHANGES, USE THE NEW DIMENSIONS TO GENERATE UI*****************
  UI(float w_, float h_)
  {
    w = w_;
    h = h_;
  }

  void display()
  {

    //************************************IF IN AREA OF BUTTONS, SHOW UI********************************************************
    if (mouseY > 0.94 * h)
    { 
      life = prevBackground; // If BG is White, show black, vice versa*******
    }
    
 

    progressBar();
    nextButton();
    prevButton();
    closeButton();
    changeSize();
    loopButton();
    changeBackgroundButton();
    lockHUD();
    helpButtonButton();
    atomicVisualiserButton();
    displayMeta();
    shakeButton();
    changeColorButton();
    speakerVisualiserButton();
    tunnelLightsButton();
    stringSpectrumButton();
    fullSpectrumButton();

    // Switch between Play/Pause Buttons
    if (in.isPlaying())
      pauseButton();
    else
      playButton();

    // If dark, move towards white, vice versa..
    if (prevBackground == 255)
      life -= 2;
    else if (prevBackground == 0)
      life += 2;
    // For not messing with the timing of fading and color, keep value under bounds******
    life = constrain(life, 0, 255);
  }


  void progressBar()
  {

    strokeWeight(1); 
    if (prevBackground == 0)//**
      stroke((life) * 1.1 );//******  These were required to achieve that dim/inactive state, AND fade into Background.
    else                    //**      The headaches this gave me, >_<, later I remembered that there is a thing called Alpha value (╯°□°)╯  ┻━┻.
      stroke((life) * 0.1); //**      Not doing this again.
      
    line(0.05 * w, 0.95 * h, 0.95 * w, 0.95 * h);
    strokeWeight(2); 
    //The light up on hover is achieved using this, on hovering, just increase the stroke weight :D, and then don't let UI fade.
    if (mouseX > 0.05 * w && mouseX < 0.95 * w && mouseY > 0.945 * h && mouseY < 0.955 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pos = in.position();
    len = in.length();

    stroke(life);
    line(0.05 * w, 0.95 * h, map(pos, 0, len, 0.05 * w, 0.95 * w ), 0.95 * h);

    stroke(0);
    strokeWeight(0);
  }

  void playButton()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.49 * w && mouseX < 0.51 * w && mouseY > 0.965 * h && mouseY < 0.975 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pushMatrix();
    translate(w/2, 0.97 * h);
    triangle(8, 0, -2, 8, -2, -8);
    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void pauseButton()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.49 * w && mouseX < 0.51 * w && mouseY > 0.965 * h && mouseY < 0.975 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pushMatrix();
    translate(w/2, 0.97 * h);
    rectMode(CENTER);
    rect(-4, 0, 1, 15);
    rect(4, 0, 1, 15);
    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void nextButton()
  {
    stroke(life);
    if (totalSize == 0 || fileIndex == totalSize - 1)
    {
      if (prevBackground == 0)
        stroke((life) * 1.1 );
      else
        stroke((life) * 0.1);
    }
    //stroke(life * 0.1);
    strokeWeight(2); 
    if (mouseX > 0.54 * w && mouseX < 0.56 * w && mouseY > 0.965 * h && mouseY < 0.975 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pushMatrix();
    translate(0.55*w, 0.97 * h);
    rectMode(CENTER);
    triangle(0, 0, -8, 8, -8, -8);
    triangle(8, 0, 0, 8, 0, -8);
    rect(9, 0, 2, 16);
    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void prevButton()
  {
    stroke(life);
    if (totalSize == 0 || fileIndex == 0)
    {
      //stroke(life * 0.1);
      if (prevBackground == 0) // Using alpha to dim doesn't look good without fill.
        stroke((life) * 1.1 );
      else
        stroke((life) * 0.1);
    }
    strokeWeight(2); 
    if (mouseX > 0.44 * w && mouseX < 0.46 * w && mouseY > 0.965 * h && mouseY < 0.975 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pushMatrix();
    translate(0.45*w, 0.97 * h);
    rectMode(CENTER);
    rotate(PI);
    triangle(0, 0, -8, 8, -8, -8);
    triangle(8, 0, 0, 8, 0, -8);
    rect(9, 0, 2, 16);
    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void closeButton()
  {
    stroke(life);
    strokeWeight(2); 


    if (mouseX > 0.97 * w && mouseX < 0.99 * w && mouseY > 0.025 * h && mouseY < 0.035 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pushMatrix();
    rectMode(CENTER);
    translate(0.98 * w, 0.03 * h);

    rotate(PI/4);
    line(0, 10, 0, -10);
    //rect(0, 0 , 2, 15);
    rotate(PI/2);
    line(0, 10, 0, -10);
    //rect(0, 0 , 2, 15);
    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void changeSize()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.95 * w && mouseX < 0.97 * w && mouseY > 0.025 * h && mouseY < 0.035 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pushMatrix();
    rectMode(CENTER);
    translate(0.96 * w -5, 0.03 * h);
    rect(0, 0, 10, 10);
    rect(-3, 3, 10, 10);
    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void loopButton()
  {
    stroke(life);
    strokeWeight(1); 
    if (mouseX > 0.66 * w && mouseX < 0.68 * w && mouseY > 0.965 * h && mouseY < 0.975 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    if (looping)
      strokeWeight(3); 
    pushMatrix();
    translate(0.67 * w, 0.97 * h);
    //textMode(CENTER);
    arc(0, 0, 16, 16, PI/2, TWO_PI);
    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void displayMeta()
  {
    //***********************DISPLAY TRACK INFORMATION, THEN FADE AWAY***********************************************
    fill(life);
    textSize(16);
    textFont(font);
    text(meta.title(), 0.05 * boundW, 0.97 * boundH);
    text(meta.author(), 0.05 * boundW, 0.97 * boundH + 15); 
    int min = (int)pos/60000;
    text((int)pos/60000 + " : " + int(pos/1000 - min*60), 0.94 * boundW, 0.97 * boundH);
    /*min = (int)len/60000;
     text((int)len/60000 + " : " + int(len/1000 - min*60), 0.90 * boundW, 0.97 * boundH + 15); */
  }

  void changeBackgroundButton()
  {

    stroke(life);
    if (visualisation == 1 || visualisation == 2)
      stroke(255, 0, 0, life);

    strokeWeight(2); 
    if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.145 * h && mouseY < 0.155 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pushMatrix();
    rectMode(CENTER);
    translate(0.97 * w -5, 0.15 * h);
    fill(life);
    if (visualisation == 1 || visualisation == 2)
      fill(255, 0, 0, life);
    ellipse(2, 2, 10, 10);
    noFill();
    ellipse(-2, -2, 10, 10);




    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void helpButtonButton()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.075 * h && mouseY < 0.085 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }

    pushMatrix();
    rectMode(CENTER);
    translate(0.97 * w -5, 0.08 * h);
    noFill();
    //fill(life);
    line(0, -2, 0, 8);
    //noFill();
    ellipse(0, -6, 1, 1);
    ellipse(0, 0, 18, 18);

    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void lockHUD()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.115 * h && mouseY < 0.125 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    if (lockHUD)
      strokeWeight(4); 
    pushMatrix();
    rectMode(CENTER);
    translate(0.97 * w -5, 0.12 * h);
    fill(life);
    rect(0, 0, 10, 8);
    noFill();
    ellipse(0, -6, 8, 8);

    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void atomicVisualiserButton()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.245 * h && mouseY < 0.255 * h)
    {
      strokeWeight(4); 
      life = prevBackground;
    }
    pushMatrix();
    translate(0.97 * w -5, 0.25 * h);
    rotate(PI/4);
    ellipse(0, 0, 5, 20);
    rotate(PI);
    ellipse(0, 0, 20, 5 );
    rotate(PI/4);
    ellipse(0, 0, 5, 20);
    rotate(PI);
    ellipse(0, 0, 20, 5 );



    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void shakeButton()
  {
    {
      stroke(life);
      strokeWeight(2); 
      noFill();
      if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.275 * h && mouseY < 0.285 * h)
      {
        strokeWeight(4); 
        life = prevBackground;
      }
      if (shake)
        strokeWeight(5); 
      pushMatrix();
      rectMode(CENTER);
      translate(0.97 * w -5, 0.28 * h);
      line(0, -6, 0, -20);
      arc(-5, 0, 10, 10, 0, PI);
      rotate(PI);
      arc(-5, 0, 10, 10, 0, PI);
      popMatrix();
      stroke(0);
      strokeWeight(0);
    }
  }

  void changeColorButton()
  {
    {
      stroke(life);
      strokeWeight(2); 
      noFill();
      if (mouseX > 0.96 * w  && mouseX < 0.98 * w && mouseY > 0.195 * h && mouseY < 0.205 * h)
      {
        strokeWeight(4); 
        life = prevBackground;
      }
      pushMatrix();
      rectMode(CENTER);
      translate(0.97 * w -5, 0.2 * h);
      // stroke(colors[0], colors[1], colors[2], life);
      ellipse(-5, 0, 10, 10);
      //stroke(colors[3], colors[4], colors[5], life);
      ellipse(-0, 0, 10, 10);
      //stroke(colors[6], colors[7], colors[8], life);
      ellipse(5, 0, 10, 10);
      popMatrix();
      stroke(0);
      strokeWeight(0);
    }
  }

  void speakerVisualiserButton()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.325 * h && mouseY < 0.335 * h)
    {
      strokeWeight(3); 
      life = prevBackground;
    }
    pushMatrix();
    translate(0.97 * w -5, 0.33 * h);

    ellipse(0, 0, 20, 20);
    ellipse(0, 0, 12, 12 );
    ellipse(0, 0, 4, 4);

    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void tunnelLightsButton()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.375 * h && mouseY < 0.385 * h)
    {
      strokeWeight(3); 
      life = prevBackground;
    }
    pushMatrix();
    translate(0.97 * w -5, 0.38 * h);

    for (int i = 0; i < TWO_PI; i+= PI/2)
      ellipse(5 * cos(i), 5 * sin(i), 5, 5);


    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void stringSpectrumButton()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.425 * h && mouseY < 0.435 * h)
    {
      strokeWeight(3); 
      life = prevBackground;
    }
    pushMatrix();
    translate(0.97 * w -5, 0.43 * h);

    ellipse(0, 0, 5, 5);
    ellipse(0, 0, 20, 20);


    popMatrix();
    stroke(0);
    strokeWeight(0);
  }

  void fullSpectrumButton()
  {
    stroke(life);
    strokeWeight(2); 
    if (mouseX > 0.96 * w && mouseX < 0.98 * w && mouseY > 0.475 * h && mouseY < 0.485 * h)
    {
      strokeWeight(3); 
      life = prevBackground;
    }
    pushMatrix();
    translate(0.97 * w -5, 0.48 * h);

    rect(-5, 0, 5, 10);
    rect(0, -1, 5, 12);
    rect(5, 1, 5, 7);


    popMatrix();
    stroke(0);
    strokeWeight(0);
  }
}

