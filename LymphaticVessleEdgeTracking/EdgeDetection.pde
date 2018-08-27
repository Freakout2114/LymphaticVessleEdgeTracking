/*
    Steps
    1. Read in the line
    2. Find the background colour
    3. Find the array of dark pixels
    4. Average Index in the PVector
    
*/


public class EdgeDetection
{
    private PVector displayOffset = new PVector(0, 24);
    EdgeDetection() {}
    
    public ArrayList<Integer> getEdgeBetweenPoints(PVector p1, PVector p2) {
        ArrayList<Integer> capturePixels = getPixelsBetweenPoints(p1, p2);
        getBackgroundColour(capturePixels);
        
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
    
    /*
        Get the darkest pixel of the array
        Get the difference in darkness between each pixel and the darkest pixel
        Then find the standard deviation
        Highlight all pixels with Diff < standard deviation
        
        This function works by:
        1. Getting the darkest pixel index from the array
        2. Calculate the birghtness differences for each pixel from the darkest pixel
        3. Find the standard deviation of those darknesses
        4. From the darkest index look left and right for all pixels that have a difference 
           less than the standard deviation.
        5. Take a weighted average of those pixels to determine the location of the edge
        
        TODO - I want to change that array search to be more efficient
    */
    public float diffLessStd(ArrayList<Integer> capturePixels) {
        float min = brightness(capturePixels.get(0));
        int darkestIndex = 0;
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
        
        // Look right from the darkest index
        for (int i = darkestIndex; i < differences.size(); i++) {
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
        
        // Look left from the darkest point
        for (int i = darkestIndex; i >= 0; i--) {
            float diff = differences.get(i);
            if (diff < std) {
                float pixelW = capture.width / capturePixels.size();
                fill(capturePixels.get(i));
                rect(i * pixelW, capture.height + displayOffset.y + 32, pixelW, 10);
                edgeIndexes.add(i);
            } else {
                i = -1;
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
        
        return weightedAvg;
    }
    
    public ArrayList<Integer> highlightEdge(ArrayList<Integer> capturePixels) {
        float min = brightness(capturePixels.get(0));
        float mean = 0;
        float variance = 0;
        float std = 0;
        
        for (Integer v : capturePixels) { 
            mean += brightness(v); 
            min = min(min, brightness(v));
        }
        
        mean /= capturePixels.size();
        
        for (Integer v : capturePixels) { 
            float bright = brightness(v);
            variance += (mean - bright) * (mean - bright); 
        }
        
        variance /= capturePixels.size();
        
        std = (float)Math.sqrt(variance);
        
        println("Min: " + min + ", Mean: " + mean + ", Variance: " + variance + ", Std: " + std + ", min + std = " + (min + std));
        
        ArrayList<Integer> darkPixels = new ArrayList<Integer>();
        
        for (int i = 0; i < capturePixels.size(); i++) {
            color c = capturePixels.get(i);
            if (brightness(c) <= min + std) {
                float pixelW = capture.width / capturePixels.size();
                fill(c);
                rect(i * pixelW, capture.height + displayOffset.y + 32, pixelW, 10);
                darkPixels.add(i);
            }
        }
        
        return darkPixels;
    }
    
    private void getBackgroundColour(ArrayList<Integer> capturePixels) {
        float R = 0;
        float G = 0;
        float B = 0;
        
        for (Integer pixel : capturePixels) {
            R += red(pixel);
            G += green(pixel);
            B += blue(pixel);
        }
        
        R /= capturePixels.size();
        G /= capturePixels.size();
        B /= capturePixels.size();
        
        fill(R, G, B);
        rect(64, height - 64, 64, 64);
        fill(0);
        text((int) brightness(color(R, G, B)), 64 + 32, height - 64 + 32); 
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