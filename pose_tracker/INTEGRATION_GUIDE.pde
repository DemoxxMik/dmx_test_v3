/*
 * GUIDE D'INTÉGRATION: Pose Tracking dans votre projet DMX
 * 
 * Ce fichier montre comment intégrer les données de pose corporelle
 * dans votre projet existant dmx_test_v3
 * 
 * ÉTAPE 1: Ajouter ces variables globales dans dmx_test_v3.pde
 * ------------------------------------------------------------
 */

// Variables pour la pose corporelle (à ajouter après les autres variables globales)
float poseHeadX = 0.5;
float poseHeadY = 0.5;
float poseLeftHandX = 0.5;
float poseLeftHandY = 0.5;
float poseRightHandX = 0.5;
float poseRightHandY = 0.5;


/*
 * ÉTAPE 2: Modifier OSC_Control.pde
 * ----------------------------------
 * Ajouter ce code dans la fonction oscEvent() APRÈS le bloc /nuage
 */

void oscEvent(OscMessage theOscMessage) {
  
  // Code existant pour /nuage...
  if(theOscMessage.checkAddrPattern("/nuage")==true) {
    if(theOscMessage.checkTypetag("f")) {
      float value = theOscMessage.get(0).floatValue();
      if(nuages != null){
        nuages.osc_value = value;
      }
    } else {
      println(" ERROR: Typetag mismatch for /nuage. Expected 'f', got: " + theOscMessage.typetag());
    }
  }
  
  // NOUVEAU: Gestion des messages de pose corporelle
  // Tête
  else if(theOscMessage.checkAddrPattern("/pose/head/x")) {
    poseHeadX = theOscMessage.get(0).floatValue();
  }
  else if(theOscMessage.checkAddrPattern("/pose/head/y")) {
    poseHeadY = theOscMessage.get(0).floatValue();
  }
  // Main gauche
  else if(theOscMessage.checkAddrPattern("/pose/lefthand/x")) {
    poseLeftHandX = theOscMessage.get(0).floatValue();
  }
  else if(theOscMessage.checkAddrPattern("/pose/lefthand/y")) {
    poseLeftHandY = theOscMessage.get(0).floatValue();
  }
  // Main droite
  else if(theOscMessage.checkAddrPattern("/pose/righthand/x")) {
    poseRightHandX = theOscMessage.get(0).floatValue();
  }
  else if(theOscMessage.checkAddrPattern("/pose/righthand/y")) {
    poseRightHandY = theOscMessage.get(0).floatValue();
  }
}


/*
 * ÉTAPE 3: Utiliser les valeurs de pose dans draw()
 * --------------------------------------------------
 * Exemples d'utilisation dans dmx_test_v3.pde ou dans vos modèles
 */

// Exemple 1: Contrôler la luminosité avec la position verticale de la tête
void example1_headBrightness() {
  // Plus la tête est haute (Y faible), plus c'est lumineux
  int brightness = int(map(poseHeadY, 0, 1, 255, 0));
  channel_value[0] = brightness;
}

// Exemple 2: Contrôler des couleurs RGB avec les mains
void example2_handsRGB() {
  // Main gauche contrôle le rouge (position X)
  int red = int(map(poseLeftHandX, 0, 1, 0, 255));
  
  // Main droite contrôle le bleu (position X)
  int blue = int(map(poseRightHandX, 0, 1, 0, 255));
  
  // Position Y de la tête contrôle le vert
  int green = int(map(poseHeadY, 0, 1, 0, 255));
  
  // Assigner aux canaux DMX (adapter selon vos lumières)
  channel_value[1] = red;
  channel_value[2] = green;
  channel_value[3] = blue;
}

// Exemple 3: Créer des effets dynamiques
void example3_dynamicEffect() {
  // Distance entre les deux mains
  float handDistance = dist(poseLeftHandX, poseLeftHandY, 
                            poseRightHandX, poseRightHandY);
  
  // Mapper la distance sur un paramètre (0.0 à ~1.4 max)
  int effect = int(map(handDistance, 0, 1.4, 0, 255));
  effect = constrain(effect, 0, 255);
  
  channel_value[4] = effect;
}

// Exemple 4: Trigger/Switch basé sur la position
void example4_zoneTriggers() {
  // Diviser l'écran en zones
  // Si la tête est dans la zone gauche (X < 0.33)
  if (poseHeadX < 0.33) {
    channel_value[5] = 255; // Activer lumière gauche
    channel_value[6] = 0;
  }
  // Zone centrale
  else if (poseHeadX < 0.66) {
    channel_value[5] = 0;
    channel_value[6] = 255; // Activer lumière centrale
  }
  // Zone droite
  else {
    channel_value[5] = 0;
    channel_value[6] = 0;
  }
}

// Exemple 5: Combiner pose + VCV Rack (/nuage)
void example5_combined() {
  if (nuages != null) {
    // Multiplier la valeur OSC de VCV par la position de la main
    float combined = nuages.osc_value * poseRightHandY;
    
    // Mapper sur un canal DMX
    int value = int(map(combined, 0, 1, 0, 255));
    channel_value[7] = constrain(value, 0, 255);
  }
}


/*
 * ÉTAPE 4: Visualisation des données (optionnel)
 * -----------------------------------------------
 * Ajouter ceci dans draw() pour voir les valeurs
 */

void debug_pose(int x, int y) {
  fill(255);
  textSize(12);
  
  text("=== POSE TRACKING ===", x, y);
  text("Head:  X=" + nf(poseHeadX, 1, 2) + " Y=" + nf(poseHeadY, 1, 2), x, y+15);
  text("L-Hand: X=" + nf(poseLeftHandX, 1, 2) + " Y=" + nf(poseLeftHandY, 1, 2), x, y+30);
  text("R-Hand: X=" + nf(poseRightHandX, 1, 2) + " Y=" + nf(poseRightHandY, 1, 2), x, y+45);
}

// Puis dans draw():
// debug_pose(10, 100);


/*
 * WORKFLOW COMPLET
 * ================
 * 
 * 1. Lancer pose_tracker.py
 *    > python pose_tracker/pose_tracker.py
 * 
 * 2. Lancer votre sketch Processing dmx_test_v3
 * 
 * 3. Les valeurs poseHeadX, poseHeadY, etc. seront mises à jour automatiquement
 * 
 * 4. Utiliser ces valeurs où vous voulez dans votre code!
 * 
 * 
 * ASTUCES
 * =======
 * 
 * - Les valeurs vont de 0.0 à 1.0 (normalisées)
 * - Utilisez map() pour convertir vers vos plages (0-255 pour DMX)
 * - Utilisez constrain() pour éviter les débordements
 * - Combinez avec vos effets existants (Nuages, etc.)
 * 
 */
