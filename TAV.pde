/*The Awesome Visualiser
 Author : Rishabh Asthana, 05 Aug 2014
 Licensed under Creative Commons Attribution 4.0 International License
 http://creativecommons.org/licenses/by/4.0/legalcode
 
 Made entirely in Processing 2.2.1 (by Ben Fry and Casey Reas)
 
 Making this was fun, but it would've been impossible without the awesome libraries like minim(by Damien Di Fede), sDrop(by Andreas Schlegel), and great resources available around the internet,
 Also a special thanks to Daniel Shiffman, author of Nature Of Code, that book is amazing, and taught me some really cool stuff in a way that was easy to understand,
 pretty much the reason I started to use processing.
 Lastly I can't believe how easy Processing makes doing things, that extra layer of abstraction, and Java power under the hood together works like magic, processing made 
 making this convenenient and possible, and how easy it is to port things to another platform (except Mac).
 (although I wish maximizing and minimizing would have been automatic, rather than restructuring the program to recreate itself with multiple dimensions.
 
 NOTE : Comments refer to the things written below them, if written on side, it refers to that specific thing.
 
 */

// We need only these three imports for now.
import ddf.minim.*;
import ddf.minim.analysis.*;
import sojamo.drop.*;

DisposeHandler dh;   // This is a class from Java, this executes when program is about to close, can be used to make text files which remember last loaded tracks..
// For drag and drop event management.
SDrop drop;
//Minim stuff, hopefully you know this.
Minim minim;
AudioPlayer in;
AudioMetaData meta;
FFT fft;

PFont font;
PImage helpWindow;

UI ui;

ArrayList<String> files;  
float[] fftAverages = new float[11]; 

Particle[]  particlesBass; 
Particle[]  particlesMid; 
Particle[]  particlesTreble; 

int fileIndex = 1;
int totalSize = 0;
int colorSet = 0;

// Some boolean triggers for On/Off type events.
boolean paused = true;
boolean looping = false;
boolean lockHUD = true;
boolean mixColors = true;
boolean shake = false;
// boolean bassMode;
boolean help = true;




float max = 3;

float maxBass = 3;
float maxMid = 3;
float maxTreble = 3;

float[] maximum = {
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
};

// This right here is what manages the flow, the visualisation is set to a value by clicking a corresponding UI button, then each viz has a state associated with it, 
// and left clicking on display window cycles them.
int visualisation = 0;
int state = 1;
int state2 = 0;
int state3 = 0;
int state4 = 0;

// Very important, accepted by almost every function of mine, things are scaled, translated, rotated relative to them, Why? because normal resizing doesn't work
// So upon minimizing/maximizing based upon toggle, sketch is resized by boundW, boundH, and all visualizer specific display functions get updated accrodingly
int boundW, boundH;
int toggle = 1;

SpectrumString[] strings = new SpectrumString[12];

// Used by arcGenerator, make changes here to set radius, thickness, 
float shrink = 0.8; // So that radius to thickness ratio is maintained.
float r = 480 * shrink;
float t = 50 * shrink;
float angle = 0;

//float g = 30 * shrink;    Ignore, Used by previous arcGenerators.

//float test = 0;

// These are required for those spectrum wave visualisations
int bsize;
float[] specVal;





Light[] lights = new Light[12];

arcGenerator generator1, generator2, generator3;  // 3 medium, and for one big arcReactors.

arcGenerator[] generators = new arcGenerator[12]; // 12 small arcReactors.

// Also important, they both are used to achieve that black to white, vice versa UI toggle, and to force black BG on visualizations using ADD blendMode.
int background = 0;
int prevBackground = 255;

// I love this stuff, there is a function that overwrites colors[] value, and these values are again what most my visualization display functions accept,
// result : instant color change
int[] colors = {
  255, 0, 0, 255, 255, 0, 0, 0, 255
};
// Change this right here to alter what colors each arc, particle cluster uses when mixColors tag is true(it's true when colorSet == 4)
// Note: Must have same or greater number of RGB values than number of arcs in arcGenerator. 
int[] colorsMixed = {
  255, 0, 0, 255, 255, 0, 0, 0, 255, 0, 255, 0
};

