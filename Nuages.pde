class Nuages {

  PGraphics pg;
  PGraphics debug;

  float x = 0;
  float y = 0;

  float rect_y = 0;

  // Valeur OSC pour contrôler la luminosité du fond (0.0 = Blanc, 1.0 = Noir)
  float osc_value = 0.0;
  float w = 0.0;
  float envelope = 0.0;
  float peak = 1;

  int oscPortRef = -1;


  Nuages() {
    pg = createGraphics(400, 400);
    pg.beginDraw();
    pg.background(255); // Commence en blanc
    pg.endDraw();

    debug = createGraphics(pg.width, pg.height);
    debug.beginDraw();
    debug.background(0);
    debug.fill(255);
    debug.endDraw();
  }

  void draw(int px, int py) {

    pg.beginDraw();

    w = (osc_value);

    float amp = w*w;

    float attack = 0.05;
    float release = 0.05;
    float peakFalloff = 0.995;

    if (amp > envelope) {
      envelope = lerp(envelope, amp, attack);
    } else {
      envelope = lerp(envelope, amp, release);
    }

    if (envelope > peak) {
      peak = envelope;
    } else {
      peak *= peakFalloff;
    }

    float normalized = envelope / peak;

    normalized = constrain(normalized, 0, 1);
    //normalized = pow(normalized, 1.5);


    float test = map(normalized, 0, 1, 30, 255);
    println("valeur = " + normalized );
    // couleur fixe et interpolation selon w
    color base = color(0, 0, 0); // R,G,B fixe
    color bg = lerpColor(color(test, test, test), base, 0); // 0 = noir, 1 = base
    pg.background(bg);
    //print(test);
    pg.noStroke();

    // afficher le port en debug sur le PGraphics
    pg.fill(255);
    //pg.text("OSC port: " + oscPortRef, 10, 14);

    pg.fill(0, 255, 255);
    pg.rect(mouseX, mouseY, 30, 30);


    pg.endDraw();

    image(pg, px, py);
  }



  void open_mark() {
    debug.beginDraw();
    debug.clear();
  }
  void close_mark() {
    debug.endDraw();
  }
  void mark(String label, int px, int py) {
    debug.fill(255, 255, 0);
    debug.text(label, px, py);
    debug.noStroke();
    debug.ellipse(px, py, 3, 3);
  }
  void draw_debug(int px, int py) {
    image(debug, px, py);
  }
}
