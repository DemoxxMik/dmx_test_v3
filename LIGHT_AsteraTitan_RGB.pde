class LIGHT_AsteraTitan_RGB{
	Led [] led;
	int px;
	int py;

	LIGHT_AsteraTitan_RGB(int channel, int numLed){
		led = new Led[numLed];
		for(int i=0; i<numLed; i++){
			led[i] =  new Led(0,0,0,0);
		}
	}
	void setRGBW(int index, int r, int g, int b, int w){
		led[index].setColor_RGBW(r, g, b, w);
	}
	void setRGB(int index, int r, int g, int b){
		led[index].setColor_RGB(r, g, b);
	}
	void setWhite(int index, int w){
		led[index].setColor_White(w);
	}
	 void setWhiteAllWhite(int w){
		for(int i=0; i<led.length; i++){
			led[i].setColor_White(w);
		}
	}

	int[] getData(){
		int[] data = new int[led.length * 4];
		for(int i=0; i<led.length; i++){
			int[] _color = led[i].getColor_RGBW();
			data[i*4] = _color[0];
			data[i*4 + 1] = _color[1];
			data[i*4 + 2] = _color[2];
			data[i*4 + 3] = _color[3];
		}
		return data;
	}
	
	int[] mix(int[] datas, int startChannel){
		int[] ledData = getData();
		for(int i=0; i<ledData.length; i++){
			datas[startChannel + i] = ledData[i];
		}
		return datas;
	}

	void draw(int px, int py){
		this.px = px;
		this.py = py;
		this.draw();
	}

	void draw(){
		int ledSize = 20;
		for(int i=0; i<led.length; i++){
			fill(led[i].red, led[i].green, led[i].blue);
			rect(px + i * (ledSize + 5), py, ledSize, ledSize);
			fill(led[i].white);
			ellipse(px + i * (ledSize + 5) + ledSize/2, py + ledSize + 10, ledSize/2, ledSize/2);
		}
	}
}