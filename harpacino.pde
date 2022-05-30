import controlP5.*;
import oscP5.*;
import netP5.*;
import processing.serial.*;

Serial serialPort;

PImage harpImage;
PImage backImage;

RadioButton rbScales;
RadioButton rbBaseNote;
RadioButton rbOctave;

ControlP5 cp5;
OscP5 oscP5;
NetAddress myRemoteLocation;
void setup() {
  size(880, 586);
  //frameRate(7);
  
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
  
  String portName = Serial.list()[0]; // THE SKETCH ONLY RUNS IF AN ARDUINO IS CONNECTED
  serialPort = new Serial(this, portName, 9600);
  
  int harpWidth = 380;
  int harpHeight = 570;
  noFill();
  
  backImage = loadImage("ireland.jpeg");
  background(backImage);
  
  //280x419
  harpImage = loadImage("harp.png");
  harpImage.resize(harpWidth, harpHeight);
  
  cp5 = new ControlP5(this);
    
   PFont pfontLabel = createFont("Georgia-Bold", 18);
   PFont pfontRButton = createFont("Georgia-Bold", 11);
   PFont pfontBaseNote = createFont("Georgia-Bold", 14);  
   Textlabel scalesLabel = cp5.addTextlabel("scalesLabel")
                    .setText("Scales:")
                    .setPosition(20,0)
                    .setColor(color(130, 60, 130))
                    .setFont(pfontLabel);
                    
   rbScales = cp5.addRadioButton("rbScales")
         .setPosition(20,25)
         .setSize(50,30)
         .setColorForeground(color(180, 129, 183))
         .setColorBackground(color(240, 201, 201))
         .setColorActive(color(130, 60, 130))
         .setColorLabel(color(97, 9, 97))
         .setSpacingRow(5)
         .addItem("Major Blues",Scale.MAJOR_BLUES.toInt())
         .addItem("Minor Blues",Scale.MINOR_BLUES.toInt())
         .addItem("Pentatonic Minor", Scale.MINOR_PENTATONIC.toInt())
         .addItem("Whole Tone Scale",Scale.WHOLE_TONE.toInt())
         .addItem("Phrygian",Scale.PHRYGIAN.toInt());
         
   for(Toggle t:rbScales.getItems()) 
   {
       t.setFont(pfontRButton);
   }
   
   rbScales.activate(1);
   
   Textlabel baseNoteLabel = cp5.addTextlabel("baseNoteLabel")
                .setText("Base notes:")
                .setPosition(220,0)
                .setColor(color(130, 60, 130))
                .setFont(pfontLabel);
                           
   rbBaseNote = cp5.addRadioButton("rbBaseNote")
         .setPosition(220,25)
         .setSize(50,30)
         .setColorForeground(color(180, 129, 183))
         .setColorBackground(color(240, 201, 201))
         .setColorActive(color(130, 60, 130))
         .setColorLabel(color(97, 9, 97))
         .setSpacingRow(5)
         .addItem("C", 0)
         .addItem("C#", 1)
         .addItem("D", 2)
         .addItem("D#", 3)
         .addItem("E", 4)
         .addItem("F", 5)
         .addItem("F#", 6)
         .addItem("G", 7)
         .addItem("G#", 8)
         .addItem("A", 9)
         .addItem("A#", 10)
         .addItem("B", 11);
   int baseNoteIndex = 0;
   for(Toggle t:rbBaseNote.getItems()) 
   {
       t.setFont(pfontBaseNote);
       if (baseNoteIndex >= 7 )
       {
         t.setColorLabel(color(255, 230, 230));
       }
       baseNoteIndex++;
   }
   
   rbBaseNote.activate(0);
   
   Textlabel octaveLabel = cp5.addTextlabel("octaveLabel")
                .setText("Octaves:")
                .setPosition(360,0)
                .setColor(color(130, 60, 130))
                .setFont(pfontLabel);
                
   rbOctave = cp5.addRadioButton("rbOctave")
         .setPosition(360,25)
         .setSize(50,30)
         .setColorForeground(color(180, 129, 183))
         .setColorBackground(color(240, 201, 201))
         .setColorActive(color(130, 60, 130))
         .setColorLabel(color(97, 9, 97))
         .setSpacingRow(5)
         .addItem("     2 octave", 0)
         .addItem("     3 octave", 1)
         .addItem("     4 octave", 2)
         .addItem("     5 octave", 3)
         .addItem("     6 octave", 4);
   rbOctave.activate(2);
   for(Toggle t:rbOctave.getItems()) 
   {
       t.setFont(pfontRButton);
   }
}

//y(x,t) = A sin(kx - ωt) + A sin(kx + ωt) = 2A sin(kx)cos(ωt).
boolean[] stringsState = {false, false, false, false, false, false};

