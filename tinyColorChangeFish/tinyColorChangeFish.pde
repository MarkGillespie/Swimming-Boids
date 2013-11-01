/*************************************
Boid Class
**************************************/

/************************************
Behavior:
The boid's motion is dictated by its neighbors. It feels 3 forces - alignment, cohesion, and separation.
Alignment pushes the boid to travel in the same direction as its neighbors. Cohesion pushes the boids towards
neighbors, and separation pushes boids away from neighbors that are too close.

Each boid also has a color. The boids start with random colors, and update their colors to be similar to the
colors of boids in front of them. Sometimes, if there is no boid in front of itself, it will randomly change its
color.

Also, when the spacebar is pressed, boids will flee the mouse.
**************************************/
class Boid{
 int size = 2;//scale factor
 int RANDOM_COLOR_CHANGE = 50;//to keep the colors interesting, the color of a 
                              //leading fish will sometimes randomly change. 
                              //This specifies the maximum possible change
 float visionCone = PI/6; //this is the greates angle from the vertical that 
                          //fish can see. This affects their changing color to match fish in front of them
 float comfortZone = 15*size;//this is how close a fish has to be to repel the fish by separation
 float eyeSight = 37*size;//this is how far away the fish can see (for cohesion and alignment)
 float colorVision = 30*size;//this is how far the fish can see to set its color. 
                             //Fish farther away don't affect the color
 float speedLimit = 20*size;//this is the fastest a fish will go. Without this constraint, they go too fast.
 float forceLimit = .01*size;//this is the maximum force that can be applied

  
 float sepWeight = 10;//initial weight for separation
 float aliWeight = .1;//initial weight for alignment
 float cohWeight = .1;//initial weight for cohesion
 
 PVector position,velocity,steeringForce;//vectors for position, velocity, and steering forces
 
 float H, S, B;//floats to store the Hue, Saturation, and Brightness for the fish's color

 /*************************************
 Constructor
 **************************************/
 public Boid(int x, int y, int H_)//constructor. Takes and x coordinate, a y coordinate, and a hue
 {
 // puts the position vector at (x,y) plus or minus 10 in each direction
  position = new PVector(x + random(-10,10), y + random(-10,10));
  
  velocity = PVector.random2D();//randomize velocity (makes a vector with magnitude 1 and a random angle
  
  H = H_;//set the hue from the parameter
  
  /*sets the value of saturation randomly to a value from 0-99. 
  Saturation ranges from 0 to 100, so this keeps it fairly saturated*/
  S = (float)(Math.random()*50)+50;
  
  /*sets the value of brightness randomly to a value from 0-99. 
  brightness ranges from 0 to 100, so this keeps it fairly bright*/
  B = (float)(Math.random()*50)+50;
 }
 
 /*************************************
 Update (Called Every Frame)
 **************************************/
 void update(ArrayList<Boid> school)//update the fish's velocity and position
 {
  steeringForce = new PVector(0,0);//clear the old steering force
  steeringForce.add(forces(school));//calculate the forces
  velocity.mult(.5);//divide the old velocity in half. This keeps the fish responsive to new forces, while 
                    //still following general paths
  velocity.add(steeringForce);//add the force to the velocity (F = ma with mass 1)
  if(velocity.mag()<1)//if the velocity gets too low, double it
    velocity.mult(2);
  velocity.limit(speedLimit);//make sure the velocity isn't too fast
  position.add(velocity);//update the position (with velocity in pixels per frame, 
                         //it measures the number of pixels to be moved each frame)
  
  //wrap fish around the edges
  //(coordinates are measured with the origin at the top left
  
  /*if it goes off the left of the screen (if the position plus 
  the distance from the center to the edge of the fish is off the edge)*/
  if (position.x < size){
    position.x = width-size;//move the fish to the right of the screen(minus the radius of the fish)
  }
  
  /*if it goes off the top of the screen (if the position plus
  the distance from the center to the edge of the fish is off the edge)*/
  if (position.y < size) {
    position.y = height-size;
  }
  
  /*if it goes off the right of the screen (if the position plus
  the distance from the center to the edge of the fish is off the edge)*/
  if (position.x > width-size) {
    position.x = size;
  }
  
  /*if it goes off the bottom of the screen (if the position plus
  the distance from the center to the edge of the fish is off the edge)*/
  if (position.y > height-size){
    position.y = size;
  }
 }
 
