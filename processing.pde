int done = 0;
int targetCount = 0;

// size of a tile in pixels
int tileSize = 50;

// width of the grid
int w = 10;
// height of the grid
int h = 10;

// width of the window in pixels
int width;
// height of the window in pixels
int height;

// position of the player (x,y)
PVector playerPosition;
// position of the boxes (x,y)
ArrayList<PVector> boxes;

// type of the cell on the grid (only static tiles)
enum Cell {
   Wall,
   Floor,
   Target
}

// tilemap of the game represented by a 2d array
// it is row major meaning the first index represents the row index
// second index represent the column index
// so the tile of coordinates (x,y) is at grid[y][x]
Cell[][] grid;

void settings() {
  // load the level as as an array of lines
  String[] lines = loadStrings("1.txt");
  w = lines[0].length();
  h = lines.length;
  // initialize the grid
  grid = new Cell[h][w];
  // initiliaze the boxes array
  boxes = new ArrayList<PVector>();

  // parse the level file
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      char currentChar = lines[y].charAt(x);
      if(currentChar == '#') {
        grid[y][x] = Cell.Wall;
      } else if(currentChar == ' ') {
        grid[y][x] = Cell.Floor;
      } else if(currentChar == '@') { // represents initial player position
        playerPosition = new PVector(x,y);
        grid[y][x] = Cell.Floor;
      } else if(currentChar == '$') {
        grid[y][x] = Cell.Floor;
        boxes.add(new PVector(x,y));
      } else if (currentChar == '.') {
        grid[y][x] = Cell.Target;
        targetCount++;  
      }
    }
  }

  width = w * tileSize;
  height = h * tileSize;

  setSize(width, height);
}

/**
  * Draws the grid (static objects) on the screen
  */
void drawGrid() {
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      Cell cell = grid[y][x];
      if(cell == Cell.Wall) { 
        fill(0); // black
      } else if(cell == Cell.Floor) {
        fill(255); // white
      } else if(cell == Cell.Target) {
        fill(255, 214, 51); // some kind of yellow
      }
      rect(x * tileSize, y * tileSize, tileSize, tileSize);
    }
  }
}

/**
  * Draws the boxes on the screen
  */
void drawBoxes() {  
  for(int i = 0; i < boxes.size(); i++) {
    fill(115, 77, 38);
    PVector pos = boxes.get(i);
    rect(pos.x * tileSize, pos.y * tileSize, tileSize, tileSize);
  }
}

/**
  * Draws the player on the screen
  */
void drawPlayer() {
  fill(0, 102, 204);
  rect(playerPosition.x * tileSize, playerPosition.y * tileSize, tileSize, tileSize);
}

/**
  * Returns the cell at (x,y) in pos
  */
Cell cellAt(PVector pos) {
  return grid[(int)pos.y][(int)pos.x];
}

/**
  * Checks if a box exists at the given position
  */
boolean boxExists(PVector pos) {
  for(int i = 0; i < boxes.size(); i++) {
    if(boxes.get(i).equals(pos)) {
      return true;
    }
  }
  return false;
}

/**
  * Checks if the tile at the given position is free
  * That is, the tile is not a wall and there isn't a box
  */
boolean isFree(PVector position) {
   return cellAt(position) != Cell.Wall && !boxExists(position);
}

/**
  * Checks if the player can move in the direction given
  */
boolean playerCanMove(PVector dir) {
  PVector next = PVector.add(playerPosition, dir); 
  return isFree(next);
}

/**
  * Checks if the box can move in the direction given
  * The condition for the box to move happens to be the same conditions for the player
  * but for some variants of Sokoban games, this might not be true
  */
boolean boxCanMove(PVector pos, PVector dir) {
    PVector next = PVector.add(pos, dir); 
    return isFree(next);
}

/**
  * Returns the box at the given position if it exists, otherwise returns null
  */
PVector getBox(PVector pos) {
  for(int i = 0; i < boxes.size(); i++) {
    if(boxes.get(i).equals(pos)) {
      return boxes.get(i);
    }
  }
  return null;
}
  
/**
  * Allows us to 'listen' or 'wait' for key presses from the user
  */
void keyPressed() {
  // directin 'intention/
  PVector dir = new PVector(0,0);
  if(keyCode == UP) {
    dir.y = -1;
  }
  if(keyCode == DOWN) {
    dir.y = 1;
  }
  if(keyCode == LEFT) {
    dir.x = -1;
  }
  if(keyCode == RIGHT) {
    dir.x = 1;
  }
  // next position if the player is able to move in that direction
  PVector next = PVector.add(playerPosition, dir);
  if(playerCanMove(dir)) { // can move right now
    // move the player
    playerPosition.add(dir);
  } else {
     if(boxExists(next)) {
       if(boxCanMove(next, dir)) {
         PVector box = getBox(next);
         // if the box is on target cell and moves away from it
         // we have one less box on the target
         if(cellAt(box) == Cell.Target) {
           done--;
         }
         box.add(dir);
         // if the box moves on top of a target cell 
         // we have one more box on the target
         if(cellAt(box) == Cell.Target) {
           done++;
         }
         // move the player
          playerPosition.add(dir);
       }
     }   
  }  
}

/**
  * Draws the grid, boxes and player on the screen
  * How many times it gets called depends on the framerate that we set, or simply how fast the user's computer is
  * A good framerate is 60fps
  */
void draw() {
  // Order of drawing is important as they get layered
  drawGrid();
  drawBoxes();
  drawPlayer();
}