void draw() 
{
  background(backImage);
  image(harpImage, (width - harpImage.width)/2 + 210, 0);
  
  //TODO:
  if(serialPort.available()>0)
  {
    int stringIndex = int(str(serialPort.readChar())); // read index of string that's being played
    stringPlucked(stringIndex);
    redrawState(stringIndex);
  }
  
  checkTime();
  
  drawString1(stringsState[0]);
  drawString2(stringsState[1]);
  drawString3(stringsState[2]);
  drawString4(stringsState[3]);
  drawString5(stringsState[4]);
  drawString6(stringsState[5]);
}

void checkTime()
{
  int currentTime = millis();
  int passedTime = currentTime - savedTime1;
  if (passedTime > totalTime) 
  {
    stringsState[0] = false;
  }
  
  passedTime = currentTime - savedTime2;
  if (passedTime > totalTime) 
  {
    stringsState[1] = false;
  }
  
  passedTime = currentTime - savedTime3;
  if (passedTime > totalTime) 
  {
    stringsState[2] = false;
  }
  
  passedTime = currentTime - savedTime4;
  if (passedTime > totalTime) 
  {
    stringsState[3] = false;
  }
  
  passedTime = currentTime - savedTime5;
  if (passedTime > totalTime) 
  {
    stringsState[4] = false;
  }
  
  passedTime = currentTime - savedTime6;
  if (passedTime > totalTime) 
  {
    stringsState[5] = false;
  }
}

void draw_curve_from_points(int[] _points) 
{ 
  int len = _points.length;
  beginShape();
  curveVertex(_points[0], _points[1]);  // the first point is used as control point
  for (int i = 0; i < len; i +=2) {
    curveVertex(_points[i], _points[i+1]);
  }
  curveVertex(_points[len-2], _points[len-1]);  // the last point is used as control point
  endShape();
}

void draw_line_from_points(int[] _points) 
{  
  line(_points[0], _points[1], _points[2], _points[3]);
}

int totalTime = 2000;

int savedTime1;
boolean flag1 = false;
void drawString1( boolean state )
{
  int startX = 540; 
  int startY = 60;
  
  int endX = 590; 
  int endY = 458;
  
  if (state)
  { 
    if (flag1)
     {
        int[] points = {startX, startY, endX, endY,};
        draw_line_from_points(points);
     }
     else
     {
        int[] points = {startX, startY, startX+15, (endY - startY)/3, startX+35, (endY - startY)/3*2, endX, endY,};
        draw_curve_from_points(points);
     }   
     flag1 = !flag1;
  }
  else
  {
     int[] points = {startX, startY, endX, endY,};
     draw_line_from_points(points);
  };
}

int savedTime2;
boolean flag2 = false;
void drawString2( boolean state )
{
  int startX = 580; 
  int startY = 65;
  
  int endX = 623; 
  int endY = 419;
  
  if (state)
  {
    if (flag2)
     {
        int[] points = {startX, startY, endX, endY,};
        draw_line_from_points(points);
     }
     else
     {
        int[] points = {startX, startY, startX+10, (endY - startY)/3, startX+30, (endY - startY)/4*3, endX, endY};
        draw_curve_from_points(points);
     }   
     flag2 = !flag2;
  }
  else
  {
     int[] points = {startX, startY, endX, endY,};
     draw_line_from_points(points);
  }
}

int savedTime3;
boolean flag3 = false;
void drawString3( boolean state )
{
  int startX = 620; 
  int startY = 90;
  
  int endX = 655; 
  int endY = 375;
  
  if (state)
  {
    if (flag3)
     {
        int[] points = {startX, startY, endX, endY,};
        draw_line_from_points(points);
     }
     else
     {
        int[] points = {startX, startY, startX+20, startY + (endY - startY)/3, startX+30, startY + (endY - startY)/3*2, endX, endY};
        draw_curve_from_points(points);
     }   
     flag3 = !flag3;
  }
  else
  {
     int[] points = {startX, startY, endX, endY,};
     draw_line_from_points(points);
  }
}

int savedTime4;
boolean flag4 = false;
void drawString4( boolean state )
{
  int startX = 660; 
  int startY = 142;
  
  int endX = 685; 
  int endY = 336;
  
  if (state)
  {
    if (flag4)
     {
        int[] points = {startX, startY, endX, endY,};
        draw_line_from_points(points);
     }
     else
     {
        int[] points = {startX, startY, startX+15, startY + (endY - startY)/3, startX+25, startY + (endY - startY)/3*2, endX, endY,};
        draw_curve_from_points(points);
     }   
     flag4 = !flag4;
  }
  else
  {
     int[] points = {startX, startY, endX, endY,};
     draw_line_from_points(points);
  }
}

int savedTime5;
boolean flag5 = false;
void drawString5( boolean state )
{
  int startX = 700; 
  int startY = 180;
  
  int endX = 715; 
  int endY = 298;
  
  if (state)
  {
    if (flag5)
     {
        int[] points = {startX, startY, endX, endY,};
        draw_line_from_points(points);
     }
     else
     {
        int[] points = {startX, startY, startX+10, startY + (endY - startY)/3, startX+15, startY + (endY - startY)/3*2, endX, endY,};
        draw_curve_from_points(points);
     }   
     flag5 = !flag5;
  }
  else
  {
     int[] points = {startX, startY, endX, endY,};
     draw_line_from_points(points);
  };
}

