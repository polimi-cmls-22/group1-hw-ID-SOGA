/*
This sketch reads input (in 0-1023 range) from photoresistors.
When a photoresistor reads between a given THRESHOLD value then 
that string has been touched.

Using pins 3,5,6,9,10,11 for the laser diodes because they have pwm.
The 6 analog input pins are for the photoresistors.

This sketch sends just the index ("0", "1", ..., "5") of the string 
that's being played over serial protocol.
*/

// threshold for photoresistor values
#define PRINT_ANALOG false // FOR DEBUGGING, set to true to print values read from the pins
int THRESHOLD[] = {280, 280, 280, 280, 280, 280};

// a boolean for each photoresistors that is set to true when the light
// is blocked. This is to avoid re-triggering the same string multiple times
bool onStrings[6] = {false, false, false, false, false};

void setup() {
  Serial.begin(9600);

  // turn on laser diodes
  pinMode(3, OUTPUT);
  analogWrite(3, 80);
  pinMode(5, OUTPUT);
  analogWrite(5, 80);
  pinMode(6, OUTPUT);
  analogWrite(6, 80);
  pinMode(9, OUTPUT);
  analogWrite(9, 80);
  pinMode(10, OUTPUT);
  analogWrite(10, 80);
  pinMode(11, OUTPUT);
  analogWrite(11, 80);

  delay(1500);
}

void loop() {
  // read photoresistor values
  for(int i=0; i<6; i++){
    int val = analogRead(i);
    // check value read: if under threshold and if the ON message has not been sent yet
    if(val<THRESHOLD[i] && !onStrings[i]){
      onStrings[i] = true;
      Serial.print((String) i);
      if(PRINT_ANALOG) Serial.print('='+(String) val + '\n');
    }
    if(val>=THRESHOLD[i] && onStrings[i]){ // reset string state
      onStrings[i] = false;
    }
  }
  delay(5);
}
