/**
This program simulates the movements of schools of fish controlled by the factors of 
separation, alignment and cohesion as laid out by Craig Reynolds for his Boids
**/

/*************************************
Declare Important Values
**************************************/
int NUM_BOIDS = 100; //initial number of fish
ArrayList<Boid> school = new ArrayList<Boid>(); //stores all live fish
HScrollbar sep; //scroll bar to control separation
HScrollbar ali; //scroll bar to control alignement
HScrollbar coh; //scroll bar to control cohesion
PFont f = createFont("Lucida Bright Italic", 10.0, true); //font for scrollbars
PImage water;//background image
int BIG_ADD = 10;//number of fish added upon a right mouse click
boolean aBarIsSelected = false;//boolean variable to keep track of if one scrollbar is selected
                                 //this stops the user from being able to drag multiple scrollbars at once

void setup(){
  /*************************************
  Set Up Initial Conditions
  **************************************/
  frameRate(25);//sets the frame rate at 25 frames per second
  size(1280, 700);//sets window dimensions: width is 1280 pixels, height is 700 pixels
 
  for(int i = 0; i < NUM_BOIDS; i++){ //adds the initial number of fish to the list that stores live fish
   school.add(new Boid(300, 300, (int)(Math.random()*360))); //adds the fish at position (300,300) 
                                                           //with a random color (a hue specified as an integer from 0 to 360
  }
  
  sep = new HScrollbar(10, 10);//create a scrollbar for separation with top left corner at point (10,10)
  ali = new HScrollbar(10, 50);//create a scrollbar for alignment with top left corner at point (10,50)
  coh = new HScrollbar(10, 90);//create a scrollbar for cohesion with top left corner at point (10,90)
  sep.setValue(2); //set the initial separaiton value to 2
  coh.setValue(2.8); //set the initial cohesion value to 2.8
  
  water = loadImage("water.jpg");//load the background image
  image(water,0,0);//draw the background image
  textFont(f, 10);//use font f to write text
  textAlign(LEFT);//when writing text, specify position by top left corner
  colorMode(HSB, 360, 100, 100);//use Hue Saturation Brightness colors
  noStroke();//don't outline shapes
}

void draw(){
  image(water,0,0); //draw the background image
  
  
  /***************************************
  Loop through all the fish and update them
  ****************************************/
  for(Boid b: school)//iterate through the list of fish
  { 
    b.sepWeight = sep.getRoundedPos();//weight the separation using the value from the scrollbar
    b.aliWeight = ali.getRoundedPos();//weight the alignment using the value from the scrollbar
    b.cohWeight = coh.getRoundedPos();//weight the cohesion using the value from the scrollbar
    b.update(school);//calculate the forces imparted on the fish by all other members of the school
    b.render(); //render the fish
  }
  
  
  /***************************************
  Render and Update Scrollbars
  ****************************************/
  sep.update();
  sep.render();
 
  
  ali.update();
  ali.render();
  
  
  coh.update();
  coh.render();
 
  
 /***************************************
  Write Text
  ****************************************/
  
  fill(360);//set the text color to white
  text("Separation: " + sep.getRoundedPos(), 210, 15);
  text("Alignment: " + ali.getRoundedPos(), 210, 55);
  text("Cohesion: " + coh.getRoundedPos(), 210, 95);
  
  text("Number of Boids: " + school.size(), width-200, 15);//print number of fish at the top right
}

 /***************************************
  User Input
  ****************************************/

void mousePressed(){
  if(mouseButton==LEFT)//on a left click, add 1 fish
  {
     school.add(new Boid(mouseX, mouseY,(int)(Math.random()*312)));//add a new fish at the mouse's x and y coordinates with a random color
  }
  if(mouseButton==RIGHT)//on right click, add many fish. The number is specified by constant BIG_ADD whose value is set at the top
  {
    int H = (int)(Math.random()*360);//pick a random hue
    //the hue is picked here so that all of the added fish will have the same color. This makes schools of the same color arise faster
    for(int i = 0; i < BIG_ADD; i++)//loop BIG_ADD times
    {
      school.add(new Boid(mouseX, mouseY, H));//add a random fish with hue H
    } 
  }
     
}

void keyPressed(){
 if(key == 'c'||key=='C')//when the user presses c, randomize the colors. 'c' and 'C' are both considered in case shift is pressed
 {
    for(Boid b : school)//iterate through all fish in the school
    {
     b.H = (float)(Math.random()*360);//sets the hue to a random color within the range of hue values (0-360)
     b.S = (float)(Math.random()*50)+50;//sets the value of saturation randomly to a value from 0-99. Saturation ranges from 0 to 100, so this keeps it fairly saturated
     b.B = (float)(Math.random()*50)+50;//sets the value of brightness randomly to a value from 0-99. brightness ranges from 0 to 100, so this keeps it fairly bright
  }
 } 
}
