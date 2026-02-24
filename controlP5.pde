import controlP5.*;
import java.util.List;

ControlP5 cp5;



void init_cp5() {
  cp5 = new ControlP5(this);


  for (int i=0; i<nb_channel; i++) {
    cp5.addSlider("channel_"+i)
      .setPosition(30, i*30+50)
      .setRange(0, 255)
      .setSize(300, 16)
      ;
  }
}


void controlEvent(ControlEvent e) {
  String [] data = split(e.getController().getName(), "_");
  String type=data[0];
  int id = int(float(data[1]));

  if (type.equals("channel")) {
    channel_value[id]=(byte)e.getController().getValue();
  }
}
