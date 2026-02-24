import dmxP512.*;
import processing.serial.*;

DmxP512 dmxOutput;
int universeSize = 513;

boolean DMXPRO = false; // False pour désactiver le dmx, true pour activer le dmx.
String DMXPRO_PORT = "COM5";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE = 57600;


int nb_channel = 513;
int[] channel_value = new int[nb_channel];

// Variables pour la pose corporelle (reçues via OSC du script Python)
float poseHeadX = 0.5;
float poseHeadY = 0.5;
float poseLeftHandX = 0.5;
float poseLeftHandY = 0.5;
float poseRightHandX = 0.5;
float poseRightHandY = 0.5;


void setup() {
  size(1300, 800, P2D);
  dmxOutput = new DmxP512(this, universeSize, DMXPRO);

  init_model_B();

  init_osc(7000);

  if (DMXPRO) {
    dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  }
}

float t = 0;

void draw() {
  background(0);
  println("poseHeadX = " + poseHeadX);
  println("poseHeadY = " + poseHeadY);
  println("poseLeftHandX = " + poseLeftHandX);
  println("poseLeftHandY = " + poseLeftHandY);
  println("poseRightHandX = " + poseRightHandX);
  println("poseRightHandY = " + poseRightHandY);
  t += 0.2;

  draw_model_B();

  for (int i = 0; i < channel_value.length; i++) {
    if (dmxOutput!= null) {
      dmxOutput.set(i+1, channel_value[i]);
    }
  }

  debug(450, 60, 1200);
}


void debug(int px, int py, int max_width) {
  int original_px = px;

  for (int i = 0; i < channel_value.length; i++) {
    fill(map(channel_value[i], 0, 255, 50, 255));
    text(channel_value[i], px, py);

    px += 30;
    if (px > max_width) {
      px = original_px;
      py += 15;
    }
  }
}
