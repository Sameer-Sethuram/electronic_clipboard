/*
 "touchpad_sender.ino"
 Copyright (C) 2021 lingib
 Last update 14 July 2021.
 
 This program sends any stylus touch made to a four-wire 
 resistive touchpad to a matching Processing 3 pr0gram called  
 "touchpad_receiver.pde"

 ----------
 Copyright
 ----------
 This is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This software is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License. If 
 not, see <http://www.gnu.org/licenses/>.
 */
// ------------
//  Globals
// ------------

// ----- Touchpad connections
const int Left = 14;                    // Arduino pin A0
const int Bottom  = 15;                 // Arduino pin A1
const int Right = 16;                   // Arduino pin A2
const int Top = 17;                     // Arduino pin A3

// ----- Touchpad coordinates
int Xpos = 0;
int Ypos = 0;
int Last_Xpos = 0;
int Last_Ypos = 0;

// ---- Serial connections
const long Bauds = 115200L;             // Serial baud rate

// ------------
//  setup()
// ------------
void setup() {
  Serial.begin(Bauds);

  // ----- attach the graphics display
  connect_to_display();                 //connect to the display

}

// ------------
//  loop()
// ------------
void loop() {

  // ----- has the display asked for data
  if (Serial.available() > 0)
  {
    char character = Serial.read();     // read character

    // ----- send data to display whenever a send character ('S') is received
    if (character == 'S') {

      // ---- Check touchpad
      touchpad();
      //calibrate();

      Serial.print(Xpos);
      Serial.print(',');
      Serial.println(Ypos);
    }
  }
}

// ------------
//  touchpad()
// ------------
void touchpad() {
  // ----- Apply volts across Y-axis
  pinMode(Top, OUTPUT);
  pinMode(Bottom, OUTPUT);
  digitalWrite(Top, HIGH);
  digitalWrite(Bottom, LOW);
  pinMode(Left, INPUT);
  pinMode(Right, INPUT);

  // ----- Calculate Y-coordinate
  int y = constrain(analogRead(Left), 61, 958);
  Ypos = map(y, 61, 958, 0, 800);

  // ----- Apply volts across X-axis
  pinMode(Left, OUTPUT);
  pinMode(Right, OUTPUT);
  digitalWrite(Left, HIGH);
  digitalWrite(Right, LOW);
  pinMode(Top, INPUT);
  pinMode(Bottom, INPUT);

  // ----- Calculate X-coordinate
  int x = constrain(analogRead(Bottom), 95, 912);
  Xpos = map(x, 95, 912, 0, 600);
}

// ------------
//  calibrate()
// ------------
void calibrate() {
  // ----- Apply volts across Y-axis
  pinMode(Top, OUTPUT);
  pinMode(Bottom, OUTPUT);
  digitalWrite(Top, HIGH);
  digitalWrite(Bottom, LOW);
  pinMode(Left, INPUT);
  pinMode(Right, INPUT);

  // ----- Calculate Y-coordinate
  Ypos = analogRead(Left);

  // ----- Apply volts across X-axis
  pinMode(Left, OUTPUT);
  pinMode(Right, OUTPUT);
  digitalWrite(Left, HIGH);
  digitalWrite(Right, LOW);
  pinMode(Top, INPUT);
  pinMode(Bottom, INPUT);

  // ----- Calculate X-coordinate
  Xpos = analogRead(Bottom);
}

// ===============================
// connect to graphics display
// ===============================
void connect_to_display()
{
  while (Serial.available() <= 0)
  {
    // ----- keep sending synch ('S') until the display responds
    Serial.println("S");
    delay(250);
  }
}
