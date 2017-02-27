package djFlixel.gui;

import djFlixel.tool.DataTool;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;

/**
 * Simple graphic button with 3 states ( normal | hover | pressed )
 * 
 * 
 * 	style: {
 * 		borderCol:  0xFF222222,				:: border color
 * 		bgCol: Int							:: @optional BG sprite color tint
 * 		fgCol: Array<Int>					:: @optional colors for [normal,hover,pressed]
 * 		borderT: 0:off,1:Outline,2:Shadow	:: border type
 * 		font: String						:: @optional embedded font
 * 		width: Int							:: Width of the BG tile image
 * 		height: Int							:: Height of the BG tile image
 * 		bg:	flxGraphic						:: Tile Image of the Background
 * 		fg: flxGraphic						:: @optional Tile Image of the FG
 * 		fgSize:	Int							:: @optional Set the size of the loading asset
 * 	}
 * 
 * -------
 * FUTURE:
 * 
 * 	- Disabled buttons
 *  - Button Toggles
 *  - Customizable border color on various states ??
 * 
 * 
 */
class UIButton extends flixel.group.FlxSpriteGroup
{
	// --
	inline static var STATE_NORMAL:Int = 0;
	inline static var STATE_HOVER:Int = 1;
	inline static var STATE_PRESS:Int = 2;

	// -- Default style
	public static var defaultStyle:Dynamic = {
		font:null, bg:null, width:0, height:0, bgTint: -1,
		fgSize:0,fg:null,
		borderCol:0xFF404040, borderT:1, 
		fgCol:[0xFFFFFF, 0xDDDDDD, 0xAAAABB]
	};
	
	//====================================================;
	
	// -- The BG and FG elements
	var spr_bg:FlxSprite = null;
	var spr_fg:FlxSprite = null;
	
	// 0:Normal,1:Hover,2:Pressed
	public var current_state(default, null):Int = STATE_NORMAL;
	
	public var onPress:Dynamic->Void = null;
	public var onRelease:Dynamic->Void = null;
	public var onHover:Dynamic->Void = null;
	
	// Currently used style for this button
	public var style:Dynamic;
	
	//====================================================;
	/**
	 * @param	style Check Class Details
	 */
	public function new(?_s:Dynamic)
	{
		super();
		style = DataTool.defParams(_s, defaultStyle);
		if (style.bg != null) {
			loadBG(style.width, style.height, style.bg);
		}
		if (style.fg != null){
			loadFG(style.fgSize, style.fg);
		}
	}//---------------------------------------------------;
	
	/**
	 * Load a sprite as the background
	 * @param 	w The width of the tiles
	 * @param 	H The height of the tiles
	 * @param	gfx A Tiled image with 3 sprites, Normal, Hover and Pressed
	 */
	public function loadBG(w:Int, h:Int, gfx:FlxGraphicAsset)
	{
		spr_bg = new FlxSprite();
		spr_bg.loadGraphic(gfx, true, w, h);
		if (style.bgCol >-1) spr_bg.color = style.bgCol;
		add(spr_bg);
		
		#if FLX_MOUSE
		// Mouse and touch
		FlxMouseEventManager.add(spr_bg, _onPress, _onRelease, _onHover, _onOut);
		#else
		// Just touch
		FlxMouseEventManager.add(spr_bg, _onPress, _onRelease);
		#end
	}//---------------------------------------------------;
	
	/**
	 * Load a tiled image for the FG.
	 */
	public function loadFG(size:Int, gfx:FlxGraphicAsset)
	{
		#if debug
		if (spr_bg == null) throw "Call this after loading the BG";
		#end
		spr_fg = new FlxSprite();
		spr_fg.loadGraphic(gfx, true, size, size);
		setFG(spr_fg);
	}//---------------------------------------------------;
	
	// --
	public function setFGIndex(i:Int)
	{
		spr_fg.animation.frameIndex = i;
	}//---------------------------------------------------;
	
	
	/**
	 * Set a text for the FG, takes the style into account
	 * @param	text Text
	 * @param	size fontSize
	 */
	public function textFG(text:String, size:Int)
	{
		if (spr_fg != null) return;
		
		var t = new FlxText(0, 0, 0, text, size);
			t.font = style.font;
			t.color = 0xFFFFFFFF;
		if (style.borderT > 0){
			t.borderColor = style.borderCol;
			t.borderSize = (size > 11?2:1);
			t.borderStyle = (style.borderT == 1?FlxTextBorderStyle.OUTLINE:FlxTextBorderStyle.SHADOW);
		}
		setFG(t);
		spr_fg.x++; spr_fg.y++; /// Experimental, aligns text 
		_setState(current_state);
	}//---------------------------------------------------;
	
	
	/**
	 * Set a sprite on top of the background
	 * @param	s the sprite
	 */
	function setFG(s:FlxSprite)
	{
		spr_fg = s;
		add(spr_fg);
		// Try to center it :
		spr_fg.x = this.x + (spr_bg.width / 2) - (spr_fg.width / 2);
		spr_fg.y = this.y + (spr_bg.height / 2) - (spr_fg.height / 2);
	}//---------------------------------------------------;
	
	
	
	//====================================================;
	// EVENT HANDLERS 
	//====================================================;
	
	/**
	 * Change the graphics and state
	 * @param	s 0:normal, 1:hover, 2:press
	 */
	function _setState(s:Int)
	{
		spr_bg.animation.frameIndex = s;
		current_state = s;
		
		if (spr_fg != null) {
			spr_fg.color = style.fgCol[current_state];
		}
	}//---------------------------------------------------;
	
	function _onPress(D:Dynamic)
	{
		_setState(STATE_PRESS);
		if (onPress != null) onPress({});
	}//---------------------------------------------------;
	
	function _onRelease(D:Dynamic)
	{
		if (current_state != STATE_PRESS) return; // release from pressed
		
		// Go to hover or normal ??
		#if FLX_MOUSE 
			#if FLX_TOUCH
				// Set to hover if released by mouse
				if (FlxG.mouse.overlaps(spr_bg, spr_bg.camera))
					_setState(STATE_HOVER);
				else
					_setState(STATE_NORMAL);
			#else
				_setState(STATE_HOVER);
			#end
		#else // Just Touch
			_setState(STATE_NORMAL);
		#end
		
		if (onRelease != null) onRelease({});
	}//---------------------------------------------------;
	
	#if FLX_MOUSE
	function _onHover(D:Dynamic)
	{
		_setState(STATE_HOVER);
	}//---------------------------------------------------;	
	
	function _onOut(D:Dynamic)
	{
		_setState(STATE_NORMAL);
	}//---------------------------------------------------;
	#end
}// --