

public class InputMode extends Button
{
    private String text = inputMode;
    private String[] subTexts = new String[]{"Camera", "Video", "Load File"};
    
    InputMode() {
        setText("Input: " + text + " ");
        setSubText(subTexts);
        setButtonSizeAuto();
    }
    
    @Override
    public void buttonPressed() {
        if (mouseY < getPos().y + getHeight()) {
            text = text.equals("Camera") ? "Video" : "Camera";
            inputMode = text;   // Sets the global mode of input
            setText("Input: " + text);
        } else { // Selected a dropdown menu
            int index = floor((mouseY - getPos().y) / getHeight()) - 1;
            
            if (index == 2) {
                selectInput("Select a file to process:", "fileSelected");
            } else {
                inputMode = subTexts[index];   // Sets the global mode of input
                setText("Input: " + subTexts[index]);
            }
        }
    }
}

public class StartStopVideo extends Button
{
    private String text = "Stop";
    
    StartStopVideo() {
        text = pauseVideo ? "Start" : "Stop";
        setText(text); 
    }
    
    @Override
    public void buttonPressed() {
        println("StartStopVideo   buttonPressed()");
        if (text.equals("Start")) {
            text = "Stop";
            pauseVideo = false;
            video.play();
        } else {
            text = "Start";
            pauseVideo = true;
            video.pause();
        }
        
        setText(text); 
    }
}

public class PlaybackSpeed extends Button
{
    float playbackSpeed = 1.0;
    float[] playbackSpeeds = new float[] {0.1, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0};
    
    PlaybackSpeed() {
        setText("Speed: " + playbackSpeed + "x  ");
        setSubText(playbackSpeeds);
        setButtonSizeAuto();
    }
    
    @Override
    public void buttonPressed() {
        println("PlaybackSpeed");
        
        if (mouseY < getPos().y + getHeight()) {
            playbackSpeed *= 0.5;
            if (playbackSpeed == 0.125)
                playbackSpeed = 2;
        } else { // Selected a dropdown menu
            int index = floor((mouseY - getPos().y) / getHeight()) - 1;
            playbackSpeed = playbackSpeeds[index];
            setMouseHover(false);
        }
        setText("Speed: " + playbackSpeed + "x");
        video.speed(playbackSpeed);
    }
}

public class GreyScaleImage extends Button
{
    private boolean greyScale = false;
    
    GreyScaleImage() {
        setText("Greyscale: " + greyScale);
        setButtonSizeAuto();
    }
    
    @Override
    public void buttonPressed() {
        println("GreyScaleImage");
        greyScale = greyScale ? false : true;
        setText("Greyscale: " + greyScale);
        preProcessing.setGreyScale(greyScale);
    }
}

public class InvertImage extends Button
{
    private boolean invertImage = false;
    
    InvertImage() {
        setText("Invert Image: " + invertImage);
        setButtonSizeAuto();
    }
    
    @Override
    public void buttonPressed() {
        println("InvertImage");
        invertImage = invertImage ? false : true;
        setText("Invert Image: " + invertImage);
        preProcessing.setInvertImage(invertImage);
    }
}

public class BitDepth extends Button
{
    int[] bitDepths = new int[] {1, 2, 3, 4, 5, 6, 7, 8};
    int bitDepth = bitDepths.length;
    
    BitDepth() {
        setText("BitDepth: " + bitDepth);
        setSubText(bitDepths);
        setButtonSizeAuto();
    }
    
    @Override
    public void buttonPressed() {
        println("BitDepth");
        
        if (mouseY < getPos().y + getHeight()) {
            bitDepth--;
            if (bitDepth < 0)
                bitDepth = bitDepths.length - 1;
        } else { // Selected a dropdown menu
            int index = floor((mouseY - getPos().y) / getHeight()) - 1;
            bitDepth = index;
            setMouseHover(false);
        }
        setText("BitDepth: " + bitDepths[bitDepth]);
        preProcessing.setBitDepth(bitDepths[bitDepth]);
    }
}

public class ExportData extends Button
{
    ExportData() {
        setText("Export Data");
        setButtonSizeAuto();
    }
    
    @Override
    public void buttonPressed() {
        println("Exporting Data");
        output.exportData(); 
        println("Exporting Data Complete");
    }
}

public class RestartRecording extends Button
{
    RestartRecording() {
        setText("Reset Recording");
        setButtonSizeAuto();
    }
    
    @Override
    public void buttonPressed() {
        println("Reset Recording");
        output.resetRecording(); 
    }
}