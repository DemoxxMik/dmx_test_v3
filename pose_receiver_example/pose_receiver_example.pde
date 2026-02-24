/*
 * EXEMPLE: Récepteur OSC pour les données de pose corporelle
 *
 * Cet exemple montre comment recevoir les messages OSC du pose_tracker.py
 * et les utiliser pour contrôler des éléments visuels.
 *
 * Les messages OSC reçus:
 * - /pose/head/x (float 0.0-1.0)
 * - /pose/head/y (float 0.0-1.0)
 * - /pose/lefthand/x (float 0.0-1.0)
 * - /pose/lefthand/y (float 0.0-1.0)
 * - /pose/righthand/x (float 0.0-1.0)
 * - /pose/righthand/y (float 0.0-1.0)
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;

// Variables pour stocker les positions de pose
float poseHeadX = 0.5;
float poseHeadY = 0.5;
float poseLeftHandX = 0.5;
float poseLeftHandY = 0.5;
float poseRightHandX = 0.5;
float poseRightHandY = 0.5;

void setup() {
  size(800, 600);

  // Initialiser OSC sur le port 7000
  oscP5 = new OscP5(this, 7000);

  println("=== POSE RECEIVER EXAMPLE ===");
  println("Listening for OSC messages on port 7000");
  println("Launch pose_tracker.py to start receiving data");
}

void draw() {
  background(30);

  // Convertir les coordonnées normalisées (0.0-1.0) en pixels
  float headX = poseHeadX * width;
  float headY = poseHeadY * height;
  float leftHandX = poseLeftHandX * width;
  float leftHandY = poseLeftHandY * height;
  float rightHandX = poseRightHandX * width;
  float rightHandY = poseRightHandY * height;

  // Dessiner les points du corps

  // Tête (jaune)
  fill(255, 255, 0);
  noStroke();
  ellipse(headX, headY, 60, 60);

  // Main gauche (rouge)
  fill(255, 100, 100);
  ellipse(leftHandX, leftHandY, 40, 40);

  // Main droite (bleue)
  fill(100, 150, 255);
  ellipse(rightHandX, rightHandY, 40, 40);

  // Lignes de connexion
  stroke(150);
  strokeWeight(3);
  line(headX, headY, leftHandX, leftHandY);
  line(headX, headY, rightHandX, rightHandY);

  // Afficher les valeurs
  fill(255);
  textSize(14);
  int yPos = 20;
  text("=== POSE DATA ===", 10, yPos);
  yPos += 25;
  text("Head:      X=" + nf(poseHeadX, 1, 3) + "  Y=" + nf(poseHeadY, 1, 3), 10, yPos);
  yPos += 20;
  text("Left Hand:  X=" + nf(poseLeftHandX, 1, 3) + "  Y=" + nf(poseLeftHandY, 1, 3), 10, yPos);
  yPos += 20;
  text("Right Hand: X=" + nf(poseRightHandX, 1, 3) + "  Y=" + nf(poseRightHandY, 1, 3), 10, yPos);

  yPos += 40;
  text("=== DMX MAPPING EXAMPLE ===", 10, yPos);
  yPos += 25;

  // Exemple: mapper les valeurs de pose sur des canaux DMX simulés (0-255)
  int headBrightness = int(map(poseHeadY, 0, 1, 0, 255));
  int redChannel = int(map(poseLeftHandX, 0, 1, 0, 255));
  int blueChannel = int(map(poseRightHandX, 0, 1, 0, 255));

  text("DMX Channel 0 (Head brightness): " + headBrightness, 10, yPos);
  yPos += 20;
  text("DMX Channel 1 (Red from L-Hand): " + redChannel, 10, yPos);
  yPos += 20;
  text("DMX Channel 2 (Blue from R-Hand): " + blueChannel, 10, yPos);

  // Visualisation des canaux DMX
  yPos = height - 100;
  fill(headBrightness);
  rect(10, yPos, 100, 30);
  fill(255);
  text("CH0", 45, yPos + 20);

  fill(redChannel, 0, 0);
  rect(120, yPos, 100, 30);
  fill(255);
  text("CH1", 155, yPos + 20);

  fill(0, 0, blueChannel);
  rect(230, yPos, 100, 30);
  fill(255);
  text("CH2", 265, yPos + 20);
}

// Fonction appelée quand un message OSC est reçu
void oscEvent(OscMessage theOscMessage) {

  // Tête X
  if (theOscMessage.checkAddrPattern("/pose/head/x")) {
    poseHeadX = theOscMessage.get(0).floatValue();
  }
  // Tête Y
  else if (theOscMessage.checkAddrPattern("/pose/head/y")) {
    poseHeadY = theOscMessage.get(0).floatValue();
  }
  // Main gauche X
  else if (theOscMessage.checkAddrPattern("/pose/lefthand/x")) {
    poseLeftHandX = theOscMessage.get(0).floatValue();
  }
  // Main gauche Y
  else if (theOscMessage.checkAddrPattern("/pose/lefthand/y")) {
    poseLeftHandY = theOscMessage.get(0).floatValue();
  }
  // Main droite X
  else if (theOscMessage.checkAddrPattern("/pose/righthand/x")) {
    poseRightHandX = theOscMessage.get(0).floatValue();
  }
  // Main droite Y
  else if (theOscMessage.checkAddrPattern("/pose/righthand/y")) {
    poseRightHandY = theOscMessage.get(0).floatValue();
  }
}
