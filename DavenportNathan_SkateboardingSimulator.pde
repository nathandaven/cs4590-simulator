// Nathan Davenport - Skateboarding Simulator Version 1

import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import controlP5.*;


//name of a file to load from the data directory
String sampleJSON = "samplejson.json";
Event currentEvent;

// objects
ControlP5 p5;

// colors
color backGood = color(30, 50, 30);
color backWin  = color(90,100,70);
color backFail = color(100, 50, 30);

color active   = color(178, 235, 128);
color fore     = color(148, 235, 128);
color back     = backGood;

// Sliders
Slider[] sliders;

Slider skaterTotalPushesSlider;
Slider skaterPushPowerSlider;
Slider skaterPopHeightSlider;
Slider skaterPopDistanceFromObstacleSlider;
Slider obstacleThicknessSlider;
Slider obstacleHeightSlider;
Slider groundAngleSlider;
Slider masterVolumeSlider;

RadioButton selector;

Toggle recordToggle;
Toggle manualModeToggle;
Toggle gameModeToggle;
Toggle blindModeToggle;
Button runSimulatorButton;
Button resetSimulatorButton;
Button helpButton;

// animation
int time;
boolean animationRunning;
int ground = 300;

boolean recordMode;
boolean gameMode = false;
boolean manualMode = false;
boolean blindMode = false;
boolean showHelp = false;


// constants
int SCREEN_WIDTH = 900;
int SCREEN_HEIGHT = 580;
int SCREEN_HEIGHT_EXPANDED = 730;
int BOARD_HEIGHT = 26;
int BOARD_WIDTH = 80;
int BOARD_X_DRAG = 1;
int BOARD_X_MAX_VELOCITY = 20;
int BOARD_X_INITIAL = 0;
int BOARD_Y_INITIAL = ground - BOARD_HEIGHT;
int OBSTACLE_X_INITIAL = 600;
int OBSTACLE_Y_INITIAL = ground;
int PUSH_TIMING = 20;
int TOTAL_PUSHES = 3;

// board variables
int boardX;
int boardY;
int boardXvelocity;
int boardXacceleration = 1;
int boardYvelocity;
int boardYacceleration = 1;
int totalPushes;
boolean canPop;
boolean canPush;
boolean voicePlayed;
boolean hasPopped;
boolean playedLandSound;
boolean boardHasCleared;

// input
boolean spacePressed;
int userPopPower;
int pushTimer;

// i moved a lot of setup into their own methods and files for organization
void setup() {
  // maximum window size used
  size(900, 750);
  
  // audio context
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  setupAudio(); // sonification.pde
  ac.start();
  
  // creates a default event to prevent errors
  currentEvent = new Event(loadJSONArray(sampleJSON).getJSONObject(0));

  // create the user interface
  createUI();

  // loading default selector
  playbackSelector(0);
}

