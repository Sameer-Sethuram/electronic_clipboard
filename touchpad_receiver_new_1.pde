/*
  "touchpad_receiver.pde"
  Copyright (C) 2021 lingib
  Last update 14 July 2021.
 
  This sprogram works in conjuntion with an Arduino program called
  "touchpad_receiver.ino".
  
  All four-wire touchpad keystrokes from the Arduino are displayed 
  in a graphics window.
  
  I addition, a valid gcode file called "drawing.gcode" is 
  created in the same folder as this program.
 
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

// ======================
// globals
// ======================

// ----- serial port
import processing.serial.*;             // Import the serial library
import java.lang.Math;
Serial myPort;                          // Name of Serial port object
final int Baud_rate = 115200;           // Communication speed
boolean Connected = false;              // Flag          

// ----- display graphics
PGraphics Canvas;                       // Name of drawing area

// ----- Create  data filename
PrintWriter drawing;                    // Name of data file
String Input_string;                    // For incoming data 
int lastX = 0;                          // Incoming data
int lastY = 0;
int count = 0;

// ----- Button coordinates
int exitLeft = 500;
int exitRight = 600;
int buttonHeight = 750;

// ----- Screen coordinates
int Xpos;
int Ypos;

// ----- Function Triggers
int f1_trig;
int f2_trig;
int f3_trig;
int f4_trig;
int f5_trig;

// ----- Function counters
int f1_counter = 0;
int f2_counter = 0;
int f3_counter = 1;
int f4_counter = 0;
int f5_counter = 0;

// ----- Flags
boolean penDown  = false;
boolean exitFlag = false;

// ----- Software timer
long timer;                                                  // Automatic pen up
long delay = 0;                                           // time before pen lifts

// ======================
// setup
// ======================
void setup() 
{
  // ----- image window
  size(600, 800); // 1110, 1380 alternate dimensions for shifter maybe (???)

  // ----- Create drawing area
  Canvas = createGraphics(width, height);  

  // ----- Create data file
  drawing = createWriter("drawing.gcode");

  // ----- Initialize the serial port
  printArray(Serial.list());                                // Lists your COM ports on screen
  myPort = new Serial(this, Serial.list()[2], Baud_rate);
  if (myPort == null) { println("wut\n"); }
  myPort.bufferUntil('\n');
}

// ======================
// draw
// ======================
void draw() 

{
  background(255);                                          // White background
  image(Canvas, 0, 0);                                      // Display "canvas" image

  // ----- Automatic pen up
  if ((Xpos == 0) && (Ypos == 0)) {                         // Default code from Arduino while pen up
    if (millis() > (timer + delay)) {
      if (penDown) {
        println("Pen up");
        penDown = false;
      }
      count = 0;
    }
  }

  // ----- Close file
  /*if (exitFlag == true) {
    drawing.println("G00 X0 Y0");
    if (penDown) {
      penDown = false;
      println("Pen up");
    }
    println("G00 X0 Y0");
    drawing.flush();
    drawing.close();
    println ("Drawing complete");
    while (true);
    //exit();
  }*/
}

