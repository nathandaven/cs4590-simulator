
PrintWriter output;
int totalFiles = 1;

int totalNormalRuns;
int totalBlindRuns;

int totalSimulatorRuns;
int totalSuccessfulRuns;
int totalSuccessfulRunsBlind;



int successfulBlindRuns;

int totalTimeSpentUntilSuccess;
int totalTimeSpentUntilSuccessBlind;
boolean recordingTotalTime;
boolean recordingTotalTimeBlind;


void createNewFile() {
  // Create a new file in the sketch directory

  output = createWriter("results/trial" + Integer.toString(totalFiles) + ".txt"); 
  totalFiles++;
  totalSimulatorRuns = 0;
  totalNormalRuns = 0;
  totalBlindRuns = 0;
  totalSuccessfulRuns = 0;
  totalSuccessfulRunsBlind = 0;
  totalTimeSpentUntilSuccess = 0;
  totalTimeSpentUntilSuccessBlind = 0;
  recordingTotalTime = true;
  recordingTotalTimeBlind = true;
}

void writeToFile(String note) {
    output.println(note);
}

void closeFile() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
}