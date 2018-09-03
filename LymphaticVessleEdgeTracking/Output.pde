import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Set;

public class Output 
{
    private ArrayList<Timestamp> timestamps = new ArrayList<Timestamp>();
    private boolean recording = false;
    
    public Output() {
        
    }
    
    public void resetRecording() {
        timestamps = new ArrayList<Timestamp>();
    }
    
    public void addTimestamp(Timestamp timestamp) {
        println("Adding timestamps");
        timestamps.add(timestamp);
    }
    
    public void exportData() {
        HashMap<Integer, String> timestampsHashMap = new HashMap<Integer, String>();
        
        for (Timestamp ts : timestamps) {
            int id = ts.getId();  
            
            String values = timestampsHashMap.get(id);
            if (values == null) {
                String input = id + "," + ts.getDistance();
                timestampsHashMap.put(id, input);
            } else {
                values += "," + ts.getDistance();
                timestampsHashMap.put(id, values);
            }
        }
        
        
        String[] finalOutput = new String[timestampsHashMap.size()];
        Set set = timestampsHashMap.entrySet();
        Iterator iterator = set.iterator();
        int index = 0;
        while(iterator.hasNext()) {
           Map.Entry mentry = (Map.Entry)iterator.next();
           System.out.print("key is: "+ mentry.getKey() + " & Value is: ");
           System.out.println(mentry.getValue());
           finalOutput[index] = (String)mentry.getValue();
           index++;
        }
        
        saveStrings("output.txt", finalOutput);
    }
    
    public void setRecording(boolean value) { this.recording = value; }
    public boolean getRecording() { return recording; }
}