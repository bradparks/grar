package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.part.Item;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import haxe.xml.Fast;

class PartParser {

	public static function parse(xml:Fast):StructurePart
	{
		var part = new StructurePart();

		if(xml.has.name) part.name = xml.att.name;
		if(xml.has.file) part.file = xml.att.file;
		if(xml.has.display) part.display = xml.att.display;
		if(xml.has.next) part.next = xml.att.next;
		if(xml.has.bounty) part.setPerks(xml.att.bounty);
		if(xml.has.requires) part.setPerks(xml.att.requires, part.requirements);

		for(child in xml.elements){
			switch(xml.name.toLowerCase()){
				case "text":
					part.elements.push(ItemFactory.createItemFromXml(xml));
				case "part":
					part.createPart(xml);
				case "sound":
					part.soundLoop = xml.att.content;
				case "button":
					var content = null;
					if(xml.has.content)
						content = ParseUtils.parseHash(xml.att.content);
					part.buttons.set(xml.att.ref, content);
					if(xml.has.goTo){
						if(xml.att.goTo == "")
							part.buttonTargets.set(xml.att.ref, null);
						else{
							var i = 0;
							while((part.elements[i] != ElementType.TEXT || cast(elements[i], TextItem).content != xml.att.goTo) && i < elements.length){
								i++;
							}
							if(i != elements.length)
								buttonTargets.set(xml.att.ref, elements[i]);
						}
					}
			}
		}

		completeElements(part.textElements, part);
		completeElements(part.videoElements, part);
		completeElements(part.soundElements, part);

		for(elem in elements){
			if(elem.isPattern()){
				for(item in cast(elem, Pattern).patternContent){
					for(image in item.tokens)
						tokens.add(image);
				}
			}
		}
	}

	private static function parseElement(xml:Fast):Void
	{

	}

	/**
	* Common attributes between xml tag and part file
	**/
	private static function parseHeader(xml: Fast): Void
	{
	}

	private static function completeElements(collection: Array<Item>, part: StructurePart):Void
	{
		for(item in collection){
			if(item.button == null || Lambda.empty(item.button))
				item.button = part.buttons;
			for(token in item.tokens)
				part.tokens.add(token);
		}
	}
}