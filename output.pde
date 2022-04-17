
PrintWriter output;
int totalFiles = 1;

int totalNormalRuns;
int totalBlindRuns;

int totalSimulatorRuns;
int totalSuccessfulRuns;
int totalSuccessfulRunsBlind;



int successfulBlindRuns;


void createNewFile() {
  // Create a new file in the sketch directory

  output = createWriter("results/trial" + Integer.toString(totalFiles) + ".txt"); 
  totalFiles++;
  totalSimulatorRuns = 0;
  totalSuccessfulRuns = 0;
  totalSuccessfulRunsBlind = 0;
  totalNormalRuns = 0;
  totalBlindRuns = 0;
}

void writeToFile(String note) {
    output.println(note);
}

void closeFile() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
}