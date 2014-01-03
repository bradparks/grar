package com.knowledgeplayers.grar;

import com.knowledgeplayers.grar.controller.GameManager;

class Main {

	/**
	* Passer des paramètres d'entrée (Flash vars,...)
	**/
	public static function main()
	{

		#if ios
		Lib.current.stage.addEventListener(Event.RESIZE, function(e: Event){
			new Main();
		});
	#else
		new Main();
		#end

	}

	public function new()
	{
		// Create main controller
		var controller = new GameManager();

		// Initialize model
		controller.init();
	}
}

// TODO
// Exposer une API ?
// ModelConfig.hx pour garder la config initiale


