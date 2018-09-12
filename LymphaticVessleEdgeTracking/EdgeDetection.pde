
public class EdgeDetection
{
    private PVector displayOffset = new PVector(0, 24);
    EdgeDetection() {}
    
    public ArrayList<Integer> getEdgeBetweenPoints(PVector p1, PVector p2) {
        ArrayList<Integer> capturePixels = getPixelsBetweenPoints(p1, p2);
        
        return capturePixels;
    }
    
    public ArrayList<Integer> getPixelsBetweenPoints(PVector p1, PVector p2) {
        ArrayList<Integer> capturePixels = new ArrayList<Integer>();
        
        PVector pos = p1.copy();
        PVector dir = PVector.sub(p2, p1);
        dir.normalize();
        dir.mult(1);
        stroke(0);
        
        for (int i = 0; i < PVector.dist(p1, p2); i++) {
            pos = PVector.add(pos, dir);
            int index = (int)pos.x + (int)(pos.y - displayOffset.y) * capture.width;
            color c = capture.pixels[index];
            fill(c);
            float pixelW = capture.width / PVector.dist(p1, p2);
            rect(i * pixelW, capture.height + displayOffset.y, pixelW, 10);
            fill(0);
            text((int)brightness(c), i * pixelW + pixelW/2, capture.height + displayOffset.y + 16, pixelW);
            capturePixels.add(c);
        }
        
        return capturePixels;
    }
    
    // Looks for the darkest pixel between the two points. If the index of the darkest pixel is
    // within the 1/4 to 3/4 range then it is assumed to be a single line. Otherwise it assumes 2 lines
    public int getEstimateLineSize(PVector p1, PVector p2) {
        ArrayList<Integer> pix = getPixelsBetweenPoints(p1, p2);
        
        int darkIndex = 0;
        for (int i = 0; i < pix.size(); i++) {
            float dark = brightness(pix.get(darkIndex));   
            float c = brightness(pix.get(i));   
            
            if (c < dark) {
                darkIndex = i;    
            }
        }
        
        if (darkIndex > pix.size() * 1/4 && darkIndex < pix.size() * 3/4) {
            println("1 Line");
            return 1;
        }
        println("2 Lines");
        return 2;
    }
    
