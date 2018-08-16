
public class Line
{
    private int id;
    private Point p1, p2, p1Current;
    private PVector p1Initial;
    private boolean selected = false;
    
    Line(PVector p1, PVector p2, int id) {
        this.p1 = new Point(p1);
        this.p2 = new Point(p2);
        this.id = id;
        initialise();
    }
    
    public void firstOutputVersion() {
        // Get x samples along the drawn line
        ArrayList<ArrayList<Integer>> samples = getSampleRows(5);
        
        // Used to record the found "edges" along the sample line (Samples > edges > pixels)
        ArrayList<ArrayList<ArrayList<Integer>>> samplesEdges = new ArrayList<ArrayList<ArrayList<Integer>>>();
        
        for (ArrayList<Integer> sample : samples) {
            ArrayList<Integer> darkPixels = edgeDetection.getDarkestPixels(sample);
            ArrayList<ArrayList<Integer>> edges = edgeDetection.convertDarkPixelsToArray(darkPixels);
            //println(edges);
            
            // If the number of "edges" found in the sample is > 2 remove the smallest width edge
            while (edges.size() > 2) {
                int smallest = 0;
                for (int i = 1; i < edges.size(); i++) {
                    if (edges.get(i).size() < edges.get(smallest).size()) {
                        smallest = i;    
                    }
                }
                //println("Removed noise at index: " + smallest + ", edge width: " + edges.get(smallest).size());
                edges.remove(smallest);
            }
            
            samplesEdges.add(edges);
        }
        
        PVector edgeP1 = null;
        PVector edgeP2 = null;
        
        int middleSample = samples.size() / 2;
        for (ArrayList<Integer> edges : samplesEdges.get(middleSample)) {
            float averageIndex = 0;
            for (Integer pixelIndex : edges) {
                averageIndex += pixelIndex;
            }
            averageIndex /= edges.size();
            PVector edgePosition = indexToPVector(averageIndex);
            stroke(255, 0, 0);
            noFill();
            ellipse(edgePosition.x, edgePosition.y, 10, 10);
            if (edgeP1 == null) {
                edgeP1 = edgePosition.copy();
            } else {
                edgeP2 = edgePosition.copy();
            }
        }
        
        if (p1Initial == null)
            p1Initial = edgeP1;
        
        if (edgeP2 == null)
            edgeP2 = p1Initial;
        
        if (!pauseVideo) {
            Timestamp timestamp = new Timestamp(id, edgeP1, edgeP2);
            output.addTimestamp(timestamp);
        }
    }
    
    public void initialise() {
        ArrayList<ArrayList<Integer>> samples = getSampleRows(5);
        ArrayList<ArrayList<Integer>> darkestPixelSamples = new ArrayList<ArrayList<Integer>>();
        
        for (ArrayList<Integer> sample : samples) {
            ArrayList<Integer> darkPixels = edgeDetection.getDarkestPixels(sample);
            ArrayList<ArrayList<Integer>> edges = edgeDetection.convertDarkPixelsToArray(darkPixels);
            println(edges);
            darkestPixelSamples.add(darkPixels);
        }
        
        float averagePos = 0;
        int sampleSize = 0;
        int lineCountAverage = 0;
        for (ArrayList<Integer> darkestPixelSample : darkestPixelSamples) {
            lineCountAverage += edgeDetection.getLineCount(darkestPixelSample);
            for (int index :  darkestPixelSample) {
                averagePos += index;
                sampleSize++;
                PVector pos = indexToPVector(index);
                fill(255, 0, 0);
                stroke(255, 0, 0);
                ellipse(pos.x, pos.y, 2, 2); 
            }
        }
        
        lineCountAverage /= darkestPixelSamples.size();
        println("lineCountAverage: " + lineCountAverage);
        averagePos /= (float)sampleSize;
        p1Current = new Point(indexToPVector(averagePos));
    }
    
    public void step() {
        
    }
    
    public void analyse() {
        if (selected) {
            ArrayList<ArrayList<Integer>> samples = getSampleRows(5);
            edgeDetection.analyse(samples);
        }
        firstOutputVersion();
    }
    
    public ArrayList<ArrayList<Integer>> getSampleRows(int rows) {
        ArrayList<ArrayList<Integer>> samples = new ArrayList<ArrayList<Integer>>();
        PVector offset = PVector.sub(p2.pos, p1.pos);
        offset.normalize();
        offset.mult(1);
        offset = new PVector(-offset.y, offset.x);
        
        for (int i = -rows/2; i <= rows/2; i++) {
            PVector v1 = new PVector(p1.pos.x + offset.x * i, p1.pos.y + offset.y * i);
            PVector v2 = new PVector(p2.pos.x + offset.x * i, p2.pos.y + offset.y * i);
            samples.add(getSampleRow(v1, v2));
        }

        if (selected)
        for (int i = 0; i < samples.size(); i++) {
            for (int j = 0; j < samples.get(i).size(); j++) {
                fill(samples.get(i).get(j));    
                rect(j * 10, 24 * 2 + capture.height + 10 * i, 10, 10);
            }
        }
        
        return samples;
    }
    
    private ArrayList<Integer> getSampleRow(PVector p1, PVector p2) {
        ArrayList<Integer> samples = new ArrayList<Integer>();
        float dist = PVector.dist(p1, p2);
        PVector current = p1.copy();
        PVector dir = PVector.sub(p2, p1);
        int sections = (int)dist/1;
        dir.normalize();
        dir.mult(dist / sections);
        
        for (int i = 0; i < sections; i++) {
            current.add(dir);
            int x = (int)current.x;
            int y = (int)current.y - 24;
            int index = x + y * capture.width;
            color c = capture.pixels[index];
            samples.add(c);
        }
        
        return samples;
    }
    
    public void display() {
        stroke(255, 80);
        strokeWeight(1);
        
        if (selected) {
            strokeWeight(3);
        }
            
        line(p1.getX(), p1.getY(), p2.getX(), p2.getY());
        
        if (selected) {
            p1.display(id);
        } else {
            p1.display();
        }
        
        p2.display();
        if (p1Current != null && false)
            p1Current.display();
        strokeWeight(1);
    }
    
    public PVector indexToPVector(float index) {
        PVector dir = PVector.sub(p2.pos, p1.pos);
        dir.normalize();
        dir.mult(index);
        
        return PVector.add(p1.pos, dir);
    }
    
    public boolean getSelected() { return selected; }
    public void setSelected(boolean value) { this.selected = value; }
    public void toggleSelected() { this.selected = this.selected ? false : true; }
}