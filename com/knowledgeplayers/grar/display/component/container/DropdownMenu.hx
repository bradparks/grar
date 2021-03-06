package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.util.ParseUtils;
import flash.geom.Point;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import haxe.ds.GenericStack;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * Drop down menu component
 */
class DropdownMenu extends WidgetContainer {

	public var items (default, default):GenericStack<String>;
	public var currentLabel (default, set_currentLabel):String;

	private var list:Sprite;
	private var labelSprite:Sprite;
	private var sprites:Map<String, Sprite>;
	private var blank:Bool;
	private var color:String;

	public function new(?xml: Fast, blankItem = false)
	{
		super(xml);
		blank = blankItem;
		buttonMode = true;
		items = new GenericStack<String>();
		sprites = new Map<String, Sprite>();
		list = new Sprite();
		labelSprite = new Sprite();
		list.visible = false;
		addEventListener(Event.ADDED_TO_STAGE, onAdd);
		addEventListener(MouseEvent.CLICK, onClick);

        if (xml.has.color){
              color = xml.att.color;
        }
        else{
              color = "0x02000000";
        }
	}

	/**
     * Add an item at the top of the menu
     * @param	item : Item to add
     */

	public function addItem(item:String):Void
	{
		items.add(item);
	}

	// Private

	private function set_currentLabel(label:String):String
	{
		currentLabel = label;
		if(labelSprite.numChildren > 0)
			labelSprite.removeChildAt(0);
		labelSprite.addChild(KpTextDownParser.parse(label)[0].createSprite(maskWidth));
		dispatchEvent(new Event(Event.CHANGE));
		return label;
	}

	public function onAdd(e:Event):Void
	{
		var yOffset:Float = 0;
		for(item in items){
			if(item != null){
				var sprite = KpTextDownParser.parse(item)[0].createSprite(maskWidth);
				sprite.buttonMode = true;
				sprite.y = yOffset;
				yOffset += sprite.height;
				sprite.addEventListener(MouseEvent.CLICK, onItemClick);
				list.addChild(sprite);
				sprites.set(item, sprite);
			}
		}
		if(localToGlobal(new Point(0, 0)).y+list.height > stage.stageHeight)
			list.y = y - list.height;

        list.visible = false;

		if(!blank)
			set_currentLabel(items.first());
		else{
			labelSprite.graphics.beginFill(ParseUtils.parseColor(color).color, ParseUtils.parseColor(color).alpha);
			labelSprite.graphics.drawRect(0, 0, list.getChildAt(0).width, list.getChildAt(0).height);
			labelSprite.graphics.endFill();

		}
		addChild(labelSprite);

		addChild(list);


	}

	private function onItemClick(e:MouseEvent):Void
	{
		for(label in sprites.keys()){
			if(e.currentTarget == sprites.get(label))
				set_currentLabel(label);
		}
		list.visible = false;
		labelSprite.visible = true;
		e.stopImmediatePropagation();
		addEventListener(MouseEvent.CLICK, onClick);
	}

	private function onClick(e:MouseEvent):Void
	{
		labelSprite.visible = false;
		list.visible = true;
		removeEventListener(MouseEvent.CLICK, onClick);
	}
}