void setup()
{
  //This way it adapts to every screen size, P3D because it gets the best fps, Also I plan to make some 3d ones as I learn more.
  size(displayWidth, displayHeight, P3D);
  frame.setResizable(true);

  dh = new DisposeHandler(this);
  files = new ArrayList<String>();
  ui = new UI(width, height);
  boundW = width;
  boundH = height;
  font = loadFont("SourceSansPro-Regular-16.vlw");
  helpWindow = loadImage("Help.png");
  

  //float test = 0;

  regenerateState1(boundW, boundH);
  regenerateState2(boundW, boundH);


  frameRate(60);


  minim = new Minim(this);
  in = minim.loadFile("D1.mp3", 1024);
  //in.loop();
  meta = in.getMetaData();
  fft = new FFT(in.bufferSize(), in.sampleRate());

  fft.logAverages(11, 1);

  frameRate(60);
  drop = new SDrop(this);



  for (int i = 0; i < 12; i++)
    lights[i] = new Light();

  for (int i = 0; i < 12; i++)
    strings[i] = new SpectrumString();
}

void draw()
{
  background(background);

  totalSize = files.size();


  //println(frameRate);

  //***********************PROVIDE FFT OBJECTS WITH AVERAGED/MIXED STEREO INFORMATION OF CURRENT TRACK*******************************

  fft.forward(in.mix);
  //************************************CALCULATE MAXIMUM VALUE EVER REACHED FOR THE CHANNELS****************************************


  for (int i = 0; i < 11; i++)
  {
    fftAverages[i] = fft.getAvg(i);
  }

  /* if(bassMode)
   {
   int l = 0;
   for (int i = 0; i < 11; i++)
   {
   fftAverages[i] = fft.getAvg(l);
   l++;
   l %= 2;
   }
   }*/

  for (int i = 0; i < 11; i++)
  {
    float temp = fftAverages[i];
    if (maximum[i] < temp)
      maximum[i] = temp;
  }
  maximum[11] = 10 + fftAverages[10];




  //************************CALCULATE LINEAR AVERAGES FOR 3 CHANNEL, SINGLE CHANNEL VISUALISATION, OR VOLUME/SCALE/ROTATION CONTROL******************
  float bassAvg = (fftAverages[0] + fftAverages[1] + fftAverages[2] + fftAverages[3])/4;
  float midAvg  = (fftAverages[4] + fftAverages[5] + fftAverages[6] + fftAverages[7])/4;
  //********************************THE 12 CHANNEL PART IS LIKE CAKE, IT'S A LIE :O, 12th IS 11th CHANNEL REPEATED***********************************
  float trebleAvg = (fftAverages[8] + fftAverages[9] + fftAverages[10]) *2 ;

  float volAvg = bassAvg + midAvg + trebleAvg / 3;

  if (max < volAvg)
    max = volAvg;

  if (maxBass < bassAvg)
    maxBass = bassAvg;
  if (maxMid < midAvg)
    maxMid = midAvg;
  if (maxTreble < trebleAvg)
    maxTreble = trebleAvg;

  //*****************************TO ROTATE ARC SPEAKERS ACCORDING TO TOTAL VOLUME************************
  float angleAcc = map(volAvg, 0, max, 0, TWO_PI);
  angle += angleAcc * 0.03;

  //*************INITIATING DISPLAY FUNCTIONS OF VISUALISATIONS UPON UI BUTTON PRESS, OR STATE CHANGE IF CLICKED WITHIN DISPLAY AREA***********
  if (help)
  {
    if(background == 255)
    tint(150, 150, 150);
    image(helpWindow, 0, 0, boundW, boundH);
  }
  else if (visualisation == 0)
  {
    //THE 'BLEND' BLENDMODE WORKS WELL WITH WHITE BG's, BUT TRANSPARENCY IS GONE, TOP MOST VISUAL LAYER GAINS PRECEDENCE************************
    blendMode(BLEND);
    //blendMode(ADD);
    //******************DISPLAYING 3 CHANNEL ROTATING ARCS**************************
    if (state == 0)
    { // Boolean counter to check if colors have to be mixed*****
      // All rings will be of same color***********************
      if (!mixColors)
      {
        generator1.display(angle, map(bassAvg, 0, maxBass, 0.5, 1.5), colors[0], colors[1], colors[2]); 
        generator2.display(angle, map(midAvg, 0, maxMid, 0.5, 1.5), colors[3], colors[4], colors[5]);
        generator3.display(angle, map(trebleAvg, 0, maxTreble, 0.5, 1.5), colors[6], colors[7], colors[8]);
      }
      // All rings will be of different colors.******************
      else 
      {
        generator1.altDisplay(angle, map(bassAvg, 0, maxBass, 0.5, 1.5), colorsMixed); 
        generator2.altDisplay(angle, map(midAvg, 0, maxMid, 0.5, 1.5), colorsMixed);
        generator3.altDisplay(angle, map(trebleAvg, 0, maxTreble, 0.5, 1.5), colorsMixed);
      }
    } // DISPLAYING 12 SMALL ROTATING ARCS***************************
    else if (state == 1)
    {
      if (!mixColors)
      {
        int counter = 0;
        for (int i = 0; i < 12; i++)
        {
          if (counter != 11)
          {
            if (i < 4)
              generators[i].display(angle, map(fftAverages[counter], 0, maximum[counter], 0.5, 4), colors[0], colors[1], colors[2]);
            else if (i < 8)
              generators[i].display(angle, map(fftAverages[counter], 0, maximum[counter], 0.5, 4), colors[3], colors[4], colors[5]);
            else
              generators[i].display(angle, map(fftAverages[counter], 0, maximum[counter], 0.5, 4), colors[6], colors[7], colors[8]);
          } else
          {
            generators[i].display(angle, map(fftAverages[10], 0, maximum[10], 0.5, 4), colors[6], colors[7], colors[8]);
            counter = counter%11;
          }
          counter++;
        }
      } else
      {
        int counter = 0;
        for (int i = 0; i < 12; i++)
        {
          if (counter != 11)
          {
            if (i < 4)
              generators[i].altDisplay(angle, map(fftAverages[counter], 0, maximum[counter], 0.5, 3), colorsMixed);
            else if (i < 8)
              generators[i].altDisplay(angle, map(fftAverages[counter], 0, maximum[counter], 0.5, 3), colorsMixed);
            else
              generators[i].altDisplay(angle, map(fftAverages[counter], 0, maximum[counter], 0.5, 3), colorsMixed);
          } else
          {
            generators[i].altDisplay(angle, map(fftAverages[10], 0, maximum[10], 0.5, 3), colorsMixed);
            counter = counter%11;
          }
          counter++;
        }
      }
    } else if (state == 2)
    {
      if (!mixColors)
        generator1.display(angle, map(volAvg, 0, max, 0.5, 3), colors[0], colors[1], colors[2]); 
      else
        generator1.altDisplay(angle, map(volAvg, 0, max, 0.5, 3), colorsMixed);
    }
  } else if (visualisation == 1)
  { 

    blendMode(ADD);
    for (int i = 0; i < 450; i++)
    {
      if (mousePressed && mouseButton == LEFT && mouseX < 0.95 * boundW  && mouseY < 0.94 * boundH )
      {
        particlesBass[i].center = new PVector(mouseX, mouseY);
        particlesMid[i].center = new PVector(mouseX, mouseY);
        particlesTreble[i].center = new PVector(mouseX, mouseY);
      } else if (shake)
      { 
        float vibY = 50 * sin(angleAcc);
        float vibX = 50 * cos(angleAcc);
        particlesBass[i].center = new PVector(boundW/2 + vibX, boundH/2 + vibY);
        particlesMid[i].center = new PVector(boundW/2 + vibX, boundH/2 + vibY);
        particlesTreble[i].center = new PVector(boundW/2 + vibX, boundH/2 + vibY);
      }
      if (!mixColors)
      {
        particlesBass[i].altRun(bassAvg, colors[0], colors[1], colors[2]);
        particlesMid[i].altRun(midAvg, colors[3], colors[4], colors[5]);
        particlesTreble[i].altRun(trebleAvg, colors[6], colors[7], colors[8]);
      } else
      {
        if (i < 150)
        {
          particlesBass[i].altRun(bassAvg, 255, 0, 0);
          particlesMid[i].altRun(midAvg, 255, 0, 0);
          particlesTreble[i].altRun(trebleAvg, 255, 0, 0);
        } else if (i < 300)
        {
          particlesBass[i].altRun(bassAvg, 255, 255, 0);
          particlesMid[i].altRun(midAvg, 255, 255, 0);
          particlesTreble[i].altRun(trebleAvg, 255, 255, 0);
        } else if (i < 450)
        {
          particlesBass[i].altRun(bassAvg, 0, 0, 255);
          particlesMid[i].altRun(midAvg, 0, 0, 255);
          particlesTreble[i].altRun(trebleAvg, 0, 0, 255);
        }
      }
    }
  } else if (visualisation == 2)
  {
    blendMode(ADD);
    if (state2 == 0)
    {

      lights[0].createSpiral(0.2*boundW, boundH/2, 200, map(bassAvg, 0, maxBass, 0, 1.5), 0, colors[0], colors[1], colors[2], 80); 
      lights[1].createSpiral(0.5*boundW, boundH/2, 200, map(midAvg, 0, maxMid, 0, 1.5), 0, colors[3], colors[4], colors[5], 80); 
      lights[2].createSpiral(0.8*boundW, boundH/2, 200, map(trebleAvg, 0, maxTreble, 0, 1.5), 0, colors[6], colors[7], colors[8], 80);
    } else if (state2 == 1)
    {

      lights[0].createSpiral(0.5*boundW, boundH/2, 400, map(volAvg, 0, max, 0, 2.5), 0, colors[0], colors[1], colors[2], 80);
    } else if (state2 == 2)
    {
      int k = 0;
      for (int j = 0; j < 3; j++)
      {
        for (int i = 0; i < 4; i++)  // 4
        {
          if (k != 11)
          {
            if (k < 4)
              lights[k].createSpiral((i+1) * boundW/4 - boundW/8, (j+1) * boundH/3 - boundH/6, 100, map(fftAverages[k], 0, maximum[k], 0.1, 1.5), 0, colors[0], colors[1], colors[2], 50);
            else if (k < 8)
              lights[k].createSpiral((i+1) * boundW/4 - boundW/8, (j+1) * boundH/3 - boundH/6, 100, map(fftAverages[k], 0, maximum[k], 0.1, 1.5), 0, colors[3], colors[4], colors[5], 50);
            else
              lights[k].createSpiral((i+1) * boundW/4 - boundW/8, (j+1) * boundH/3 - boundH/6, 100, map(fftAverages[k], 0, maximum[k], 0.1, 1.5), 0, colors[6], colors[7], colors[8], 50);
          } else
          {
            lights[k].createSpiral((i+1) * boundW/4 - boundW/8, (j+1) * boundH/3 - boundH/6, 100, map(fftAverages[10], 0, maximum[10], 0.1, 1.5), 0, colors[6], colors[7], colors[8], 50);
            k=k%11;
          }
          k++;
        }
      }
    }
  } else if (visualisation == 3)
  {
    bsize = in.bufferSize();
    specVal = new float[bsize];
    strokeWeight(2);
    noFill();
    int radius;

    for (int i = 0; i < bsize; i++)
      specVal[i] = in.mix.get(i);

    if (state3 == 0)
    {
      radius =  200;

      float xp = map(volAvg, 0, max, 0.5, 3);

      strings[0].generateString(boundW/2, boundH/2, radius, xp, colors[0], colors[1], colors[2]);
      strings[0].generateString(boundW/2, boundH/2, radius/2, xp, colors[3], colors[4], colors[5]);
      strings[0].generateString(boundW/2, boundH/2, radius/4, xp, colors[6], colors[7], colors[8]);
    } else if (state3 == 1)
    {
      radius = 100;
      strings[0].generateString(0.20*boundW, boundH/2, radius, map(bassAvg, 0, maxBass, 0.5, 3), colors[0], colors[1], colors[2]);
      strings[1].generateString(0.50*boundW, boundH/2, radius, map(midAvg, 0, maxMid, 0.5, 3), colors[3], colors[4], colors[5]);
      strings[2].generateString(0.80*boundW, boundH/2, radius, map(trebleAvg, 0, maxTreble, 0.5, 3), colors[6], colors[7], colors[8]);
      radius = 50;
      strings[0].generateString(0.20*boundW, boundH/2, radius, map(bassAvg, 0, maxBass, 0.5, 3), colors[0], colors[1], colors[2]);
      strings[1].generateString(0.50*boundW, boundH/2, radius, map(midAvg, 0, maxMid, 0.5, 3), colors[3], colors[4], colors[5]);
      strings[2].generateString(0.80*boundW, boundH/2, radius, map(trebleAvg, 0, maxTreble, 0.5, 3), colors[6], colors[7], colors[8]);
    } else if (state3 == 2)
    {  
      radius = 40;
      int k = 0;
      for (int j = 0; j < 3; j++)
      {
        for (int i = 0; i < 4; i++)  // 4
        {
          if (k != 11)
          {
            if (k < 4)
              strings[k].generateString((i+1) * boundW/4 - boundW/8, (j+1) * boundH/3 - boundH/6, radius, map(fftAverages[k], 0, maximum[k], 0.5, 3), colors[0], colors[1], colors[2]);
            else if (k < 8)
              strings[k].generateString((i+1) * boundW/4 - boundW/8, (j+1) * boundH/3 - boundH/6, radius, map(fftAverages[k], 0, maximum[k], 0.5, 3), colors[3], colors[4], colors[5]);
            else
              strings[k].generateString((i+1) * boundW/4 - boundW/8, (j+1) * boundH/3 - boundH/6, radius, map(fftAverages[k], 0, maximum[k], 0.5, 3), colors[6], colors[7], colors[8]);
          } else
          {
            strings[k].generateString((i+1) * boundW/4 - boundW/8, (j+1) * boundH/3 - boundH/6, radius, map(fftAverages[10], 0, maximum[10], 0.5, 3), colors[6], colors[7], colors[8]);
            k=k%11;
          }
          k++;
        }
      }
    }
  } else if (visualisation == 4)
  {
    bsize = in.bufferSize();
    specVal = new float[bsize];
    for (int i = 0; i < bsize; i++)
      specVal[i] = in.mix.get(i);
    pushMatrix();
    translate(0, boundH/2); 

    if (state4 == 0)
    {
      fill(colors[0], colors[1], colors[2]);
      stroke(prevBackground);
      int w = 5;
      for (int i = 0; i < bsize; i+=1)
      { //println("YAY");
        float j = map(i, 0, bsize, 0, boundW);
        float y2 =  specVal[i]*250;
        rect(j*w, 0, w, y2);
      }
      noFill();
    } else if (state4 == 1)
    {
      fill(colors[3], colors[4], colors[5]);
      stroke(prevBackground);
      int w = 10;
      for (int i = 0; i < bsize; i+=1)
      { //println("YAY");
        float j = map(i, 0, bsize, 0, boundW);
        float y2 =  specVal[i]*250;
        rect(j*w, 0, w, y2);
      }
      translate(boundW/2, -boundH/2);
      fill(colors[6], colors[7], colors[8]);
      rotate(PI/2);
      for (int i = 0; i < bsize; i+=1)
      { 
        float j = map(i, 0, bsize, 0, boundW);
        float y2 =  specVal[i]*250;
        rect(j*w, 0, w, y2);
      }
      noFill();
    } else if (state4 == 2)
    {

      beginShape();
      noFill();

      for (int i = 0; i < bsize; i+=1)
      {
        float j = map(i, 0, bsize - 1, 0, boundW);
        float x2 =  j;
        float y2 =  specVal[i]*20;
        vertex(x2, y2);
        stroke(colors[3], colors[4], colors[5]);
        strokeWeight(2);
        point(x2, y2);
      }
      endShape();
    }
    popMatrix();
  }


  if (lockHUD)
    ui.life = prevBackground;

  ui.display();


  //************************IF REPEAT IS OFF, PLAY NEXT TRACK, IF FINAL TRACK, PLAY FROM THE FIRST TRACK AGAIN*********************
  if (!in.isPlaying() && paused == false && files.size() > 0  && looping == false)
  {
    // println("ran1");
    fileIndex++;

    //fileIndex = constrain(fileIndex, 0, totalSize - 1);
    if (fileIndex == totalSize)
      fileIndex = 0;
    changeTracks(fileIndex);
  }

  //************************IF REPEAT IS ON, KEEP LOOPING THE CURRENT TRACK********************
  else if (!in.isPlaying() && paused == false && files.size() > 0 && looping == true)
  {
    //println("ran2");
    changeTracks(fileIndex);
  } else if (!in.isPlaying() && paused == false && files.size() == 0 && looping == false)
  {
    in.loop();
  }
  /*
  if(!in.isPlaying() && paused == false && files.size() > 0 && looping == false)
   {
   fileIndex++;
   fileIndex = constrain(fileIndex, 0, files.size() - 1);
   changeTracks(fileIndex); 
   }
   else if(!in.isPlaying() && paused == false && files.size() > 0 && looping == true)
   {
   changeTracks(fileIndex); 
   }*/
}

