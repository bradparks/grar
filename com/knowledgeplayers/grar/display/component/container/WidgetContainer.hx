package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.display.element.ChronoCircle;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import flash.display.Bitmap;
import aze.display.TileSprite;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.ParseUtils;
import flash.geom.Rectangle;
import haxe.ds.GenericStack;
import flash.display.Sprite;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import com.knowledgeplayers.grar.util.DisplayUtils;

/**
* Base for widget that can contain other widget
**/
class WidgetContainer extends Widget{

	/**
	* Background for the container. Could be an int or a src
	**/
	public var background (default, null):String;

	/**
	* Scale9Grid for the background
	**/
	public var grid9 (default, default):Rectangle;

	/**
	* Mask width
	**/
	public var maskWidth:Float;

	/**
	* Mask height
	**/
	public var maskHeight:Float;

	/**
	* Tilesheet for the container
	**/
	public var tilesheet (default, set_tilesheet):TilesheetEx;

	/**
	* Enable the scroll. True by default
	**/
	public var scrollable (default, default):Bool = true;

	/**
	* Content alpha
	**/
	public var contentAlpha (default, set_contentAlpha):Float;

	/**
	* Content transition
	**/
	public var contentTransition (default, default):String;

	/**
     * Content root
     */
	public var content (default, default):Sprite;

	/**
	* Children of this container
	**/
	public var children (default, default):Array<Widget>;

	public var zIndex: Int = 0;
	public var renderNeeded: Bool = false;

	private var scrollBarName: String;
	private var scrollBar:ScrollBar;
	private var scrollNeeded:Bool;
	private var layer: TileLayer;
	private var displays: Map<String, Widget>;
	private var buttonGroups: Map<String, GenericStack<DefaultButton>>;

	public function set_contentAlpha(alpha: Float):Float
	{
		return content.alpha = contentAlpha = alpha;
	}

	public function setBackground(bkg:String, ?color:Array<String>,?arrowX:Float,?arrowY:Float,?radius:Array<Float>,?line:Float,?colorLine:Int,?bubbleWidth:Float,?bubbleHeight:Float,?shadow:Float,?gap:Float,?bubbleX:Float,?bubbleY:Float, resize: Bool = false):String
	{
		if(bkg != null){
			if(Std.parseInt(bkg) != null){
				var bkgColor = ParseUtils.parseColor(bkg);
				DisplayUtils.initSprite(this, maskWidth, maskHeight, bkgColor.color, bkgColor.alpha);
			}
            else if(bkg == "bubble"){
				var colors = new Array<Int>();
				var alphas = new Array<Float>();
				for(i in 0...color.length){
					var c = ParseUtils.parseColor(color[i]);
					colors.push(c.color);
					alphas.push(c.alpha);
				}
				if(radius == null)
					radius = [0.0, 0.0, 0.0, 0.0];
				ParseUtils.formatToFour(radius);
                var bubble:SimpleBubble = new SimpleBubble(bubbleWidth!=0 ? bubbleWidth:maskWidth,bubbleHeight!=0 ? bubbleHeight:maskHeight,colors,arrowX,arrowY,radius,line,colorLine,shadow,gap,alphas,bubbleX,bubbleY);
                addChildAt(bubble,0);
            }
			else{
				if(grid9 != null){
					var bmpData: BitmapData;
					if(AssetsStorage.hasAsset(bkg))
						bmpData = AssetsStorage.getBitmapData(bkg);
					else
						bmpData = DisplayUtils.getBitmapDataFromLayer(layer.tilesheet, bkg);
					var background = new ScaleBitmap(bmpData);
					background.bitmapScale9Grid = grid9;
					background.setSize(maskWidth, maskHeight);
					background.alpha = alpha;
					addChildAt(background, 0);
				}
				else if(bkg.indexOf(".") < 0){
					var tile = new TileSprite(layer, bkg);
					tile.alpha = alpha;
					layer.addChild(tile);
					if(resize){
						tile.scaleX = maskWidth / tile.width;
						tile.scaleY = maskHeight / tile.height;
					}
					tile.x = tile.width / 2;
					tile.y = tile.height / 2;
					layer.render();
				}
				else if(AssetsStorage.hasAsset(bkg)){
					var bkg = new Bitmap(AssetsStorage.getBitmapData(bkg));
					bkg.alpha = alpha;
					addChildAt(bkg, 0);
				}
			}
		}

		return background = bkg;
	}

