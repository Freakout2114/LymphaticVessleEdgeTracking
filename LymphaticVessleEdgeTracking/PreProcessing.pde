
public class PreProcessing
{
    private boolean greyScale = false;
    private boolean invertImage = false;
    private int bitDepth = 8;
    
    private PreProcessing() {
        
    }
    
    public void applyFilters() {
        if (greyScale) 
            capture = preProcessing.greyScale(capture);    
        
        if (invertImage) 
            capture = preProcessing.invertImage(capture); 
            
        capture = reduceBitDepth(capture, 8 - bitDepth);
    }
    
    public PImage greyScale(PImage input) {
        PImage output = input.copy();
        
        output.filter(GRAY);
        return output;
    }
    
    public PImage invertImage(PImage input) {
        PImage output = input.copy();
        output.loadPixels();
        for (int i = 0; i < output.pixels.length; i++) {
            color c = output.pixels[i];
            output.pixels[i] = color(255 - red(c), 255 - green(c), 255 - blue(c));
        }
        output.updatePixels();
        return output;
    }
    
    public PImage reduceBitDepth(PImage input, int bitDepth) {
        // References
        // file:///C:/processing-3.3/modes/java/reference/color_datatype.html
        // file:///C:/processing-3.3/modes/java/reference/rightshift.html
        PImage output = input.copy();
        output.loadPixels();
        
        for (int i = 0; i < output.pixels.length; i++) {
            color pixel = output.pixels[i];
            
            int r = (pixel >> 16) & 0xFF;  // Faster way of getting red(argb)
            int g = (pixel >> 8) & 0xFF;   // Faster way of getting green(argb)
            int b = pixel & 0xFF;          // Faster way of getting blue(argb)
            
            r = r >> bitDepth << bitDepth;
            g = g >> bitDepth << bitDepth;
            b = b >> bitDepth << bitDepth;
            
            output.pixels[i] = color(r, g, b);
        }
        
        output.updatePixels();
        return output;
    }
    
    public void setGreyScale(boolean value) { this.greyScale = value; }
    public boolean getGreyScale() { return this.greyScale; }
    public void setInvertImage(boolean value) { this.invertImage = value; }
    public boolean getInvertImage() { return this.invertImage; }
    public void setBitDepth(int depth) { this.bitDepth = depth; }
    
}