// creates the user interface
void createUI() {

  // ui elements

  p5 = new ControlP5(this);

  // visual buttons


  selector = p5.addRadioButton("playbackSelector")
    .setPosition(30,530)
    .setSize(20, 20)
    .setSpacingColumn(75)
    .setItemsPerRow(10)
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .addItem("Flat (#1)", 0)
    .addItem("Incline (#2)", 1)
    .addItem("Decline (#3)", 2)
    //.addItem("Manual Slider", 3)
    //.addItem("Game Mode", 4)
    .activate(0);

  runSimulatorButton = p5.addButton("runSimulator")
    .setPosition(750, 515)
    .setSize(120, 20)
    .setLabel("Run")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(88,185,88))
    .setColorActive(color(178,235,128));

  resetSimulatorButton = p5.addButton("resetSimulator")
    .setPosition(750, 545)
    .setSize(120, 20)
    .setLabel("Reset")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(1100,120,90))
    .setColorActive(color(178,235,128));

  recordToggle = p5.addToggle("toggleRecordMode")
    .setPosition(350, 530)
    .setSize(50, 20)
    .setLabel("Record Mode")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128));

  blindModeToggle = p5.addToggle("toggleBlindMode")
    .setPosition(650, 530)
    .setSize(50, 20)
    .setLabel("Blind Mode")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128));

  manualModeToggle = p5.addToggle("toggleManualMode")
    .setPosition(550, 530)
    .setSize(50, 20)
    .setLabel("Manual Mode")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128));


  gameModeToggle = p5.addToggle("toggleGameMode")
    .setPosition(450, 530)
    .setSize(50, 20)
    .setLabel("Game Mode")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128));


  helpButton = p5.addButton("toggleHelp")
    .setPosition(4, 4)
    .setSize(15, 15)
    .setLabel("?")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128));

  // SLIDERS FOR MANUAL MODE

  skaterTotalPushesSlider = p5.addSlider("skaterTotalPushesSlider")
    .setPosition(30,  600)
    .setSize(200, 20)
    .setRange(2, 4)
    .setValue(3)
    .setLabel("Skater Total Pushes")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));

  skaterPushPowerSlider = p5.addSlider("skaterPushPowerSlider")
    .setPosition(30,  630)
    .setSize(200, 20)
    .setRange(1, 10)
    .setValue(3)
    .setLabel("Skater Push Power")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));

  skaterPopHeightSlider = p5.addSlider("skaterPopHeightSlider")
    .setPosition(30,  660)
    .setSize(200, 20)
    .setRange(5, 20)
    .setValue(15)
    .setLabel("Skater Pop Height")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));

  skaterPopDistanceFromObstacleSlider = p5.addSlider("skaterPopDistanceFromObstacleSlider")
    .setPosition(30,  690)
    .setSize(200, 20)
    .setRange(50, 200)
    .setValue(140)
    .setLabel("Skater Pop Distance from Obstacle")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));

  obstacleThicknessSlider = p5.addSlider("obstacleThicknessSlider")
    .setPosition(450, 600)
    .setSize(200, 20)
    .setRange(10, 40)
    .setValue(25)
    .setLabel("Obstacle Thickness")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));

  obstacleHeightSlider = p5.addSlider("obstacleHeightSlider")
    .setPosition(450, 630)
    .setSize(200, 20)
    .setRange(10, 100)
    .setValue(20)
    .setLabel("Obstacle Height")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));

  groundAngleSlider = p5.addSlider("groundAngleSlider")
    .setPosition(450, 660)
    .setSize(200, 20)
    .setRange(-5, 5)
    .setValue(0)
    .setLabel("Ground Angle")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));


  masterVolumeSlider = p5.addSlider("masterVolumeSlider")
    .setPosition(450, 690)
    .setSize(200, 20)
    .setRange(0, 100.0)
    .setValue(100.0)
    .setLabel("Master Volume")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));


}

// UI methods

void skaterTotalPushesSlider(int val) {
  currentEvent.skaterTotalPushes = val;
}

void skaterPushPowerSlider(int val) {
  currentEvent.skaterPushPower = val;
}

void skaterPopHeightSlider(int val) {
  currentEvent.skaterPopHeight = val;
}

void skaterPopDistanceFromObstacleSlider(int val) {
  currentEvent.skaterPopDistanceFromObstacle = val;
}

void obstacleThicknessSlider(int val) {
  currentEvent.obstacleThickness = val;
}

void obstacleHeightSlider(int val) {
  currentEvent.obstacleHeight = val;
}

void groundAngleSlider(int val) {
  currentEvent.groundAngle = val;
}

void masterVolumeSlider(float val) {
  masterGainGlide.setValue(val / 100.0);
}

