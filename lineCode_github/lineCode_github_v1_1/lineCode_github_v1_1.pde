// BIG pixels to draw on screen
int screenWidth=20;
int screenHeight=20;

// grid variables
int gridspacing=20;
int gridStartPosX=0;
int gridStartPosY=0;

// draw markers for blue dot and yellow dot
int[] endPosPoint;
int[] startPosPoint;

// this is where we want to draw the line to and from using a single value method
int startPos=39;
int endPos=60;

// basic line info
int rectWidth;
int rectHeight;
int longestSide;
int shortestSide;

int lineStartPos;
int lineEndPos;
int[] line;

int errors;

// multidirectional line drawing variables
int extendLine;
int advanceLine;


void setup()
{
  size(640,480);
  noLoop();
}

void draw()
{  
  background(100,100,100);
  for(int column=0;column<=screenWidth;column++){
    for(int row=0;row<=screenHeight;row++){
      line(gridStartPosX+column,gridStartPosY+(row*gridspacing),gridStartPosX+(column*gridspacing),gridStartPosY+(row*gridspacing));
      line(gridStartPosX+(column*gridspacing),gridStartPosY+row,gridStartPosX+(column*gridspacing),gridStartPosY+(row*gridspacing));
    }
  }

  setup_drawing();
  create_line();
  draw_line();
}

void mousePressed()
{
  loop();
  
  if(mouseButton == LEFT)
  {
    println("startPos placed");
    int pixelStart = mouse_to_pixel(mouseX, mouseY);
    startPos = pixelStart;
  }
  if(mouseButton == RIGHT)
  {
    println("endPos placed");
    int pixelEnd = mouse_to_pixel(mouseX,mouseY);
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

  rectWidth=mywidth(lineStartPos,lineEndPos);
  rectHeight=myheight(lineStartPos,lineEndPos);

  longestSide=max(rectWidth, rectHeight);
  shortestSide=min(rectWidth, rectHeight);

  // near-by pixels to current pixel
  int rightPixel=-1;
  int leftPixel=+1;
  int upperLeftPixel=screenWidth+1;
  int upperRightPixel=screenWidth-1;
  int upperPixel=screenWidth;
  
  // is the line being draw upleft or upright
  int startXColumn = pixel_xy(lineStartPos)[0];
  int endXColumn = pixel_xy(lineEndPos)[0];
  
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
  // draw start and end points
  drawBlueDot(endPos);
  drawYellowDot(startPos);
}

int errorsInLine(){
  
  // errorsInLine will have to be changed in future for any unexpected line issues
  // at the moment no errors will be caught because mouseToPixel checks if points are outisde of the grid
  
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
  line = new int[longestSide];
  // allow room for one more so we can add an extra 0 at the beginning
  int[] ratioOfSplitRect = new int[shortestSide+1];
  
  int nom=longestSide;
  int newNom=nom;
  int denom=shortestSide;
  
  // we need a zero number to begin the first ratio and following ratios
  ratioOfSplitRect[0]=0;
  
  for(int i=1;i<shortestSide+1;i++)
  {
    ratioOfSplitRect[i] = newNom / denom;
    newNom = newNom + nom;
  }
  
  int subtract=lineEndPos;
  int currentLinePos=0;
  
  for(int i=1;i<shortestSide+1;i++)
  {
    // first time draw the first point of the line. endPos...
    line[currentLinePos] = subtract;
    currentLinePos++;

    // find the distance between the current ratio and the last ratio
    int extendBy = ratioOfSplitRect[i] - ratioOfSplitRect[i-1]; 
    
    // how many times do we extend the line...
    for(int j=extendBy-1;j>0;j--)
    {
      subtract -= extendLine;
      line[currentLinePos] = subtract;
      currentLinePos++;
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
  
  // whenever startPos is to the right of endPos, a strange thing happens, that if we
  // startPos - startPos and
  // endPos - startPos
  // the resulting box loses a height of one
  if(pixel_xy(startPos)[0]>pixel_xy(endPos)[0])
  {
    thisHeight++;
  }
  
  result[0]=abs(startPos+(screenWidth*(thisHeight))-endPos);
  result[1]=thisHeight;

  return result;
}

int mouse_to_pixel(int mx, int my)
{
  int resultx = -1;
  int resulty = -1;
  int result = -1;
  
  resultx=int(mx / gridspacing );
  resulty=int(my / gridspacing );
  
  // keep line inside gridbox even if clicking non-grid area
  if(resultx>screenWidth-1)
  {
    resultx=screenWidth-1;
  }
  if(resulty>screenHeight-1)
  {
    resulty=screenHeight-1;
  }
  
  // get pixel number
  result = resultx + (screenWidth*resulty);
  return result;
}

int[] pixel_xy(int pixelnumber)
{
  
  int result[] = new int[2];
  
  int resultx=0;
  int resulty=0;
  
  resulty=int(pixelnumber/screenWidth);
  resultx=pixelnumber-(screenWidth*resulty);
  
  result[0]=resultx;
  result[1]=resulty;

  return result;
}

void drawBlueDot(int pixel)
{
  endPosPoint=pixel_xy(pixel);
  fill(0,0,255);
  ellipse(gridStartPosX+(gridspacing*endPosPoint[0])+gridspacing/2, gridStartPosY+(gridspacing*endPosPoint[1])+gridspacing/2, 15,15);
}

void drawYellowDot(int pixel)
{
  int[] startPosPoint=pixel_xy(pixel);
  fill(255,255,0);
  ellipse(gridStartPosX+(gridspacing*startPosPoint[0])+gridspacing/2, gridStartPosY+(gridspacing*startPosPoint[1])+gridspacing/2, 15,15);
}

void drawBlackPixel(int pixel)
{
  int[] coordinates=pixel_xy(pixel);
  fill(0);
  rect(coordinates[0]*gridspacing,coordinates[1]*gridspacing,gridspacing,gridspacing);
}