// =======================
// serial event  (called with each Arduino data string)
// =======================
void serialEvent(Serial myPort) {
  /////////////////////////
  //  Look for Arduino   //
  /////////////////////////  

  // ----- Wait for a line-feed
  Input_string = myPort.readStringUntil('\n');

  // ----- Validate string
  if (Input_string != null) {

    // ----- Trim whitespace
    Input_string = trim(Input_string);

    ////////////////////////////
    //   Connect to Arduino   //
    ////////////////////////////

    // ----- Check if Arduino connected
    if (Connected == false) { 

      // ----- Set flag if not connected
      if (Input_string.equals("S")) {
        Connected = true;                                  // Connection made

        // ----- request data
        myPort.clear();                                    // Clear the receive buffer
        myPort.write("S");         //request data
      }
    } else {

      ///////////////////////////
      //   Process the data    //
      ///////////////////////////

      // ----- Extract XY coordinates
      Input_string = trim(Input_string);                   // Remove leading/trailing whitespace 
      int[] values = int(split(Input_string, ','));
      Xpos = values[0];
      Ypos = values[1];
      f1_trig = values[2];
      f2_trig = values[3];
      f3_trig = values[4];    
      f4_trig = values[5];
      f5_trig = values[6];
      
      if (f2_trig == 1) {          // ------ Checks to see if the second button has been triggered
        f2_counter++;
        if (f2_counter > 3) {          
          f2_counter = 0;        // ----- Sets the counter back to 0 if it goes over 3
        }
      }
      
      if (f3_trig == 1) {          // ------ Checks to see if the 3rd button has been triggered
        f3_counter++;
        if (f3_counter > 6) {
          f3_counter = 1;
        }
      }
      
      if (f1_trig == 1) {             // ----- Checks to see if the button has been triggered
        f1_counter++;
        if (f1_counter > 1) {
          f1_counter = 0;
        }
      }
      

      // ----- Validate data from Arduino
      if ((Xpos != 0) && (Ypos != 0)) {                     // Ignore zero readings when Arduino starts

        // ----- Check for button push
        /*if (Ypos > buttonHeight) {                          // Buttons are across the top 50 screen pixels

          // ----- Check eXit button
          if ((Xpos > exitLeft) && (Xpos < exitRight)) {     // Horizontal button position
            count = 0;
            exitFlag = true;
            delay(1000);
          }
        }*/
        
        //count = 0; DO NOT UNCOMMENT THIS (USUALLY IDRK)

        // ----- Automatic pen down
        if ((Xpos > 0) && (Ypos > 0)) {
          if ((penDown == false) && (!exitFlag))
            println("Pen down");
          penDown = true;
          timer = millis();                                   // Record each pen touch ... draw() loop raises pen
        }


        // ----- Check if we are starting to plot
        
        if (count == 0) {
          lastX = Xpos;
          lastY = Ypos;
        }

        // ----- Validate screen coordinate
        if ((Ypos > 0) && (Ypos < buttonHeight)) {             // Default coordinate is (0,0)

          // ----- Display pen strokes in the Processing Window
          if (penDown == true) {
            Canvas.beginDraw();
            
            
            if (f2_counter == 0) {      // ----- Sets the pen color to black
              Canvas.stroke(0, 0, 0);
            }
            else if (f2_counter == 1) {      // ----- Sets the pen color to red
              Canvas.stroke(255, 0, 0);
            }
            else if (f2_counter == 2) {      // ----- Sets the pen color to green
              Canvas.stroke(0, 255, 0);
            }
            else {                      // ----- Sets the pen color to blue
              Canvas.stroke(0, 0, 255);
            }
            
            if (f3_counter == 1) {               // ----- Sets the pen weight to 1
              Canvas.strokeWeight(f3_counter);
            }
            else if (f3_counter == 2) {          // ----- Sets the pen weight to 2
              Canvas.strokeWeight(f3_counter);
            }
            else if (f3_counter == 3) {          // ----- Sets the pen weight to 3
              Canvas.strokeWeight(f3_counter);
            }
            else if (f3_counter == 4) {          // ----- Sets the pen weight to 4
              Canvas.strokeWeight(f3_counter);
            }
            else if (f3_counter == 5) {          // ----- Sets the pen weight to 5
              Canvas.strokeWeight(f3_counter);
            }
            else {                               // ----- Sets the pen weight to 6
              Canvas.strokeWeight(f3_counter);
            }
            
            if (f1_counter == 1) {             // ----- Erase Method
              Canvas.stroke(255, 255, 255);
              Canvas.strokeWeight(10);
            }
            
            /*if (f4_trig == 1 ) {
              f4_counter++;
              if (f4_counter > 1) {
                f4_counter = 0;
              }
            }
            if (f4_counter == 1 ) {
              Xpos += 510;
            }
            
            if (f5_trig == 1 ) {
              f5_counter++;
              if (f5_counter > 1) {
                f5_counter = 0;
              }
            }
            if (f5_counter == 1) {
              Ypos += 580;
            }*/
            
            //Canvas.stroke(0, 0, 255);
            //Canvas.strokeWeight(4);
            
            double distXsqr = Math.pow((double)(Xpos - lastX), 2); // Calculates the square of the displacement of the X coordinate
            double distYsqr = Math.pow((double)(Ypos - lastY), 2); // Calculates the square of the displacement of the Y coordinate
            double distance = Math.sqrt(distXsqr + distYsqr); // Calculates the overall distance of the line
            if (distance < 25) {
              Canvas.line(lastX, height-lastY, Xpos, height-Ypos);  // Write a conditional here that analyzes if the line is too long in a too short period of time. Use distance formula with XPos and YPos.
            } 
            
            else {
              myPort.clear();                                            // Clear the receive buffer
              myPort.write("S");
              return;
            }
            
            Canvas.endDraw();
          }

          // ------ Generate matching gcode
          if (count == 0) {                                     // New object ?
            
            // ----- Move to location (pen up)
            drawing.print("G00 X");                             // Move to start coordinate with the pen up
            drawing.print(Xpos);
            drawing.print(" Y");
            drawing.println(Ypos);
            print("G00 X");                                      // Move to start coordinate with the pen up
            print(Xpos);
            print(" Y");
            println(Ypos);
                       
            // ----- Pen down
            drawing.print("G01 X");                                     // Now lower the pen
            drawing.print(Xpos);
            drawing.print(" Y");
            drawing.println(Ypos);
            print("G01 X");                                     // Now lower the pen
            print(Xpos);
            print(" Y");
            println(Ypos);

          }
          if ((lastX != Xpos) || (lastY != Ypos)) {            // Avoid duplicate lines
          
            // ----- Draw line to next coordinate
            drawing.print("G01 X");                                     // Now lower the pen
            drawing.print(Xpos);
            drawing.print(" Y");
            drawing.println(Ypos);
            print("G01 X");                                     // Now lower the pen
            print(Xpos);
            print(" Y");
            println(Ypos);
          }

          // ----- Housekeeping
          count++;
          lastX = Xpos;
          lastY = Ypos;
        }
      }
    }

    // -----Request next coordinates
    myPort.clear();                                            // Clear the receive buffer
    myPort.write("S");
  }
}