void resetSliderValues() {
  skaterTotalPushesSlider.setValue(currentEvent.getSkaterTotalPushes());
  skaterPushPowerSlider.setValue(currentEvent.getSkaterPushPower());
  skaterPopHeightSlider.setValue(currentEvent.getSkaterPopHeight());
  skaterPopDistanceFromObstacleSlider.setValue(currentEvent.getSkaterPopDistanceFromObstacle());
  obstacleThicknessSlider.setValue(currentEvent.getObstacleThickness());
  obstacleHeightSlider.setValue(currentEvent.getObstacleHeight());
  groundAngleSlider.setValue(currentEvent.getGroundAngle());
}

void lockSliderValues() {
  skaterTotalPushesSlider.lock()
    .setColorForeground(color(200, 210, 200));
  skaterPushPowerSlider.lock()
    .setColorForeground(color(200, 210, 200));
  skaterPopHeightSlider.lock()
    .setColorForeground(color(200, 210, 200));
  skaterPopDistanceFromObstacleSlider.lock()
    .setColorForeground(color(200, 210, 200));
  obstacleThicknessSlider.lock()
    .setColorForeground(color(200, 210, 200));
  obstacleHeightSlider.lock()
    .setColorForeground(color(200, 210, 200));
  groundAngleSlider.lock()
    .setColorForeground(color(200, 210, 200));
}


void unlockSliderValues() {
  skaterTotalPushesSlider.unlock()
    .setColorForeground(color(148,235,128));
  skaterPushPowerSlider.unlock()
    .setColorForeground(color(148,235,128));
  skaterPopHeightSlider.unlock()
    .setColorForeground(color(148,235,128));
  skaterPopDistanceFromObstacleSlider.unlock()
    .setColorForeground(color(148,235,128));
  obstacleThicknessSlider.unlock()
    .setColorForeground(color(148,235,128));
  obstacleHeightSlider.unlock()
    .setColorForeground(color(148,235,128));
  groundAngleSlider.unlock()
    .setColorForeground(color(148,235,128));
}


void toggleRecordMode() {
  
  // TODO

  if (!recordMode) {
    createNewFile();
    writeToFile(currentEvent.toString());

  } else {
    writeToFile("\nTotal Runs: " + str(totalSimulatorRuns));
    writeToFile("Success rate: " + str((float) totalSuccessfulRuns / totalSimulatorRuns));
    writeToFile("Game mode: " + str(gameMode));
    writeToFile("Manual mode: " + str(manualMode));
    writeToFile("Blind mode: " + str(blindMode));
    writeToFile("\nEnd of file");
    closeFile();
  }

  recordMode = !recordMode;
}

void toggleBlindMode() {
  blindMode = !blindMode;
}

void toggleManualMode() {
  manualMode = !manualMode;
  animationRunning = false;

  if(manualMode) {
    resetSliderValues();
    surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT_EXPANDED);
    size(SCREEN_WIDTH, SCREEN_HEIGHT_EXPANDED);
    
  } else {
    surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
    size(SCREEN_WIDTH, SCREEN_HEIGHT);
  }
}

void toggleGameMode() {
  gameMode = !gameMode;
  animationRunning = false;

  if (gameMode) {
    // not used in game mode
    skaterTotalPushesSlider.lock()
      .setColorForeground(color(200, 210, 200));

  } else {
    unlockSliderValues();
  }
  
}

void toggleHelp() {
  showHelp = !showHelp;
}

void playbackSelector(int selection) {
  animationRunning = false;

  if (!gameMode) {
    surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
    size(SCREEN_WIDTH, SCREEN_HEIGHT);
  } else {
    resetSliderValues();
    unlockSliderValues();
  }
  

  switch(selection){
    case 0: // JSON 1
      currentEvent = new Event(loadJSONArray(sampleJSON).getJSONObject(0));
      println("JSON 1");
      break;

    case 1: // JSON 2
      currentEvent = new Event(loadJSONArray(sampleJSON).getJSONObject(1));
      println("JSON 2");
      break;

    case 2: // JSON 3
      currentEvent = new Event(loadJSONArray(sampleJSON).getJSONObject(2));
      println("JSON 3");
      break;

    default:
      println("No selection!");
      break;
  }
}

