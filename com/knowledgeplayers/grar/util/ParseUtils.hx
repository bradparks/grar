package com.knowledgeplayers.grar.util;

import haxe.ds.GenericStack;

using StringTools;

class ParseUtils {

	public static inline function parseHash(string: String): Map<String, String>
	{
		var content = new Map<String, String>();
		if(string.indexOf("{") == 0){
			var contentString:String = string.substr(1, string.length - 2);
			var contents = contentString.split(",");
			for(c in contents)
				content.set(c.split(":")[0].trim(), c.split(":")[1].trim());
		}
		else
			content.set(" ", string);

		return content;
	}

	public static inline function selectByAttribute(attr: String, value: String, xml: Xml): GenericStack<Xml>
	{
		var results = new GenericStack<Xml>();
		recursiveSelect(attr, value, xml, results);
		return results;
	}

	public static inline function parseListOfValues(list: String, separator: String = ","):Array<String>
	{
		var result = new Array<String>();
		for(elem in list.split(separator)){
			result.push(elem.trim());
		}
		return result;
	}

	public static inline function parseListOfIntValues(list: String, separator: String = ","):Array<Int>
	{
		var result = new Array<Int>();
		var list = parseListOfValues(list, separator);
		for(elem in list){
			result.push(Std.parseInt(elem));
		}
		return result;
	}

	public static inline function parseListOfFloatValues(list: String, separator: String = ","):Array<Float>
	{
		var result = new Array<Float>();
		var list = parseListOfValues(list, separator);
		for(elem in list){
			result.push(Std.parseFloat(elem));
		}
		return result;
	}

	public inline static function updateAttribute(attr:String, value:String, xmls:GenericStack<Xml>):Void
	{
		for(elem in xmls){
			if(value != null)
				elem.set(attr, value);
		}
	}

	public static function updateIconsXml(value:String, xmls:GenericStack<Xml>):Void
	{
		for(elem in xmls){
			if (value != null){
				if(value.indexOf(".") < 0){
					elem.set("tile", value);
					if(elem.exists("src"))
						elem.remove("src");
				}
				else{
					elem.set("src", value);
					if(elem.exists("tile"))
						elem.remove("tile");
				}
			}
		}
	}

	public static inline function formatToFour<A>(array:Array<A>):Array<A>
	{
		switch(array.length){
			case 1:
				while(array.length < 4)
					array.push(array[0]);
			case 2:
				array.push(array[0]);
				array.push(array[1]);
		}
		return array;
	}

	public static function parseColor(value: String): Color
	{
		if(value.length == 10)
			return {color: Std.parseInt("0x"+value.substr(4)), alpha: Std.parseInt(value.substr(2, 2))/10};
		else
			return {color: Std.parseInt(value), alpha: 1};
	}

	// Private

	private static inline function recursiveSelect(attr: String, value: String, xml: Xml, res: GenericStack<Xml>):Void
	{
		if(xml.get(attr) == value)
			res.add(xml);
		else{
			for(elem in xml.elements()){
				recursiveSelect(attr, value, elem, res);
			}
		}
	}
}

typedef Color = {
	var color: Int;
	var alpha: Float;
}
