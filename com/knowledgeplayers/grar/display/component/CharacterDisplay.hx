package com.knowledgeplayers.grar.display.component;

import haxe.xml.Fast;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.structure.part.dialog.Character;

/**
 * Graphic representation of a character of the game
 */
class CharacterDisplay extends TileImage {

	/**
    * Model of the character
    **/
	public var model:Character;

	/**
	* Reference to the panel where to display its name
	**/
	public var nameRef (default, default):String;

	public function new(?xml: Fast, layer:TileLayer, ?model:Character)
	{
		xml.x.remove("spritesheet");
		super(xml, layer, false);
		this.model = model;
	}

}