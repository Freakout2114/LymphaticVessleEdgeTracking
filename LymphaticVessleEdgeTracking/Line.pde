
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
        previousEdge1Pos = new Point(edge1Pos.getPos());
        ArrayList<Integer> capturePixels = edgeDetection.getEdgeBetweenPoints(linePos1.pos, linePos2.pos);
        
        //edgeDetection.highlightEdge(capturePixels);
        float edgePosition = edgeDetection.diffLessStd(capturePixels);
        PVector pvectorPosition = indexToPVector(edgePosition);
        
        edge1Pos = new Point(pvectorPosition);
        noFill(); stroke(255, 0, 0);
        edge1Pos.displayNoStyle();
        noFill(); stroke(0, 255, 0);
        previousEdge1Pos.displayNoStyle();
        
        if (edge1Pos.getPos() != null && previousEdge1Pos.getPos() != null) {
            PVector velocity = PVector.sub(edge1Pos.getPos(), previousEdge1Pos.getPos());
            PVector predictedPos = PVector.add(edge1Pos.getPos(), velocity);
            predictedEdge1Pos = new Point(predictedPos);
            noFill(); stroke(0, 0, 255);
            predictedEdge1Pos.displayNoStyle();
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
        PVector dir = PVector.sub(linePos2.pos, linePos1.pos);
        dir.normalize();
        dir.mult(index);
        
        return PVector.add(linePos1.pos, dir);
    }
    
    public boolean getSelected() { return selected; }
    public void setSelected(boolean value) { this.selected = value; }
    public void toggleSelected() { this.selected = this.selected ? false : true; }
}