LIGHT_RoorPar6_CH8 light_A;
LIGHT_RoorPar6_CH8 light_B;
LIGHT_RoorPar6_CH8 light_C;
LIGHT_RoorPar6_CH8 light_D;


void init_modelA() {
	light_A = new LIGHT_RoorPar6_CH8(1);
	light_B = new LIGHT_RoorPar6_CH8(9);
	light_C = new LIGHT_RoorPar6_CH8(17);
	light_D = new LIGHT_RoorPar6_CH8(25);
}

void draw_modelA() {
	//light_A.setRGBW(0, int(mouseX), 0, 0);
	light_A.setRGBW(int((cos(t) * 127) + 127), 0, 0, 0);
	light_B.setRGBW(0, int((cos(t) * 127) + 127), 0, 0);
	light_C.setRGBW(0, 0, int((cos(t) * 127) + 127), 0);
	light_D.setRGBW(0, 0, 0, int((sin(t) * 127) + 127));
	
	
	/*
	light_A.setRGBW(0,0,0,0);
	light_B.setRGBW(0,0,0,0);
	light_C.setRGBW(0,0,0,0);
	light_D.setRGBW(0,0,0,0);
	
	light_A.setUV(mouseX);
	light_B.setUV(mouseX);
	light_C.setUV(mouseX);
	light_D.setUV(mouseX);
	
	light_A.setAmber(255-mouseX);
	light_B.setAmber(255-mouseX);
	light_C.setAmber(255-mouseX);
	light_D.setAmber(255-mouseX);
	*/
	
	light_A.draw(20,80);
	light_B.draw(120,80);
	light_C.draw(220,80);
	light_D.draw(320,80);

	channel_value = light_A.mix(channel_value);
	channel_value = light_B.mix(channel_value);
	channel_value = light_C.mix(channel_value);
	channel_value = light_D.mix(channel_value);
}