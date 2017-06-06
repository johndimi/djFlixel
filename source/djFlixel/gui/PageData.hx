package djFlixel.gui;

// PageData
// --------
// Holds a single page data for use in FlxMenu
// Some parameters about the page like title, custom styles
// and an array with all the menuoptions it contains.
// --
class PageData
{
	public static var UID_GENERATOR:Int = 0;
	
	// Unique String ID of the page
	public var SID:String;
	
	// Unique Int ID of the page
	public var UID:Int;		
	
	// Optional Menu Header Titler
	public var header:String;
	
	// Optional Menu Description
	public var description:String;
	
	// Data holder, Store the options serially
	public var collection:Array<OptionData>;

	// Store some page specific custom parameters
	public var custom:Dynamic;	
	
	// Things that you can store in custom:
	// These vars are OPTIONAL and will override the flxMenu defaults for this page.
	// ------------------------------------------------------------------------------
	// width			 Int, Custom page width
	// slots	 		 Int, How many slots this page should have for the screen representation
	
	// styleOption		Object, custom styleOption
	// styleList		Object, custom styleList
	// styleBase		Object, custom styleBase
	
	// -- note: Get styles from the "Styles.hx" static class --
	
	// lockNavigation    Bool, If true the page cannot send a "back" request ( by pressing the back button )
	// cursorStart		 SID, the sid of the option to always highlight when going into this menu
	
	// callbacks_option   override the menu's callback function to this one.
	
	// -----------------------------------------------
	// - Fields starting with _ are used internally ::
	// -----------------------------------------------
	// 
	// _cursorLastPos   Int, Store the latest cursor position if it's needed later
	// _dynamic			Bool, Dynamic page flag
	
	
	//====================================================;
	// FUNCTIONS
	//====================================================;
	
	/**
	 * A page data holds multiple menu options.
	 * 
	 * @param	SID Identifier for the page
	 * @param	params [ header, description ]
	 */
	public function new(?SID:String, ?params:Dynamic)
	{
		collection = [];
		custom = { };
		
		this.UID = UID_GENERATOR++;
		this.SID = SID;
		
		if (params == null) return; // no need to read params if null	
		
		header = Reflect.field(params, "header");		// Header
		description = Reflect.field(params, "desc");	// Description, or subtitle
		
		// - You can set other custom data later, after creating this object
		//	 by directly setting what you need with Page.custom.whatever = whatever;
		//   You can use strings, ints, bools, or objects etc
		
	}//---------------------------------------------------;

	/**
	 * Quick add an option data to a page data
	 * 
	 * @param	label The text that will appear
	 * @param	params { 
	 * 		type: String, ["link", "slider", "oneof", "toggle", "label"]
	 * 		sid:  String,   Give the optionData an ID
	 * 		desc: String,	Description
	 * 		pool: Dynamic, Data associated with the controller
	 * 		current: Dynamic, Current value of the controller ! Warning: Unsanitized
	 * 		conf_question: String, Question to present if a confirmation check is required
	 * 		conf_options:  []:String, Options instead of YES/NO
	 * 
	 * @return The produced OptionData
	 */
	public function add(label:String, ?params:Dynamic):OptionData
	{
		var o = new OptionData(label, params);
		collection.push(o);
		return o;
	}//---------------------------------------------------;
	
	/**
	 * Quickly add a Link
	 * @param label The display name
	 * @param SID Start with "@" to link to page, Start with "!" to confirm action, "#back" to go back
	 */
	public inline function link(label:String, SID:String, ?callback:Void->Void):OptionData
	{
		return add(label, { type:"link", sid:SID, callback:callback } );
	}//---------------------------------------------------;

	/**
	 * Quickly add a Label
	 */
	public inline function label(label:String):OptionData
	{
		return add(label, { type:"label" } );
	}//---------------------------------------------------;
	
	
	/**
	 * Quickly add a back button
	 */
	public inline function addBack(?text:String):OptionData
	{
		return add(text != null?text:"Back", { type:"link", sid:"@back", desc:"Go back" } );
	}//---------------------------------------------------;

	
	/**
	 * Adds a question to the page.
	 * @param	text  Question to ask
	 * @param	sid   The results will callback as : "sid_yes", "sid_no"
	 */
	public function question(text:String, sid:String, lockNavigation:Bool = false)
	{
		add(text, { type:"label" } );
		link("yes", '${sid}_yes');
		link("no" , '${sid}_no');
		
		this.custom.lockNavigation = lockNavigation;
		this.custom.cursorStart = '${sid}_no';
	}//---------------------------------------------------;
	
	
	// --
	// Free memory, help the garbage collector?
	public function destroy()
	{
		for (i in collection) {
			i.destroy();
			i = null;
		}
		
		collection = null;
		custom = null;
	}//---------------------------------------------------;
	
	// --
	// Returns the optionData of the page with target SID
	// NULL if nothing is found
	public function get(sid:String):OptionData
	{
		for (i in collection) if (i.SID == sid) return i; return null;
	}//---------------------------------------------------;

	
}//-- end --//