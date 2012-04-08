//QuantumOfSound
//Rajarshi Roy and Niraj Chaubal

import pbox2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

//constants
static int LEFT = 0;
static int RIGHT = 1;

int state=0; //0: no boundaries 1: have  boundaries

color[] noteColors = {#FF001E, //C
                      #FF380F, //C#
                      #FF6F00, //D
                      #FFB700, //D#
                      #FFFF00, //E
                      #10C900, //F
                      #08A550, //F#
                      #00809F, //G
                      #0E4ECF, //G#
                      #1B1BFF, //A
                      #4A10C6, //A#
                      #78058D};//B

//globals
Minim minim;
AudioInput input;
FFT fft;

// A reference to our box2d world
PBox2D box2d;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
// A list for all of our rectangles
ArrayList<Circle> circles;

void setup() {
  size(600,400);
  smooth();

  //Initialize minim
  minim = new Minim(this);
  input = minim.getLineIn();
  fft = new FFT(input.bufferSize(),input.sampleRate());

  // Initialize box2d physics and create the world
  box2d = new PBox2D(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, 30);

  // Create ArrayLists	
  circles = new ArrayList<Circle>();
  boundaries = new ArrayList<Boundary>();

  //Boundary with holes on two sides
  //boundaries.add(new Boundary(300,0,500,5));
  
  //Box Boundary
  boundaries.add(new Boundary(300,0,600,5));
  boundaries.add(new Boundary(0,200,5,400));
  boundaries.add(new Boundary(600,200,5,400));
  //boundaries.add(new Boundary(3*width/4,height-50,width/2-50,10));
  boundaries.get(0).killBody();
  boundaries.get(1).killBody();
  boundaries.get(2).killBody();
  boundaries.clear();
}

void draw() {
  background(50);

  // We must always step through time!
  box2d.step();
  
  //FFT 
  detectNote(input.left, LEFT);
  detectNote(input.right, RIGHT);

  // Display all the boundaries
  for (Boundary wall: boundaries) {
    wall.display();
  }

  // Display all the circles
  for (Circle b: circles) {
    b.display();
  }

  // circles that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = circles.size()-1; i >= 0; i--) {
    Circle b = circles.get(i);
    if (b.done()) {
      circles.remove(i);
    }
  }
}

void addCircle(int r, int g, int b, int diam, int lr){
  // circles fall from the top every so often
  if (random(1) < 0.7) {
    Circle p = new Circle(width/4+(width*lr/2),height, r, g, b, diam); //source position
    circles.add(p);
  }  
}

void detectNote(AudioBuffer buffer, int lr){
  fft.forward(buffer);
  int maxfreq = 0;
  for(int i = 0; i < fft.specSize(); i++){
      if(fft.getBand(i)>fft.getBand(maxfreq)){
        maxfreq = i;
      }
    }
    color c = noteColors[maxfreq%12];
    float maxamp = fft.getBand(maxfreq);
    println(maxfreq);
    if((maxamp>12)&&(maxamp<200)&&(maxfreq>1)){
      addCircle((int)red(c),(int)green(c),(int)blue(c),((int)(maxamp)/4)+1,lr);
    }
}

void mouseClicked() {
  state^=1;
  if(state==1){
      boundaries.add(new Boundary(300,0,600,5));
      boundaries.add(new Boundary(0,200,5,400));
      boundaries.add(new Boundary(600,200,5,400));
  }
  else{
      boundaries.get(0).killBody();
      boundaries.get(1).killBody();
      boundaries.get(2).killBody();
      boundaries.clear();
  }
}
