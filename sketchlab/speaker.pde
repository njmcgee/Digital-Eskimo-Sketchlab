// Speaker objects

class Speaker
{
  int id;
  String img_src;
  String title;
  int talkday;
  int talkhour;
  int talkminute;
  String name;
  String path;
  PImage img;
  
  
  Speaker(int id1, String img_src1, String title1, int talkday1, int talkhour1, int talkminute1, String name1) {
      id = id1;
      img_src = img_src1;
      title = title1;
      talkday = talkday1;
      talkhour = talkhour1;
      talkminute = talkminute1;
      name = name1;
  }
  
  // Display already drawn image if it exists
  void display() {                
      path = "output/" + currentSpeakerString + "/" + filename + ".png";
      img = loadImage(path, "png");
      if (img == null) {
        background(bg_draw);
      } else {
        background(bg_draw);  
        image(img, safeDrawZone[0],safeDrawZone[1],safeDrawZone[2],safeDrawZone[3]);
      }
  }
  
  // Display on final screen at smaller size
  void finalDisplay(){
      path = "output/" + currentSpeakerString + "/" + filename + ".png";
      img = loadImage(path, "png");
      background(bg_confirm);
      image(img, finalDisplay[0],finalDisplay[1],finalDisplay[2],finalDisplay[3]);
  }
  
  // Save user input
  void stash() {
      //path = "redesigns/" + folder + "/" + Integer.toString(id) + ".png";
      // save the screen to file      
      PImage stashimg = get(safeDrawZone[0],safeDrawZone[1],safeDrawZone[2],safeDrawZone[3]);
      stashimg.save(path);
    }
  
}