
public class Point {
    private PVector pos;
    static final float radius = 5;
    
    Point(PVector pos) {
        this.pos = pos;
    }
    
    PVector getPos() { return pos; }
    float getX() { return pos.x; }
    float getY() { return pos.y; }
    
    public void display(int id) {
        fill(255, 255 / 2);
        ellipse(pos.x, pos.y, 15, 15);  
        fill(0);
        text(id, pos.x, pos.y);
    }
    
    public void display() {
        fill(255);
        ellipse(pos.x, pos.y, radius, radius);  
    }
    
}