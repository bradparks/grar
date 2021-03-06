package com.knowledgeplayers.grar.structure;

import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.tracking.Connection;
import com.knowledgeplayers.grar.tracking.StateInfos;
import com.knowledgeplayers.grar.tracking.Trackable;
import flash.events.IEventDispatcher;

interface Game extends IEventDispatcher {
	public var mode (default, default):Mode;
	public var state (default, default):String;
	public var inventory (default, null):Array<Token>;
	public var ref (default, default):String;
	public var menu (default, default):Xml;
	public var stateInfos (default, null):StateInfos;
	public var connection (default, null):Connection;
	public var id (default, default):String;

	public function start(?partId:String):Null<Part>;

	public function init(xml:Xml):Void;

	public function addPart(partId:String, part:Part):Void;

	public function getAllParts():Array<Part>;

	public function getAllItems():Array<Trackable>;

	public function addLanguage(value:String, path:String, flagIconPath:String):Void;

	public function initTracking(?mode:Mode):Void;

	public function getLoadingCompletion():Float;

	public function toString():String;

	public function getItemName(id:String):Null<String>;

	public function getPart(id:String):Null<Part>;
}
