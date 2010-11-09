// Scribble square objects

class scribbleSquare
{
  int xpos; 
  int ypos;
  int h;
  int w;
  float threshold;
  PImage square;
  color[] squareColors;
  float[] pixelBrightness;
  float average;
  boolean strokeCheck;
  
  scribbleSquare(int x, int y, int w1, int h1, float thres, boolean strokeCheck1) {
    xpos = x;
    ypos = y;
    w = w1;
    h = h1;
    threshold = thres;    
    strokeCheck = strokeCheck1;
    
    squareColors = new color[w*h];
    pixelBrightness = new float[w*h];
  }
  
  // you can't actually see the button but it has to be placed on screen
  void display() {
    noFill();
    noStroke();
    if(strokeCheck) stroke(0);
    rect(xpos, ypos, w, h);
  }    
  
  // check how much the brightness of the square is changing
  void checkBrightness(){
      square = get(xpos,ypos,w,h);
      average = 0;
      
      for(int y = 0; y < h; y++) {
          for(int x = 0; x < w; x++){
              squareColors[y*square.height + x] = square.get(x,y);                        
          }
      }
      
      for(int i = 0; i < pixelBrightness.length; i++){
          pixelBrightness[i] = brightness(squareColors[i]);            
          average = average + pixelBrightness[i];
      }
      
      average = average / pixelBrightness.length;
  }
  
  // check how much the saturation of the square is changing
  void checkSaturation(){
        square = get(xpos,ypos,w,h);
        average = 0;

        for(int y = 0; y < h; y++) {
            for(int x = 0; x < w; x++){
                squareColors[y*square.height + x] = square.get(x,y);                        
            }
        }

        for(int i = 0; i < pixelBrightness.length; i++){
            pixelBrightness[i] = saturation(squareColors[i]);            
            average = average + pixelBrightness[i];
        }

        average = average / pixelBrightness.length;
    }
  
  // is the mouse over the square?
  Boolean over() {
      return ((mouseX > xpos) && (mouseX < xpos+w) && (mouseY > ypos) && (mouseY < ypos+h));    
  } 
  
}