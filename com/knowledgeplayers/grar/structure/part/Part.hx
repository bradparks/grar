package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import nme.events.IEventDispatcher;
import nme.media.Sound;

interface Part extends IEventDispatcher extends PartElement extends Trackable {
public var file (default, null):String;
public var display (default, default):String;
public var isDone (default, default):Bool;
public var parent (default, default):Part;
public var next (default, default):String;

public var button (default, default):Map<String, Map<String, String>>;
public var elements (default, null):Array<PartElement>;
public var token (default, null):String;
public var tokens (default, null):GenericStack<String>;
public var buttonTargets (default, null): Map<String, PartElement>;
public var soundLoop (default, default):Sound;

public function init(xml:Fast, ?filePath:String):Void;

public function start(forced:Bool = false):Null<Part>;

public function end():Void;

public function restart():Void;

public function getNextElement(startIndex:Int = - 1):Null<PartElement>;

public function getElementIndex(element:PartElement):Int;

public function getAllParts():Array<Part>;

public function getAllItems():Array<Trackable>;

public function hasParts():Bool;

public function toString():String;

public function isDialog():Bool;

public function isStrip():Bool;

public function isActivity():Bool;

public function isText():Bool;

public function isPattern():Bool;

public function isPart():Bool;

public function getItemName(id:String):Null<String>;
}