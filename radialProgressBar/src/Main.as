package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author abdurda
	 */
	
	[SWF(width = "500", height = "500", allowsFullScreen = true, backgroundColor = '#C0C0C0')]
	
	public class Main extends Sprite 
	{
		private var _timer:Timer;
		private var _time:uint = 0;
		private var _progressBar:RadialProgressBar;
		
		public static var self:Main;
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			self = this;
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align 		= StageAlign.TOP_LEFT;
			
			_timer = new Timer(1000);
			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			
			addBar();
		}
		
		private function addBar():void 
		{
			_progressBar = new RadialProgressBar(60);
			_progressBar.x = stage.stageWidth / 2;
			_progressBar.y = stage.stageHeight / 2;
			
			addChild(_progressBar);
		}
		
		private function onResize(e:Event):void {
			_progressBar.x = stage.stageWidth / 2;
			_progressBar.y = stage.stageHeight / 2;
		}
		
		private function onTimerEvent(e:TimerEvent):void {
			_time++;
			dispatchEvent(new ApplicationEvent(ApplicationEvent.TIMER));
		}
		
	}
	
}