
public class EdgeDetection
{
    EdgeDetection() {
        
    }
    
    /*
        1. Pass through samples
        2. Look for all the darkest pixels
            a. If there is only one section, then there is only one line
            b. If there is two sections, then there are two lines
            c. Noise may be apparent so the other samples need to be analised
            (The samples are in a multidimentional array so there should be a 
            line from one side of the grid to the other.) 
            
            
        Part 2
        With what I have now, I need to check the width of each "edge", if the 
        program thinks there is 3 lines, but 2 are about 4 pixels wide and 1
        is only a single pixel, then the smallest is noise and ignore it.
        Standard div seems to be the best analysing function I know.
        
        Initially
        The line needs to start on either side and find out if there is 1 or 2 
        edges. From there record their position and from there just predict and
        update their location to track them, ignore the line and only use 
        y = mx + b to determine the location position.
    */
    
    public void analyse(ArrayList<ArrayList<Integer>> samples) {
        ArrayList<ArrayList<Integer>> darkestPixels = new ArrayList<ArrayList<Integer>>();
        ArrayList<Integer> lineSize = new ArrayList<Integer>();
        
        for (ArrayList<Integer> sample : samples) {
            ArrayList<Integer> darkPixels = getDarkestPixels(sample);
            darkestPixels.add(darkPixels);
            lineSize.add(getLineCount(darkPixels));
        }
    }
    
    public ArrayList<Integer> getDarkestPixels(ArrayList<Integer> sample) {
        if (sample == null || sample.size() == 0)
            return null;
            
        int darkestIndex = 0;
        ArrayList<Integer> darkestIndexes = new ArrayList<Integer>();
        
        for (int i = 1; i < sample.size(); i++) {
            if (sample.get(i) < sample.get(darkestIndex)) {
                darkestIndex = i;
                darkestIndexes = new ArrayList<Integer>();
            }
            
            if (sample.get(i).equals(sample.get(darkestIndex))) {
                darkestIndexes.add(i);    
            }
        }
        
        return darkestIndexes;
    }
    
    public Integer getLineCount(ArrayList<Integer> darkestPixels) {
        int lineCount = 1;
        int lineWidthCount = 1;
        ArrayList<Integer> lineWidth = new ArrayList<Integer>();
        
        for (int i = 1; i < darkestPixels.size(); i++) {
            if (darkestPixels.get(i - 1) != darkestPixels.get(i) - 1) {
                lineWidth.add(lineWidthCount);
                lineWidthCount = 1;
                lineCount++;
            } else {
                lineWidthCount++;    
            }
        }
        lineWidth.add(lineWidthCount);
        println("Line count = " + lineCount + ", Line Widths: " + lineWidth);
        return lineCount;
    }
    
    public ArrayList<ArrayList<Integer>> convertDarkPixelsToArray(ArrayList<Integer> darkestPixels) {
        ArrayList<ArrayList<Integer>> edges = new ArrayList<ArrayList<Integer>>();
        ArrayList<Integer> edge = new ArrayList<Integer>();
        
        if (darkestPixels.size() == 0)
            return edges;
            
        edge.add(darkestPixels.get(0));
        for (int i = 1; i < darkestPixels.size(); i++) {
            if (darkestPixels.get(i - 1) != darkestPixels.get(i) - 1) {
                edges.add(edge);
                edge = new ArrayList<Integer>();
            }
            
            edge.add(darkestPixels.get(i));
        }
        
        edges.add(edge);
        return edges;
    }
}