// Ryota Kato 2020-12-29
// Reference: 
// LICENCE: MIT


import themidibus.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;

MidiBus myBus;
int ccVal = 0;
int ccVal_old;
int ccNum = 20;
int cc = 20;
int msgArrPosition = 0;
HashMap<Integer, Integer> keyandCC = new HashMap<Integer, Integer>();
float msgArr[] = {0,0,0,0,0,0,0};
int ccArr[] = {20,21,22,23,24,25,26,27};
HashMap<Integer, Integer> ccCounter = new HashMap<Integer, Integer>();

void setup() {
    size(300, 300);
    background(255);
    MidiBus.list();
    myBus = new MidiBus(this, -1, 2);
    oscP5 = new OscP5(this,12000);

    for(int i = 0; i < 7; i++){
      keyandCC.put(i, cc);
      cc += 1;
    }
    println(keyandCC);

    for(int i: ccArr) {
      ccCounter.put(i, 0);
    }
    println(ccCounter);
}

void draw() {
  frameRate(0.3);

  // Use Keyboard to test
  // if(ccVal != ccVal_old){
  //    for (int i = 0; i < 2; i++){
  //       if(msgArr[msgArrPosition] >= 0.5) {
  //         controllerChange(0, ccNum, 127); 
  //       } else {
  //         controllerChange(0, ccNum, 0); 
  //       }
  //       ccNum += 1;
  //   }

  //   println(msgArr[msgArrPosition]);
  //   if(msgArr[msgArrPosition] >= 0.5) {
  //         println("on");
  //         controllerChange(0, keyandCC.get(msgArrPosition), 127); 
  //     } else {
  //         println("off");
  //         controllerChange(0, keyandCC.get(msgArrPosition), 0); 
  //     }
  // }
  // ccVal_old = ccVal;

  for(int i = 0; i < 7; i++){
    if(msgArr[i] >= 0.7) {
      if(ccCounter.get(ccArr[i]) == 0) {
        controllerChange(0, ccArr[i], 127); 
        ccCounter.put(ccArr[i], 1);
        println(ccCounter);
        println("MIDI ON");
      } else if(ccCounter.get(ccArr[i]) == 1) {
        controllerChange(0, ccArr[i], 0); 
        ccCounter.put(ccArr[i], 0);
        println(ccCounter);
        println("MIDI OFF");
      }
    }
    msgArr[i] = 0;
  }
}

void controllerChange(int channel, int number, int value) {
    myBus.sendControllerChange(channel, number, value);
    println("Channel : " + channel + "\nCC number : " + number + "\nvalue : " + value);
}

// for testing
// void keyPressed(){
//   int keyNum = Character.getNumericValue(key);

//   if(keyNum == 1) {
//     msgArrPosition = 0;
//   } else if(keyNum == 2) {
//     msgArrPosition = 1;
//   } else if(keyNum == 3) {
//     msgArrPosition = 2;
//   } else if(keyNum == 4) {
//     msgArrPosition = 3;
//   } else if(keyNum == 5) {
//     msgArrPosition = 4;
//   } else if(keyNum == 6) {
//     msgArrPosition = 5;
//   } else if(keyNum == 7) {
//     msgArrPosition = 6;
//   } else {
//     println("wrong key input");
//   }
//   println("msgArrPosition:" + msgArrPosition);

//   if (ccVal == 0){
//     ccVal = 127;
//   } else {
//     ccVal = 0;
//   }
// }

void oscEvent(OscMessage theOscMessage) {
  // println("theOscMessage is ");
  // println(theOscMessage);
  // println("\n");
  if(theOscMessage.checkTypetag("ffffff")) {
    // println("This is" + theOscMessage.checkTypetag("fffff")); trueが帰ってくる
    for (int i = 0; i <=5; i++){
      // println("OscMessage float value for CC" + ccArr[i]+ " is " + theOscMessage.get(i).floatValue());
      println(i);
      if(i < 5) {
        msgArr[i] = theOscMessage.get(i).floatValue();
      }
      // println("theOscMessage");
      // println(theOscMessage.get(i).floatValue());
      // println(msgArr);
    }
  }
}
