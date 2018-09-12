import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Set;
import java.util.Arrays;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

public class Output 
{
    private HashMap<Integer, ArrayList<Timestamp>> timestampsHm = new HashMap<Integer, ArrayList<Timestamp>>();
    private boolean recording = false;
    
    public Output() {
        
    }
    
    public void resetRecording() {
        timestampsHm = new HashMap<Integer, ArrayList<Timestamp>>();
    }
    
    public void addTimestamp(Timestamp timestamp) {
        ArrayList<Timestamp> list = timestampsHm.get(timestamp.getId());
        
        if (list == null) {
            list = new ArrayList<Timestamp>();    
            timestampsHm.put(timestamp.getId(), list);
        }
        
        list.add(timestamp);
        
    }
    
    /* Output format
    
    Timestamp   {ID   e1 displacement e2 displacement} {id diameter}
    
    */
    
    public void exportData() {
        String header = "Time";
        // Get how many lines there are total
        int totalLineCount = timestampsHm.size();
        println("totalLineCount: " + totalLineCount);
        
        // Displacement and Diameter Headers
        String displacementHeader = "";
        String diameterHeader = "";
        for (int i = 1; i <= totalLineCount; i++) {
             displacementHeader += "\t" + "e" + i + "_U " + "\t" + "e" + i + "_L";
             diameterHeader += "\t" + "e" + i + "_D";
        }
        header += displacementHeader + diameterHeader;
        
        // Get the min and max number of time stamps
        int minTs = getMinTimeStamps();
        println("minTs: " + minTs);
        int maxTs = getMaxTimeStamps();
        println("maxTs: " + maxTs);
        
        String[] finalOutput = new String[maxTs - minTs + 2];
        finalOutput[0] = header;
             
        for (int i = minTs; i <= maxTs; i++) {
            String displacements = "";
            String diameters = "";
            for (int j = 0; j < totalLineCount; j++) {
                ArrayList<Timestamp> ts = timestampsHm.get(j);
                String e1dis = getEdgeDisplacement(i, 1, ts);
                String e2dis = getEdgeDisplacement(i, 2, ts);
                displacements += "\t" + e1dis + "\t" + e2dis;
                
                String diameter = getEdgeDiameter(i, ts);
                diameters += "\t" + diameter;
            }
            finalOutput[i - minTs + 1] = i + displacements + diameters;
        }
         
        for (String s : finalOutput) {
            println(s);    
        }
        
        DateFormat dateFormat = new SimpleDateFormat("yyyy MM dd");
        Date date = new Date();
        String fileName = dateFormat.format(date) + "/" + dateFormat.format(date);
        saveFrame(fileName + ".png");
        
        saveStrings(fileName + ".txt", finalOutput);
    }
    
    private int getMinTimeStamps() {
        int minTs = -1;
        
        Set set = timestampsHm.entrySet();
        Iterator iterator = set.iterator();
        while (iterator.hasNext()) {
            Map.Entry mentry = (Map.Entry)iterator.next();
            ArrayList<Timestamp> tsList = (ArrayList<Timestamp>) mentry.getValue();
            
            for (Timestamp ts : tsList) {
                minTs = (minTs == -1) ? minTs = ts.getTimestamp() : Math.min(minTs, ts.getTimestamp());
                
                // No timestamp can be less than 0, if 0 is found return.
                if (minTs == 0) {
                    return minTs;    
                }
            }
        }
        
        return minTs;
    }
    
    private int getMaxTimeStamps() {
        int maxTs = -1;
        
        Set set = timestampsHm.entrySet();
        Iterator iterator = set.iterator();
        while (iterator.hasNext()) {
            Map.Entry mentry = (Map.Entry)iterator.next();
            ArrayList<Timestamp> tsList = (ArrayList<Timestamp>) mentry.getValue();
            
            for (Timestamp ts : tsList) {
                maxTs = (maxTs == -1) ? maxTs = ts.getTimestamp() : Math.max(maxTs, ts.getTimestamp());
            }
        }
        
        return maxTs;
    }
    
    private String getEdgeDisplacement(int timestamp, int edge, ArrayList<Timestamp> tsList) {
        String output = "";
        
        if (tsList == null) {
            return output;    
        }
        
        for (Timestamp ts : tsList) {
            if (ts.getTimestamp() == timestamp) {
                if (edge == 1) {
                    output = ts.getE1Displacement() + "";
                } else {
                    if (ts.getEdgeSize() == 2) {
                        output = ts.getE2Displacement() + "";
                    }
                }
            }
        }
        
        return output;
    }
    
    private String getEdgeDiameter(int timestamp, ArrayList<Timestamp> tsList) {
        String output = "";
        
        if (tsList == null) {
            return output;    
        }
        
        for (Timestamp ts : tsList) {
            if (ts.getTimestamp() == timestamp) {
                if (ts.getEdgeSize() == 2) {
                    output = ts.getDiameter() + "";
                }
            }
        }
        
        return output;
    }
    
    public void setRecording(boolean value) { this.recording = value; }
    public boolean isRecording() { return recording; }
}