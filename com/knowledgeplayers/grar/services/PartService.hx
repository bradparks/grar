package com.knowledgeplayers.grar.services;

import com.knowledgeplayers.grar.factory.PartParser;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import haxe.xml.Fast;
import com.knowledgeplayers.utils.assets.AssetsStorage;

class PartService {

	public function fetchPart(path:String):StructurePart
	{
		var xml = AssetsStorage.getXml(path);
		return PartParser.parse(new Fast(xml));
	}
}