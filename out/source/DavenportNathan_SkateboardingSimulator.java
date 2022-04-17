import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import beads.*; 
import org.jaudiolibs.beads.*; 
import java.util.*; 
import controlP5.*; 
import beads.*; 
import com.sun.speech.freetts.FreeTTS; 
import com.sun.speech.freetts.Voice; 
import com.sun.speech.freetts.VoiceManager; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class DavenportNathan_SkateboardingSimulator extends PApplet {

// Nathan Davenport - Skateboarding Simulator Version 1







//name of a file to load from the data directory
String flat = "flat.json";
String incline = "incline.json";
String decline = "decline.json";
Event currentEvent;

// objects
ControlP5 p5;

// colors
int backGood = color(30, 50, 30);
int backWin  = color(90,100,70);
int backFail = color(100, 50, 30);

int active   = color(178, 235, 128);
int fore     = color(148, 235, 128);
int back     = backGood;

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

Toggle recordModeToggle;
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
public void setup() {
  // maximum window size used
  
  
  // audio context
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  setupAudio(); // sonification.pde
  ac.start();
  
  // creates a default event to prevent errors
  currentEvent = new Event(loadJSONArray(flat).getJSONObject(0));

  // create the user interface
  createUI();

  // loading default selector
  playbackSelector(0);
}

// creates the user interface
public void createUI() {

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

  recordModeToggle = p5.addToggle("toggleRecordMode")
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
    .setRange(0, 100.0f)
    .setValue(100.0f)
    .setLabel("Master Volume")
    .setColorBackground(color(90,100,70))
    .setColorForeground(color(148,235,128))
    .setColorActive(color(178,235,128))
    .setColorValueLabel(color(90,100,7));


}

// UI methods

public void skaterTotalPushesSlider(int val) {
  currentEvent.skaterTotalPushes = val;
}

public void skaterPushPowerSlider(int val) {
  currentEvent.skaterPushPower = val;
}

public void skaterPopHeightSlider(int val) {
  currentEvent.skaterPopHeight = val;
}

public void skaterPopDistanceFromObstacleSlider(int val) {
  currentEvent.skaterPopDistanceFromObstacle = val;
}

public void obstacleThicknessSlider(int val) {
  currentEvent.obstacleThickness = val;
}

public void obstacleHeightSlider(int val) {
  currentEvent.obstacleHeight = val;
}

public void groundAngleSlider(int val) {
  currentEvent.groundAngle = val;
}

public void masterVolumeSlider(float val) {
  masterGainGlide.setValue(val / 100.0f);
}

public void resetSliderValues() {
  skaterTotalPushesSlider.setValue(currentEvent.getSkaterTotalPushes());
  skaterPushPowerSlider.setValue(currentEvent.getSkaterPushPower());
  skaterPopHeightSlider.setValue(currentEvent.getSkaterPopHeight());
  skaterPopDistanceFromObstacleSlider.setValue(currentEvent.getSkaterPopDistanceFromObstacle());
  obstacleThicknessSlider.setValue(currentEvent.getObstacleThickness());
  obstacleHeightSlider.setValue(currentEvent.getObstacleHeight());
  groundAngleSlider.setValue(currentEvent.getGroundAngle());
}

public void lockSliderValues() {
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


public void unlockSliderValues() {
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


public void toggleRecordMode() {
  
  // TODO

  if (!recordMode) {
    createNewFile();
    writeToFile(currentEvent.toString());

    // lock manual mode while recording
    lockSliderValues();
    /* selector.lock()
      .setColorForeground(color(200, 210, 200)); */
    manualModeToggle.lock()
      .setColorBackground(color(200, 210, 200));

  } else {
    writeToFile("\n\n\nTotal Runs: " + str(totalSimulatorRuns));
    writeToFile("Success rate (overall): " + str((float) totalSuccessfulRuns / totalSimulatorRuns));
    writeToFile("Success rate (Normal: " + str((float) totalSuccessfulRuns / totalNormalRuns));
    writeToFile("Success rate (Blind): " + str((float) totalSuccessfulRunsBlind / totalBlindRuns));
    writeToFile("\nEnd of file");
    closeFile();

    // unlock after
    unlockSliderValues();
    /* selector.unlock()
      .setColorForeground(color(148,235,128)); */
    manualModeToggle.unlock()
    .setColorBackground(color(90,100,70));
  }

  recordMode = !recordMode;
}

public void toggleBlindMode() {
  blindMode = !blindMode;
}

public void toggleManualMode() {
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

public void toggleGameMode() {
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

public void toggleHelp() {
  showHelp = !showHelp;
}

public void playbackSelector(int selection) {
  animationRunning = false;

  if (!manualMode) {
    surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
    size(SCREEN_WIDTH, SCREEN_HEIGHT);
  } else {
    resetSliderValues();
    unlockSliderValues();
  }
  

  switch(selection){
    case 0: // JSON 1
      currentEvent = new Event(loadJSONArray(flat).getJSONObject(0));
      println("JSON 1 loaded");
      break;

    case 1: // JSON 2
      currentEvent = new Event(loadJSONArray(incline).getJSONObject(0));
      println("JSON 2 loaded");
      break;

    case 2: // JSON 3
      currentEvent = new Event(loadJSONArray(decline).getJSONObject(0));
      println("JSON 3 loaded");
      break;

    default:
      println("No selection!");
      break;
  }
}

public void resetSimulator() {

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

public void runSimulator() {
  resetSimulator();

  animationRunning = true;

  ttsExamplePlayback("Go!");

  if (recordMode) {
    if (blindMode) {
      writeToFile("\n\nRun #" + Integer.toString(totalSimulatorRuns) + " (Blind)\n");
      totalBlindRuns++;
    } else {
      writeToFile("\n\nRun #" + Integer.toString(totalSimulatorRuns) + " (Normal)\n");
      totalNormalRuns++;
    }

    writeToFile("Blind mode: " + str(blindMode));
    writeToFile("Game mode: " + str(gameMode));
    writeToFile("Manual mode: " + str(manualMode) + "\n");

    totalSimulatorRuns++;
  }

  // only allow sliders to be modified between runs
  lockSliderValues(); 
}

public void update() {

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
        if (recordMode) {
          writeToFile("failed (ran out of time)");
        }
      } else {
        ttsExamplePlayback("Collision!");
        if(recordMode) {
          writeToFile("failed (collision at time: " + str(time) + ")");
        }
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

public void updateSound() {

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

public void updateBoard() {
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

public void draw() {
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
  //stroke(backGood);
  rect(-5, 490, 910, 500);

  if (recordMode) {
    stroke(backGood);
    rect(20, 500, 300, 60);
    fill(color(255,255,255));
    text("recording! swapping json disabled.", 30, 520);
    selector.hide();
  } else {
    fill(color(255,255,255));
    text("json demos:", 30, 520);
    selector.show();
  }

  // text labels
  fill(color(255,255,255));
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

  if (back == backWin) {
    text("success", SCREEN_WIDTH / 2 - 20, SCREEN_HEIGHT / 2 - 120);
  }
  if (back == backFail) {
    text("failed", SCREEN_WIDTH / 2 - 20, SCREEN_HEIGHT / 2 - 120);
  }

  //rect(0, 490, 900, 1);


}

public void keyPressed() {

  if (!recordMode) {
    // select JSON demo
    if (PApplet.parseInt(key) > 48 && PApplet.parseInt(key) < 54) {
      playbackSelector(PApplet.parseInt(key) - 49);
      selector.activate(PApplet.parseInt(key) - 49);
    }

    // toggle manual mode
    if (key == 'm' || key == 'M') {
      manualModeToggle.setValue(!manualMode);
    }

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

  // recordMode
  if (keyCode == 9) {
    recordModeToggle.setValue(!recordMode);
  }

  if (gameMode && animationRunning) {

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

public void keyReleased() {
  if (gameMode) {

    if (keyCode == 32 && canPop) {
      spacePressed = false;
      boardYvelocity = userPopPower;
      // boardY -= BOARD_HEIGHT;    


      if (recordMode) {
        writeToFile("X position of pop " + str(boardX));
        writeToFile("X velocity at pop: " + str(boardXvelocity));
        writeToFile("height of pop: " + str(userPopPower));

        println(boardX);
        println(OBSTACLE_X_INITIAL - currentEvent.getSkaterPopDistanceFromObstacle());


        writeToFile("pop position accuracy to JSON: " + str((float)( (boardX)) / (OBSTACLE_X_INITIAL - currentEvent.getSkaterPopDistanceFromObstacle())));
        writeToFile("height of pop accuracy to JSON: " + str((float) ((userPopPower) / currentEvent.getSkaterPopHeight())));
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

public void drawObstacle(int x, int y, int thickness, int height) {
    // draws ground
    pushMatrix();
    rotate(radians(currentEvent.getGroundAngle()));
    translate(x, y);
    rect(0, 0, thickness, height);
    popMatrix();
}

public void drawGround(int x, int y, int rotation) {
    // draws ground
    pushMatrix();
    translate(x, y);
    rotate(radians(rotation));
      fill(color(90,100,70));
      stroke(fore);
    rect(-50, 0, 1000, 500);
    popMatrix();
}

// draws board, rotation is in degrees
// postive tilts foward, negative tilts back
public void drawBoard(int x, int y, int rotation) {
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


public boolean collisionWithObstacle() {

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
class Event {
  
  int skaterTotalPushes;
  int skaterPushPower;
  int skaterPopHeight;
  int skaterPopDistanceFromObstacle;
  int obstacleThickness;
  int obstacleHeight;
  int groundAngle;

  String comment;
  
  public Event(JSONObject json) {
    
    this.skaterTotalPushes = json.getInt("skaterTotalPushes");
    this.skaterPushPower   = json.getInt("skaterPushPower");
    this.skaterPopHeight   = json.getInt("skaterPopHeight");
    this.skaterPopDistanceFromObstacle   = json.getInt("skaterPopDistanceFromObstacle");
    this.obstacleThickness = json.getInt("obstacleThickness");
    this.obstacleHeight    = json.getInt("obstacleHeight");
    this.groundAngle       = json.getInt("groundAngle");
    
    if (json.isNull("comment")) {
      this.comment = "~";
    }
    else {
      this.comment = json.getString("comment");
    }

  }
  
  public int getSkaterTotalPushes() { return skaterTotalPushes; }
  public int getSkaterPushPower()   { return skaterPushPower; }
  public int getSkaterPopHeight()   { return skaterPopHeight; }
  public int getSkaterPopDistanceFromObstacle()   { return skaterPopDistanceFromObstacle; }
  public int getObstacleThickness() { return obstacleThickness; }
  public int getObstacleHeight()    { return obstacleHeight; }
  public int getGroundAngle()       { return groundAngle; }

  public String getComment()        { return comment; }


  public String toString() {
      String output = "Current Event: \n\n";
      output += "skaterTotalPushes:               " + getSkaterTotalPushes() + "\n";
      output += "skaterPushPower:                 " + getSkaterPushPower() + "\n";
      output += "skaterPopHeight:                 " + getSkaterPopHeight() + "\n";
      output += "skaterPopDistanceFromObstacle:   " + getSkaterPopDistanceFromObstacle() + "\n";
      output += "obstacleThickness:               " + getObstacleThickness() + "\n";
      output += "obstacleHeight:                  " + getObstacleHeight() + "\n";
      output += "groundAngle:                     " + getGroundAngle() + "\n";
      
      output += "comment:                         " + getComment() + "\n";
      return output;
    }
}
//helper functions
AudioContext ac; //needed here because getSamplePlayer() uses it below

public Sample getSample(String fileName) {
 return SampleManager.sample(dataPath(fileName)); 
}

public SamplePlayer getSamplePlayer(String fileName, Boolean killOnEnd) {
  SamplePlayer player = null;
  try {
    player = new SamplePlayer(ac, getSample(fileName));
    player.setKillOnEnd(killOnEnd);
    player.setName(fileName);
  }
  catch(Exception e) {
    println("Exception while attempting to load sample: " + fileName);
    e.printStackTrace();
    exit();
  }
  
  return player;
}

public SamplePlayer getSamplePlayer(String fileName) {
  return getSamplePlayer(fileName, false);
}

PrintWriter output;
int totalFiles = 1;

int totalNormalRuns;
int totalBlindRuns;

int totalSimulatorRuns;
int totalSuccessfulRuns;
int totalSuccessfulRunsBlind;



int successfulBlindRuns;


public void createNewFile() {
  // Create a new file in the sketch directory

  output = createWriter("results/trial" + Integer.toString(totalFiles) + ".txt"); 
  totalFiles++;
  totalSimulatorRuns = 0;
  totalSuccessfulRuns = 0;
  totalSuccessfulRunsBlind = 0;
  totalNormalRuns = 0;
  totalBlindRuns = 0;
}

public void writeToFile(String note) {
    output.println(note);
}

public void closeFile() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
}



TextToSpeechMaker ttsMaker; 
Gain ttsGain;

Glide waveFrequency;
Gain waveGain;

// master gain
Gain masterGain;
Glide masterGainGlide;

// wave players
WavePlayer waveTone; // for testing


WavePlayer skaterPositionTone;
Glide skaterPositionGlide;
Gain skaterPositionGain;
Glide skaterPositionGainGlide;


int beepTimer;

// sampleplayers
Gain spGain;
SamplePlayer land;
SamplePlayer pop;
SamplePlayer push;

// filters
BiquadFilter highpassFilter;
Glide highpassGlide;

// envelopes
Envelope envelope;

public void setupAudio() {
  setupMasterGain();
  setupUgens();
  setupSamplePlayers();
  setupWavePlayers();
}

public void setupMasterGain() {
  masterGainGlide = new Glide(ac, 1.0f, 1.0f);  
  masterGain = new Gain(ac, 1, masterGainGlide);
  ac.out.addInput(masterGain);
}

public void setupUgens() {

  // filters
  highpassGlide = new Glide(ac, 10.0f, 500);
  highpassFilter = new BiquadFilter(ac, BiquadFilter.HP, highpassGlide, .5f);
  
  masterGain.addInput(highpassFilter);

  highpassGlide.setValue(2000.0f);


  // envelopes
  envelope = new Envelope(ac);


}

public void setupSamplePlayers() {
  ttsMaker = new TextToSpeechMaker();


  land = getSamplePlayer("land.mp3");
  pop = getSamplePlayer("pop.mp3");
  push = getSamplePlayer("push.mp3");

  land.setKillOnEnd(false);
  pop.setKillOnEnd(false);
  push.setKillOnEnd(false);

  land.pause(true);
  pop.pause(true);
  push.pause(true);

  spGain = new Gain(ac, 1, 0.3f); // create the gain object

  // add sounds
  spGain.addInput(land);
  spGain.addInput(pop);
  spGain.addInput(push);

  // using high pass filter to make sound effects less abrasive, and more room for other sounds
  highpassFilter.addInput(spGain);
  //masterGain.addInput(spGain);
}


// play sound using sample player
public void playSound(SamplePlayer sp) {
  sp.start();
  sp.setToLoopStart();
}


public void setupWavePlayers() {


  resetBaseFrequency();
  
  
  //waveTone.setBuffer(SineBuffer);
}

public void resetBaseFrequency() {

  // forreal

  skaterPositionGlide = new Glide(ac, 200.0f, 0);
  skaterPositionTone = new WavePlayer(ac, skaterPositionGlide, Buffer.SINE);

  // create gain
  skaterPositionGainGlide = new Glide(ac, 0, 0);
  skaterPositionGain = new Gain(ac, 1, 0.0f /* skaterPositionGainGlide */); // create the gain object




  skaterPositionGain.addInput(skaterPositionTone);
  masterGain.addInput(skaterPositionGain);





}

public void ttsExamplePlayback(String inputSpeech) {
  

  ttsGain = new Gain(ac, 1, 1.0f);

  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer ttsSP = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ttsGain.addInput(ttsSP);
  masterGain.addInput(ttsGain);
  ttsSP.setToLoopStart();
  ttsSP.start();
  println("TTS: " + inputSpeech);
}
//IMPORTANT:
//to use this you must import 'ttslib' into Processing, as this code uses the included FreeTTS library
//e.g. from the Menu Bar select Sketch -> Import Library... -> ttslib





class TextToSpeechMaker {

  final String TTS_FILE_DIRECTORY_NAME = "tts_samples";
  final String TTS_FILE_PREFIX = "tts";
  
  File ttsDir;
  boolean isSetup = false;
  
  int fileID = 0;
  
  FreeTTS freeTTS;
  
  private Voice voice;
    
  public TextToSpeechMaker() {
    
    VoiceManager voiceManager = VoiceManager.getInstance();
    voice = voiceManager.getVoice("kevin16");
    //using other voices is not supported (unfortunately), so you are stuck with Kevin16
    
    //find our tts_sample directory and clean it out if it has files from a previous running of this sketch
    findTTSDirectory();
    cleanTTSDirectory();
    
    freeTTS = new FreeTTS(voice);
    freeTTS.setMultiAudio(true);
    freeTTS.setAudioFile(getTTSFilePath() + "/" + TTS_FILE_PREFIX + ".wav");
    
    freeTTS.startup();
    voice.allocate();
  }
  
  //creates a WAV file of the input speech and returns the path to that file 
  public String createTTSWavFile(String input) {
    String filePath = TTS_FILE_DIRECTORY_NAME + "/" + TTS_FILE_PREFIX + Integer.toString(fileID) + ".wav";
    fileID++;
    voice.speak(input);
    return filePath; //you will need to use dataPath(filePath) if you need the full path to this file, see Example
  }
  
  //cleans up voice and FreeTTS object, use this if you are going to destroy the TextToSpeechServer object
  public void cleanup() {
    voice.deallocate();
    freeTTS.shutdown();
  }
  
  public String getTTSFilePath() {
    return dataPath(TTS_FILE_DIRECTORY_NAME);
  }
  
  //finds the tts file directory under the data path and creates it if it does not exist
  public void findTTSDirectory() {
    File dataDir = new File(dataPath(""));
    if (!dataDir.exists()) {
      try {
        dataDir.mkdir();
      }
      catch(SecurityException se) {
        println("Data directory not present, and could not be automatically created.");
      }
    }
    
    ttsDir = new File(getTTSFilePath());
    boolean directoryExists = ttsDir.exists();
    if (!directoryExists) {
      try {
        ttsDir.mkdir();
        directoryExists = true;
      }
      catch(SecurityException se) {
        println("Error creating tts file directory '" + TTS_FILE_DIRECTORY_NAME + "' in the data directory.");
      }
    }
  }
  
  //deletes ALL files in the tts file directory found/created by this object ('tts_samples')
  public void cleanTTSDirectory() {
    //delete existing files
    if (ttsDir.exists()) {
      for (File file: ttsDir.listFiles()) {
        if (!file.isDirectory())
          file.delete();
      }
    }
  }
  
}
  public void settings() {  size(900, 750); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "DavenportNathan_SkateboardingSimulator" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
