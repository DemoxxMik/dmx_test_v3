class Led{

	int red;
	int green;
	int blue;
	int white;

	Led(int r, int g, int b, int w){
		red = r;
		green = g;
		blue = b;
		white = w;
	}

	void setColor_RGBW(int r, int g, int b, int w){
		red = r;
		green = g;
		blue = b;
		white = w;
	}
	void setColor_RGB(int r, int g, int b){
		red = r;
		green = g;
		blue = b;
	}
	void setColor_White(int w){
		white = w;
	}

	int[] getColor_RGBW(){
		int[] _color = {red, green, blue, white};
		return _color;
	}

	int [] getRGB(){
		int[] rgb = {red, green, blue};
		return rgb;
	}
}