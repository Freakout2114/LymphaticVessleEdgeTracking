
public class Timestamp 
{
    private int timestamp;
    private int id;
    private int edgeSize = 1;
    private float e1Displacement, e2Displacement;
    private float diameter;
    
    public Timestamp(int id, float e1Displacement) {
        this.id = id;
        this.timestamp = timeStamp;    // Sourced from the global variable in LymphaticVessleEdgeTracking
        this.e1Displacement = e1Displacement;
    }
    
    public Timestamp(int id, float e1Displacement, float e2Displacement, float diameter) {
        this.id = id;
        this.timestamp = timeStamp;    // Sourced from the global variable in LymphaticVessleEdgeTracking
        this.e1Displacement = e1Displacement;
        this.e2Displacement = e2Displacement;
        this.diameter = diameter;
        this.edgeSize = 2;
    }
    
    public int getId() { return id; }
    public int getTimestamp() { return timestamp; }
    public float getE1Displacement() { 
        float value = e1Displacement;
        //value = floor(value * 1000);
        //value = value / 1000.0;
        return  value; 
    }
    public float getE2Displacement() { return e2Displacement; }
    public float getDiameter() { return diameter; }
    public int getEdgeSize() { return edgeSize; }
}