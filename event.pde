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
