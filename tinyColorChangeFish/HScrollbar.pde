/*
Code adapted from: http://processing.org/examples/scrollbar.html
*/

class HScrollbar {
  int swidth = 200;  // width and height of bar
  int sheight = 10;    
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  boolean over;           // is the mouse over the slider?
  boolean selected = false;

  HScrollbar (float xp, float yp) {
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
  }

  void setValue(float f){
   float n = (f + 1)*(sposMax-sposMin)/5 + sposMin;
   if(n > sposMin && n < sposMax)
     spos = n;
     newspos = n;
  }

  void update() {
    checkMouse();
    if (mousePressed && over && !aBarIsSelected) {
      selected = true;
      aBarIsSelected = true;
    }
    if (!mousePressed) {
      selected = false;
      aBarIsSelected = false;
    }
    if (selected) {
      newspos = constrain(mouseX, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos);
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  void checkMouse() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      over = true;
    } else {
      over = false;
    }
  }

  void render() {
    fill(350);
    rect(xpos, ypos, swidth, sheight);
    if ((over&&!mousePressed) || selected) {
      fill(50);
    } else {
      fill(220);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    return (spos - sposMin)/(sposMax-sposMin)*5-1;
  }
  
  float getRoundedPos(){
    return round(((spos - sposMin)/(sposMax-sposMin)*5-1)* 100) * .01;//rounds to two decimal places
  }
}
