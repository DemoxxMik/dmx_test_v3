class LIGHT_RoorPar6_CH8 {
	
	int channel = 0;
	int dimmer = 255;
	//de 0 - 5 pas de strobe
	//de 5 a 255 > strobe
	int strobe = 0;
	
	int red = 0;
	int green = 0;
	int blue = 0;
	int white = 0;
	int amber = 0;
	int uv = 0;
	
	//display
	int px;
	int py;
	
	int[] data = new int[8];
	//--------------------------------
	//CONSTRUCTOR
	//--------------------------------
	LIGHT_RoorPar6_CH8(int channel) {
		this.channel = channel;
	}
	//--------------------------------
	//SETTER
	//--------------------------------
	void setDimmer(int v) {
		this.dimmer = v;
	}
	void setRGBW(int r, int g, int b, int w) {
		this.red = constrain(r, 0, 255);
		this.green = constrain(g, 0, 255);
		this.blue = constrain(b, 0, 255);
		this.white = constrain(w, 0, 255);
	}
	void setRGBWA(int r, int g, int b, int w, int a) {
		this.red = constrain(r, 0, 255);
		this.green = constrain(g, 0, 255);
		this.blue = constrain(b, 0, 255);
		this.white = constrain(w, 0, 255);
		this.amber = constrain(a, 0, 255);
	}
	void setAmber(int a) {
		this.amber = constrain(a, 0, 255);
	}
	void setUV(int u) {
		this.uv = constrain(u, 0, 255);
	}
	
	
	int[] getData() {
		data[0] = dimmer;
		data[1] = strobe;
		
		data[2] = red;
		data[3] = green;
		data[4] = blue;
		data[5] = white;
		
		data[6] = amber;
		data[7] = uv;
		
		return data;
	}
	
	int[] mix(int[] datas) {
		for (int i = 0; i < getData().length; i++) {
			datas[channel + i] = getData()[i];
		}
		return datas;
	}
	
	void draw(int px, int py) {
		this.px = px;
		this.py = py;
		this.draw();
	}
	
	void draw() {
		
		push();
		translate(px, py);
		stroke(255);
		
		fill(red, green, blue);
		rect(0, 0, 60, 20);
		
		fill(white);
		rect(0, 20, 60, 20);
		
		fill(amber, 0, 0);
		rect(0, 40, 60, 20);
		
		fill(0, 0, uv);
		rect(0, 60, 60, 20);
		
		pop();
	}
}