void resetSimulator() {

  // reset all values for new run
  time = 0;
  animationRunning = false;
  boardX = BOARD_X_INITIAL;
  boardY = BOARD_Y_INITIAL;
  boardYvelocity = 0;
  boardXvelocity = 0;
  totalPushes = currentEvent.getSkaterTotalPushes();
  voicePlayed = false;
  pushTimer = 0;
  userPopPower = 0;
  canPush = true;
  canPop = true;
  back = backGood;
  hasPopped = false;
  boardHasCleared = false;

}

void runSimulator() {
  resetSimulator();

  animationRunning = true;

  ttsExamplePlayback("Go!");

  if (recordMode) {

    writeToFile("\n\nRun #" + Integer.toString(totalSimulatorRuns) + "\n");
    totalSimulatorRuns++;
  }

  // only allow sliders to be modified between runs
  lockSliderValues(); 
}

void update() {

  // !! UPDATE SECTION
  
  // during animation
  if(animationRunning) {
    
    // incrementing time
    time++;

    // update sound info
    updateSound();

    // update board data
    updateBoard();


    // collision with obstacle
    if (collisionWithObstacle() || (time > 500 && boardXvelocity == 0)) {
      back = backFail;
      animationRunning = false;
      unlockSliderValues();

      if ((time > 500 && boardXvelocity == 0)) {
        ttsExamplePlayback("Ran out of time!");
      } else {
        ttsExamplePlayback("Collision!");
      }
    }


  } else { // not during animation

    unlockSliderValues(); // allow user to change sliders;
    skaterPositionGainGlide.setValue(0);

  }

  // checking conditions

  if (boardX > OBSTACLE_X_INITIAL + currentEvent.getObstacleThickness() && animationRunning) {
    boardHasCleared = true;
  }

  if (boardHasCleared && animationRunning && boardX > SCREEN_WIDTH) {
    ttsExamplePlayback("Success!");
    if (recordMode) {
      totalSuccessfulRuns++;
      writeToFile("time of success: " + str(time));
    }
    back = backWin;
  }

  // ending animation if board goes off screen
  if (boardX > SCREEN_WIDTH) {
    animationRunning = false;
  }

}

void updateSound() {

  // while animation running
  if (!boardHasCleared) {

    // updating the pitch based on board's Y value
    float pitch = 800 - (boardY);
    skaterPositionGlide.setValue(pitch);



    // using envelope to induce a beeping effect as board gets closer to obstacle
    if (skaterPositionGain.getGain() == 0) { // checking if previous segment is complete
      envelope.clear();

      // defining sustain value for segment
      int sustain =  300 - (boardX / 2);
      if (sustain < 100) {
        sustain = 100;
      }

      // adding segments to envelope
      envelope.addSegment(1, 1, 1);      // attack
      envelope.addSegment(0, sustain, 1); // release
    }

    // updates gain
    skaterPositionGain.setGain(envelope);

  } else { // when animation successful
    envelope.clear();
    skaterPositionGain.setGain(0);


  }
}

