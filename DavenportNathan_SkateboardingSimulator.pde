// Nathan Davenport - Skateboarding Simulator Version 1

import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import controlP5.*;


TextToSpeechMaker ttsMaker; 

//<import statements here>

//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String sampleJSON = "samplejson.json";
Event currentEvent;

// objects
ControlP5 p5;

// colors
color backGood = color(30, 50, 30);
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

RadioButton selector;

Toggle manualModeToggle;
Toggle gameModeToggle;
Toggle blindModeToggle;
Button runSimulatorButton;

// animation
int time;
boolean animationRunning;
int ground = 300;

boolean gameMode = false;
boolean manualMode = false;
boolean blindMode = false;


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

// input
boolean spacePressed;
int userPopPower;
int pushTimer;


void setup() {
  // maximum window size used
  size(900, 750);
  
  // audio context
  ac = new AudioContext(); //ac is defined in helper_functions.pde

  setupWaveplayers(); // sonification.pde
  ac.start();
  

  // text to speech

  // this will create WAV files in your data directory from input speech 
  // which you will then need to hook up to SamplePlayer Beads
  ttsMaker = new TextToSpeechMaker();
  
  String exampleSpeech = "Text to speech enabled";
  
  //ttsExamplePlayback(exampleSpeech); 
  //see ttsExamplePlayback below for usage


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
    .setPosition(740, 530)
    .setSize(140, 20)
    .setLabel("Run Simulator (press R)")
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

void playbackSelector(int selection) {
  animationRunning = false;
  unlockSliderValues();
  surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
  
    

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
            /*
        case 3: // Manual Slider
          println("Manual");
          surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT_EXPANDED);
          size(SCREEN_WIDTH, SCREEN_HEIGHT_EXPANDED);
          resetSliderValues();
          //currentEvent = null;


            break;
        case 4: // Game
          println("Game");
          gameMode = true;
          

            break;*/
        default:
          println("No selection!");
          break;

    }

    
}

void runSimulator() {

  // reset all values for new run
  time = 0;
  animationRunning = false;
  boardX = BOARD_X_INITIAL;
  boardY = BOARD_Y_INITIAL;
  boardYvelocity = 0;
  boardXvelocity = 0;
  animationRunning = true;
  totalPushes = currentEvent.getSkaterTotalPushes();
  voicePlayed = false;
  pushTimer = 0;
  userPopPower = 0;
  canPush = true;
  canPop = true;
  back = backGood;
  hasPopped = false;
  ttsExamplePlayback("Go!");


  // only allow sliders to be modified between runs
  lockSliderValues(); 
}

void update() {

  // !! UPDATE SECTION

  //!! variables
  


  // ending animation if board goes off screen
  if (boardX > SCREEN_WIDTH) {
    animationRunning = false;
  }

  // updating board math
  if(animationRunning) {
    // incrementing time
    time++;

    // visual effect
    if (collisionWithObstacle() || (time > 500 && boardXvelocity == 0)) {
      back = backFail;
      animationRunning = false;
      unlockSliderValues();
    }

    // update sound info
    updateSound();

    // update board data
    updateBoard();


  } else {

    unlockSliderValues(); // allow user to change sliders;
    masterGainGlide.setValue(0.0); // make it shut up

  }
}

void updateSound() {

  /*
  if (boardX > OBSTACLE_X_INITIAL + currentEvent.getObstacleThickness()) {
    waveFrequency.setValue(0);
  } else {
    waveFrequency.setValue(boardX + 1000);
  }
  */

  /*
  if (time % 10 == 0 || time % 20 == 0) {
    println("aaaa");
    masterGainGlide.setValue(1.0);
  } else {
    println("bbbb");
    masterGainGlide.setValue(0.0);
  }
  */
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
      
      if (totalPushes > 0) {
        totalPushes--;
      }
    }
    // json pop
    if (boardX > OBSTACLE_X_INITIAL - currentEvent.getSkaterPopDistanceFromObstacle() && !hasPopped) {
      hasPopped = true;
      boardYvelocity = currentEvent.getSkaterPopHeight();
      ttsExamplePlayback("Pop!");
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
    background(color(20, 40, 20));
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

      drawGround(0, ground, currentEvent.getGroundAngle());
      drawBoard(boardX, boardY, boardRoation);
      drawObstacle(
        OBSTACLE_X_INITIAL, 
        OBSTACLE_Y_INITIAL - currentEvent.getObstacleHeight(), 
        currentEvent.getObstacleThickness(), 
        currentEvent.getObstacleHeight()
      );

    }

  }

    
  // text labels
  fill(color(255,255,255));
  text("1, 2, 3 to select demo,          r to run simulation,          g for game mode,          m for manual mode,          b for blind mode", 100, 15);
  if(gameMode) {
    text("enter to push,          space to ollie (jump), hold to charge up ollie (jump)", 240, 480); 
  }
  text("json demos:", 30, 520);
  text("modes:", 450, 520);
  text("manual sliders:", 30, 590);


  // debug text
  text("time: " + str(time), 820, 15 + 575);
  text("posX: " + str(boardX), 820, 25 + 575);
  text("velX: " + str(boardXvelocity), 820, 35 + 575);
  text("pop: " + str(userPopPower), 820, 45 + 575);
  text("pushes: " + str(currentEvent.getSkaterTotalPushes()), 820, 55 + 575);
  rect(0, 490, 900, 1);

}

void keyPressed() {
  
  if (int(key) > 48 && int(key) < 54) {
    playbackSelector(int(key) - 49);
    selector.activate(int(key) - 49);
  }
  if (key == 'm') {
    manualModeToggle.setValue(!manualMode);
  }

  if (key == 'g') {
    gameModeToggle.setValue(!gameMode);
  }

  if (key == 'b') {
    blindModeToggle.setValue(!blindMode);
  }

  // reset
  if (keyCode == 8) {
    animationRunning = false;
  }

  if (key == 'r') {
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
    }

  }

}

void keyReleased() {
  if (gameMode) {

    if (keyCode == 32 && canPop) {
      spacePressed = false;
      boardYvelocity = userPopPower;
      // boardY -= BOARD_HEIGHT;    
      userPopPower = 0;
      canPop = false;
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
    rect(0, 0, 1000, 5);
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


void ttsExamplePlayback(String inputSpeech) {
  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
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