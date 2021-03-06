package com.knowledgeplayers.grar.util.guide;

import com.knowledgeplayers.grar.display.component.TileImage;
import flash.events.Event;
import com.knowledgeplayers.grar.display.TweenManager;
import flash.display.DisplayObject;
import flash.geom.Point;

/**
 * Manage a grid to place object
 */
class Grid implements Guide {
	/**
    * Number of rows
    **/
	public var numRow (default, default):Int;
	/**
    * Number of columns
    **/
	public var numCol (default, default):Int;
	/**
    * Size of a cell
    **/
	public var cellSize (default, default):Size;
	/**
    * X of the grid
    **/
	public var x (default, set_x):Float;
	/**
    * Y of the grid
    **/
	public var y (default, set_y):Float;
	/**
	* Space between columns
	**/
	public var gapCol (default, default):Float;
	/**
	* Space between rows
	**/
	public var gapRow (default, default):Float;

	public var transitionIn (default, default):String;

	private var nextCell:Point;

	private var alignment: GridAlignment;
	private var resize: Bool;

	public function new(numRow:Int, numCol:Int, cellWidth:Float = 0, cellHeight:Float = 0, gapCol:Float = 0, gapRow:Float = 0, ?alignment:GridAlignment, resize: Bool = true, ?transitionIn: String)
	{
		this.numRow = numRow;
		this.numCol = numCol;
		this.gapCol = gapCol;
		this.gapRow = gapRow;
		this.resize = resize;
		this.transitionIn = transitionIn;

		this.alignment = alignment != null ? alignment : GridAlignment.TOP_LEFT;

		cellSize = {width: cellWidth, height: cellHeight};

		// Initialize nextCell to (0;0)
		empty();
	}

	public function set_x(x:Float):Float
	{
		return this.x = x;
	}

	public function set_y(y:Float):Float
	{
		return this.y = y;
	}

	/**
	* @inherits
	**/
	public function add(object:DisplayObject, ?tween:String, tile: Bool = false):DisplayObject
	{
		if(cellSize.width == 0){
			cellSize.width = object.width;
		}
		if(cellSize.height == 0){
			cellSize.height = object.height;
		}

		var targetX:Float = x + nextCell.x * cellSize.width;
		targetX += gapCol * nextCell.x;
		targetX += switch(alignment){
			case CENTER, TOP_MIDDLE, BOTTOM_MIDDLE: cellSize.width / 2 - object.width / 2;
			case TOP_RIGHT, MIDDLE_RIGHT, BOTTOM_RIGHT: cellSize.width - object.width;
			default: 0;// Already on the left
		}

		var targetY:Float = y + nextCell.y * cellSize.height;
		targetY += gapRow * nextCell.y;
		targetY += switch(alignment){
			case CENTER, MIDDLE_LEFT, MIDDLE_RIGHT: cellSize.height / 2 - object.height / 2;
			case BOTTOM_LEFT, BOTTOM_MIDDLE, BOTTOM_RIGHT: cellSize.height - object.height;
			default: 0;// Already on top
		}

		if(nextCell.x < numCol - 1){
			nextCell.x++;
		}
		else if(nextCell.y < numRow){
			nextCell.x = 0;
			nextCell.y++;
		}
		else
			throw "This grid is already full!";

		if(tween != null)
		    TweenManager.applyTransition(object,tween);
		else if(transitionIn != null)
			TweenManager.applyTransition(object,transitionIn);

        if(tile){
            cast(object, TileImage).set_x(targetX);
            cast(object, TileImage).set_y(targetY);
        }
        else{
            object.x = targetX;
            object.y = targetY;
        }
        if(resize){

        fitInGrid(object);
        object.addEventListener(Event.CHANGE, function(e){
            fitInGrid(object);
        });

        }
		return object;
	}

	/**
    * Align the element in the cell, if the cell is too large
    **/

	public function setAlignment(alignment: String):Void
	{
		this.alignment = Type.createEnum(GridAlignment, alignment.toUpperCase());
	}

	public function empty():Void
	{
		nextCell = new Point(0, 0);
	}

	private inline function fitInGrid(object: DisplayObject):Void
	{
		object.width = cellSize.width;
		object.height = cellSize.height;
	}
}

enum GridAlignment {
	CENTER;
	TOP_LEFT;
	TOP_RIGHT;
	TOP_MIDDLE;
	MIDDLE_LEFT;
	MIDDLE_RIGHT;
	BOTTOM_LEFT;
	BOTTOM_MIDDLE;
	BOTTOM_RIGHT;
}

typedef Size = {
	var width: Float;
	var height: Float;
}
