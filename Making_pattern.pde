import fontastic.*;
 
import krister.Ess.*;
 
 
int        bufferSize;
int        steps;
float      limitDiff;
int        numAverages = 32;
float      myDamp = .1f;
float      maxLimit,minLimit;
SoundLayer lowLayer;
SoundLayer midLayer1;
SoundLayer midLayer2;
SoundLayer highLayer;
 
//render type switch
boolean block = true;
 
FFT myFFT;
AudioInput myInput;
 
void setup () {
 size(1000,700);
 smooth();
 // start up Ess
 Ess.start(this);  
 
 // set up our AudioInput
 bufferSize = 512;
 myInput    = new AudioInput(bufferSize);
 
 // set up our FFT
 myFFT      = new FFT(bufferSize*2);
 myFFT.equalizer(true);
 
 // set up our FFT normalization/dampening
 minLimit   = .005;
 maxLimit   = .05;
 myFFT.limits(minLimit,maxLimit);
 myFFT.damp(myDamp);
 myFFT.averages(numAverages);
 
 // get the number of bins per average 
 steps=bufferSize/numAverages;
 
 // get the distance of travel between minimum and maximum limits
 limitDiff=maxLimit-minLimit;
 
 frameRate(5);       
 
 lowLayer  = new SoundLayer(0, 0, 100, #F5A9F2);  //#F5A9F2
 midLayer1 = new SoundLayer(1, 100, 200, #F3F381); //#F3F381
 midLayer2 = new SoundLayer(2, 200, 350, #BCA9F5); //#BCA9F5
 highLayer = new SoundLayer(3, 350, 512,#81F7D8 ); //#81F7D8
 
 myInput.start();
 
 Fontastic f = new Fontastic(this, "WormFont");
 f.setAdvanceWidth(1000);
 
 PVector[] points= new PVector[6];
 points[0] = new PVector(0, 0);
 points[1] = new PVector(0, 150);
 points[2] = new PVector(600, 750);
 points[3] = new PVector(750, 750);
 points[4] = new PVector(750, 600);
 points[5] = new PVector(150, 0);
 
 PVector[] points1 = new PVector[6];
 points1[0] = new PVector(750, 0);
 points1[1] = new PVector(600, 0);
 points1[2] = new PVector(0, 600);
 points1[3] = new PVector(0, 750);
 points1[4] = new PVector(150, 750);
 points1[5] = new PVector(750, 150);
 
 PVector[] points2 = new PVector[6];
 points2[0] = new PVector(0, 375);
 points2[1] = new PVector(150, 480);
 points2[2] = new PVector(600, 480);
 points2[3] = new PVector(750, 375);
 points2[4] = new PVector(600, 270);
 points2[5] = new PVector(150, 270);
 
 PVector[] points3 = new PVector[6];
 points3[0] = new PVector(375, 0);
 points3[1] = new PVector(270, 150);
 points3[2] = new PVector(270, 600);
 points3[3] = new PVector(375, 750);
 points3[4] = new PVector(480, 600);
 points3[5] = new PVector(480, 150);
 
 f.addGlyph('0').addContour(points);
 f.addGlyph('1').addContour(points1);
 f.addGlyph('2').addContour(points2);
 f.addGlyph('3').addContour(points3);
 
 f.buildFont();
 PFont myFont = createFont(f.getTTFfilename(), 64);
 
 textFont(myFont);
 
 myInput.start();
}
 
 
void draw()
{
background(0);
 //fill(0, 100); //TRAILS
 //rect(100, 100, width, height);
// translate (200,100);
 //noStroke();
 
 lowLayer.update();
 midLayer1.update();
 midLayer2.update();
 highLayer.update();
 
 //HERE HERE HERE HERE HERE HERE
 // Saves each frame as line-000001.png, line-000002.png, etc. 
 saveFrame("line-######.png");

}
 
public void audioInputData(AudioInput theInput)
{
 myFFT.getSpectrum(myInput);
}
 
// each glyph is 50 high and large, 
// so they should always be drawn at a i*150 offset
float placeOnGrid(float number){
  float result;
  result = number - number % 50;
  return result;
}
 
class SoundLayer
{
 int lowPoint    = 0;
 int highPoint   = 512;
 int edginess    = 0;
 int objectID    = 0;
 boolean show    = true;
 float threshold = 0.05;
 int color_      = #FFFFFF;
 
  // constructor
  SoundLayer(int _objectID, int _lowPoint, int _highPoint, int _color_){
    lowPoint  = _lowPoint;
    highPoint = _highPoint;
    objectID  = _objectID;
    color_    = _color_;
  };
 
 
void update()
{
 pushMatrix();
   String myText = String.valueOf(objectID);
   fill(color_);
   //looping through only this layer's portion of the sound buffer
   for (int i= lowPoint; i<highPoint; i++)
   {
     float left      =  560; //it was 160
     float right     =  560; //it was 160
     float amplitude =  myFFT.spectrum[i]; //amp at this frequency
     float r         =  random(-50, 55); //it was 255 not 555
     left            -= amplitude*9050.0; //650 changes the size growth of the spectrum lines
     right           -= amplitude*9050.0;//it was 2050
 
     if(false || frameCount % 30 == 0)
     {
       println(amplitude);
       println("LEFT : " + left);
       println("RIGHT: " + right);
     }
 
 
     if(amplitude >= threshold)
     {
      text(myText , placeOnGrid(50 +i)         , placeOnGrid(left*i));
      text(myText , placeOnGrid(0.1*left*i)    , placeOnGrid(i)          , placeOnGrid(-200*i));
      text(myText , placeOnGrid(1000-i)         , placeOnGrid(100*i)      , placeOnGrid(100)      , placeOnGrid(100*right));
      text(myText , placeOnGrid(500+i)         , placeOnGrid(500+i)      , placeOnGrid(100)      , placeOnGrid(1*right));
      text(myText , placeOnGrid(900*sin(left)) , placeOnGrid(600*cos(i)) , placeOnGrid(i*r)      , placeOnGrid(1000*sin(right)));
     }
   }
 
   popMatrix();
 }
}
