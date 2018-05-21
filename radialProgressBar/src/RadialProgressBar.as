package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author abdurda
	 */	
	public class RadialProgressBar extends Sprite
	{
		private var _settings:Object = {
			radius				:40,
			progressLineWidth	:10,
			borderWidth			:5,
			progressLineColor	:0xec1616,
			borderColor			:0x0000000,
			autoStart			:true,
			removeOnComplete	:false
		}
		private var _time:int = 0;
		private var _duration:int = 0;
		private var _progress:Number = 0;
		private var _maska:Bitmap;
		private var _container:Sprite;
		
		public function RadialProgressBar(duration:Number, currentProgress:Number = 0, settings:Object = null) {
			_progress = currentProgress;
			_duration = duration;
			if (settings){
				for (var obj:* in settings)
					_settings[obj] = settings[obj];
			}	
			checkSettings();
			draw();
			if (_settings.autoStart) start(_progress);
		}
		
		private function checkSettings():void {
			if (_settings.progressLineWidth + _settings.borderWidth * 2 > _settings.radius){
				while (_settings.progressLineWidth + _settings.borderWidth * 2 > _settings.radius) {
					if (_settings.progressLineWidth > _settings.borderWidth * 2){
						_settings.progressLineWidth--
					}else{
						_settings.borderWidth--;
					}
				}
			}
		}
		
		private function draw():void {
			_container = new Sprite();
			_container.cacheAsBitmap = true;
			addChild(_container);
			drawContainerMask();
			drawFillBackground();
			drawCircles();
		}
		
		private function drawContainerMask():void {
			var maska:Shape = new Shape();
			maska.graphics.beginFill(0x0, 1);
			maska.graphics.drawCircle(0, 0, _settings.radius);
			maska.graphics.drawCircle(0, 0, _settings.radius - _settings.borderWidth*2 - _settings.progressLineWidth);
			maska.graphics.endFill();
			maska.cacheAsBitmap = true;
			_container.addChild(maska);
			_container.mask = maska;
		}
		
		private function drawFillBackground():void {
			var background:Shape = new Shape();
			background.graphics.beginFill(_settings.progressLineColor, 1);
			background.graphics.drawCircle(0, 0, _settings.radius);
			background.graphics.endFill();
			background.cacheAsBitmap = true;
			background.filters = [new GlowFilter(0xdc631c, .7, 20, 20, 1), new GlowFilter(0xdc631c, .7, 6, 6, 2, 1, true)];
			
			_maska = new Bitmap(new BitmapData(_settings.radius*2, _settings.radius*2, true, 0xffffff));
			_maska.cacheAsBitmap = true;
			_maska.smoothing = true;
			_maska.x = -_maska.width / 2;
			_maska.y = -_maska.height / 2;
			
			background.mask = _maska;
			_container.addChild(background);
			_container.addChild(_maska);
		}
		
		private function drawCircles():void {
			var line1:Shape = new Shape();
			line1.graphics.beginFill( _settings.borderColor, 1);
			line1.graphics.drawCircle(0, 0, _settings.radius);
			line1.graphics.drawCircle(0, 0, _settings.radius - _settings.borderWidth);
			line1.graphics.endFill();
			line1.cacheAsBitmap = true;
			
			var radius:int = _settings.radius - _settings.progressLineWidth - _settings.borderWidth;
			var line2:Shape = new Shape();
			line2.graphics.beginFill(_settings.borderColor, 1);
			line2.graphics.drawCircle(0,0, radius);
			line2.graphics.drawCircle(0,0, radius - _settings.borderWidth);
			line2.graphics.endFill();
			line2.cacheAsBitmap = true;
			
			_container.addChild(line1);
			_container.addChild(line2);
		}
		
		private function update(e:ApplicationEvent):void {
			_time++;
			if (_time > _duration){
				onComplete()
			}else{
				progress = _time / _duration;
			}
		}
		
		private function onComplete():void 
		{	
			clearListeners();
			trace('timer COMPLETE')
			if (_settings.removeOnComplete){
				dispose();
			}
		}
		
		private  function drawSegment(startAngle:Number, endAngle:Number, segmentRadius:Number, xpos:Number, ypos:Number, step:Number, lineColor:Number, fillColor:Number):Shape  {
			var holder:Shape = new Shape();
			
			holder.graphics.lineStyle(2, lineColor);
			holder.graphics.beginFill(fillColor);
			
			var originalEnd:Number = -1;
			if(startAngle > endAngle){
				originalEnd = endAngle;
				endAngle = 360;
			}
			var degreesPerRadian:Number = Math.PI / 180;
			var theta:Number;
			startAngle *= degreesPerRadian;
			endAngle *= degreesPerRadian;
			step *= degreesPerRadian;
			
			holder.graphics.moveTo(xpos, ypos);
			for (theta = startAngle; theta < endAngle; theta += Math.min(step, (endAngle - theta))) {
				holder.graphics.lineTo(xpos + segmentRadius * Math.cos(theta), ypos + segmentRadius * Math.sin(theta));
			}
			holder.graphics.lineTo(xpos + segmentRadius * Math.cos(endAngle), ypos + segmentRadius * Math.sin(endAngle));
			
			if(originalEnd > -1){ 
				startAngle = 0;
				endAngle = originalEnd * degreesPerRadian;
				for (theta = startAngle; theta < endAngle; theta += Math.min(step, endAngle - theta)) {
				  holder.graphics.lineTo(xpos + segmentRadius * Math.cos(theta), ypos + segmentRadius * Math.sin(theta));
				}
				holder.graphics.lineTo(xpos + segmentRadius * Math.cos(endAngle), ypos + segmentRadius * Math.sin(endAngle));
			}
			holder.graphics.lineTo(xpos, ypos);
			holder.graphics.endFill();
		   
			return holder;
		}
		
		private function clearListeners():void {
			Main.self.removeEventListener(ApplicationEvent.TIMER, update);
		} 
		
		private function setListeners():void {
			Main.self.addEventListener(ApplicationEvent.TIMER, update);
		}
		
		public function start(_currentProgress:Number = 0):void {
			if (_currentProgress < 0) _currentProgress = 0;
			if (_currentProgress > 1) _currentProgress = 1;
			_progress = _currentProgress;
			_time = int(_currentProgress * _duration);
			setListeners();
		}
		
		public function set progress(_currentProgress:Number):void{
			if (_currentProgress < 0) _currentProgress = 0;
			if (_currentProgress > 1) _currentProgress = 1;	
			_progress = _currentProgress;
			
			var posRadius:int = Math.round(360 * _progress);
			_maska.bitmapData = new BitmapData(_settings.radius * 2, _settings.radius * 2, true, 0xFF);
			_maska.bitmapData.draw(drawSegment(-90, posRadius - 90, _settings.radius + 2, _settings.radius, _settings.radius, 2, 0xEEEEEE, 0x003da8));
		}
		
		public function dispose():void {	
			clearListeners();
			if (parent) parent.removeChild(this);
		}
	}
}