//*******************************DRAG AND DROP & FILE MANAGEMENT FUNCTION**********************

void dropEvent(DropEvent theDropEvent) {
  println("Drop Happened");
  if (theDropEvent.isFile())
  {
    String file = "" + theDropEvent.file();
    if (file.substring(file.length() - 3, file.length()).equalsIgnoreCase("mp3"))
    {
      String path = file.replace('\\', '/');
      files.add(path);
      println("Total : " + files.size() + " Track added : " + path);
    } else 
      println("Nope, not a valid music format");
  } else
    println("Nope, not even a proper file -_-");
}

//*****************************CHANGE TRACKS FUNCTION******************************************
void changeTracks(int index)
{
  minim.stop(); 
  in = minim.loadFile(files.get(index), 1024);
  in.play();
  meta = in.getMetaData();
  max = 2;

  for (float f : maximum)
    f = 2;

  maxBass = 2;
  maxMid = 2;
  maxTreble = 2;

  println(index + " : " + files.get(index));
}

//********************************FORCE FULLSCREEN ON STARTUP************************************
boolean sketchFullScreen() {
  return true;
}

//********************************MOUSEPRESS EVENT MANAGEMENT**************************************
void mousePressed()
{
  //******************************MINIMIZE SCREEN OPERATION************************************
  if (mouseButton == CENTER && toggle == 1 || mouseX > 0.95 * boundW && mouseX < 0.97 * boundW && mouseY > 0.025 * boundH && mouseY < 0.035 * boundH && toggle == 1)
  {
    boundW = 1000;
    boundH = 600;
    frame.setSize(boundW, boundH);
    if (visualisation == 0)
    {
      if (state == 0)
        regenerateState1(boundW, boundH);
      else if (state == 1)
        regenerateState2(boundW, boundH);
      else if (state == 2)
        regenerateState3(boundW, boundH);
    } else if (visualisation == 1)
    {
      regenerateParticles(boundW, boundH);
    }
    ui = new UI(boundW, boundH);
    toggle *= -1;
    // bound = 800;
  } 
  //*****************************MAXIMIZE SCREEN OPERATION************************************
  else if ((mouseButton == CENTER && toggle == -1) || mouseX > 0.95 * boundW && mouseX < 0.97 * boundW && mouseY > 0.025 * boundH && mouseY < 0.035 * boundH && toggle == -1)
  {
    boundW = displayWidth;
    boundH = displayHeight;
    frame.setSize(boundW, boundH);
    if (visualisation == 0)
    {
      if (state == 0)
        regenerateState1(boundW, boundH);
      else if (state == 1)
        regenerateState2(boundW, boundH);
      else if (state == 2)
        regenerateState3(boundW, boundH);
    } else if (visualisation == 1)
    {
      regenerateParticles(boundW, boundH);
    }
    ui = new UI(boundW, boundH);
    toggle *= -1;
  } 
  //*************************************SHOW HUD/UI**************************************************
  else if (mouseButton == RIGHT)
    ui.life = prevBackground;

  //*****************************SWITCH STATES OF CURRENT VISUALISATION & LEAVE RIGHT SIDE SCREEN MARGIN FOR BUTTONS*******************
  else if (mouseX < 0.95 * boundW  && mouseY < 0.94 * boundH )
  {
    if (visualisation == 0)
    {
      state ++;
      state = state % 3;
      if (state == 0)
        regenerateState1(boundW, boundH);
      else if (state == 1)
        regenerateState2(boundW, boundH);
      else if (state == 2)
        regenerateState3(boundW, boundH);
    } else if (visualisation == 2)
    {
      state2 ++;
      state2 = state2 % 3;
    } else if (visualisation == 3)
    {
      state3 ++;
      state3 = state3 % 3;
    } else if (visualisation == 4)
    {
      state4++;
      state4 = state4 % 3;
    }
  }
  //****************************REPEAT/LOOP CURRENT BUTTON**********************************
  else if (mouseX > 0.66 * boundW && mouseX < 0.68 * boundW && mouseY > 0.965 * boundH && mouseY < 0.975 * boundH)
  {
    looping = !looping;
  }
  //*******************PLAY/PAUSE BUTTONS*************************************
  else if (mouseX > 0.49 * boundW && mouseX < 0.51 * boundW && mouseY > 0.965 * boundH && mouseY < 0.975 * boundH && mouseButton == LEFT)
  {
    if (in.isPlaying()) 
    {
      in.pause();
      paused = true;
    } else
    {
      in.play();
      paused = false;
    }
  }
  /* else if(mouseX > 0.49 * boundW && mouseX < 0.51 * boundW && mouseY > 0.965 * boundH && mouseY < 0.975 * boundH && mouseButton == LEFT && looping == false && !in.isPlaying())
   {
   in.rewind();
   paused = false;
   }*/
  //***************PROGRESS BAR SCAN**************************
  else if (mouseX > 0.05 * boundW && mouseX < 0.95 * boundW && mouseY > 0.945 * boundH && mouseY < 0.955 * boundH && mouseButton == LEFT)
  {
    in.cue(int(map(mouseX, 0.05 * boundW, 0.95 * boundW, 0, in.length())));
  }
  //*************CLOSE BUTTTON*****************************
  else if (mouseX > 0.97 * boundW && mouseX < 0.99 * boundW && mouseY > 0.025 * boundH && mouseY < 0.035 * boundH)
  {
    dh.dispose();
  }
  //*************PREVIOUS BUTTON**************************
  else if (mouseX > 0.44 * boundW && mouseX < 0.46 * boundW && mouseY > 0.965 * boundH && mouseY < 0.975 * boundH && mouseButton == LEFT && totalSize != 0 && fileIndex != 0)
  {
    fileIndex--;
    fileIndex = constrain(fileIndex, 0, files.size() - 1);
    changeTracks(fileIndex);
    paused = false;
  }
  //************* NEXT BUTTON ****************************
  else if (mouseX > 0.54 * boundW && mouseX < 0.56 * boundW && mouseY > 0.965 * boundH && mouseY < 0.975 * boundH && mouseButton == LEFT && totalSize != 0 && fileIndex != totalSize - 1)
  {
    fileIndex++;
    fileIndex = constrain(fileIndex, 0, files.size() - 1);
    changeTracks(fileIndex);
    paused = false;
  }
  //*************CHANGE BACKGROUND****************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.145 * boundH && mouseY < 0.155 * boundH && visualisation != 1 && visualisation != 2)
  {
    if (background == 0)
    {
      background = 255;
      prevBackground = 0;
    } else if (background == 255)
    {
      background = 0;
      prevBackground = 255;
    }

    if (colorSet == 4)
      setColors(prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground);
  }
  //*********************LOCK/UNLOCK HUD************************************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.115 * boundH && mouseY < 0.125 * boundH)
  {
    lockHUD = !lockHUD;
  }
  //**************************HELP BUTTON*************************************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.075 * boundH && mouseY < 0.085 * boundH)
  {
    help = !help;
  }
  //************************ATOM VISUALISER****************************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.245 * boundH && mouseY < 0.255 * boundH)
  {
    releaseMemory();
    if (background == 255)
    {
      background = 0;
      prevBackground = 255;
    }
    visualisation = 1;

    if (colorSet == 4)
      setColors(prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground);
    regenerateParticles(boundW, boundH);
  }
  //****************************SPEAKER VISUALISER*******************************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.325 * boundH && mouseY < 0.335 * boundH)
  {
    releaseMemory();
    visualisation = 0;
    state = 1;
    regenerateState2(boundW, boundH);
  }
  //****************************LIGHT VISUALISATION***********************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.375 * boundH && mouseY < 0.385 * boundH)
  {
    releaseMemory();
    visualisation = 2;
    //state = 1;
    if (background == 255)
    {
      background = 0;
      prevBackground = 255;
    }


    if (colorSet == 4)
      setColors(prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground);
  }

  //***************************SPECTRUM STRING VISUALISATION*********************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.425 * boundH && mouseY < 0.435 * boundH)
  {
    releaseMemory();
    visualisation = 3;

    if (colorSet == 4)
      setColors(prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground);
  }
  //*****************************FULL SPECTRUM VISUALISATION********************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.475 * boundH && mouseY < 0.485 * boundH)
  {
    releaseMemory();
    visualisation = 4;

    if (colorSet == 4)
      setColors(prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground);
  }
  //***************************SHAKE(SINE) BUTTON********************************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.275 * boundH && mouseY < 0.285 * boundH)
  {
    shake = !shake;
  }
  //***************************NEXT COLOR SET************************************************
  else if (mouseX > 0.96 * boundW && mouseX < 0.98 * boundW && mouseY > 0.195 * boundH && mouseY < 0.205 * boundH)
  {

    if (colorSet == 0)
    {
      mixColors = false;
      setColors(255, 0, 0, 255, 255, 0, 0, 0, 255);
    } else if (colorSet == 1)
      setColors(255, 0, 0, 0, 255, 0, 0, 0, 255);
    else if (colorSet == 2)
      setColors(255, 50, 0, 0, 255, 0, 0, 0, 255);
    else if (colorSet == 3)
      setColors(prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground, prevBackground);
    else if (colorSet == 4)
      mixColors = true;
    else if (colorSet == 5)
    {
      mixColors = false;
      setColors(0, 250, 250, 100, 255, 0, 96, 0, 255);  
    }
    else if (colorSet == 6)
      setColors(60, 150, 200, 0, 255, 45, 78, 41, 255);
    //DO NOT ALTER ABOVE VALUES, INSTEAD ADD NEW FROM BELOW


    colorSet++;
    colorSet = colorSet % 7; // !!!!CHANGE TO NUMBER OF (TOTAL COLOR SETS + 1) FOR PROPER CYLCLING.
  }
}