	public function set_tilesheet(tilesheet:TilesheetEx):TilesheetEx
	{
		if(layer == null)
			layer = new TileLayer(tilesheet);
		else
			layer.tilesheet = tilesheet;
		layer.render();
		return this.tilesheet = tilesheet;
	}

	/**
	* Empty the container
	**/
	public function clear()
	{
		removeChild(content);
		content = new Sprite();
		content.addChild(layer.view);
		content.mask = null;

		var max = (background != null && background != "") ? 1 : 0;
		while(numChildren > max)
			removeChildAt(numChildren - 1);
	}

	public function maskSprite(sprite: Sprite, maskWidth: Float = 1, maskHeight: Float = 1, maskX: Float = 0, maskY: Float = 0):Void
	{
		DisplayUtils.maskSprite(sprite, maskWidth, maskHeight, maskX, maskY);
	}

	override public function toString():String
	{
		return super.toString()+' $maskWidth x $maskHeight $background';
	}

	// Privates

	private function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
		super(xml);
		content = new Sprite();
		displays = new Map<String, Widget>();
		buttonGroups = new Map<String, GenericStack<DefaultButton>>();
		children = new Array<Widget>();

		addChild(content);
		if(xml != null){
			// Default tilesheet
			if(tilesheet != null)
				this.tilesheet = tilesheet;
			else
				this.tilesheet = UiFactory.tilesheet;

			contentAlpha = xml.has.contentAlpha ? Std.parseFloat(xml.att.contentAlpha) : 1;
			scrollBarName = xml.has.scrollBar ? xml.att.scrollBar : null;
			if(xml.has.contentTransition)
				contentTransition = xml.att.contentTransition;
			if(xml.has.scrollable)
				scrollable =  xml.att.scrollable == "true";
			else
				scrollable = false;

			if(xml.has.grid){
				var grid = new Array<Float>();
				for(number in xml.att.grid.split(","))
					grid.push(Std.parseFloat(number));
				grid9 = new Rectangle(grid[0], grid[1], grid[2], grid[3]);
			}
			for(child in xml.elements){
				createElement(child);
			}
			maskWidth = xml.has.width ? Std.parseFloat(xml.att.width) : width;
			maskHeight = xml.has.height ? Std.parseFloat(xml.att.height) : height;

			content.addChildAt(layer.view, 0);

			setBackground
			(
				xml.has.background ? xml.att.background:null,
				xml.has.color ? Std.string(xml.att.color).split(","):null,
				xml.has.arrowX ? Std.parseFloat(xml.att.arrowX):0,
				xml.has.arrowY ? Std.parseFloat(xml.att.arrowY):0,
				xml.has.radius ? ParseUtils.parseListOfFloatValues(xml.att.radius):null,
				xml.has.line ? Std.parseFloat(xml.att.line):0,
				xml.has.colorLine ? Std.parseInt(xml.att.colorLine):0xFFFFFF,
				xml.has.bubbleWidth ? Std.parseInt(xml.att.bubbleWidth):0,
				xml.has.bubbleHeight ? Std.parseInt(xml.att.bubbleHeight):0,
				xml.has.shadow ? Std.parseFloat(xml.att.shadow):0,
				xml.has.gap ? Std.parseFloat(xml.att.gap):5,
				xml.has.bubbleX ? Std.parseFloat(xml.att.bubbleX):0,
				xml.has.bubbleY ? Std.parseFloat(xml.att.bubbleY):0,
				xml.has.resize ? xml.att.resize == "true" : false
			);
		}
		addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		addEventListener(Event.ENTER_FRAME, checkRender);
	}

	private inline function scrollToRatio(position:Float)
	{
		content.y = -position * content.height;
	}

	private inline function moveCursor(delta:Float)
	{
		scrollBar.moveCursor(delta);
	}

	private function displayContent(trim: Bool = false):Void
	{
		maskSprite(content, (trim ? content.width:maskWidth), maskHeight);


		if(maskHeight < content.height && scrollable){
			if(parent != null)
				setScrollBar();
			else
				addEventListener(Event.ADDED_TO_STAGE, setScrollBar, 10);
		}
		else{
			scrollNeeded = false;
		}

        TweenManager.applyTransition(content, contentTransition);

		for(child in children){
            if(child.transformation != null){
                TweenManager.applyTransition(child, child.transformation);
            }
        }
	}

	private inline function setScrollBar(?e: Event):Void
	{
		var partDisplay = parent;

		while(!Std.is(partDisplay, KpDisplay)){
			partDisplay = partDisplay.parent;
		}
		if(scrollBarName == null){
			var keyArray = [];
			for (key in cast(partDisplay, KpDisplay).scrollBars.keys()) keyArray.push(key);
			scrollBarName = keyArray[0];
		}
		scrollBar = cast(partDisplay, KpDisplay).scrollBars.get(scrollBarName);


		scrollBar.setHeight(maskHeight);
		scrollBar.set_ratio(maskHeight / content.height);
		scrollBar.x = content.x + maskWidth;
		scrollBar.y = content.y;
		scrollBar.scrolled = scrollToRatio;
		scrollNeeded = true;

		addChild(scrollBar);
	}


	private inline function render():Void
	{
		layer.render();
	}

	public function createElement(elemNode:Fast):Widget
	{
		 return switch(elemNode.name.toLowerCase()){
			case "background" | "image": createImage(elemNode);
			case "button": createButton(elemNode);
			case "text": createText(elemNode);
            case "timer":createTimer(elemNode);
			case "include" :
				var tmpXml = Xml.parse(DisplayUtils.templates.get(elemNode.att.ref).toString()).firstElement();
				for(att in elemNode.x.attributes()){
					if(att != "ref")
						tmpXml.set(att, elemNode.x.get(att));
				}
				createElement(new Fast(tmpXml));
			 case "div":
				 var div = new SimpleContainer(elemNode);
				 addElement(div);
				 div;
			default: null;
		 }
	}

    private function createImage(itemNode:Fast):Widget
    {

        if(itemNode.has.src){
            var img:Image = new Image(itemNode);
            addElement(img);
			return img;
        }
        else{

            var tileImg:TileImage = new TileImage(itemNode, layer,true,true);
            addElement(tileImg);
	        return tileImg;
        }

    }

	private function createText(textNode: Fast):Widget
	{
		var text = new ScrollPanel(textNode);
		addElement(text);
        return text;
	}

    private function createTimer(timerNode: Fast):Widget
	{
        var timer = new ChronoCircle(timerNode);

		addElement(timer);

        return timer;
	}

	private function addElement(elem:Widget):Void
	{
		elem.zz = zIndex;
        displays.set(elem.ref,elem);

		content.addChild(elem);
		children.push(elem);
        zIndex++;
		dispatchEvent(new Event(Event.CHANGE));
	}

	private function createButton(buttonNode:Fast):Widget
	{
		var button:DefaultButton = new DefaultButton(buttonNode);

		if(buttonNode.has.action)
			setButtonAction(button, buttonNode.att.action);
		if(buttonNode.has.group){
			if(buttonGroups.exists(buttonNode.att.group.toLowerCase()))
				buttonGroups.get(buttonNode.att.group.toLowerCase()).add(button);
			else{
				var stack = new GenericStack<DefaultButton>();
				stack.add(button);
				buttonGroups.set(buttonNode.att.group.toLowerCase(), stack);
			}
		}
		button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
		addElement(button);
		return button;
	}

	private function setButtonAction(button:DefaultButton, action:String):Void
	{}

	// Handlers

	private function onWheel(e:MouseEvent):Void
	{
		if(scrollable){
			if(e.delta > 0 && content.y + e.delta > 0){
				content.y = 0;
			}
			else if(e.delta < 0 && content.y + e.delta < -(content.height - maskHeight)){
				content.y = -(content.height - maskHeight);
			}
			else{
				content.y += e.delta;
			}
			if(scrollBar != null)
				moveCursor(e.delta);
		}
	}

	private inline function checkRender(e:Event):Void
	{
		if(renderNeeded){
			render();
			renderNeeded = false;
		}
	}

	private function onButtonToggle(e:ButtonActionEvent):Void
	{
		var button = cast(e.target, DefaultButton);
		if(button.toggleState == "inactive" && button.group != null){
			for(b in buttonGroups.get(button.group)){
				if(b != button)
					b.toggle(true);
			}
		}
	}
}
