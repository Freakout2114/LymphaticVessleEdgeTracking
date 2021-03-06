import processing.video.*;

Movie video;                    // Used for loading in the video files
Capture camera;                 // Used for webcam 
String inputMode = "Video";     // "Camera" for webcam, "Video" for video file.
PImage capture;                 // The image frame sourced from either the webcam or video file.
PreProcessing preProcessing;    // PreProcessing object to be globally used.
EdgeDetection edgeDetection;    // EdgeDection object to be globally used.
Output output;                  // Output object used to track the timestamps (Edge positions)

boolean pauseVideo = true;      // Allows the video to be started / stopped
ArrayList<Button> buttons;      // List of all the custom buttons at the top of the screen
ArrayList<Line> lines;          // List of all the line objects that are tracking the edges

boolean mouseHeld = false;      // Used when creating a line by clicking and draging
PVector mouseInitialPos;        // When the user is creating a line by draging the mouse, this is the starting vector of the mouse

int timeStamp = 0;              // used as a time stamp in the output recordings

public void setup() {
    size(800, 800);
    surface.setResizable(true);
    frameRate(120);   
    
    Initialise();
}

public void Initialise() {
    // Creation of the buttons
    float xPosition = 0;    // Used to space the position of the buttons accross the page
    buttons = new ArrayList<Button>(); 
    buttons.add( new InputMode() );
    buttons.add( new StartStopVideo() );
    buttons.add( new PlaybackSpeed() );
    buttons.add( new GreyScaleImage() );
    buttons.add( new InvertImage() );
    buttons.add( new BitDepth() );
    buttons.add( new Record() );
    buttons.add( new ExportData() );
    
    for (Button btn : buttons) {
        btn.setPosition(new PVector(xPosition, 0));
        xPosition += btn.getWidth();
    }
     
    // List of all the lines that will be tracking the edges 
    lines = new ArrayList<Line>();
    
    // Create the new Edge detection object
    edgeDetection = new EdgeDetection();
    
    // Create the new Pre-Processing object
    preProcessing = new PreProcessing();
    
    // Create the Output object
    output = new Output();
    
    // TODO - Remove these later
    //loadCamera();
    loadVideo();
}

public void loadCamera() {
    println("Loading Camera");
    String[] cameras = Capture.list();
      
    if (cameras.length == 0) {
        println("There are no cameras available for capture.");
        exit();
    } else {
        println("Available cameras:");
        if (false)
        for (int i = 0; i < cameras.length; i++) {
            println("i: " + i + "   "   + cameras[i]);
        }
            
        // The camera can be initialized directly using an 
        // element from the array returned by list():
        camera = new Capture(this, cameras[73]);
        camera.start();     
    }   
    println("Loading Camera Completed");
}
    
public void fileSelected(File selection) {
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
    } else {
        println("User selected " + selection.getAbsolutePath());
        video = new Movie(this, selection.getAbsolutePath());
        video.play();
        video.pause();
        println("Loaded File Complete");
        capture = loadVideoNextFrame(true);
    }
}

public void loadVideo() {
    File file = new File("C:/Users/Harry/Desktop/Assignments/Year 4/SEM 1/SENG4211A - SE FINAL PROJECT/Assignment/Individual/Software/V1/vid1.avi");
    fileSelected(file);
}

public PImage loadCameraNextFrame() {
    if (camera == null)
        return null;
        
    if (camera.available() == true) {
        camera.read();
    }
    
    return camera;
}

public PImage loadVideoNextFrame() {
    return loadVideoNextFrame(false);
}

public PImage loadVideoNextFrame(boolean forceLoad) {
    if (video == null) {
        println("INFO:   loadVideoNextFrame   video == null");
        return null;
    }
        
    // If forceLoad, ignore the pause function and return the current frame
    if (forceLoad) {
        video.read();  
        return video;
    }
    if (video.available()) {
        // First Frame of the video to be loaded
        if (pauseVideo && capture == null) {
            video.read();
            video.pause();
            return video;
        }
        
        // If video loaded and not paused
        if (!pauseVideo) {
            timeStamp++;
            video.read();
            return video;
        }
    }
    // Video Paused so just return current frame again
    return capture;
}