//*****************************KEYBOARD EVENT MANAGEMENT**************************************
void keyPressed()
{
  //************************PLAY/PAUSE ---- SPACEBAR CONTROL*******************************
  if (key == ' ')
  { 
    ui.life = 255;
    if (in.isPlaying()) 
    {
      in.pause();
      paused = true;
    } else
    {
      in.play();
      paused = false;
    }
  }
  //***********************NEXT TRACK ---- Keyboard - W/w control****************************
  else if (key == 'D' || key == 'd' && totalSize != 0)
  {
    fileIndex++;
    fileIndex = constrain(fileIndex, 0, files.size() - 1);
    changeTracks(fileIndex);
  }
  //***********************PREVIOUS TRACK ---- Keyboard - S/s control****************************
  else if (key == 'A' || key == 'a' && totalSize != 0)
  {
    fileIndex--;
    fileIndex = constrain(fileIndex, 0, files.size() - 1);
    changeTracks(fileIndex);
  }
  //***********************CLOSE OPERATION ---- Keyboard - X/x control****************************
  else if (key == 'X' || key == 'x')
  {
  }
}

//***********************Remake 3 * big speakers***********************************
void regenerateState1(float w, float h)
{
  //xLoc, yLoc, radius, thickness, gap,  startAngle, endAngle, int[] colors,  arcCount_
  generator1 = new arcGenerator(0.15*w, h/2, r, t, 0, 0.8 * TWO_PI, 4);
  generator2 = new arcGenerator(0.5 *w, h/2, r, t, 0, 0.8 * TWO_PI, 4);
  generator3 = new arcGenerator(0.85*w, h/2, r, t, 0, 0.8 * TWO_PI, 4);
}

