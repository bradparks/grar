package com.knowledgeplayers.grar.structure.part;

import haxe.ds.GenericStack;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.factory.ItemFactory;
import haxe.xml.Fast;

class Pattern implements PartElement {
	/**
	* @inherits
	**/
	public var id (default, null):String;
	/**
     * Array of item composing the pattern
     */
	public var patternContent (default, default):Array<Item>;

	/**
	* @inheritDoc
	**/
	public var ref (default, default):String;

	/**
    * Id of the next pattern
**/
	public var nextPattern (default, default):String;

	/**
    * Buttons for this pattern
**/
	public var buttons (default, null):Map<String, Map<String, String>>;

	/**
    * Implements PartElement.
    **/
	public var tokens (default, null):GenericStack<String>;

	public var endScreen (default, null):Bool = false;

	/**
    * Current item index
**/
	private var itemIndex: Int;

	/**
    * Constructor
    * @param name : Name of the pattern
**/
	public function new(name:String)
	{
		this.id = name;
		patternContent = new Array<Item>();
		buttons = new Map<String, Map<String, String>>();
		tokens = new GenericStack<String>();
		restart();
	}

	/**
     * Init the pattern with an XML node
     * @param	xml : fast xml node with structure infos
     */

	public function init(xml:Fast):Void
	{
		for(itemNode in xml.nodes.Text){
			var item:Item = ItemFactory.createItemFromXml(itemNode);
			patternContent.push(item);

		}
		for(child in xml.elements){
			if(child.name.toLowerCase() == "button" || child.name.toLowerCase() == "choice"){
				if(child.has.content)
					buttons.set(child.att.ref, ParseUtils.parseHash(child.att.content));
				else
					buttons.set(child.att.ref, new Map<String, String>());
			}
		}
		nextPattern = xml.att.next;
	}

	/**
     * @return the next item in the pattern, or null if the pattern reachs its end
     */

	public function getNextItem():Null<Item>
	{
		if(itemIndex < patternContent.length){
			itemIndex++;
			return patternContent[itemIndex - 1];
		}
		else{
			restart();
			return null;
		}
	}

	/**
    * Restart a pattern
**/

	public inline function restart():Void
	{
		itemIndex = 0;
	}

	/**
    * @return whether this pattern has choice or not
**/

	public function hasChoices():Bool
	{
		return false;
	}

	// PartElement implementation

	/**
    * @return false
**/

	public function isActivity():Bool
	{
		return false;
	}

	/**
    * @return false
**/

	public function isText():Bool
	{
		return false;
	}

	/**
    * @return true
**/

	public function isPattern():Bool
	{
		return true;
	}

	/**
    * @return false
**/

	public function isPart():Bool
	{
		return false;
	}

	/**
    * @return false
**/

	public function isVideo():Bool
	{
		return false;
	}

	/**
    * @return false
**/

	public function isSound():Bool
	{
		return false;
	}
}