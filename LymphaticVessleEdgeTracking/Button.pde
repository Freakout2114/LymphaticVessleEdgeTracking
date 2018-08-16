
public class Button
{
    private float btnWidth, btnHeight;
    private PVector pos;
    private String text;
    private String[] subText;
    private boolean mouseHover;
    
    Button() {
        this("Click Me", new PVector(8, 8), 64, 24);
    }
    
    Button(String text, PVector pos) {
        this(text, pos, 64, 24);
    }
    
    Button(String text, PVector pos, float w, float h) {
        this.text = text;
        this.pos = pos;
        this.btnWidth = w;
        this.btnHeight = h;
    }
    
    public void mouseHover() {
        if (mouseHover && subText != null) {   // If the button has subButtons and is already being hovered
            mouseHover = (mouseX > pos.x && mouseX < pos.x + btnWidth && mouseY > pos.y && mouseY < pos.y + btnHeight * (subText.length + 1));
        }
        else
            mouseHover = (mouseX > pos.x && mouseX < pos.x + btnWidth && mouseY > pos.y && mouseY < pos.y + btnHeight);
    }
    
    public boolean mousePressed() {
        if (mouseHover) {
            buttonPressed();
            return true;
        }
        
        return false;
    }
    
    public void buttonPressed() {
        println("buttonPressed()");
    }
    
    public void display() {
        if (mouseHover) {
            if (subText != null)
                displayDropdown();
            stroke(0, 0, 50);
            fill(200, 225, 225);
        } else {
            stroke(0);
            fill(#e1e1e1);
        }
        rect(pos.x, pos.y, btnWidth, btnHeight);
        textAlign(CENTER, CENTER);
        fill(0);
        text(text, pos.x + btnWidth / 2, pos.y + btnHeight / 2);
    }
    
    public void displayDropdown() {
        for (int i = 0; i < subText.length; i++) {
            if (mouseY > pos.y + btnHeight * (i + 1) && mouseY < pos.y + btnHeight * (i + 2)) {
                stroke(0, 0, 50);
                fill(200, 225, 225);
            } else {
                stroke(0);
                fill(#e1e1e1);
            }
            rect(pos.x, pos.y + btnHeight * (i + 1), btnWidth, btnHeight);
            textAlign(CENTER, CENTER);
            fill(0);
            text(subText[i], pos.x + btnWidth / 2, pos.y + btnHeight * (i + 1) + btnHeight / 2);
        }
    }
    
    public void setText(String text) { this.text = text; }
    public void setSubText(String[] text) { this.subText = text; }
    public void setSubText(int[] values) { 
        String[] subTexts = new String[values.length];
        for (int i = 0; i < values.length; i++) {
            subTexts[i] = values[i] + "";
        }
        this.subText = subTexts; 
    }
    public void setSubText(float[] values) { 
        String[] subTexts = new String[values.length];
        for (int i = 0; i < values.length; i++) {
            subTexts[i] = values[i] + "";
        }
        this.subText = subTexts; 
    }
    public void setPosition(PVector pos) { this.pos = pos; }
    public void setButtonSizeAuto() { this.btnWidth = getText().length() * 7; }
    public void setButtonSize(float w, float h) { this.btnWidth = w; this.btnHeight = h; }
    public void setWidth(float w) { this.btnWidth = w; }
    public void setHeight(float h) { this.btnHeight = h; }
    public void setMouseHover(boolean value) { this.mouseHover = value; }
    
    public String getText() { return this.text; }
    public PVector getPos() { return this.pos; }
    public float getWidth() { return this.btnWidth; }
    public float getHeight() { return  this.btnHeight; }
}