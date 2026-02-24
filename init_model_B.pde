
LIGHT_AsteraTitan_RGB [] lights = new LIGHT_AsteraTitan_RGB[8];
Nuages nuages;


void init_model_B(){

	for(int i=0; i<lights.length; i++){
		lights[i] = new LIGHT_AsteraTitan_RGB(i*8 + 1, 16);
		println("init light : "+i*8 + 1);
	}

	nuages = new Nuages();

}

void draw_model_B(){
	
	// Astera Titan RGB lights
	//Arc en ciel
	/*
	for(int i=0; i<lights.length; i++){
		for(int j=0; j<16; j++){
			lights[i].setRGBW(j, 
				int((cos(t + i*0.5 + j*0.2) * 127) + 127), 
				int((cos(t + i*0.5 + j*0.2 + TWO_PI/3) * 127) + 127), 
				//int((cos(t + i*0.5 + j*0.2 + 2*TWO_PI/3) * 127) + 127),
				0, 
				0);
		}
		lights[i].draw(20, 80 + i * 40);
		channel_value = lights[i].mix(channel_value, i * 64);
	}
	*/



	nuages.open_mark();
	
	for(int i=0; i<lights.length; i++){
		for(int j=0; j<16; j++){
			
			int px = int(map(j, 0, 15, 0, nuages.pg.width-1));
			int py = int(map(i, 0, 7, 0, nuages.pg.height-1));

			color col = nuages.pg.get(
				px,
				py
			);

			nuages.mark(i+":"+j,px,py);
			
			lights[i].setRGB(j, 
				int(red(col)), 
				int(green(col)), 
				int(blue(col))
				);
		}
		lights[i].draw(20, 50 + i * 40);
		channel_value = lights[i].mix(channel_value, i * 64);
		lights[i].setWhiteAllWhite(0);
	}

	nuages.close_mark();

	// Exemple de contrôle de la valeur osc (décommenter pour tester avec la souris)
	// nuages.osc_value = map(mouseY, 0, height, 0, 1);
	
	nuages.draw(20, 380);
	nuages.draw_debug(20, 380);
}