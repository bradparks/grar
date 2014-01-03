package com.knowledgeplayers.grar.services;

import haxe.xml.Fast;
import com.knowledgeplayers.grar.factory.StructureParser;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import com.knowledgeplayers.grar.structure.KpGame;

class ModuleService {

	public function fetchModule(path:String):KpGame
	{
		var xml = AssetsStorage.getXml(path);
		return StructureParser.parse(new Fast(xml));
	}
}