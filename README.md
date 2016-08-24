# Socket

Socket is a Mac app that establishes a socket listening for commands 
(START and STOP) on port 6653.
After receiving a START command it starts a countdown with an adjustable 
duration.
The countdown will be displayed in the menu bar by default and can 
additionally take place in a panel.
The app has been written for a very particluar use case in an automated
environment and is rather a prototype than a full fledged app. :-)

## Requirements

Written in Objective-C using Xcode 7.3.1 under OS X 10.11.6, I see no 
reason why it shouldn't run on older OS X versions too.
