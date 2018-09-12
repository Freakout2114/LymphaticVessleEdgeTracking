import java.awt.*;
import java.awt.event.*;
import java.awt.CheckboxMenuItem;
import java.awt.MenuBar;
import java.awt.Menu;
import processing.awt.PSurfaceAWT;

public class MenuListener implements ActionListener, ItemListener {
    
    public void actionPerformed(ActionEvent e) {
        MenuItem source = (MenuItem)(e.getSource());
        
        if (source.equals(videoLoad)){
            selectInput("Select a video file to process:", "fileSelected");
            return;
        }
        
        if (source.equals(projectLoad)){
            
        }
        
        if (source.equals(webCamRefresh)) {
            println("Refresh Webcam Items");
            
            // Remove all existing cameras from the dropdown
            while (webCamMenu.getItemCount() > 1) {
                webCamMenu.remove(1);
            }
            
            String[] cameras = Capture.list();
            webCams = new MenuItem[cameras.length];
            
            if (cameras.length == 0) {
                println("There are no cameras available for capture.");
                exit();
            } else {
                println("Available cameras:");
                for (int i = 0; i < cameras.length; i++) {
                    println("i: " + i + "   "   + cameras[i]);
                    webCams[i] = new MenuItem(cameras[i]);
                    webCams[i].addActionListener(menuListener);
                    webCamMenu.add(webCams[i]);
                }
                    
                // The camera can be initialized directly using an 
                // element from the array returned by list():
                //camera = new Capture(this, cameras[73]);
                //camera.start();     
            }   
            println("Loading Camera Completed");
            return;
        }
        
        for (int i = 0; i < webCams.length; i++) {
            MenuItem item = webCams[i];
            if (source.equals(item)){
                println("Camera Selected: '" + webCams[i].getLabel() + "'");
                loadCamera(i);
                return;
            }
        }
    }
    public void itemStateChanged(ItemEvent e) {  
        MenuItem source = (MenuItem)(e.getSource());
        println("MenuListener    itemStateChanged");
            
        if(source.equals(videoLoad)){
            println("Load a layer");
        }
    }
}