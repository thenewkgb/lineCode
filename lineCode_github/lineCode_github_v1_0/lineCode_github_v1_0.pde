// BIG pixels to draw on screen
int screenWidth=10;
int screenHeight=10;

// grid variables
int gridspacing=20;
int gridStartPosX=0;
int gridStartPosY=0;

// drawing markers for BlueDot YellowDot
int[] endPospoint;
int[] startPospoint;

// this is where we want to draw the line to and from using a single value method
int startPos=39;
int endPos=60;

// basic line info
int rectWidth;
int rectHeight;
int[] ratio;
int[] details;
int longestSide;
int shortestSide;
int[] line;

int errors;

// multidirectional line drawing variables
int extendLine;
int advanceLine;
int lineStartPos;
int lineEndPos;

void setup()
{
  size(640,480);
  noLoop();
}

void draw()
{  
  background(100,100,100);
  for(int scolumn=0;scolumn<=screenWidth;scolumn++){
    for(int srow=0;srow<=screenHeight;srow++){
      line(gridStartPosX+scolumn,gridStartPosY+(srow*gridspacing),gridStartPosX+(scolumn*gridspacing),gridStartPosY+(srow*gridspacing));
      line(gridStartPosX+(scolumn*gridspacing),gridStartPosY+srow,gridStartPosX+(scolumn*gridspacing),gridStartPosY+(srow*gridspacing));
    }
  }

  setup_drawing();
  create_line();
  printArray(line);
  //println("width:"+rectWidth+" height:"+rectHeight);
  draw_line();
}

void mousePressed()
{
  loop();
  
  if(mouseButton == LEFT)
  {
    println("startPos placed");
    int pixelStart = mouseToPixel(mouseX, mouseY);
    startPos = pixelStart;
  }
  if(mouseButton == RIGHT)
  {
    println("endPos placed");
    int pixelEnd = mouseToPixel(mouseX,mouseY);
    endPos = pixelEnd;
  }
}

void mouseReleased()
{
  noLoop();
}

// 
//Custom functions start here
//

void setup_drawing()
{  
  //if we want to left/right click anywhere in the grid
  //possibly mixing up th start and endPos
  //keep the start and end clear direction in the code
  if(startPos > endPos)
  {
    lineStartPos = endPos;
    lineEndPos = startPos;
  }
  else
  {
    lineStartPos = startPos;
    lineEndPos = endPos;
  }
  
  //rectHeight=myheight(lineStartPos,lineEndPos);
  //rectWidth=mywidth(lineStartPos,lineEndPos);
  rectWidth=mywidth(lineStartPos,lineEndPos);
  rectHeight=myheight(lineStartPos,lineEndPos);
  //which side is larger
  longestSide=greater(rectWidth, rectHeight);
  shortestSide=lesser(rectWidth, rectHeight);

  int rightPixel=-1;
  int leftPixel=+1;
  int upperLeftPixel=screenWidth+1;
  int upperRightPixel=screenWidth-1;
  int upperPixel=screenWidth;
  
  // is the line being draw upleft or upright
  int startXColumn = pixelxy(lineStartPos)[0];
  int endXColumn = pixelxy(lineEndPos)[0];
  
  if(rectWidth>rectHeight)
  {
    if(startXColumn <= endXColumn)
    {
      advanceLine=upperLeftPixel;
      extendLine=leftPixel;
    }
    else
    {
      advanceLine=upperRightPixel;
      extendLine=rightPixel;
    }
  }
  else
  {
    if(startXColumn <= endXColumn)
    {
      advanceLine=upperLeftPixel;
      extendLine=upperPixel;
    }
    else
    {
      advanceLine=upperRightPixel;
      extendLine=upperPixel;
    }
  }
}

void draw_line()
{
  errors=errorsInLine();
  if(errors==0){
    printLine(line);
  }
  else
  {
    println(errors+" errors in line");
  }
}

void printLine(int[] line){
  for(int i=0;i<line.length;i++){
    drawBlackPixel(line[i]);
  }
  drawBlueDot(endPos);
  drawYellowDot(startPos);
}

int errorsInLine(){
  // assume there are zero problems
  int result=0;
  if(screenWidth*screenHeight<=endPos || endPos < 0){
    result++;
    println("endPos lays outside of grid");
  }
  if(screenWidth*screenHeight<=startPos || startPos < 0){
    result++;
    println("startPos lays outside of grid");
  }
  return result;
}

void create_line()
{
  // draw end points
  drawBlueDot(endPos);
  drawYellowDot(startPos);
  
  line = new int[longestSide];
  println(longestSide);
  int[][] ratioOfSplitRect = new int[shortestSide+1][2];
  
  int nom=longestSide;
  int newNom=nom;
  int denom=shortestSide;
  
  ratioOfSplitRect[0][0]=0;
  
  for(int i=1;i<shortestSide+1;i++)
  {
    //ratioOfSplitRect[i][0] = ratio(newNom,denom)[0];
    //ratioOfSplitRect[i][1] = ratio(newNom,denom)[1];
    ratioOfSplitRect[i][0] = newNom / denom;
    println("n/d"+newNom+"/"+denom);
    newNom = newNom + nom;
    //printArray(ratioOfSplitRect[i][0]);
  }
  
  int subtract=lineEndPos;
  int currentLinePos=0;
  
  for(int i=1;i<shortestSide+1;i++)
  {
    // first time draw the first point of the line. endPos...
    line[currentLinePos] = subtract;
    currentLinePos++;
    println("i loop"+currentLinePos);

    int extendBy = ratioOfSplitRect[i][0] - ratioOfSplitRect[i-1][0];
    //int prevExtendBy = ratioOfSplitRect[i-1][0]; 
    
    // how many times do we extend the line
    println(ratioOfSplitRect[i][0]+","+ratioOfSplitRect[i-1][0]);
    for(int j=extendBy-1;j>0;j--)
    {
      subtract -= extendLine;
      line[currentLinePos] = subtract;
      currentLinePos++;
      //extendBy -= prevExtendBy;
      //println(extendBy);
      println("j loop"+currentLinePos);
    }
    // ...then on subsequent i loops advance the line
    subtract-=advanceLine;
  }
}