 /*************************************
 Calculate the forces on each fish
 **************************************/
 PVector forces(ArrayList<Boid> school){
   //initialize necessary vectors to 0
   PVector steering = new PVector(0,0);
   PVector separation = new PVector(0,0);//a force that pushed the fish away from other fish that are too close
   PVector alignment = new PVector(0,0);//a force that pushes a fish to travel in the same direction as its neighbors
   PVector cohesion = new PVector(0,0);//a force that pulls fish together
   int sepCount = 0;//integer to store number of fish within the separation range
   int counter = 0;//stores the number of fish within cohesion/alignment range
   int colorCount = 0;//stores the number of fish within color sight
   float frontColor = 0;//color of the fish in front of this one
   for(Boid b: school){//loop through all other fish in the school
     if(!b.equals(this))
     {
      float dist =PVector.dist(this.position, b.position);//calculates the distance between this boid and the other one
       if(dist < eyeSight)//if the other boid is within eyesight(for cohesion and alignment)
       { 
         counter++;//increment the counter to record that another fish has been found in range
         
          /*************************************
           ALIGNMENT
           **************************************/
         PVector temp = new PVector(b.velocity.x, b.velocity.y);//store the other fish's velocity
         temp.normalize();//normalize the velocity
         
         /*as long as it can, the program will divide the velocity by 
         the distance. This creates a vector pointing in the direction 
         of the other velocity whose magnitude is inversely proportional 
         to the distance between this boid and the other*/
         if(dist > 0)
         {
           temp.div(dist);
         }
         alignment.add(temp);//add the resulting vector to the net force due to alignment
         
         /*************************************
           COHESION
         **************************************/
         /*this subtracts this fish's position from the other position
         resulting in a vector pointing from this fish to the other fish*/
         temp = PVector.sub(b.position, position);
         temp.normalize();//normalize the vector. This creates a unit vector pointing towards the other fish
         if(dist > 0){
           temp.div(dist);//again makes the magnitude inversely proportional to distance
           temp.mult(5);//multiply the vector to bring it a scale that fits with the other forces
           cohesion.add(temp);//add the resulting vector to the net force due to cohesion
         }
       }
       
       /*************************************
           SEPARATION
       **************************************/
       if(dist < comfortZone)//the radius for the separation force is lower, so we need another check
       {
         /*this subtracts this fish's position from the other position
         resulting in a vector pointing from this fish to the other fish*/
         PVector temp = PVector.sub(position, b.position);
         temp.normalize();//normalize the vector. This creates a unit vector pointing towards the other fish
         if(dist > 0){
           temp.div(dist);//again makes the magnitude inversely proportional to distance
         } else {
           temp.div(.00001); //If they are in the same place, there needs to be a strong separating force
         }
         temp.mult(5);//multiply the vector to bring it a scale that fits with the other forces
         separation.add(temp);//add the resulting vector to the net force due to cohesion
         sepCount++;//increment the separation counter to record that another fish has been found 
                    //inside the separation radius
       }
       
       /*************************************
           COLOR CHANGE
       **************************************/
       //calculates the vector displacement between this boid and the other one
       PVector disp =PVector.sub(b.position, this.position);
       if(dist < colorVision)//the color vision also has a different radius, so it requires another check
       {
         float head = disp.heading();//get angle from this boid to the other boid
         
         //check to see if the other boid is ahead of this one (if the heading is within the vision Cone)
         if(Math.abs(head-velocity.heading())<visionCone)
         {
           frontColor += b.H;//add the color of the fish in front to the observed color variable
           colorCount++;//increment the counter to record that another fish has been found in front
         }
       }  
     }   
   } 
  if(colorCount < 1)//if there are no fish in front
  {
    /*with a 10% chance, randomly change the color 
    by a factor of up to RANDOM_COLOR_CHANGE, which is specified at the top*/
    int rnd = (int)random(0,10);
    if(rnd==0)
    {
      H += (int)(Math.random()*RANDOM_COLOR_CHANGE-RANDOM_COLOR_CHANGE/2);
      H %= 360;
    }
  } else if (colorCount > 5){//if there are more than 3 boids in front, just take their average color
    float otherColor = frontColor/colorCount;
    H = otherColor;
  } else {//otherwise, mix the average front color with the current color
    float otherColor = frontColor/colorCount;
    H = (otherColor + H)/2;
  }
  
  
  //calculate the average forces exerted. The if statements prevent division by 0
  if(counter > 0)
    alignment.div(counter);
  if(counter > 0)
    cohesion.div(counter);
  if(sepCount > 0)
     separation.div(sepCount); 

  //multiply the forces by their respective weights and
  //add the forces to the total steering force
  alignment.mult(aliWeight);
  steering.add(alignment);
  
  cohesion.mult(cohWeight);
  steering.add(cohesion);
  
  separation.mult(sepWeight);
  steering.add(separation);
  
  steering.limit(forceLimit);   //limit steering force so that it cannot be above the maximum force
      
 /*************************************
  FEAR OF THE MOUSE
 **************************************/
 if(!mousePressed)
 {
   if(keyPressed)
   {
     if(key == ' ')
     {
         /*If the mouse is not pressed, and the spacebar is, the fish are repelled by the mouse*/
         PVector mouse = new PVector(mouseX, mouseY);//store the mouse position as a vector
         mouse.sub(position);
         float dist = mouse.mag();
         mouse.normalize();
         mouse.div(dist); //creates a vector pointing away from the mouse, whose 
                          //magnitude is inversely proportional to distance
         steering.sub(mouse);//add into steering
     }
   }
 }
  return steering;
}


void render() {
    float theta = velocity.heading2D();//get the heading of the fish
    fill(H,S,B);//fill with the fish's color
    pushMatrix();//store the coordinate system
      translate(position.x, position.y);//translate the origin to the fish position
      rotate(theta);//rotate by the heading
      beginShape(TRIANGLES);//draws a triangle for the tail, centered on the x axis and pointing right
        vertex(size, 0);
        vertex(-2*size,-2*size);
        vertex(-2*size, 2*size);
      endShape();
      ellipse(size*2,0,4*size,2.5*size);//draw an ellipse for the body centered on the x axis
    popMatrix(); 
  }
}
