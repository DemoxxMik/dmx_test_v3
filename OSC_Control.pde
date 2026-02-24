import oscP5.*;
import netP5.*;

OscP5 oscP5;
int oscPort = -1;
NetAddress vcvRackLocation; // Adresse de destination pour VCV Rack

void init_osc(int port) {
  oscPort = port;
  /* start oscP5, listening for incoming messages at port */
  oscP5 = new OscP5(this, oscPort);

  // Configurer l'envoi vers VCV Rack (Localhost, port 7001)
  // ATTENTION: Dans VCV Rack, réglez votre module OSC sur le port 7001 (UDP)
  vcvRackLocation = new NetAddress("127.0.0.1", 7001);

  println("OSC initialized on port " + oscPort);
  println("Sending OSC to VCV Rack on port 7001");

  // Update Nuages instance so it can display the current port without accessing globals
  if (nuages != null) {
    nuages.oscPortRef = oscPort;
  }
}

// Check if a message matches a pose pattern and update variables
boolean checkPoseMessage(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/pose/head/x")) {
    poseHeadX = theOscMessage.get(0).floatValue();
    return true;
  }
  if (theOscMessage.checkAddrPattern("/pose/head/y")) {
    poseHeadY = theOscMessage.get(0).floatValue();
    return true;
  }
  if (theOscMessage.checkAddrPattern("/pose/lefthand/x")) {
    poseLeftHandX = theOscMessage.get(0).floatValue();
    return true;
  }
  if (theOscMessage.checkAddrPattern("/pose/lefthand/y")) {
    poseLeftHandY = theOscMessage.get(0).floatValue();
    return true;
  }
  if (theOscMessage.checkAddrPattern("/pose/righthand/x")) {
    poseRightHandX = theOscMessage.get(0).floatValue();
    return true;
  }
  if (theOscMessage.checkAddrPattern("/pose/righthand/y")) {
    poseRightHandY = theOscMessage.get(0).floatValue();
    return true;
  }
  return false;
}

// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage) {

  // 1. D'abord gérer les messages "internes" venant de VCV Rack (ex: /nuage)
  if (theOscMessage.checkAddrPattern("/nuage")==true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f")) {

      float value = theOscMessage.get(0).floatValue();
      if (nuages != null) {
        nuages.osc_value = value;
      }
    } else {
      println(" ERROR: Typetag mismatch for /nuage. Expected 'f', got: " + theOscMessage.typetag());
    }
  }

  // 2. Ensuite gérer les messages de POSE venant du Python
  // Si c'est un message de pose, on met à jour les variables ET on transfère à VCV Rack
  else if (checkPoseMessage(theOscMessage)) {
    // Le message a mis à jour les variables globales via checkPoseMessage
    // Maintenant on le re-transmet à VCV Rack tel quel
    oscP5.send(theOscMessage, vcvRackLocation);
  }
}
