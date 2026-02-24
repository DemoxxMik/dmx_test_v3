# 🎭 Body Pose Tracker - OSC Output

Détection corporelle en temps réel avec MediaPipe qui envoie les positions via OSC vers Processing et VCV Rack.

## 🚀 Installation

### Prérequis
- Python 3.8 ou supérieur
- Webcam ou caméra de téléphone
- Processing (pour recevoir les données)

### Étape 1: Installer Python
Si Python n'est pas installé, télécharge-le depuis [python.org](https://www.python.org/downloads/)

Vérifie l'installation:
```bash
python --version
```

### Étape 2: Installer les dépendances
```bash
cd pose_tracker
pip install -r requirements.txt
```

> **Note**: Sur certains systèmes, utilise `pip3` au lieu de `pip`

### Étape 3 (Optionnel): Configurer la caméra du téléphone

Si tu veux utiliser la caméra de ton téléphone:

#### Option A: DroidCam (Android/iOS)
1. Télécharge **DroidCam** sur ton téléphone et PC
2. Lance l'application sur les deux appareils
3. Note l'URL affichée sur le téléphone (ex: `http://192.168.1.100:4747/video`)

#### Option B: IP Webcam (Android)
1. Télécharge **IP Webcam** depuis le Play Store
2. Lance l'app et démarre le serveur
3. Note l'URL (ex: `http://192.168.1.100:8080/video`)

---

## 📖 Utilisation

### Utilisation basique (webcam PC)
```bash
python pose_tracker.py
```

### Avec caméra de téléphone
```bash
python pose_tracker.py --camera-url http://192.168.1.100:4747/video
```

### Personnaliser le port OSC
```bash
python pose_tracker.py --osc-port 8000
```

### Envoyer vers une autre machine
```bash
python pose_tracker.py --osc-ip 192.168.1.50 --osc-port 7000
```

### Mode headless (sans prévisualisation)
```bash
python pose_tracker.py --no-preview
```

### Toutes les options
```bash
python pose_tracker.py --help
```

---

## 🎵 Messages OSC envoyés

Le tracker envoie **6 messages OSC** en continu:

| Message OSC             | Description                    | Plage    |
|------------------------|--------------------------------|----------|
| `/pose/head/x`         | Position X de la tête          | 0.0-1.0  |
| `/pose/head/y`         | Position Y de la tête          | 0.0-1.0  |
| `/pose/lefthand/x`     | Position X de la main gauche   | 0.0-1.0  |
| `/pose/lefthand/y`     | Position Y de la main gauche   | 0.0-1.0  |
| `/pose/righthand/x`    | Position X de la main droite   | 0.0-1.0  |
| `/pose/righthand/y`    | Position Y de la main droite   | 0.0-1.0  |

Les coordonnées sont **normalisées** entre 0.0 et 1.0:
- **X**: 0.0 = gauche de l'écran, 1.0 = droite
- **Y**: 0.0 = haut de l'écran, 1.0 = bas

---

## 🎨 Utilisation dans Processing

### Étendre `OSC_Control.pde`

Ajoute ces variables globales au début de ton sketch principal:

```java
// Variables pour la pose
float poseHeadX = 0.5;
float poseHeadY = 0.5;
float poseLeftHandX = 0.5;
float poseLeftHandY = 0.5;
float poseRightHandX = 0.5;
float poseRightHandY = 0.5;
```

Modifie la fonction `oscEvent()` dans `OSC_Control.pde`:

```java
void oscEvent(OscMessage theOscMessage) {
  
  // Existing code for /nuage
  if(theOscMessage.checkAddrPattern("/nuage")==true) {
    if(theOscMessage.checkTypetag("f")) {
      float value = theOscMessage.get(0).floatValue();
      if(nuages != null){
        nuages.osc_value = value;
      }
    }
  }
  
  // NOUVEAU: Gestion des messages de pose
  if(theOscMessage.checkAddrPattern("/pose/head/x")==true) {
    poseHeadX = theOscMessage.get(0).floatValue();
  }
  else if(theOscMessage.checkAddrPattern("/pose/head/y")==true) {
    poseHeadY = theOscMessage.get(0).floatValue();
  }
  else if(theOscMessage.checkAddrPattern("/pose/lefthand/x")==true) {
    poseLeftHandX = theOscMessage.get(0).floatValue();
  }
  else if(theOscMessage.checkAddrPattern("/pose/lefthand/y")==true) {
    poseLeftHandY = theOscMessage.get(0).floatValue();
  }
  else if(theOscMessage.checkAddrPattern("/pose/righthand/x")==true) {
    poseRightHandX = theOscMessage.get(0).floatValue();
  }
  else if(theOscMessage.checkAddrPattern("/pose/righthand/y")==true) {
    poseRightHandY = theOscMessage.get(0).floatValue();
  }
}
```

