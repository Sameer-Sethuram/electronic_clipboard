# Electronic Clipboard Project - Sameer Sethuram

This repository contains my code for the Arduino functions and the Processing 3 functions of my electronic clipboard project.

The arduino is meant to function with 3 buttons and a touchpad, in which the touchpad will record penstrokes and movements the user is making as they are writing on paper on top of the clipboard. The buttons serve to change the pen colors, the pen widths, and also as an eraser. The eraser function would work better with a more sensitive touchpad, but seeing as though this was my last touchpad that I had for the project at the time, I couldn't change it. The file in which this is all done is the touchpad_sender file, named touchpad_sender because it sends touchpad data to the computer so that the touchpad_receiver file can interpret the instructions coming in.

Processing 3 is used to create the digital visual aspect of the electronic clipboard, as the main purpose of this project is to print analog penstrokes to the computer's notes. Processing 3 creates a digital canvas, one in which every penstroke is recorded. Performance of this touchpad_receiver file isn't great because during testing, we found that oftentimes, the user will rest their hand on the touchpad itself, creating false penstroke inputs. 

