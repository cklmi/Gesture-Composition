#define CONTROL_CHANGE 176
#define ALL_NOTE_OFF 120
#define COUNTOF(array) (sizeof(array) / sizeof(array[0]))

void sendMidi(int cmd, int pitch, int velocity) {
  Serial.write(cmd);
  Serial.write(pitch);
  Serial.write(velocity);
}

//button
int buttonPin[] = {2, 3, 4, 5};     // the number of the pushbutton pin
int cc_of_button[] = {12, 13, 14, 15};
int buttonState[] = {LOW, LOW, LOW, LOW}; // variable for reading the pushbutton status
int button_sate_old[] = {LOW, LOW, LOW, LOW}; // variable for save previous status

void setup() {
  // button
  for(int i=0; i<COUNTOF(buttonPin); i++){
    pinMode(buttonPin[i], INPUT);
  }
  Serial.begin(31250);
  //sendMidi(CONTROL_CHANGE, ALL_NOTE_OFF, 0);
}

void loop() {
  // buttons
  for(int i=0; i<COUNTOF(buttonPin); i++){
    button_sate_old[i] = buttonState[i];
    buttonState[i] = digitalRead(buttonPin[i]);
  
    // check if the pushbutton is pressed. If it is, the buttonState is HIGH:
    if (buttonState[i] != button_sate_old[i]) {
      if (buttonState[i] == HIGH) {
       sendMidi(CONTROL_CHANGE, cc_of_button[i], 127); 
      } else {
        sendMidi(CONTROL_CHANGE, cc_of_button[i], 0);
      }
    }
  }
//  // Flex Sensor
//  // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  //print out the value you read:
  if(sensorValue < 670){
    sensorValue=670;
  }else if(sensorValue > 730){
    sensorValue=730;
  }
//  int pos = map(sensorValue, 670, 730, 0, 127);
//  if(pos < 2){
//    pos = 0;
//  }
  int pos = map(sensorValue, 670, 730, 127, 0);
  
  if(pos > 125){
    pos = 127;
  }
  sendMidi(CONTROL_CHANGE, 29, pos);
  delay(1);
}
