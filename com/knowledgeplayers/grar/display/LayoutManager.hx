package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.grar.display.layout.Layout;
import com.knowledgeplayers.grar.localisation.Localiser;
import haxe.xml.Fast;

class LayoutManager{

	/**
	* Localisation file for the interface
	**/
	public var interfaceLocale (default, default):String;

	private var layoutNode:Fast;

	private var layouts:Map<String, Layout>;

	/**
    * Layout Display
    **/

	public function new():Void
	{
		super();
		layouts = new Map<String, Layout>();
	}

	/**
	* @return the layout with the given ref
	**/

	public function getLayout(ref:String):Layout
	{
		return layouts.get(ref);
	}

	/**
	* Parsing du Xml
	**/

	public function parseXml(xml:Xml):Void
	{

		var fastXml = new Fast(xml);
		layoutNode = fastXml.node.Layouts;
		loadInterfaceXml(layoutNode);
	}

	public function loadInterfaceXml(_xml:Fast):Void
	{
		if(_xml.has.text){
			interfaceLocale = _xml.att.text;
			Localiser.instance.layoutPath = interfaceLocale;
		}

		for(lay in layoutNode.elements){

			var layout:Layout = new Layout(lay);

			layouts.set(layout.name, layout);
		}
		onLoaded();
	}

	dynamic public function onLoaded():Void {}
}
