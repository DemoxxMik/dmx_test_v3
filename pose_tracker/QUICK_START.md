# Quick Start Guide - Pose Tracker

## Installation Rapide

1. **Ouvrir un terminal** dans le dossier `pose_tracker`:
```bash
cd d:\Boulot\Workshop\Faust\test_dmx\dmx_test_v3\pose_tracker
```

2. **Installer les dépendances**:
```bash
pip install -r requirements.txt
```

3. **Lancer le tracker**:
```bash
python pose_tracker.py
```

Une fenêtre devrait s'ouvrir montrant ta webcam avec détection du squelette!

---

## Test avec Processing

### Option 1: Tester avec l'exemple fourni

1. Ouvrir `pose_receiver_example.pde` dans Processing
2. Appuyer sur ▶️ Run
3. Lancer `pose_tracker.py` en parallèle
4. Bouger devant la caméra et voir les points se déplacer!

### Option 2: Intégrer dans ton projet existant

Voir le fichier `INTEGRATION_GUIDE.pde` pour les instructions détaillées.

---

## Utilisation avec la caméra du téléphone

### Si tu veux utiliser ton téléphone:

1. **Télécharger DroidCam** (ou IP Webcam)
2. **Lancer l'app** sur ton téléphone
3. **Noter l'URL** affichée (ex: `http://192.168.1.100:4747/video`)
4. **Lancer avec**:
```bash
python pose_tracker.py --camera-url http://192.168.1.100:4747/video
```

---

## Raccourcis Clavier (dans la fenêtre de prévisualisation)

- **Q** : Quitter
- **H** : Afficher/Masquer l'aide

---

## Dépannage Rapide

**❌ "Impossible d'ouvrir la caméra"**
- Ferme les autres apps qui utilisent la caméra (Zoom, Teams, etc.)

**❌ "Processing ne reçoit rien"**
- Vérifie que Processing écoute sur le port 7000
- Vérifie que les deux programmes tournent en même temps

**❌ "Pas de squelette détecté"**
- Éloigne-toi un peu de la caméra (2-3m idéal)
- Améliore l'éclairage
- Assure-toi que ton corps est visible (au moins tête → hanches)

---

Pour plus de détails, voir `README.md`
