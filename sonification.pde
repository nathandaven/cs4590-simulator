
import beads.*;

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

// panner
Panner panner;
Glide pannerGlide;

void setupAudio() {
  setupMasterGain();
  setupUgens();
  setupSamplePlayers();
  setupWavePlayers();
}

void setupMasterGain() {
  masterGainGlide = new Glide(ac, 1.0, 1.0);  
  masterGain = new Gain(ac, 2, masterGainGlide);
  ac.out.addInput(masterGain);
}

void setupUgens() {

  // filters
  highpassGlide = new Glide(ac, 10.0, 500);
  highpassFilter = new BiquadFilter(ac, BiquadFilter.HP, highpassGlide, .5);
  
  masterGain.addInput(highpassFilter);

  highpassGlide.setValue(2000.0);


  // envelopes
  envelope = new Envelope(ac);


  // panner
  pannerGlide = new Glide(ac, 0, 5);
  panner = new Panner(ac, pannerGlide);


}

void setupSamplePlayers() {
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

  spGain = new Gain(ac, 2, 0.3); // create the gain object

  // add sounds
  spGain.addInput(land);
  spGain.addInput(pop);
  spGain.addInput(push);

  // using high pass filter to make sound effects less abrasive, and more room for other sounds
  highpassFilter.addInput(spGain);
  //masterGain.addInput(spGain);
}


// play sound using sample player
void playSound(SamplePlayer sp) {
  sp.start();
  sp.setToLoopStart();
}


void setupWavePlayers() {


  resetBaseFrequency();
  
  
  //waveTone.setBuffer(SineBuffer);
}

void resetBaseFrequency() {

  // forreal

  skaterPositionGlide = new Glide(ac, 200.0, 0);
  skaterPositionTone = new WavePlayer(ac, skaterPositionGlide, Buffer.SINE);

  // create gain
  skaterPositionGainGlide = new Glide(ac, 0, 0);
  skaterPositionGain = new Gain(ac, 2, 0.0 /* skaterPositionGainGlide */); // create the gain object




  skaterPositionGain.addInput(skaterPositionTone);
  panner.addInput(skaterPositionGain);
  masterGain.addInput(panner);

}

void ttsExamplePlayback(String inputSpeech) {
  

  ttsGain = new Gain(ac, 2, 1.0);

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
