#!/usr/bin/env python3
"""
Body Pose Tracker with OSC Output
Détecte les mouvements corporels en temps réel et envoie les positions via OSC
"""

import cv2
import mediapipe as mp
import argparse
from pythonosc import udp_client
from pythonosc.osc_message_builder import OscMessageBuilder
import time

class PoseTracker:
    def __init__(self, camera_index=0, camera_url=None, osc_ip="127.0.0.1", osc_port=7000, show_preview=True):
        """
        Initialise le tracker de pose
        
        Args:
            camera_index: Index de la caméra (0 pour webcam par défaut)
            camera_url: URL de la caméra IP (ex: "http://192.168.1.100:4747/video")
            osc_ip: Adresse IP de destination OSC
            osc_port: Port OSC de destination
            show_preview: Afficher la fenêtre de prévisualisation
        """
        # MediaPipe 0.10.8 (stable version with solutions API)
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles
        
        # Configuration de la détection de pose
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
            model_complexity=1  # 0=lite, 1=full, 2=heavy
        )
        
        # Configuration de la caméra
        if camera_url:
            self.cap = cv2.VideoCapture(camera_url)
            print(f"📱 Connexion à la caméra IP: {camera_url}")
        else:
            self.cap = cv2.VideoCapture(camera_index)
            print(f"📷 Utilisation de la webcam (index {camera_index})")
        
        if not self.cap.isOpened():
            raise RuntimeError("❌ Impossible d'ouvrir la caméra!")
        
        # Configuration OSC
        self.osc_client = udp_client.SimpleUDPClient(osc_ip, osc_port)
        print(f"🎵 OSC configuré: {osc_ip}:{osc_port}")
        
        self.show_preview = show_preview
        
        # Variables pour les positions
        self.head_x = 0.5
        self.head_y = 0.5
        self.left_hand_x = 0.5
        self.left_hand_y = 0.5
        self.right_hand_x = 0.5
        self.right_hand_y = 0.5
        
        # FPS tracking
        self.prev_time = 0
        
    def extract_key_points(self, landmarks):
        """
        Extrait les points clés du corps
        MediaPipe Pose landmarks: https://google.github.io/mediapipe/solutions/pose.html
        
        Points utilisés:
        - 0: Nez (tête)
        - 15: Poignet gauche
        - 16: Poignet droit
        """
        if landmarks:
            # Tête (nose)
            nose = landmarks[self.mp_pose.PoseLandmark.NOSE.value]
            self.head_x = nose.x
            self.head_y = nose.y
            
            # Main gauche (left wrist)
            left_wrist = landmarks[self.mp_pose.PoseLandmark.LEFT_WRIST.value]
            self.left_hand_x = left_wrist.x
            self.left_hand_y = left_wrist.y
            
            # Main droite (right wrist)
            right_wrist = landmarks[self.mp_pose.PoseLandmark.RIGHT_WRIST.value]
            self.right_hand_x = right_wrist.x
            self.right_hand_y = right_wrist.y
            
            return True
        return False
    
    def send_osc(self):
        """Envoie les positions via OSC"""
        try:
            # Tête
            self.osc_client.send_message("/pose/head/x", self.head_x)
            self.osc_client.send_message("/pose/head/y", self.head_y)
            
            # Main gauche
            self.osc_client.send_message("/pose/lefthand/x", self.left_hand_x)
            self.osc_client.send_message("/pose/lefthand/y", self.left_hand_y)
            
            # Main droite
            self.osc_client.send_message("/pose/righthand/x", self.right_hand_x)
            self.osc_client.send_message("/pose/righthand/y", self.right_hand_y)
        except Exception as e:
            print(f"⚠️ Erreur OSC: {e}")
    
    def draw_info(self, image, fps):
        """Dessine les informations sur l'image"""
        h, w, _ = image.shape
        
        # Background semi-transparent pour le texte
        overlay = image.copy()
        cv2.rectangle(overlay, (0, 0), (400, 180), (0, 0, 0), -1)
        cv2.addWeighted(overlay, 0.6, image, 0.4, 0, image)
        
        # Informations
        y_offset = 25
        cv2.putText(image, f"FPS: {fps:.1f}", (10, y_offset), 
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
        
        y_offset += 25
        cv2.putText(image, f"Head:  X={self.head_x:.3f} Y={self.head_y:.3f}", 
                    (10, y_offset), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        y_offset += 25
        cv2.putText(image, f"L-Hand: X={self.left_hand_x:.3f} Y={self.left_hand_y:.3f}", 
                    (10, y_offset), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        y_offset += 25
        cv2.putText(image, f"R-Hand: X={self.right_hand_x:.3f} Y={self.right_hand_y:.3f}", 
                    (10, y_offset), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        y_offset += 35
        cv2.putText(image, "Press 'Q' to quit", (10, y_offset), 
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (100, 200, 255), 1)
        
        y_offset += 25
        cv2.putText(image, "Press 'H' to toggle help", (10, y_offset), 
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (100, 200, 255), 1)
    
    def run(self):
        """Boucle principale de détection"""
        print("\n🚀 Démarrage du tracker de pose...")
        print("📊 Envoi OSC actif")
        print("👁️  Fenêtre de prévisualisation:", "Activée" if self.show_preview else "Désactivée")
        print("\n💡 Conseils:")
        print("   - Place-toi à environ 2-3 mètres de la caméra")
        print("   - Assure-toi d'avoir un bon éclairage")
        print("   - Porte des vêtements contrastés avec le fond")
        print("\n" + "="*50 + "\n")
        
        show_help = False
        
        try:
            while self.cap.isOpened():
                success, image = self.cap.read()
                if not success:
                    print("⚠️ Échec de lecture de la caméra")
                    continue
                
                # Calculer FPS
                current_time = time.time()
                fps = 1 / (current_time - self.prev_time) if self.prev_time > 0 else 0
                self.prev_time = current_time
                
                # Flip horizontal pour effet miroir
                image = cv2.flip(image, 1)
                
                # Convertir BGR vers RGB
                image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
                image_rgb.flags.writeable = False
                
                # Détection de pose
                results = self.pose.process(image_rgb)
                
                # Dessiner sur l'image
                image_rgb.flags.writeable = True
                image = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2BGR)
                
                if results.pose_landmarks:
                    # Extraire les points clés
                    self.extract_key_points(results.pose_landmarks.landmark)
                    
                    # Envoyer via OSC
                    self.send_osc()
                    
                    # Dessiner le squelette
                    if self.show_preview:
                        self.mp_drawing.draw_landmarks(
                            image,
                            results.pose_landmarks,
                            self.mp_pose.POSE_CONNECTIONS,
                            landmark_drawing_spec=self.mp_drawing_styles.get_default_pose_landmarks_style()
                        )
                
                # Afficher les informations
                if self.show_preview:
                    self.draw_info(image, fps)
                    
                    if show_help:
                        self.draw_help(image)
                    
                    cv2.imshow('Body Pose Tracker - OSC', image)
                    
                    key = cv2.waitKey(1) & 0xFF
                    if key == ord('q'):
                        print("\n👋 Arrêt du tracker...")
                        break
                    elif key == ord('h'):
                        show_help = not show_help
        
        finally:
            self.cap.release()
            cv2.destroyAllWindows()
            self.pose.close()
            print("✅ Tracker arrêté proprement")
    
    def draw_help(self, image):
        """Affiche l'aide sur l'image"""
        h, w, _ = image.shape
        
        help_text = [
            "=== POINTS DETECTES ===",
            "Tete: Nez (landmark 0)",
            "Main gauche: Poignet gauche (15)",
            "Main droite: Poignet droit (16)",
            "",
            "=== MESSAGES OSC ===",
            "/pose/head/x",
            "/pose/head/y",
            "/pose/lefthand/x",
            "/pose/lefthand/y",
            "/pose/righthand/x",
            "/pose/righthand/y",
            "",
            "Coordonnees: 0.0 - 1.0",
        ]
        
        x_start = w - 350
        y_start = 30
        
        overlay = image.copy()
        cv2.rectangle(overlay, (x_start - 10, y_start - 20), 
                     (w - 10, y_start + len(help_text) * 20 + 10), (0, 0, 0), -1)
        cv2.addWeighted(overlay, 0.7, image, 0.3, 0, image)
        
        for i, line in enumerate(help_text):
            cv2.putText(image, line, (x_start, y_start + i * 20), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1)


def main():
    parser = argparse.ArgumentParser(description='Body Pose Tracker with OSC Output')
    parser.add_argument('--camera', type=int, default=0, 
                       help='Index de la caméra (0 par défaut)')
    parser.add_argument('--camera-url', type=str, default=None,
                       help='URL de la caméra IP (ex: http://192.168.1.100:4747/video)')
    parser.add_argument('--osc-ip', type=str, default='127.0.0.1',
                       help='Adresse IP OSC de destination (127.0.0.1 par défaut)')
    parser.add_argument('--osc-port', type=int, default=7000,
                       help='Port OSC de destination (7000 par défaut)')
    parser.add_argument('--no-preview', action='store_true',
                       help='Désactiver la fenêtre de prévisualisation')
    
    args = parser.parse_args()
    
    print(r"""
    ╔═══════════════════════════════════════════╗
    ║   BODY POSE TRACKER - OSC OUTPUT         ║
    ║   Détection corporelle en temps réel     ║
    ╚═══════════════════════════════════════════╝
    """)
    
    try:
        tracker = PoseTracker(
            camera_index=args.camera,
            camera_url=args.camera_url,
            osc_ip=args.osc_ip,
            osc_port=args.osc_port,
            show_preview=not args.no_preview
        )
        tracker.run()
    except KeyboardInterrupt:
        print("\n\n⏹️  Interruption par l'utilisateur")
    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
