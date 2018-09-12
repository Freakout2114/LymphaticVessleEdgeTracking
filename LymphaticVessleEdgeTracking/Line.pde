
public class Line
{
    private int id;
    private int edgeSize = 1;
    private Point linePos1, linePos2;    // Position of the line end points
    private Point initialEdge1Pos, initialEdge2Pos;    // Position of the edge walls at the first frame
    private Point edge1Pos, edge2Pos;    // Position of the edge walls
    private Point previousEdge1Pos, previousEdge2Pos;    // Position of the edge walls
    private Point predictedEdge1Pos, predictedEdge2Pos;    // Position of the edge walls
    private boolean selected = false;
    private float windowSize = 20;
    
    Line(PVector p1, PVector p2, int id) {
        this.linePos1 = new Point(p1);
        this.linePos2 = new Point(p2);
        this.id = id;
        
        edge1Pos = new Point(null);
        previousEdge1Pos = new Point(null);
        predictedEdge1Pos = new Point(null);
        
        initialise();
    }
    
    private void initialise() {
        // Get the pixels between the two points
        ArrayList<Integer> capturePixels = edgeDetection.getEdgeBetweenPoints(linePos1.pos, linePos2.pos);
        
        // Return the darkest pixel within that capture
        float edgePosition = edgeDetection.diffLessStd(capturePixels);
        PVector pvectorPosition = indexToPVector(edgePosition);
        
        // Set the defaults for the initialisation
        initialEdge1Pos = new Point(pvectorPosition);
        edge1Pos = new Point(pvectorPosition);
        previousEdge1Pos = new Point(pvectorPosition);
        predictedEdge1Pos = new Point(pvectorPosition);
    }
    
    public void analyse() {
        
        // Update the previous position of the edge location
        previousEdge1Pos = new Point(edge1Pos.getPos());
        
        // Instead of using the first given points for the line
        // adjust the window x pixels either side of the predicted edge position
        PVector newP1, newP2;
        PVector pointDir = PVector.sub(linePos2.pos, linePos1.pos);
        pointDir.normalize();
        pointDir.mult(windowSize);
        // Predicted Edge
        //newP1 = PVector.sub(predictedEdge1Pos.getPos(), pointDir);
        //newP2 = PVectoradd(predictedEdge1Pos.getPos(), pointDir);
        // Last Edge
        newP1 = PVector.sub(previousEdge1Pos.getPos(), pointDir);
        newP2 = PVector.add(previousEdge1Pos.getPos(), pointDir);
        
        // Display the new window area
        Point newP1Point = new Point(newP1);
        Point newP2Point = new Point(newP2);
        newP1Point.display();
        newP2Point.display();
        
        // Get the pixels from the new Window
        ArrayList<Integer> capturePixels = edgeDetection.getEdgeBetweenPoints(newP1, newP2);
        
        // Get the observed edge location
        float edgePosition = (int)edgeDetection.diffLessStd(capturePixels);
        
        PVector pvectorPosition = indexToPVector(edgePosition, newP1, newP2);
        
        // Check if the edge has moved too far away
        float displacement = PVector.dist(pvectorPosition, predictedEdge1Pos.getPos());
        float tolerance = PVector.dist(previousEdge1Pos.getPos(), predictedEdge1Pos.getPos());
        
        // Set the new position and display
        if (displacement > 4) {//max(tolerance * 1.5, 3)) {
            println("Displacement: " + displacement + ", tolerance: " + tolerance);
            edge1Pos = new Point(previousEdge1Pos.getPos());
        } else {
            edge1Pos = new Point(pvectorPosition);
        }
        
        noFill(); stroke(255, 0, 0);
        edge1Pos.displayNoStyle();
        
        // Predict the next location
        PVector velocity = PVector.sub(edge1Pos.getPos(), previousEdge1Pos.getPos());
        PVector predictedPos = PVector.add(edge1Pos.getPos(), velocity);
        predictedEdge1Pos = new Point(predictedPos);
        noFill(); stroke(0, 0, 255);
        predictedEdge1Pos.displayNoStyle();
        
        
        // Add Timestamps
        if (output.isRecording() && !pauseVideo) {
            Timestamp timestamp;
            
            if (edgeSize == 1) {
                float e1Displacement = PVector.dist(edge1Pos.getPos(), initialEdge1Pos.getPos());
                timestamp = new Timestamp(id, e1Displacement);
            } else { // 2 Edges
                float e1Displacement = PVector.dist(edge1Pos.getPos(), initialEdge1Pos.getPos());
                float e2Displacement = PVector.dist(edge2Pos.getPos(), initialEdge2Pos.getPos());
                float diameter = PVector.dist(edge1Pos.getPos(), edge2Pos.getPos()); 
                timestamp = new Timestamp(id, e1Displacement, e2Displacement, diameter);
            }
            output.addTimestamp(timestamp);
        }
    }
    
    public void display() {
        stroke(255, 255);
        if (selected) { strokeWeight(3); } else { strokeWeight(1); }
            
        line(linePos1.getX(), linePos1.getY(), linePos2.getX(), linePos2.getY());
        
        if (selected) { linePos1.display(id); } else { linePos1.display(); }
        linePos2.display();
        strokeWeight(1);
    }
    
    public PVector indexToPVector(float index) {
        return indexToPVector(index, linePos1.pos, linePos2.pos);
    }
    
    public PVector indexToPVector(float index, PVector p1, PVector p2) {
        PVector dir = PVector.sub(p2, p1);
        dir.normalize();
        dir.mult(index);
        
        return PVector.add(p1, dir);
    }
    
    public boolean getSelected() { return selected; }
    public void setSelected(boolean value) { this.selected = value; }
    public void toggleSelected() { this.selected = this.selected ? false : true; }
    public int getEdgeSize() { return edgeSize; }
    public int getId() { return this.id; }
}