public void draw() {
    background(#ffffff);
    fill(0);
    textAlign(LEFT);
    text("FrameCount: " + (int)frameCount, 32, height - 48);
    text("TimeStamp: " + (int)timeStamp, 32, height - 32);
    text("FPS: " + (int)frameRate, 32, height - 16);
    
    for (int itterations = 0; itterations < 5; itterations++) {
        // Get the next frame of video or webcam
        if (inputMode.equals("Camera")) {
            capture = loadCameraNextFrame();
        } else {
            capture = loadVideoNextFrame();
            if (capture != null) {
                float percentage = video.time() / video.duration();
                fill(255);
                stroke(0);
                line(5, 24 + 5 + capture.height, capture.width - 5, 24 + 5 + capture.height);
                rect(capture.width * percentage - 5, 24 + capture.height, 5, 10);
            }
        }
        
        if (capture != null) {
            preProcessing.applyFilters();
            image(capture, 0, 24);
        }
        
        for (Line line : lines) {
            line.analyse();
            //line.display();
        }
    }
    
    for (Button button : buttons) {
        button.mouseHover();
        button.display();
    }
    
    // Draw the line being created currently if mouse held
    if (mouseHeld) {
        stroke(255);
        line(mouseInitialPos.x, mouseInitialPos.y, mouseX, mouseY);    
    }
}

public void mousePressed() {
    boolean buttonPressed = false;
    // Loop through all buttons and check if the user clicked one
    for (Button button : buttons) {
        if (button.mousePressed())
            buttonPressed = true;
    }
    
    // If the mouse was not held then they are creating a tracking line
    if (!buttonPressed) {
        mouseHeld = true;
        mouseInitialPos = new PVector(mouseX, mouseY);
    }
}

public void mouseReleased() {
    // If the user didn't click a button mouseHeld will be true
    if (mouseHeld) {
        // If the distance between themmouse pressed and released is < 10, the user clicked the mouse
        if (PVector.dist(new PVector(mouseX, mouseY), mouseInitialPos) < 10) {   // Mouse clicked
            // The mouse was pressed inside the capture location
            if (mouseY < 24 + capture.height) {
                // Then find the line that should be selected
                for (Line line : lines) {
                    // Ensure the mouse is within the x coords of both the points of the line
                    if ((line.linePos1.getX() < line.linePos2.getX() && mouseX >= line.linePos1.getX() && mouseX <= line.linePos2.getX()) ||
                        (line.linePos1.getX() > line.linePos2.getX() && mouseX >= line.linePos2.getX() && mouseX <= line.linePos1.getX())) {
                        
                        // Using the equation y = mx + b, we can substitute the mouseX and compare the expected
                        // y value of the line to the mouseY, if within a certain distance of each other then assume
                        // the user is trying to select this line
                        float m, x, b, y;
                        m = (line.linePos2.getY() - line.linePos1.getY()) / (line.linePos2.getX() - line.linePos1.getX());
                        x = mouseX;        
                        b = line.linePos1.getY() - m * line.linePos1.getX();
                        y = (m * x + b);
                        
                        if (PVector.dist(new PVector(mouseX, mouseY), new PVector(mouseX, y)) < 8) {
                            boolean lineSelectedValue = line.getSelected();
                            // Deselect all lines first
                            for (Line line2 : lines) 
                                line2.setSelected(false);   
                            line.setSelected(!lineSelectedValue);
                            break;
                        }
                    }
                }
            } else { // Otherwise the mouse was pressed outside the capture and may be trying to change timestamp
                if (mouseY >= 24 + capture.height && mouseY <= 24 * 2 + capture.height) {
                    if (inputMode.equals("Video")) {
                        float timestamp = map(mouseX, 0, capture.width, 0, video.duration());
                        video.jump(timestamp);   
                        capture = loadVideoNextFrame(true);
                    }
                }
            }
        } else {   // Otherwise the mouse was dragged and create a line
            // Add a new line
            Line line = new Line(mouseInitialPos,  new PVector(mouseX, mouseY), lines.size());
            lines.add( line );
        }
        
        mouseHeld = false;
        mouseInitialPos = null;
    }
}

public void keyPressed() {
    if (keyCode == 127) { // Delete Key
        for (Line line : lines) {
            if (line.getSelected()) {
                lines.remove(line);
                break;
            }
        }
    }
}