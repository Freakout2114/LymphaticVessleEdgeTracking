
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
    
    private ArrayList<Timestamp> localTimestamps = new ArrayList<Timestamp>();    // Records the timestamps to show the debug movement 
    
    Line(PVector p1, PVector p2, int id) {
        this.linePos1 = new Point(p1);
        this.linePos2 = new Point(p2);
        this.id = id;
        
        edge1Pos = new Point(null);
        previousEdge1Pos = new Point(null);
        predictedEdge1Pos = new Point(null);
        
        edge2Pos = new Point(null);
        previousEdge2Pos = new Point(null);
        predictedEdge2Pos = new Point(null);
        
        initialise();
    }
    
    private void initialise() {
        // Estimate the line size
        edgeSize = edgeDetection.getEstimateLineSize(linePos1.pos, linePos2.pos);
        
        // Get the pixels between the two points or each half for 2 lines
        ArrayList<Integer> capturePixels = edgeDetection.getEdgeBetweenPoints(linePos1.pos, linePos2.pos);
        PVector mid = PVector.add(linePos1.pos, linePos2.pos);
        mid = PVector.div(mid, 2);
        
        if (edgeSize == 2) {
            capturePixels = edgeDetection.getEdgeBetweenPoints(linePos1.pos, mid);
        }
        
        // Return the darkest pixel within that capture
        float edgePosition = edgeDetection.diffLessStd(capturePixels);
        PVector pvectorPosition = indexToPVector(edgePosition, linePos1.pos, mid);
        
        // Set the defaults for the initialisation
        initialEdge1Pos = new Point(pvectorPosition);
        edge1Pos = new Point(pvectorPosition);
        previousEdge1Pos = new Point(pvectorPosition);
        predictedEdge1Pos = new Point(pvectorPosition);
        
        if (edgeSize == 2) {
            capturePixels = edgeDetection.getEdgeBetweenPoints(mid, linePos2.pos);
            // Return the darkest pixel within that capture
            edgePosition = edgeDetection.diffLessStd(capturePixels);
            pvectorPosition = indexToPVector(edgePosition, mid, linePos2.pos);
            
            // Set the defaults for the initialisation
            initialEdge2Pos = new Point(pvectorPosition);
            edge2Pos = new Point(pvectorPosition);
            previousEdge2Pos = new Point(pvectorPosition);
            predictedEdge2Pos = new Point(pvectorPosition);
        }
       
    }
    
    public void analyse() {
        
        // Update the previous position of the edge location
        updatePreviousPosition();
        
        // Instead of using the first given points for the line
        // adjust the window x pixels either side of the predicted edge position
        PVector pointDir = PVector.sub(linePos2.pos, linePos1.pos);
        pointDir.normalize();
        pointDir.mult(windowSize);
        
        PVector e1NewP1, e1NewP2;
        PVector e2NewP1, e2NewP2;
        // Predicted Edge
        //newP1 = PVector.sub(predictedEdge1Pos.getPos(), pointDir);
        //newP2 = PVector.add(predictedEdge1Pos.getPos(), pointDir);
        // Last Edge
        e1NewP1 = PVector.sub(previousEdge1Pos.getPos(), pointDir);
        e1NewP2 = PVector.add(previousEdge1Pos.getPos(), pointDir);
        
        // Display the new window area
        Point e1NewP1Point = new Point(e1NewP1);
        Point e1NewP2Point = new Point(e1NewP2);
        //e1NewP1Point.display();
        //e1NewP2Point.display();
        
        // Get the pixels from the new Window
        ArrayList<Integer> capturePixels = edgeDetection.getEdgeBetweenPoints(e1NewP1, e1NewP2);
        
        // Get the observed edge location
        float edgePosition = (int)edgeDetection.diffLessStd(capturePixels);
        
        PVector pvectorPosition = indexToPVector(edgePosition, e1NewP1, e1NewP2);
        
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
        
        fill(255); noStroke();
        edge1Pos.displayNoStyle();
        // Predict the next location
        PVector velocity = PVector.sub(edge1Pos.getPos(), previousEdge1Pos.getPos());
        PVector predictedPos = PVector.add(edge1Pos.getPos(), velocity);
        predictedEdge1Pos = new Point(predictedPos);
        noFill(); stroke(0, 0, 255);
        predictedEdge1Pos.displayNoStyle();
        
        
        if (edgeSize == 2) {
            // Predicted Edge
            //newP1 = PVector.sub(predictedEdge1Pos.getPos(), pointDir);
            //newP2 = PVector.add(predictedEdge1Pos.getPos(), pointDir);
            // Last Edge
            e2NewP1 = PVector.sub(previousEdge2Pos.getPos(), pointDir);
            e2NewP2 = PVector.add(previousEdge2Pos.getPos(), pointDir);
            
            Point e2NewP1Point = new Point(e2NewP1);
            Point e2NewP2Point = new Point(e2NewP2);
            //e2NewP1Point.display();
            //e2NewP2Point.display();
            
            // Get the pixels from the new Window
            capturePixels = edgeDetection.getEdgeBetweenPoints(e2NewP1, e2NewP2);
            
            // Get the observed edge location
            edgePosition = (int)edgeDetection.diffLessStd(capturePixels);
            
            pvectorPosition = indexToPVector(edgePosition, e2NewP1, e2NewP2);
            
            // Check if the edge has moved too far away
            displacement = PVector.dist(pvectorPosition, predictedEdge2Pos.getPos());
            tolerance = PVector.dist(previousEdge2Pos.getPos(), predictedEdge2Pos.getPos());
            
            // Set the new position and display
            if (displacement > 4) {//max(tolerance * 1.5, 3)) {
                println("Displacement: " + displacement + ", tolerance: " + tolerance);
                edge2Pos = new Point(previousEdge2Pos.getPos());
            } else {
                edge2Pos = new Point(pvectorPosition);
            }
            
            fill(255); noStroke();
            edge2Pos.displayNoStyle();
            // Predict the next location
            velocity = PVector.sub(edge2Pos.getPos(), previousEdge2Pos.getPos());
            predictedPos = PVector.add(edge2Pos.getPos(), velocity);
            predictedEdge2Pos = new Point(predictedPos);
            noFill(); stroke(0, 0, 255);
            predictedEdge2Pos.displayNoStyle();
            
        }
        
        
        // Add Timestamps
        if (!pauseVideo) {
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
            
            localTimestamps.add(timestamp);
            
            if (localTimestamps.size() > 300) {
                localTimestamps.remove(0);    
            }
            
            if (output.isRecording()) {
                output.addTimestamp(timestamp);
            }
        }
    }
    
    private void updatePreviousPosition() {
        // Update the previous position of the edge location
        previousEdge1Pos = new Point(edge1Pos.getPos());
        if (edgeSize == 2) {
            previousEdge2Pos = new Point(edge2Pos.getPos());
        }
    }
    
    public void display() {
        stroke(255, 255);
        if (selected) { strokeWeight(3); } else { strokeWeight(1); }
            
        line(linePos1.getX(), linePos1.getY(), linePos2.getX(), linePos2.getY());
        
        if (selected) { linePos1.display(id); } else { linePos1.display(); }
        linePos2.display();
        strokeWeight(1);
        
        PVector mid = PVector.add(linePos1.pos, linePos2.pos);
        mid = PVector.div(mid, 2);
        PVector dir = PVector.sub(linePos2.pos, linePos1.pos);
        dir.normalize();
        
        float y = height - 128;
        for (int i = 0; i < localTimestamps.size(); i++) {
            Timestamp ts = localTimestamps.get(i);
        }
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