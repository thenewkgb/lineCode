// version 1_2_b
//
// chat in programs is really cool
//
// started branching off to lines off the screen. I did however get three lines on the screen, then a square
// which i found an error when drawn off screen. So i started bug fixing....
// the voice said to move on and do the bug fixing later, something i thought was a lie. It made sense but i couldn't trust the voice
// so you wanted multiple lines and ways to draw multiple lines on screen... to completely changing the program, because you didn't
// trust voices

// todo Any line or square to be drawn outside of screen causes a shift in the shape to another area of the screen
//      can do a check before setup_line is called to limit the line onto the screen and not flow over to the right hand
//      side if the line goes off to the left

// todo use xy_to_pixel so you can detect if the line goes off the screen
//      do not write to pixels[] if < 0 (off the screen)
//      the create_line array will be smaller due to the line being off the screen
//      so therefor, if a square is off to the left, the left side will not even be drawn or sent to pixels[]
//
// todo screen not refreshing
//
// todo points always remain in a verticle column below grid

int pScreenWidth=640;
int pScreenHeight=480;

// grid variables
int gridspacing=10;
int gridStartPosX=100;
int gridStartPosY=100;

int screenWidth=20;
int screenHeight=20;

// create a pseudo screen to work with
//int screenWidth=pScreenWidth/gridspacing;
//int screenHeight=pScreenHeight/gridspacing;

// some preset positions for the corners of the screen
int sx=0;
int ex=(screenWidth*screenHeight)-1;
int sx_other=0+screenWidth-1;
int ex_other=ex-screenWidth+1;

// loop array for lines idea
//int linesAllowed = 5;
//int[][] linesToBeDrawn = new int[linesAllowed][20];

// information for each current line that needs setup and drawing
int[] currentSetup;
int[] currentLine;
int currentStartPos;
int currentEndPos;

// draw markers for blue dot and yellow dot
int[] endPosPoint;
int[] startPosPoint;

// multidirectional line drawing variables
int extendLine;
int advanceLine;

// testing purposes for one line only
int[] oneLineSetup;
int[] oneLine;
int oneLineStartPos = sx;
int oneLineEndPos = ex;

void setup()
{
  size(640,480);
  background(100,100,100);
  noLoop();
}

void draw()
{  
  if(gridspacing>9)
  {
    // use a peusdo screen
    draw_grid();
    // a very basic line example
    oneLineSetup = setup_line(oneLineStartPos,oneLineEndPos);
    oneLine = create_line(oneLineSetup);
    draw_simple_line(oneLine);
  }
  else
  {
    // draw into pixels[] for advanced drawing
    draw_square_processing(5,5,5);
    
    // one line
    currentStartPos=screenWidth*8+screenWidth/2;
    currentEndPos=ex-screenWidth*4-screenWidth/4;
    currentSetup = setup_line(currentStartPos, currentEndPos);
    currentLine = create_line(currentSetup);
    draw_processing_line(currentLine);
  
    // another line
    currentStartPos=0;
    currentEndPos=screenWidth*8+screenWidth/2;
    currentSetup = setup_line(currentStartPos, currentEndPos);
    currentLine = create_line(currentSetup);
    draw_processing_line(currentLine);
  }
}

void mousePressed()
{
  loop();
  
  if(mouseButton == LEFT)
  {
    println("startPos placed");
    int pixelStart = mouse_to_pixel(mouseX, mouseY);
    oneLineStartPos = pixelStart; 
  }
  
  if(mouseButton == RIGHT)
  {
    println("endPos placed");
    int pixelEnd = mouse_to_pixel(mouseX,mouseY);
    oneLineEndPos = pixelEnd;
  }
}

void mouseReleased()
{
  noLoop();
}

// 
//  Custom functions start here
//

int[] setup_line(int startPos, int endPos)
{  
  // hold information for setup
  int[] lineSetup = new int[8];
  // mixing up the start and endPos. Line will always be drawn from endPos.
  int lineStartPos;
  int lineEndPos;
  int rectWidth;
  int rectHeight;
  int longestSide;
  int shortestSide;
  
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
  int startXColumn = pixel_to_xy(lineStartPos)[0];
  int endXColumn = pixel_to_xy(lineEndPos)[0];
  
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
  
  lineSetup[0] = lineStartPos;
  lineSetup[1] = lineEndPos;
  lineSetup[2] = rectWidth;
  lineSetup[3] = rectHeight;
  lineSetup[4] = longestSide;
  lineSetup[5] = shortestSide;
  lineSetup[6] = advanceLine;
  lineSetup[7] = extendLine;
  
  return lineSetup;
}

int[] create_line(int[] setup)
{
  // use local vars from the setup method
  int lineEndPos=setup[1];
  int longestSide=setup[4];
  int shortestSide=setup[5];
  
  // create the line
  int[] line = new int[longestSide];
  
  // allow room for one more so we can add an extra value 0 at the beginning
  int[] ratioOfSplitRect = new int[shortestSide+1];
  
  int nom=longestSide;
  int plussingNom=nom;
  int denom=shortestSide;
  
  // we need a zero number to begin the first ratio and calculate the following ratios
  ratioOfSplitRect[0]=0;
  // start at 1 as ratio[0] needs to be zero
  for(int i=1;i<shortestSide+1;i++)
  {
    ratioOfSplitRect[i] = plussingNom / denom;
    plussingNom = plussingNom + nom;
  }
  
  // the beginning of the line
  int subtract=lineEndPos;
  int currentPixel=0;
  
  for(int i=1;i<shortestSide+1;i++)
  {
    // first time draw the first point of the line. endPos...
    line[currentPixel] = subtract;
    currentPixel++;

    // find the distance between the current ratio and the last ratio
    int extendBy = ratioOfSplitRect[i] - ratioOfSplitRect[i-1]; 
    
    // how many times do we extend the line...
    for(int j=extendBy-1;j>0;j--)
    {
      subtract -= extendLine;
      line[currentPixel] = subtract;
      currentPixel++;
    }
    // ...then on subsequent i loops advance the line
    subtract-=advanceLine;
  }
  
  return line;
}