void updateBoard() {
  // game mode
  if (userPopPower < currentEvent.getSkaterPopHeight() && spacePressed) {
    userPopPower++;
  }

  // automated modes pushing + popping
  if(!gameMode) {
    // json pushes
    if (pushTimer < time && totalPushes > 0) {
      
      boardXvelocity += currentEvent.getSkaterPushPower();
      pushTimer = time + PUSH_TIMING;
      playSound(push);
      
      if (totalPushes > 0) {
        totalPushes--;
      }
    }


    // json pop
    if (boardX > OBSTACLE_X_INITIAL - currentEvent.getSkaterPopDistanceFromObstacle() && !hasPopped) {
      hasPopped = true;
      boardYvelocity = currentEvent.getSkaterPopHeight();
      playedLandSound = false;
      //ttsExamplePlayback("Pop!");

      playSound(pop);
    }
  }


  //!! y direction
  boardY -= boardYvelocity;

  if (boardY < BOARD_Y_INITIAL) {
    boardYvelocity -= boardYacceleration;


  } else {
    boardY = BOARD_Y_INITIAL;
    boardYvelocity = 0;
    canPop = true;

    if(!playedLandSound) {
      playSound(land);
      playedLandSound = true;
    }
  }


  //!! x direction
  boardX += boardXvelocity;

  //boardXvelocity -= boardXacceleration;
  // applying angle to drag frequency to make the angle *feel* more difficult to push up, or easier to go down depending on angle
  if (time % (55 + (currentEvent.getGroundAngle() * 10)) == 0) {
      boardXvelocity -= BOARD_X_DRAG;

    /*
    if (currentEvent.getGroundAngle() > 0) {
      // makes board accelerate faster downhill
      boardXvelocity += BOARD_X_DRAG;
    } else {
      boardXvelocity -= BOARD_X_DRAG;
      // makes board drag uphill
    } */

  }
  if (boardXvelocity < 0) {
    boardXvelocity = 0;
  }
  if (boardXvelocity > BOARD_X_MAX_VELOCITY) {
    boardXvelocity = BOARD_X_MAX_VELOCITY;
  }
}

void draw() {
  update();

  // ui


  // !! DRAW SECTION
  if (blindMode) {
    background(back); //color(20, 40, 20)
    fill(fore);
    stroke(fore);
    text("audio only mode enabled", SCREEN_WIDTH / 2 - 70, SCREEN_HEIGHT / 2 - 50);
    
  } else {

    // UI setup 
    background(back);
    fill(fore);
    stroke(fore);


    
    // Animation drawing
    if(animationRunning) {

      int boardRoation = -2*boardYvelocity;
      if (boardRoation > 0) {
        boardRoation = 0;
      }

      // UI setup 
      background(back);
      

      fill(color(90,100,70));
      stroke(color(90,100,70));
      drawGround(0, ground, currentEvent.getGroundAngle());

      fill(fore);
      stroke(fore);
      drawBoard(boardX, boardY, boardRoation);
      drawObstacle(
        OBSTACLE_X_INITIAL, 
        OBSTACLE_Y_INITIAL - currentEvent.getObstacleHeight(), 
        currentEvent.getObstacleThickness(), 
        currentEvent.getObstacleHeight()
      );
    }

  }

  // ui section and background
  fill(backGood);
  rect(-5, 490, 910, 500);

  // text labels
  fill(color(255,255,255));
  text("json demos:", 30, 520);
  text("modes:", 350, 520);
  text("manual sliders:", 30, 590);
  
  if (showHelp) {
    text("1, 2, 3 to select demo,          r to run simulation,          g for game mode,          m for manual mode,          b for blind mode", 100, 15);
    if(gameMode) {
      text("enter to push,          space to ollie (jump), hold to charge up ollie (jump)", 240, 480); 
    }

    // debug text
    text("time: " + str(time), 820, 15 + 575);
    text("pop: " + str(userPopPower), 820, 45 + 575);
    text("pushes: " + str(currentEvent.getSkaterTotalPushes()), 820, 55 + 575);
    text("posY: " + str(boardY), 820, 65 + 575);
    text("posX: " + str(boardX), 820, 75 + 575);
    text("velX: " + str(boardXvelocity), 820, 85 + 575);
  }


  //rect(0, 490, 900, 1);


}