    /*
        This function works by:
        1. Getting the darkest pixel index from the array
        2. Calculate the birghtness differences for each pixel from the darkest pixel
        3. Find the standard deviation of those darknesses
        4. From the darkest index look left and right for all pixels that have a difference 
           less than the standard deviation.
        5. Take a weighted average of those pixels to determine the location of the edge
        
        TODO - I want to change that array search to be more efficient
        TODO - Also i need it to take the center pixels more into account then the edge of the array
        TODO - Maybe look at the new possible line locations and then select the one closest to the predicted position
    */
    public float diffLessStd(ArrayList<Integer> capturePixels) {
        if (capturePixels.isEmpty()) {
            return 0;
        }
        
        // Start with the first index as a base for darkest pixel
        float min = brightness(capturePixels.get(0));
        
        // Remember what index the darkest pixel was at
        int darkestIndex = 0;
        
        // A List to track the differences in brightness between the darkest pixel and every other pixel
        ArrayList<Integer> differences = new ArrayList<Integer>();
        
        // Find the darkest pixel from the array
        for (int i = 0; i < capturePixels.size(); i++) {
            Integer v = capturePixels.get(i);
            
            if (brightness(v) < min) {
                min = brightness(v);
                darkestIndex = i;
            }
        }
        
        // Calculate the brightness differences between each pixel and the darkest pixel 
        for (Integer v : capturePixels) { 
            differences.add( (int) abs(brightness(v) - min) );
        }
        
        // Calculate the standardDeviation from the brightness differences
        float std = standardDeviation(differences);
        ArrayList<Integer> edgeIndexes = new ArrayList<Integer>();
        
        /*
        // Look at all pixels that have a brightness < standard deviation
        for (int i = 0; i < differences.size(); i++) {
            float diff = differences.get(i);
            if (diff < std) {
                float pixelW = capture.width / capturePixels.size();
                fill(capturePixels.get(i));
                rect(i * pixelW, capture.height + displayOffset.y + 32, pixelW, 10);
                edgeIndexes.add(i);
            } else {
                i = differences.size();
            }
        }
        */
        
        ArrayList<PVector> possibleEdgeIndexes = new ArrayList<PVector>();
        
        // Look at all pixels that have a brightness < standard deviation. This will results in 1 or more possible
        // edge locations that need to be evaluated for the most likely.
        for (int i = 0; i < differences.size(); i++) {
            // Indexes of the possible line
            int startingIndex = i;
            int endingIndex = i;
            
            // If the current pixel is less than the standard deviation
            // loop through the entire line to find the start and end position
            while (i < differences.size() && differences.get(i) < std) {
                // Debug drawing 
                float pixelW = capture.width / capturePixels.size();
                fill(capturePixels.get(i));
                rect(i * pixelW, capture.height + displayOffset.y + 32, pixelW, 10);
                edgeIndexes.add(i);
                
                endingIndex = i;
                
                i++;
            }
            
            if (startingIndex != endingIndex) {
                //println("Edge is between indexes: [" + startingIndex + ", " + endingIndex + "]");
                possibleEdgeIndexes.add( new PVector(startingIndex, endingIndex) );
            }
        }
        
        // After the possible edges have been identified, find the edge that is closest to the center (predicted location)
        int closestEdge = 0;
        for (int i = 1; i < possibleEdgeIndexes.size(); i++) {
            int closestPosition = (int)(possibleEdgeIndexes.get(closestEdge).x + possibleEdgeIndexes.get(closestEdge).y) / 2;    
            int currentPosition = (int)(possibleEdgeIndexes.get(i).x + possibleEdgeIndexes.get(i).y) / 2;    
            
            int closestDistance = abs(capturePixels.size() / 2 - closestPosition);
            int currentDistance = abs(capturePixels.size() / 2 - currentPosition);
            if (currentDistance < closestDistance) {
                closestEdge = i;    
            }
            
        }
        
        edgeIndexes = new ArrayList<Integer>();
        if (possibleEdgeIndexes.size() > 0) {
            for (int i = (int)possibleEdgeIndexes.get(closestEdge).x; i < possibleEdgeIndexes.get(closestEdge).y; i++) {
                edgeIndexes.add(i); 
            }
        }
        
        /*
        Weighted Average of the edge indexes
        Take the each pixels difference with the standard deviation, treat that as
        a weight and then do a weighted average of those values to find the vector
        position of the edge.
        Weighted average = sumproduct(indexes, weights) / sum(weights)
        */
        float weightedAvg = 0;
        float sumProduct = 0;
        float sumWeights = 0;
        float[] weights = new float[edgeIndexes.size()];
        
        for (int i = 0; i < edgeIndexes.size(); i++) {
            weights[i] = std - differences.get(i);
            sumWeights += weights[i];
            sumProduct += edgeIndexes.get(i) * weights[i];
        }
        
        weightedAvg = sumProduct / sumWeights;
        
        {
        float pixelW = capture.width / capturePixels.size();
        rect(weightedAvg * pixelW, capture.height + displayOffset.y + 64, pixelW, 10);
        }
        
        return weightedAvg + 1;
    }
    
    public float standardDeviation(ArrayList<Integer> capturePixels) {
        float mean = 0;
        float variance = 0;
        float std = 0;
        
        for (Integer v : capturePixels) { 
            mean += brightness(v); 
        }
        
        mean /= capturePixels.size();
        
        for (Integer v : capturePixels) { 
            float bright = brightness(v);
            variance += (mean - bright) * (mean - bright); 
        }
        
        variance /= capturePixels.size();
        
        std = (float)Math.sqrt(variance);
        
        return std;
    }
}