### Exemple d'utilisation

Tu peux maintenant utiliser ces valeurs dans ton code Processing:

```java
void draw() {
  // Exemple: Utiliser la position de la tête pour contrôler une lumière
  int headBrightness = int(map(poseHeadY, 0, 1, 0, 255));
  channel_value[0] = headBrightness;
  
  // Exemple: Utiliser les mains pour contrôler des couleurs
  int redChannel = int(map(poseLeftHandX, 0, 1, 0, 255));
  int blueChannel = int(map(poseRightHandX, 0, 1, 0, 255));
  channel_value[1] = redChannel;
  channel_value[2] = blueChannel;
}
```

---

## 🔧 Troubleshooting

### Problème: "Impossible d'ouvrir la caméra"
- **Solution**: Vérifie que la caméra n'est pas utilisée par une autre application
- Pour webcam: Essaye un autre index: `--camera 1`
- Pour caméra IP: Vérifie l'URL et que le téléphone est sur le même réseau WiFi

### Problème: "Pas de détection de corps"
- Assure-toi d'être visible de la tête aux hanches au minimum
- Améliore l'éclairage de la pièce
- Éloigne-toi un peu de la caméra (2-3 mètres idéal)
- Porte des vêtements contrastés avec le fond

### Problème: "Processing ne reçoit pas les messages OSC"
- Vérifie que Processing écoute sur le bon port (7000 par défaut)
- Si le tracker est sur une autre machine, utilise `--osc-ip [IP de la machine Processing]`
- Vérifie le firewall

### Problème: "FPS très bas / lent"
- Réduis la résolution de la caméra
- Utilise `model_complexity=0` dans le code (mode lite)
- Ferme les autres applications gourmandes

### Problème: Installation de mediapipe échoue
Sur Windows, tu peux avoir besoin de **Visual C++ Redistributable**:
- Télécharge depuis: https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist

---

## 💡 Conseils d'utilisation

### Pour la meilleure détection:
1. **Éclairage uniforme** sans contre-jour
2. **Fond uni** (évite les motifs complexes)
3. **Distance caméra**: 2-3 mètres
4. **Vêtements**: Contrastés avec le fond
5. **Position**: Corps entier visible (au moins tête → hanches)

### Pour les performances:
- Ferme les applications non nécessaires
- Utilise une résolution de caméra modérée (720p suffisant)
- Si besoin, lance avec `--no-preview` pour économiser des ressources

---

## 🎯 Aller plus loin

### Ajouter d'autres points du corps

MediaPipe détecte **33 points** du corps. Tu peux facilement en ajouter d'autres!

Points intéressants:
- **11**: Épaule gauche
- **12**: Épaule droite
- **13**: Coude gauche
- **14**: Coude droit
- **23**: Hanche gauche
- **24**: Hanche droite
- **25**: Genou gauche
- **26**: Genou droit

Voir la [documentation MediaPipe](https://google.github.io/mediapipe/solutions/pose.html) pour tous les points.

### Modifier le code

Édite `pose_tracker.py` dans la fonction `extract_key_points()` pour ajouter tes propres points!

---

## 📚 Ressources

- [MediaPipe Pose Documentation](https://google.github.io/mediapipe/solutions/pose.html)
- [python-osc Documentation](https://pypi.org/project/python-osc/)
- [Processing OSC Library](http://www.sojamo.de/libraries/oscP5/)

---

## 🐛 Signaler un problème

Si tu rencontres un problème, n'hésite pas à demander de l'aide!

---

**Bon tracking! 🎉**
