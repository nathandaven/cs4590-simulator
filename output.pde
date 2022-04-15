
PrintWriter output;
int totalFiles = 1;
int totalSimulatorRuns;
int totalSuccessfulRuns;


void createNewFile() {
  // Create a new file in the sketch directory

  output = createWriter("results/trial" + Integer.toString(totalFiles) + ".txt"); 
  totalFiles++;
  totalSimulatorRuns = 0;
  totalSuccessfulRuns = 0;
}

void writeToFile(String note) {
    output.println(note);
}

void closeFile() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
}