int mywidth(int startPos,int endPos){
  int result=-1;
  result=comp_width_and_height(startPos,endPos)[0];
  return result+1;
}

int myheight(int startPos, int endPos){
  int result=-1;
  result=comp_width_and_height(startPos,endPos)[1];
  return result+1;
}

int[] comp_width_and_height(int startPos,int endPos){
  int[] result={-1,-1};
  
  int thisHeight=0;
  int newEndPos=endPos-startPos;
  
  thisHeight = int(newEndPos / screenWidth);
  
  if(pixelxy(startPos)[0]>pixelxy(endPos)[0])
  {
    thisHeight++;
  }
  
  result[0]=abs(startPos+(screenWidth*(thisHeight))-endPos);
  result[1]=thisHeight;

  return result;
}

int[] ratio(int nom, int denom){
  // Ratio (whole number and remainder)
  int[] result={-1,-1,-1};
  
  // send a nominator which is larger than the denominator
  longestSide=greater(nom,denom);
  shortestSide=lesser(nom,denom);
  int[] details=details(longestSide, shortestSide);
  //wholenumber
  result[0]=details[7];
  //remainder
  result[1]=details[8];
  
  // if you can imagine a square, a diagonal line connecting corners is all d's
  // a straight line up is all w's
  if(rectWidth>=rectHeight){
    // wider rect or square
    result[2]=1;
  }
  else{
    // taller rect
    result[2]=0;
  }
  
  return result;
}

// how many denom go into nominator
int[] details(int nom, int denom){
  
  int[] r = new int[9];
  
  // our initial values. Nominator must be larger
  //r[0]=greater(nom,denom);
  //r[1]=lesser(nom,denom);
  r[0]=nom;
  r[1]=denom;
  // assume under guessing
  //r[6]=0;
  // denominator will always go in once to larger number above
  for(int total=denom;total<nom;total+=denom){
    //println(total);
    // how many denom go into nom
    r[2]++;
    // over guess
    //r[3]=total+denom;
    // under guess
    //r[4]=total;
  }
  
  // save whole number
  r[7]=r[2];
  // find remainder
  int halfWay = r[2] * denom;
  r[8] = nom - halfWay;
  
  // find difference between over guess and nom
  //int nearzero=greater(r[0],r[3]) - lesser(r[0],r[3]);
  // find difference in lower guess and nom
  //int nearzero2=greater(r[0],r[4]) - lesser(r[0],r[4]);
  // find closest distance from nom with the two calculations
  //r[5]=lesser(nearzero, nearzero2);
  // if over guessing is closer to nom, add 1 to R
  //if(nearzero<nearzero2){
    //r[2]++;
    // we have over guessed
    //r[6]=1;
  //}

  return r;
}

int lesser(int first, int second){

  int result=0;
 
  if(first>=second){
    result=second;
  }
  else if (second>first){
    result=first;
  }
  else{
    result=-1;
  }
  
  return result;
}

int greater(int first, int second){

  int result=0;
  
  if(first>=second){
    result=first;
  }
  else if(second>first){
    result=second;
  }
  else{
    result=-1;
  }
  
  return result;
}

int mouseToPixel(int mx, int my)
{
  int result = -1;
  int resultx = -1;
  int resulty = -1;
  
  resultx=int(mx / gridspacing );
  resulty=int(my / gridspacing );
  println(resultx+","+resulty);
  
  // get pixel number
  result = resultx + (screenWidth*resulty);
  
  return result;
}

int[] pixelxy(int pixelnumber){
  int result[];
  result = new int[2];
  int resultx=0;
  int resulty=0;
  
  resulty=int(pixelnumber/screenWidth);
  resultx=pixelnumber-(screenWidth*resulty);
  
  result[0]=resultx;
  result[1]=resulty;

  return result;
}

void drawBlueDot(int x){
  endPospoint=pixelxy(x);
  fill(0,0,255);
  ellipse(gridStartPosX+(gridspacing*endPospoint[0])+gridspacing/2, gridStartPosY+(gridspacing*endPospoint[1])+gridspacing/2, 15,15);
}

void drawYellowDot(int x){
  int[] startPospoint=pixelxy(x);
  fill(255,255,0);
  ellipse(gridStartPosX+(gridspacing*startPospoint[0])+gridspacing/2, gridStartPosY+(gridspacing*startPospoint[1])+gridspacing/2, 15,15);
}

void drawBlackPixel(int x){
  int[] coordinates=pixelxy(x);
  fill(0);
  rect(coordinates[0]*gridspacing,coordinates[1]*gridspacing,gridspacing,gridspacing);
}
