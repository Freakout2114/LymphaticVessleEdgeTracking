
public class Timestamp 
{
    private int id;
    private float time;
    private PVector p1, p2;
    
    public Timestamp(int id, PVector p1) {
        this(id, p1, null);
    }
    
    public Timestamp(int id, PVector p1, PVector p2) {
        this.id = id;
        this.p1 = p1;
        this.p2 = p2;
        this.time = video.time();
    }
    
    public int getId() { return id; }
    public float getTime() { return time; }
    public float getDistance() { 
        float distance = PVector.dist(p1, p2);
        distance *= 1000;
        distance = (int) distance;
        distance /= 1000;
        return distance; 
    }
}