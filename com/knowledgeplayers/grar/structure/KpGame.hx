package com.knowledgeplayers.grar.structure;

import com.knowledgeplayers.grar.structure.part.StructurePart;
import com.knowledgeplayers.grar.display.contextual.menu.MenuDisplay;
import com.knowledgeplayers.grar.factory.PartFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.tracking.Connection;
import com.knowledgeplayers.grar.tracking.StateInfos;
import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.xml.Fast;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.Lib;

using StringTools;

/**
 * KP inmplentation of a game
 */
class KpGame extends EventDispatcher #if haxe3 implements Game #else ,implements Game #end{
	/**
     * Connection mode
     */
    public var mode (default, default):Mode;

    /**
     * State of the game
     */
    public var state (default, default):String;

	/**
     * Global inventory
     */
    public var inventory (default, null):Array<Token>;

	/**
    * Reference for the layout
    **/
    public var ref (default, default):String;

	/**
    * Xml describing the menu
    **/
    public var menu (default, default):Xml;

	/**
	* Tracking infos
	**/
    public var stateInfos (default, null):StateInfos;

	/**
	* Connection with the LMS
	**/
    public var connection (default, null):Connection;

    /**
	* Unique identifier of the module
	**/
	public var id (default, default):String;

    /**
    * Index of the current part
    **/
    private var partIndex:Int = 0;
    private var structureXml:Fast;
    private var languages:Map<String, String>;
    private var flags:Map<String, String>;
    private var parts:Array<Part>;
    private var numParts:Int = 0;
    private var nbPartsLoaded:Int = 0;
    private var layoutLoaded:Bool = false;
    private var numStyleSheet:Int = 0;
    private var numStyleSheetLoaded:Int = 0;

	/**
    * Constructor.
    * Register the game to the GameManager
    **/
    public function new()
    {
        super();
        languages = new Map<String, String>();
        flags = new Map<String, String>();
        parts = new Array<Part>();
        inventory = new Array<Token>();

        Lib.current.stage.addEventListener(Event.DEACTIVATE, onExit);
    }

    /**
	* Called when the game is fully loaded
	**/
	dynamic public function onGameLoaded(layout:String = "default"):Void {}

	/**
     * Start the game
     * @param	partId : the ID of the part to start.
     * @return 	the part with id partId or null if this part doesn't exist
     */
    public function start(?partId:String):Null<Part>
    {
        var nextPart:Part = null;
        if(partId == null){
            do{
                nextPart = parts[partIndex].start();
                partIndex++;
            }
            while(nextPart == null && partIndex < parts.length);
        }
        else if(partId != null){
            var i:Int = 0;
            while(i < getAllParts().length && getAllParts()[i].id != partId){
                i++;
            }
	        if(i != getAllParts().length){
                nextPart = getAllParts()[i].start(true);
	            var j = 0;
	            var k = 0;
	            while(j <= i){
	                if(getAllParts()[j] == parts[k] && j > 0)
	                    k++;
	                j++;
	            }
	            partIndex = k + 1;
	        }
        }
        return nextPart;
    }

	public function onLayoutLoaded():Void
	{
		layoutLoaded = true;
	}

	/**
     * Add a part to the game at partIndex
     * @param	partId : ID of the part
     * @param	part : the part to add
     */
    public function addPart(partId:String, part:StructurePart):Void
    {
        part.onLoaded = onPartLoaded;
        parts.push(part);
    }

    /**
     * Add a language to the game
     * @param	value : name of the language
     * @param	path : path to the localisation folder
     * @param	flagIconPath : path to the flag for this language
     */
    public function addLanguage(value:String, path:String, flagIconPath:String):Void
    {
        Localiser.get_instance().localisations.set(value, path);
        flags.set(value, flagIconPath);
    }

    /**
     * @return a string-based representation of the game
     */
    override public function toString():String
    {
        return mode + " - " + state + ". Parts: \n\t" + parts.toString();
    }

	/**
     * Start the tracking
     * @param	mode : tracking mode (SCORM/AICC)
     */
    public function initTracking(?mode:Mode):Void
    {
	    connection = new Connection();
		if(mode != null)
            this.mode = mode;


        var activationTracking:String = "off";
        var parametersNode:Fast = structureXml.node.Grar.node.Parameters;

        if(parametersNode.node.State.has.tracking)
            activationTracking = parametersNode.node.State.att.tracking;

        connection.initConnection(this.mode,false,activationTracking);
        stateInfos = connection.revertTracking();
        if(stateInfos.isEmpty()){
            stateInfos.loadStateInfos(state);
        }
		Localiser.instance.currentLocale = stateInfos.currentLanguage;
    }

    /**
     * Get the state of loading of the game
     * @return a float between 0 (nothing loaded) and 1 (everything's loaded)
     */
    public inline function getLoadingCompletion():Float
    {
        return nbPartsLoaded / numParts;
    }

	/**
     * @return all the parts of the game
     */
    public function getAllParts():Array<Part>
    {
        var array = new Array<Part>();
        for(part in parts){
            array = array.concat(part.getAllParts());
        }

        return array;
    }

	/**
    * @return all trackable items of the game
    **/
    public function getAllItems():Array<Trackable>
    {
        var trackable = new Array<Trackable>();
        for(part in parts){
            trackable = trackable.concat(part.getAllItems());
        }

        return trackable;
    }

	/**
    * @param    id : Id of the item
    * @return the name of the item
    **/
    public function getItemName(id:String):Null<String>
    {
        var i = 0;
        var name:String = null;
        while(i < parts.length && name == null){
            name = parts[i].getItemName(id);
            i++;
        }
        return name;
    }

	/**
	* @param    id : Id of the part
	* @return the part with the given id
	**/
    public function getPart(id:String):Null<Part>
    {
        var i = 0;
        while(i < getAllParts().length && getAllParts()[i].id != id)
            i++;
        return i == getAllParts().length ? null : getAllParts()[i];
    }

    // Privates

    private function checkIntegrity():Void
    {
        if(stateInfos.checksum != getAllParts().length){
            throw "Invalid checksum (" + getAllParts().length + " part(s) found instead of " + stateInfos.checksum + "). The structure file must be corrupt";
        }
    }

    private function addPartFromXml(partIndex:String, partXml:Fast):Void
    {
        var part:Part = PartFactory.createPartFromXml(partXml);
        addPart(partIndex, part);
        part.init(partXml);
    }

    private function initLangs(xml:Xml):Void
    {
        var languagesXml:Fast = new Fast(xml);
        for(lang in languagesXml.node.Langs.nodes.Lang){
            addLanguage(lang.att.value, lang.att.folder, lang.att.pic);
        }
    }

    // Handlers

	private function onPartLoaded():Void
	{
		nbPartsLoaded++;
		checkLoading();
	}

    private function createMenuXml(xml:Xml, part:Part, level:Int = 1):Void
    {
        var child = Xml.createElement("h" + level);
        child.set("id", part.id);
        xml.addChild(child);
        for(elem in part.elements){
            if(elem.isPart() && cast(elem, Part).hasParts()){
                createMenuXml(child, cast(elem, Part), level++);
            }
            else if(Std.is(elem, Trackable)){
                var item = Xml.createElement("item");
                item.set("id", cast(elem, Trackable).id);
                child.addChild(item);
            }
        }
    }

    private function checkLoading():Void
    {
        if(getLoadingCompletion() == 1 && (numStyleSheet == numStyleSheetLoaded)){
        	//checkIntegrity();
        	// Menu hasn't been set, creating the default
            if(menu == null){
                var menuXml = Xml.createDocument();
	            menuXml.addChild(Xml.createElement("menu"));
                for(part in parts){
                    createMenuXml(menuXml, part);
                }
                menu = menuXml;
            }
            if(!layoutLoaded){
	            if(stateInfos.tmpState != null)
	                stateInfos.loadStateInfos(stateInfos.tmpState);
	            for(part in getAllParts())
                    part.isDone = stateInfos.isPartFinished(part.id);
            }
            else{
	            onGameLoaded(ref);
	            if(MenuDisplay.instance.exists)
                    MenuDisplay.instance.init();
            }
        }
    }

    private function onExit(e:Event):Void
    {
        //Lib.exit();
    }
}