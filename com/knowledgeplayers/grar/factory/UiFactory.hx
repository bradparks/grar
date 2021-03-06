package com.knowledgeplayers.grar.factory;

import flash.geom.Matrix;
import flash.display.BitmapData;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
#if !flash
	import openfl.Assets;
#end

/**
 * Factory to create UI components
 */

class UiFactory {

	/**
    * Tilesheet containing UI elements
    **/
	public static var tilesheet (default, null):TilesheetEx;
	private static var layerPath:String;

	private function new()
	{}

	/**
    * Create a tilesprite from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a tilesprite
    **/

	public static function addImageToLayer(xml:Fast, layer: TileLayer, visible:Bool = true): Void
	{
		var itemTile = new TileSprite(layer, xml.att.tile);
		if(xml.has.x)
			itemTile.x = Std.parseFloat(xml.att.x);
		if(xml.has.y)
			itemTile.y = Std.parseFloat(xml.att.y);
		if(xml.has.scale)
			itemTile.scale = Std.parseFloat(xml.att.scale);
		if(xml.has.mirror){
			itemTile.mirror = switch(xml.att.mirror.toLowerCase()){
				case "horizontal": 1;
				case "vertical": 2;
				case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
			}
		}

		itemTile.visible = visible;
		layer.addChild(itemTile);
		layer.render();
	}

	/**
     * Set the spritesheet file containing all the UI images
     * @param	id : ID of the Spritesheet in the assets
     */

	public static function setSpriteSheet(id:String):Void
	{
		tilesheet = AssetsStorage.getSpritesheet(id);
	}

	private static function flipBitmapData(original:BitmapData, axis:String = "x"):BitmapData
	{
		var flipped:BitmapData = new BitmapData(original.width, original.height, true, 0);
		var matrix:Matrix;
		if(axis == "x"){
			matrix = new Matrix( - 1, 0, 0, 1, original.width, 0);
		} else {
			matrix = new Matrix( 1, 0, 0, - 1, 0, original.height);
		}
			flipped.draw(original, matrix, null, null, null, true);
		return flipped;
	}


}