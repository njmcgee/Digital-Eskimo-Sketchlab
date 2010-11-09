// Sketchlab for Web Directions, by Nathan McGinness

// Declare image objects, backgrounds etc
PImage bg_start;
PImage bg_draw;
PImage bg_confirm;
PImage penimg;
PImage eraserimg;
PImage square_speaker;

// Declare scribblesquares/buttons
scribbleSquare startsquare;
scribbleSquare cancel;
scribbleSquare savesquare;
scribbleSquare eraser;
scribbleSquare pen;
scribbleSquare edit;
scribbleSquare startagain;
scribbleSquare quit;
scribbleSquare prev;
scribbleSquare next;

// To pass into functions, stroke yes or no
boolean strokeYes = true;
boolean strokeNo = false;

// Arrays containing safe draw zones (x,y,w,h)
int[] safeDrawZone = { 44, 152, 944, 503 };
int[] penZone = { 262, 668, 129, 49 };
int[] finalDisplay = { 138, 203, 749, 399 };

// XML and speaker objects/variables/arrays
XMLElement xml;
int numSpeakers = 35;
int pageTurnM;
int drawM;
Speaker[] speakers = new Speaker[numSpeakers];
String currentSpeakerString;
int currentSpeaker; 
String filename;
// Array of scribblesquare objects for each speaker
scribbleSquare[] speakerSquares = new scribbleSquare[numSpeakers];

// Page based variables
int numPages = 7;
int numSpeakersPerPage = 5;
int currentPage = 0;
int startIndex = 0;
PImage[] pages = new PImage[numPages];
PImage[] speakerText = new PImage[numSpeakers];

// Array of dimensions for speakersquares
int[] box_x = {129,202,401,624,761,92,184,381,584,762,129,202,401,624,761,92,184,381,584,762,129,202,401,624,761,92,184,381,584,762,129,202,401,624,761};
int[] box_y = {344,625,397,626,344,372,620,404,587,352,344,625,397,626,344,372,620,404,587,352,344,625,397,626,344,372,620,404,587,352,344,625,397,626,344};

// Varibles for pen settings
color penColor;
int penWidth = 4;
int eraserWidth = 22;
int sw = penWidth;
color yellow = color (255, 224, 1);
color black = color(0);
color white = color(255);

// This string determines three main program modes
String mode = "start"; // can be "start" "speaker" "draw" "complete"

// Variables for timeout funtionality
int timeCheck;
int timeOut;
int currentTime;
int timeOutDraw = 180000;

// Variables used to stop accidental drawing when when a new page loads
int prevMillis = 0;
int millisSinceLastDraw = 0;
boolean isDelay = false;
int delayMillis = 0;
int delayTime = 10000;

void setup()
{
    // set display params
    ellipseMode(RADIUS);
    size(1024, 768);
    background(255);
    smooth();
    
    // Comment back in for installation to remove cursor!
    //noCursor();    
    
    // load images
    bg_start = loadImage("bg-start.png");
    bg_draw = loadImage("bg-draw.png");
    bg_confirm = loadImage("bg-confirm.png");
    square_speaker = loadImage("square-speaker.png");
    eraserimg = loadImage("eraser.jpg");
    penimg = loadImage("pen.jpg");
    
    pageTurnM = millis();
    
    // initialise buttons
    startsquare = new scribbleSquare(487, 368, 69, 55, 90, strokeNo);    
    cancel = new scribbleSquare(920, 84, 20, 16, 90, strokeNo); // for these black pens the lower the number the more scribble required
    savesquare = new scribbleSquare(917, 683, 22, 18, 120, strokeNo);
    eraser = new scribbleSquare(85, 684, 22, 18, 150, strokeNo);
    pen = new scribbleSquare(277, 682, 22, 18, 100, strokeNo); // for this white pen go higher    
    edit = new scribbleSquare(182, 683, 22, 18, 100, strokeNo);
    startagain = new scribbleSquare(470, 685, 22, 18, 100, strokeNo);
    quit = new scribbleSquare(920, 84, 20, 16, 100, strokeNo);    
    prev = new scribbleSquare(461, 665, 37, 34, 90, strokeNo);
    next = new scribbleSquare(526, 665, 37, 34, 90, strokeNo);
    
    // initialise xml and speakers
    xml = new XMLElement(this, "speakers/speakers.xml");
    
    for (int i = 0; i < numSpeakers; i++) {
        XMLElement kid = xml.getChild(i);
        int id = kid.getIntAttribute("id");
        String img_src = kid.getStringAttribute("image"); 
        String title = kid.getStringAttribute("title"); 
        int talkday = kid.getIntAttribute("day");
        int talkhour = kid.getIntAttribute("hour");
        int talkminute = kid.getIntAttribute("minute");
        String name = kid.getContent();
        speakers[i] = new Speaker(id, img_src, title, talkday, talkhour, talkminute, name);
        
        speakerSquares[i] = new scribbleSquare(box_x[i], box_y[i], 16, 16, 110, strokeNo);
        int speakerAdd = i + 1;
        speakerText[i] = loadImage("speaker_" + speakerAdd + ".jpg");
    }
    
    for (int i = 0; i < numPages; i++) {
        pages[i] = loadImage("page" + i + ".png");
      }
    
    // Function to start
    acceptNewUser();  
 }

