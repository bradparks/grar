package com.knowledgeplayers.grar.event;

import com.knowledgeplayers.grar.structure.Token;
import flash.events.Event;

/**
 * Token related event
 */

class TokenEvent extends Event {
	/**
	 * Add token to the inventory
	 */
	public static var ADD (default, null):String = "Add";

	/**
    * object Token
    **/
	public var token:Token;

	public function new(type:String, ?_token:Token, bubbles:Bool = false, cancelable:Bool = false)
	{
		super(type, bubbles, cancelable);
		this.token = _token;

	}

	override public function clone():Event
	{
		return new TokenEvent(type, token, bubbles, cancelable);
	}
}