void keyPressed() {
  
  // select JSON demo
  if (int(key) > 48 && int(key) < 54) {
    playbackSelector(int(key) - 49);
    selector.activate(int(key) - 49);
  }

  // toggle manual mode
  if (key == 'm' || key == 'M') {
    manualModeToggle.setValue(!manualMode);
  }

  // toggle game mode
  if (key == 'g' || key == 'G') {
    gameModeToggle.setValue(!gameMode);
  }

  // toggle blind mode
  if (key == 'b' || key == 'B') {
    blindModeToggle.setValue(!blindMode);

  }

  // reset 
  if (keyCode == 8) { // backspace key
    resetSimulator();
  }

  // run simulator
  if (key == 'r' || key == 'R') {
    runSimulator();
  }


  if (gameMode) {

    // pop
    if (keyCode == 32 && canPop && !spacePressed) { // spacebar
      spacePressed = true;
      canPop = false;
    } 

    // push
    if (key == RETURN || key == ENTER && pushTimer < time && /* totalPushes > 0 && */ canPush && canPop) {
      boardXvelocity += currentEvent.getSkaterPushPower();
      pushTimer = time + PUSH_TIMING;
      canPush = false;
      if (totalPushes > 0) {
        totalPushes--;
      }
      if (recordMode) {
        writeToFile("pushed at: " + str(boardX));
      }

      playSound(push);
    }

  }

}

void keyReleased() {
  if (gameMode) {

    if (keyCode == 32 && canPop) {
      spacePressed = false;
      boardYvelocity = userPopPower;
      // boardY -= BOARD_HEIGHT;    


      if (recordMode) {
        writeToFile("X position of pop " + str(boardX));
        writeToFile("X velocity at pop: " + str(boardXvelocity));
        writeToFile("height of pop: " + str(userPopPower));
      }

      userPopPower = 0;
      canPop = false;

      playSound(pop);
      playedLandSound = false;


    }

    if (key == RETURN || key == ENTER) {
      canPush = true;
    }
  }
}

void drawObstacle(int x, int y, int thickness, int height) {
    // draws ground
    pushMatrix();
    rotate(radians(currentEvent.getGroundAngle()));
    translate(x, y);
    rect(0, 0, thickness, height);
    popMatrix();
}

void drawGround(int x, int y, int rotation) {
    // draws ground
    pushMatrix();
    translate(x, y);
    rotate(radians(rotation));
      fill(color(90,100,70));
      stroke(color(90,100,70));
    rect(-50, 0, 1000, 500);
    popMatrix();
}

// draws board, rotation is in degrees
// postive tilts foward, negative tilts back
void drawBoard(int x, int y, int rotation) {
  pushMatrix();
  // check collision box with this
  // rect(boardX, boardY, BOARD_WIDTH, BOARD_HEIGHT);
  // rotation
  rotate(radians(currentEvent.getGroundAngle()));
  translate(x + 10, y + 20);
  rotate(radians(rotation));

  // deck
  rect(0, -12, 60, 4);

  // wheels
  pushMatrix();
  translate(10, 0);
  circle(0, 0, 14);
  popMatrix();

  pushMatrix();
  translate(50, 0);
  circle(0, 0, 14);
  popMatrix();

  // tail
  pushMatrix();
  translate(-8, -3 - 12);
  rotate(radians(20));
  rect(0, 0, 10, 4);
  popMatrix();

  // nose
  pushMatrix();
  translate(60, 1 - 12);
  rotate(radians(-20));
  rect(0, 0, 10, 4);
  popMatrix();

  popMatrix();
}


boolean collisionWithObstacle() {

  int colA = boardX;
  int rowA = boardY;
  int widthA = BOARD_WIDTH;
  int heightA = BOARD_HEIGHT;
  int colB = OBSTACLE_X_INITIAL;
  int rowB = OBSTACLE_Y_INITIAL - currentEvent.getObstacleHeight();
  int widthB = currentEvent.getObstacleThickness();
  int heightB = currentEvent.getObstacleHeight();

  return rowA < rowB + heightB && rowA + heightA > rowB
        && colA < colB + widthB && colA + widthA > colB;

  
}