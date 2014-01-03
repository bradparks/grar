package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.display.LayoutManager;
import com.knowledgeplayers.grar.display.contextual.menu.MenuDisplay;
import com.knowledgeplayers.grar.structure.contextual.Bibliography;
import com.knowledgeplayers.grar.structure.contextual.Glossary;
import com.knowledgeplayers.grar.structure.contextual.Notebook;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import com.knowledgeplayers.grar.display.contextual.ContextualDisplay.ContextualType;
import com.knowledgeplayers.grar.display.FilterManager;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.utils.assets.loaders.concrete.TextAsset;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.tracking.Connection.Mode;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import com.knowledgeplayers.grar.structure.KpGame;

class StructureParser {

	public static function parse(xml: Fast):KpGame
	{
		var game = new KpGame();

		var parametersNode:Fast = xml.node.Grar.node.Parameters;
		var displayNode:Fast = xml.node.Grar.node.Display;

		game.mode = Type.createEnum(Mode, parametersNode.node.Mode.innerData);
		game.state = parametersNode.node.State.innerData;
		game.id = parametersNode.node.Id.innerData;

		// Load Xml templates
		if(displayNode.hasNode.Templates){
			var templateFolder = displayNode.node.Templates.att.folder;
			var templates = AssetsStorage.getFolderContent(templateFolder, "xml");
			var xmlList = new List<Xml>();
			for(temp in templates)
				xmlList.add(cast(temp, TextAsset).getXml());
			DisplayUtils.loadTemplates(xmlList);
		}

		// Start Tracking

		game.initTracking();

		// Load UI
		UiFactory.setSpriteSheet(displayNode.node.Ui.att.display);

		// Load styles
		for(stylesheet in displayNode.nodes.Style){
			var fullPath = stylesheet.att.file.split("/");

			var localePath:StringBuf = new StringBuf();
			for(i in 0...fullPath.length - 1){
				localePath.add(fullPath[i] + "/");
			}
			localePath.add(Localiser.instance.currentLocale + "/");
			localePath.add(fullPath[fullPath.length - 1]);
			var extension = localePath.toString().split(".");
			StyleParser.parse(AssetsStorage.getText(localePath.toString()), extension[extension.length-1]);
		}

		// Load Languages
		game.initLangs(AssetsStorage.getXml(parametersNode.node.Languages.att.file));

		// Load Transition
		if(displayNode.hasNode.Transitions)
			TweenManager.loadTemplate(displayNode.node.Transitions.att.display);

		// Load filters
		if(displayNode.hasNode.Filters)
			FilterManager.loadTemplate(displayNode.node.Filters.att.display);

		// Load contextual
		var structureNode:Fast = xml.node.Grar.node.Structure;
		for(contextual in structureNode.nodes.Contextual){
			var display = AssetsStorage.getXml(contextual.att.display);
			var contextualType: ContextualType = Type.createEnum(ContextualType, contextual.att.type.toUpperCase());
			switch(contextualType){
				case NOTEBOOK:    NotebookDisplay.instance.parseContent(display);
					NotebookDisplay.instance.model = new Notebook(contextual.att.file);
				case GLOSSARY:    Glossary.instance.fillWithXml(contextual.att.file);
				case BIBLIOGRAPHY:Bibliography.instance.fillWithXml(contextual.att.file);
				case MENU :       MenuDisplay.instance.parseContent(display);
					if(contextual.has.file)
						game.menu = AssetsStorage.getXml(contextual.att.file);
				default: null;
			}
		}

		//if(structureNode.has.inventory)
		//	controller.loadTokens(structureNode.att.inventory);

		game.ref = structureNode.att.ref;
		// Count parts
		for(part in structureNode.nodes.Part){
			game.numParts++;
		}

		// Load them
		for(part in structureNode.nodes.Part){
			game.addPartFromXml(part.att.id, part);
		}

		// TODO Service
		// Load Layout
		var layoutManager = new LayoutManager();
		layoutManager.onLoaded = game.onLayoutLoaded;
		layoutManager.parseXml(AssetsStorage.getXml(xml.node.Grar.node.Parameters.node.Layout.att.file));

		return game;
	}
}