
public class Line
{
    private int id;
    private Point linePos1, linePos2;    // Position of the line end points
    private Point edge1Pos, edge2Pos;    // Position of the edge walls
    private Point previousEdge1Pos, previousEdge2Pos;    // Position of the edge walls
    private Point predictedEdge1Pos, predictedEdge2Pos;    // Position of the edge walls
    private boolean selected = false;
    
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
        pointDir.mult(10);
        newP1 = PVector.sub(predictedEdge1Pos.getPos(), pointDir);
        newP2 = PVector.add(predictedEdge1Pos.getPos(), pointDir);
        
        // Display the new area
        Point newP1Point = new Point(newP1);
        Point newP2Point = new Point(newP2);
        newP1Point.display();
        newP2Point.display();
        
        // *************** I think the PVector is offset because of the video play area ************* 24 pixels
        
        
        ArrayList<Integer> capturePixels = edgeDetection.getEdgeBetweenPoints(newP1, newP2);
        
        float edgePosition = (int)edgeDetection.diffLessStd(capturePixels);
        PVector pvectorPosition = indexToPVector(edgePosition, newP1, newP2);
        
        edge1Pos = new Point(pvectorPosition);
        noFill(); stroke(255, 0, 0);
        edge1Pos.displayNoStyle();
        noFill(); stroke(0, 255, 0);
        previousEdge1Pos.displayNoStyle();
        
        
        PVector velocity = PVector.sub(edge1Pos.getPos(), previousEdge1Pos.getPos());
        PVector predictedPos = PVector.add(edge1Pos.getPos(), velocity);
        predictedEdge1Pos = new Point(predictedPos);
        noFill(); stroke(0, 0, 255);
        predictedEdge1Pos.displayNoStyle();
        
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
}