void draw() 
{   
    millisSinceLastDraw = millis() - prevMillis;
    
    checkTimeOut(); 
    
    // Return if screen has only just been loaded
    if(isDelay){
        delayMillis += millisSinceLastDraw;
        if(delayMillis < delayTime){ 
            return;
        } else {
            isDelay = false;
            delayMillis = 0;
        }
    }
      
    // we only really use draw() for handling clicks
    if (!mousePressed) {
        prevMillis = millis(); 
        return;  
    }
    
    // Draw now!
    stroke(penColor);
    strokeWeight(sw);    
    if(penColor == white){
        if((mouseX > (safeDrawZone[0] + eraserWidth/3) && mouseX < ((safeDrawZone[0]+safeDrawZone[2]) - eraserWidth/3)) && (mouseY > (safeDrawZone[1] + eraserWidth/3) && mouseY < ((safeDrawZone[1]+safeDrawZone[3]) - eraserWidth/3))) {    
            penDraw(mouseX, mouseY);  
        } else if ((mouseX > (penZone[0] + eraserWidth/3) && mouseX < ((penZone[0]+penZone[2]) - eraserWidth/3)) && (mouseY > (penZone[1] + eraserWidth/3) && mouseY < ((penZone[1]+penZone[3]) - eraserWidth/3))){
            penDraw(mouseX, mouseY);  
        }
    } else {
        penDraw(mouseX, mouseY);  
    }
    
    // Main modes - these modes mainly check for button presses / state changes 
    // Start screen    
    if (mode == "start") {
        timeCheck = millis();
        timeOut = timeCheck + timeOutDraw;
        if (startsquare.over()) {
            startsquare.checkSaturation();            
            if(startsquare.average > startsquare.threshold){
                  selectSpeaker();                   
            }
        }
    
    // Speaker selection screen       
    } else if (mode == "speaker") {
        timeCheck = millis();
        timeOut = timeCheck + timeOutDraw;
        for(int i = startIndex; i < startIndex + numSpeakersPerPage; i++) {
            if (speakerSquares[i].over()) {
                 speakerSquares[i].checkSaturation();
                 if(speakerSquares[i].average > speakerSquares[i].threshold){
                       currentSpeaker = i;
                       currentSpeakerString = Integer.toString(speakers[i].id) + "-" + speakers[i].name;
                       speakerSelected();                       
                 }
             }
        }         
        if (prev.over()) {              
          prev.checkSaturation();
          if(prev.average > prev.threshold){
              page(-1);
              prev.display();
              next.display();
          }
        }

        if (next.over()) {
            next.checkSaturation();
            if(next.average > next.threshold){
                page(1);
                prev.display();
                next.display();
            }
        }
        if (cancel.over()) {
          cancel.checkSaturation();     
          if(cancel.average > cancel.threshold){
              acceptNewUser();
          }
        }
    
    // Main draw screen selection screen                  
    } else if (mode == "draw") {
        timeCheck = millis();
        timeOut = timeCheck + timeOutDraw;
        if (savesquare.over()) {
            savesquare.checkBrightness();
            if(savesquare.average < savesquare.threshold){
                  confirm();
            }
        }
        if (quit.over()) {
            quit.checkBrightness();
            if(quit.average < quit.threshold){
                acceptNewUser();
            }
        }
        if (eraser.over()) {
            eraser.checkBrightness();
            if(eraser.average < eraser.threshold){     
                eraserChange();              
            }
        }
        if (pen.over()) {
            pen.checkBrightness();            
            if(pen.average > pen.threshold){
                penChange();
            }
        }
        
    // Final thankyou screen
    } else if (mode == "complete") {
        if (edit.over()) {
            edit.checkBrightness();
            if(edit.average < edit.threshold){
                speakerSelected();
            }
        }
        if (startagain.over()) {
            startagain.checkBrightness();
            if(startagain.average < startagain.threshold){
                selectSpeaker();
            }
        }
        if (quit.over()) {
            quit.checkBrightness();
            if(quit.average < quit.threshold){
                acceptNewUser();
            }
        }
    }
    prevMillis = millis();

}