int mywidth(int startPos,int endPos){
  int result=-1;
  // first result from comp_width_and_height
  result=comp_width_and_height(startPos,endPos)[0];
  return result+1;
}

int myheight(int startPos, int endPos){
  int result=-1;
  // last result from comp_width_and_height
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
  // the resulting rect loses a height of one
  if(pixel_to_xy(startPos)[0]>pixel_to_xy(endPos)[0])
  {
    thisHeight++;
  }
  // some math can result in correct negative values
  // width
  result[0]=abs(startPos+(screenWidth*(thisHeight))-endPos);
  // height
  result[1]=thisHeight;

  return result;
}

int xy_to_pixel(int x, int y)
{
  int result=-1;
  result = x+screenWidth*y;
  return result;
}

int mouse_to_pixel(int mx, int my)
{
  int resultx = -1;
  int resulty = -1;
  int result = -1;
  
  resultx=int(mx / gridspacing );
  resulty=int(my / gridspacing );
  
  // get pixel number
  result = resultx + (screenWidth*resulty);
  return result;
}

int[] pixel_to_xy(int pixelnumber)
{
  
  //int result[] = new int[2];
  int result[] = {-1,-1};
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
  endPosPoint=pixel_to_xy(pixel);
  fill(0,0,255);
  ellipse(gridStartPosX+(gridspacing*endPosPoint[0])+gridspacing/2,
          gridStartPosY+(gridspacing*endPosPoint[1])+gridspacing/2,
          gridspacing,gridspacing);
}

void drawYellowDot(int pixel)
{
  int[] startPosPoint=pixel_to_xy(pixel);
  fill(255,255,0);
  ellipse(gridStartPosX+(gridspacing*startPosPoint[0])+gridspacing/2, gridStartPosY+(gridspacing*startPosPoint[1])+gridspacing/2, gridspacing,gridspacing);
}

void draw_processing_pixels(int pixel)
{
  color red = color(255,0,0);
  if(pixel > 0)
  {
    pixels[pixel] = red;
  }
}

void draw_processing_line(int[] line)
{
  loadPixels();
  for(int i=0;i<line.length;i++)
  {
    draw_processing_pixels(line[i]);
  }
  updatePixels();  
}

void draw_black_pixel(int pixel)
{
  int[] coordinates=pixel_to_xy(pixel);
  fill(0);
  rect(gridStartPosX+coordinates[0]*gridspacing,gridStartPosY+coordinates[1]*gridspacing,gridspacing,gridspacing);
}

void draw_simple_line(int[] line)
{
  for(int i=0;i<line.length;i++)
  {
    draw_black_pixel(line[i]);
  }
  
  // draw start and end points over top
  drawBlueDot(line[0]);
  // find end of array value
  drawYellowDot(line[line.length-1]);
}

void draw_grid()
{
  for(int column=0;column<=screenWidth;column++)
  {
    for(int row=0;row<=screenHeight;row++)
    {
      line(gridStartPosX+column,gridStartPosY+(row*gridspacing),gridStartPosX+(column*gridspacing),gridStartPosY+(row*gridspacing));
      line(gridStartPosX+(column*gridspacing),gridStartPosY+row,gridStartPosX+(column*gridspacing),gridStartPosY+(row*gridspacing));
    }
  }
}

void draw_square_processing(int x, int y, int size)
{
  int middle;
  int topLeftCorner;
  int topRightCorner;
  int bottomLeftCorner;
  int bottomRightCorner;
  
  middle = xy_to_pixel(x,y);
  
  loadPixels();
  // indictation of where box middle is
  color black = color(0);
  pixels[middle] = black;
  updatePixels();
  
  topLeftCorner = middle-(screenWidth*size)-size;
  topRightCorner =middle-(screenWidth*size)+size;
  bottomLeftCorner = middle+(screenWidth*size)-size;
  bottomRightCorner = middle+(screenWidth*size)+size;

  // top of box
  int topsx = topLeftCorner;
  int topex = topRightCorner;
  int topsetUp[] = setup_line(topsx,topex);
  int topline[] = create_line(topsetUp);
  
  // left of box
  int leftsx = topLeftCorner;
  int leftex = bottomLeftCorner;
  int leftsetUp[] = setup_line(leftsx,leftex);
  int leftline[] = create_line(leftsetUp);
  
  // bottom of box
  int bottomsx = bottomLeftCorner;
  int bottomex = bottomRightCorner;
  int bottomsetUp[] = setup_line(bottomsx, bottomex);
  int bottomline[] = create_line(bottomsetUp);
  
  // right of box
  int rightsx = topRightCorner;
  int rightex = bottomRightCorner;
  int rightsetUp[] = setup_line(rightsx, rightex);
  int rightline[] = create_line(rightsetUp);

  draw_processing_line(topline);
  draw_processing_line(bottomline);
  draw_processing_line(leftline);
  draw_processing_line(rightline);
}
