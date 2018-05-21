package  
{
	import flash.events.Event;
	/**
	 * ...
	 * @author abdurda
	 */
	public class ApplicationEvent extends Event 
	{
		public static const TIMER:String = 'timer';
		
		public var params:Object;
		
		public function ApplicationEvent(type:String, params:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.params = params;
			super(type, bubbles, cancelable);
		}
	}
}