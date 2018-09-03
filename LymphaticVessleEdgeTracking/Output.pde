import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Set;

public class Output 
{
    private HashMap<Integer, ArrayList<Timestamp>> timestamps = new HashMap<Integer, ArrayList<Timestamp>>;
    private boolean recording = false;
    
    public Output() {
        
    }
    
    public void resetRecording() {
        timestamps = new ArrayList<Timestamp>();
    }
    
    public void addTimestamp(Timestamp timestamp) {
        ArrayList<Timestamp> list = timestamps.get(timestamp.getTimestamp());
        
        if (list == null) {
            list = new ArrayList<Timestamp>();    
            timestamps.put(timestamp.getTimestamp(), list);
        }
        
        list.add(timestamp);
        
    }
    
    /* Output format
    
    Timestamp   {ID   e1 displacement e2 displacement} {id diameter}
    
    */
    
    public void exportData() {
        
        
        saveStrings("output.txt", finalOutput);
    }
    
    public void setRecording(boolean value) { this.recording = value; }
    public boolean isRecording() { return recording; }
}