// These funtions load background, varibles and settings for different modes/states
// First funtion called, get started.
void acceptNewUser() {
    timeOut = 0;
    background(bg_start);
    penColor = yellow;  
    sw = penWidth; 
    mode = "start";  
    startsquare.display();
    long ts = (new Date()).getTime();
    filename = Long.toString(ts);
    startDelay();
}

void selectSpeaker() {
    background(pages[currentPage]);
    penColor = yellow;   
    for (int i = 0; i < 5; i++) {
        speakerSquares[i].display();
    } 
    
    mode = "speaker";
    prev.display();
    next.display();
    cancel.display();
    startDelay();    
}

void speakerSelected() {
    mode = "draw";
    penColor = black;   
    background(bg_draw);
    speakers[currentSpeaker].display();   
    image(speakerText[currentSpeaker], 0, 0); 
    //cancel.display();
    quit.display();
    savesquare.display();    
    eraser.display();    
    pen.display();
    startDelay();
}

void confirm() {
    mode = "complete";    
    speakers[currentSpeaker].stash();
    speakers[currentSpeaker].finalDisplay();    
    edit.display();
    startagain.display();
    quit.display();
    startDelay();    
}

void eraserChange(){
    penColor = white;
    sw = eraserWidth;
    image(penimg, 78, 670, 301, 44);   
}

void penChange(){    
    penColor = black;
    sw = penWidth;
    image(eraserimg, 78, 670, 301, 44);
}

void page(int increment) {
  // set/check pageTurnM for locking purposes
  if (millis() - pageTurnM < 300) return;
  pageTurnM = millis();
  
  currentPage = (currentPage + numPages + increment) % numPages; // add numSpaces to counteract java's dumbfuck approach to signing on the % operator
  startIndex = currentPage * numSpeakersPerPage;
  background(pages[currentPage]);
  
    for(int i = startIndex; i < startIndex + numSpeakersPerPage; i++) {
        speakerSquares[i].display();
    }
  cancel.display();
}
 
// only draw if reasonable time since last draw
// need this hack as pmouseX, pmouseY don't reset when interaction is 
// by wiimote  
void penDraw(int x, int y) {
    if(pmouseX == 0 && pmouseY == 0) return;

    if (millis() - drawM > 100) {
      pmouseX = x;
      pmouseY = y;
      drawM = millis();
      return;
    }
    drawM = millis();
    line(x, y, pmouseX, pmouseY);
}


void checkTimeOut(){
    currentTime = millis();
    //println("Curent time is " + currentTime);
    //println("Timeout is " + timeOut);
    if (currentTime > timeOut && timeOut != 0 ) {
      acceptNewUser();
      timeOut = 0;              
    }

    if (timeOut == 0){
      timeCheck = millis();
      timeOut = timeCheck + timeOutDraw;
    }    
}

void startDelay(){
    isDelay = true;
}