//***********************Remake 12 * small speakers***********************************
void regenerateState2(float w, float h)
{
  generators = new arcGenerator[12];
  int k = 0;
  for (int j = 0; j < 3; j++)
  {
    for (int i = 0; i < 4; i++)  // 4
    {
      //xLoc, yLoc, radius, thickness, gap,  startAngle, endAngle, int[] colors,  arcCount_
      generators[k] = (new arcGenerator((i+1) * w/4 - w/8, (j+1) * h/3 - h/6, r/4, t/4, 0, 0.8 * TWO_PI, 4));
      k++;
    }
  }
}
//***********************One Giant Speaker*****************************************
void regenerateState3(float w, float h)
{
  //xLoc, yLoc, radius, thickness, gap,  startAngle, endAngle, int[] colors,  arcCount_
  generator1 = new arcGenerator(0.5*w, h/2, r, t, 0, 0.8 * TWO_PI, 4);
}

void setColors(int br, int bg, int bb, int mr, int mg, int mb, int tr, int tg, int tb)
{
  colors[0] = br;
  colors[1] = bg;
  colors[2] = bb;
  colors[3] = mr;
  colors[4] = mg;
  colors[5] = mb;
  colors[6] = tr;
  colors[7] = tg;
  colors[8] = tb;
}

void regenerateParticles(float w, float h)
{
  particlesBass = new Particle[450];
  particlesMid = new Particle[450];
  particlesTreble = new Particle[450];

  for (int i = 0; i < 450; i++)
  {
    particlesBass[i] = new Particle(0.25*w, h/2, 50, 0.1);
    particlesMid[i] = new Particle(0.5*w, h/2, 50, 0.8);
    particlesTreble[i] = new Particle(0.75*w, h/2, 50, 1);
  }
}

void releaseMemory()
{
  if (visualisation != 0)
  {
    generators = null;
    generator1 = null;
    generator2 = null;
    generator3 = null;
  } else if (visualisation != 1)
  {
    particlesBass = null;
    particlesMid = null;
    particlesTreble = null;
  } else if (visualisation != 3)
  {
    specVal = null;
  } else if (visualisation != 4)
  {
    specVal = null;
  }
}


//**********************RELEASING RESOURCES ON EXIT**********************
public class DisposeHandler
{
  DisposeHandler(PApplet pa)
  {
    pa.registerDispose(this);
  }

  public void dispose()
  {
    println("In dispose");
    in.close();
    minim.stop();
    exit();
  }
}


