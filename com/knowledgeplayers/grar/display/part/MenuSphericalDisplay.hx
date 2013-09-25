package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.localisation.Localiser;
import flash.display.DisplayObject;
import com.knowledgeplayers.grar.util.MathUtils;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import haxe.ds.GenericStack;
import com.knowledgeplayers.grar.util.Curve;
import flash.geom.Point;
import haxe.xml.Fast;

using com.knowledgeplayers.grar.util.MathUtils;

/**
 * Display of a spherical menu
 */
class MenuSphericalDisplay extends MenuDisplay {

	public static var instance(get_instance, null): MenuSphericalDisplay;

	private var curves: Map<DisplayObject, Curve>;
	private var originCurve: Curve;

	public static function get_instance():MenuSphericalDisplay
	{
		if(instance == null)
			instance = new MenuSphericalDisplay();
		return instance;
	}

	private function new()
	{
		super();
		curves = new Map<DisplayObject, Curve>();
	}

	override public function init():Void
	{
		levelDisplays = new Map<String, Fast>();
		var regEx = ~/h[0-9]+|hr|item/i;
		for(child in displayFast.elements){
			if(regEx.match(child.name))
				levelDisplays.set(child.name, child);
		}

		for(child in displayFast.elements){
			createElement(child);
		}

		var menuXml = GameManager.instance.game.menu;

		createMenuLevel(menuXml.firstElement().firstElement());
	}

	override private function createMenuLevel(level:Xml):Void
	{
		if(!levelDisplays.exists(level.nodeName))
			throw "Display not specified for tag " + level.nodeName;

		var fast:Fast = levelDisplays.get(level.nodeName);

		var curve: Curve = null;
		if(level.nodeName == "hr"){
			addLine(fast);
		}
		else{
			var tree = new XmlTree(GameManager.instance.game.menu);
			var i = 0;
			var nodes = tree.getDepth(i);
			Localiser.instance.pushLocale();
			Localiser.instance.layoutPath = LayoutManager.instance.interfaceLocale;
			while(!nodes.isEmpty()){
				for(level in nodes)
					createSphericLevel(level);
				nodes = tree.getDepth(++i);
			}
			Localiser.instance.popLocale();
		}

		GameManager.instance.menuLoaded = true;
	}

	private function createSphericLevel(level:TreeNode<Xml>):Void
	{
		var fast:Fast = levelDisplays.get(level.value.nodeName);
		var button = addButton(fast.node.Button, GameManager.instance.getItemName(level.value.get("id")));
		buttons.set(level.value.get("id"), button);
		var curve: Curve;
		var parent: DisplayObject = buttons.get(level.parent.value.get("id"));
		if(curves.exists(buttons.get(level.parent.value.get("id")))){
			curve = curves.get(buttons.get(level.parent.value.get("id")));
		}
		else if(originCurve == null && parent == null){
				var x = fast.has.x ? Std.parseFloat(fast.att.x) : 0;
				var y = fast.has.y ? Std.parseFloat(fast.att.y) : 0;
				originCurve = new Curve(new Point(x, y), Std.parseFloat(fast.att.radius));
				curve = originCurve;
				if(fast.has.minAngle) originCurve.minAngle = Std.parseFloat(fast.att.minAngle);
				if(fast.has.maxAngle) originCurve.maxAngle = Std.parseFloat(fast.att.maxAngle);
		}
		else if(parent == null)
			curve = originCurve;
		else{
			curve = new Curve(new Point(parent.x, parent.y), Std.parseFloat(fast.att.radius));
			var angle: Float = -1;
			for(c in curves){
				if(c.contains(parent))
					angle = c.getAngle(parent);
			}
			if(angle == -1)
				angle = originCurve.getAngle(parent);
			var offset = angle.radToDegree() - Std.parseFloat(fast.att.maxAngle)/2;
			curve.minAngle = (fast.has.minAngle ? Std.parseFloat(fast.att.minAngle) : 0) + offset;
			curve.maxAngle = (fast.has.maxAngle ? Std.parseFloat(fast.att.maxAngle) : 0) + offset;
			curves.set(parent, curve);
		}

		curve.add(button);
		addChild(button);
	}
}

private class XmlTree{

	var root: TreeNode<Xml>;

	public function new(xml:Xml):Void
	{
		root = new TreeNode<Xml>();
		var doc = xml.firstElement();
		for(elem in doc.elements())
			root.children.add(parseKid(elem, root));
		root.value = doc;
	}

	public function parseKid(xml:Xml, parent: TreeNode<Xml>):TreeNode<Xml>
	{
		var node = new TreeNode<Xml>(xml);
		for(elem in xml.elements()){
			node.children.add(parseKid(elem, node));
		}
		node.parent = parent;
		return node;
	}

	public function getDepth(depth:Int):GenericStack<TreeNode<Xml>>
	{
		var result = new GenericStack<TreeNode<Xml>>();
		recursiveSearch(root, depth+1, result);
		return result;
	}

	private function recursiveSearch(node: TreeNode<Xml>, depth: Int, results: GenericStack<TreeNode<Xml>>):Void
	{
		if(depth > 0){
			for(elem in node.children)
				recursiveSearch(elem, depth-1, results);
		}
		else{
			results.add(node);
		}
	}
}

private class TreeNode<V>{
	public var value (default, default):V;
	public var children (default, default):GenericStack<TreeNode<V>>;
	public var parent (default, default):TreeNode<V>;

	public function new(?value: V):Void
	{
		this.value = value;
		children = new GenericStack<TreeNode<V>>();
	}
}