int savedTime6;
boolean flag6 = false;
void drawString6( boolean state )
{
  int startX = 735; 
  int startY = 185;
  
  int endX = 744; 
  int endY = 260;
  
  if (state)
  {
    if (flag6)
     {
        int[] points = {startX, startY, endX, endY,};
        draw_line_from_points(points);
     }
     else
     {
        int[] points = {startX, startY, startX + 7, startY + (endY - startY)/4, startX + 11, startY + (endY - startY)/3*2, endX, endY,};
        draw_curve_from_points(points);
     }   
     flag6 = !flag6;
  }
  else
  {
     int[] points = {startX, startY, endX, endY,};
     draw_line_from_points(points);
  };
}
  
void keyPressed() 
{
  if (key == 'f')
  {
    redrawState(0);
    stringPlucked(0);
  }
  else if (key == 'g')
  {
    redrawState(1);
    stringPlucked(1);
  }
  else if (key == 'h')
  {
    redrawState(2);
    stringPlucked(2);
  }
  else if (key == 'j')
  {
    redrawState(3);
    stringPlucked(3);
  }
  else if (key == 'k')
  {
    redrawState(4);
    stringPlucked(4);
  }
  else if (key == 'l')
  {
    redrawState(5);
    stringPlucked(5);
  }
}

void redrawState(int note)
{
  stringsState[note] = false;
  redraw();
    
  stringsState[note] = true;
  flag1 = false;
  flag2 = false;
  flag3 = false;
  flag4 = false;
  flag5 = false;
  flag6 = false;
  redraw();
}

void stringPlucked(int note) 
{
  switch (note)
  {
    case(0):
    savedTime1 = millis();
    break;
    case(1):
    savedTime2 = millis();
    break;
    case(2):
    savedTime3 = millis();
    break;
    case(3):
    savedTime4 = millis();
    break;
    case(4):
    savedTime5 = millis();
    break;
    case(5):
    savedTime6 = millis();
    break;
  }
  
  OscMessage myMessage = new OscMessage("/stringPlucked");
  myMessage.add(computeFrequency(getCurrentScale(), note ));
  oscP5.send(myMessage, myRemoteLocation); 
}

Scale defaultScale = Scale.MINOR_BLUES;
public enum Scale 
{
    MAJOR_BLUES(0), 
    MINOR_BLUES(1), 
    MINOR_PENTATONIC(2),
    WHOLE_TONE(3),
    PHRYGIAN(4);
    
    private final int code;

    private Scale(int code) {
        this.code = code;
    }

    public int toInt() {
        return code;
    }

     public static Scale fromInt(int scale) {
        switch(scale) {
        case 0:
            return MAJOR_BLUES;
        case 1:
            return MINOR_BLUES;
        case 2:
            return MINOR_PENTATONIC;
        case 3:
            return WHOLE_TONE;
        case 4:
            return PHRYGIAN;
        default:
            return MINOR_BLUES;
        }
    }
};

int notes_in_scale = 6;

int major_blues_pattern[] = {0, 2, 3, 4, 7, 9};
int minor_blues_pattern[] = {0, 3, 5, 6, 7, 10};
int minor_pentatonic_pattern[] = {0, 3, 5, 7, 10, 12};
int whole_tone_pattern[] = {0, 2, 4, 6, 8, 10};
int phrygian_pattern[] = {0, 1, 3, 7, 8, 10};

//frequencies of the C pitch in octaves from 2-6
float baseCFreq[] = {65.406, 130.813, 261.626, 523.251, 1046.502};

Scale getCurrentScale()
{
  int currentScale = (int)rbScales.getValue();
  return Scale.fromInt(currentScale);
}

float computeBaseNoteFrequency()
{
  int octave = (int) rbOctave.getValue();
  if (octave >= 0 && octave < baseCFreq.length )
  {
    float baseC = baseCFreq[octave];
    int baseNote = (int) rbBaseNote.getValue();
    return baseC * (float) Math.pow(2, baseNote / 12.0f);
  }
  return baseCFreq[0];
}

float computeFrequency(Scale scale, int note)
{
  int numSemitones = 0;
  if (note >= 0 && note < notes_in_scale)
  {
    switch (scale)
    {
      case MAJOR_BLUES:
        numSemitones= major_blues_pattern[note];
      break;
      case MINOR_BLUES:
        numSemitones= minor_blues_pattern[note];
      break;
      case MINOR_PENTATONIC:
        numSemitones= minor_pentatonic_pattern[note];
      break;
      case WHOLE_TONE:
        numSemitones= whole_tone_pattern[note];
      break;
      case PHRYGIAN:
        numSemitones= phrygian_pattern[note];
      break;
      default:
      break; 
    } 
  }
  
  float freq = computeBaseNoteFrequency() * (float)Math.pow(2, numSemitones / 12.0f );
  return freq;
}
