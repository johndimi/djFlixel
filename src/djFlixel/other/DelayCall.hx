package djFlixel.other;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;


/**
 * Callbacks after an amount of time has passed
 * Auto-added and removed from the state
 * 
 * USAGE:
 * 		new DelayCall(function(){trace("1 second has passed");},1);
 * 
 * 	If you want to cancel a callback, you can capture the object and then call destroy()
 */
class DelayCall extends FlxBasic
{
	var countDown:Float;
	var callback:Void->Void;
	// --
	/**
	 * Delay call to a function. TIP: You can use function.bind(..) to predefine parameters
	 * @param	Callback The function to call
	 * @param	time Call it after this much time has passed
	 * @param	state The state to add this, Useful if running from a substate where the main state is paused
	 */
	public function new(?autoAdd:Bool = true, Callback:Void->Void, time:Float = 0)
	{
		super();
		callback = Callback;
		countDown = time;
		if (autoAdd) {
			FlxG.state.add(this);
		}
	}//---------------------------------------------------;
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if ((countDown -= elapsed) <= 0) {
			destroy();
			if (callback != null) callback();
		}
	}//---------------------------------------------------;	
	
	override public function destroy():Void 
	{
		if (!exists) return;
		FlxG.state.remove(this);
		super.destroy();
	}//---------------------------------------------------;
	
}// --