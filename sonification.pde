
import beads.*;

Glide waveFrequency;
Gain waveGain;

// master gain
Gain masterGain;
Glide masterGainGlide;

// wave players
WavePlayer waveTone;

int beepTimer;


void setupWaveplayers() {


  masterGainGlide = new Glide(ac, .2, 0);  
  masterGain = new Gain(ac, 1, masterGainGlide);
  ac.out.addInput(masterGain);

  resetBaseFrequency();
  
  //waveTone.setBuffer(SineBuffer);
}

void resetBaseFrequency() {

  // clear connections
  masterGain.clearInputConnections();

  waveFrequency = new Glide(ac, 440.0, 200);
  waveTone = new WavePlayer(ac, waveFrequency, Buffer.SINE);

  // create gain
  waveGain = new Gain(ac, 1, 0.0); // create the gain object

  // add inputs to gains
  waveGain.addInput(waveTone); 
  masterGain.addInput(waveGain);

}