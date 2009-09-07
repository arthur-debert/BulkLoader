package br.com.stimuli.loading
{
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.containers.HBox;
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarMode;

	public class LoadingItemRenderer extends HBox{
		public var pb : ProgressBar;
		public var oldValue : Object;
		//public var src : Object;
		public function LoadingItemRenderer()
		{
				
		}
		
	

    
    
		override protected function createChildren() : void{
			pb = new ProgressBar();
			pb.mode = ProgressBarMode.MANUAL;
			pb.width = 170;
			pb.labelPlacement = "right";
			pb.label = "";
			pb.setStyle("trackHeight", 20);
			pb.setStyle("fontWeight", "normal");
			addChild(pb);
			pb.setStyle("labelWidth", 50);
			pb.setStyle("isOverBar", false);
			pb.setStyle("verticalGap", 0);
		}
		
		override public function set data(value : Object):void{
			if(oldValue){
				oldValue.removeEventListener("progress", onItemProgress, false);
				oldValue.removeEventListener("complete", onDone, false);
			}
			oldValue = value;
			
			oldValue.addEventListener("progress", onItemProgress, false, 0, true);
			oldValue.addEventListener("complete", onDone, false, 0, true);
			updateProgress(value as LoadingItem);
			
		}
		
		public function onDone(evt : Event):void{
			var src : LoadingItem = evt.target as LoadingItem;
			updateBarColor(src);
		}
		
		public function updateBarColor(item : LoadingItem) : void{
			
			var c : uint = 0;
			var trackColors : Array = [0xE6EEEE,0xE6EEEE];
			switch(item.status){
				case LoadingItem.STATUS_FINISHED:
					c = 0x00FF00;
					break;
				case LoadingItem.STATUS_STARTED:
					c = 0x0000FF;
					break;
				case LoadingItem.STATUS_ERROR:
					c = 0xFF0000;
					trackColors =  [0xFF0000,0xFF0000];
					break;
				case LoadingItem.STATUS_STOPPED:
					c = 0x888888;
					break;
			}
			if(c != 0){
				pb.setStyle(".barColor", c);
				pb.setStyle("trackColors", trackColors);
			}
		}
		
		public function onItemProgress(evt : ProgressEvent):void{
			var src : LoadingItem = evt.target as LoadingItem;
			updateProgress(src);
		}
		
		public function updateProgress(src : LoadingItem) : void{
			
			pb.setProgress(src.bytesLoaded, src.bytesTotal);
			pb.toolTip = src.bytesLoaded + "/" + src.bytesTotal;
			updateBarColor(src);
			
			pb.label= src.humanFiriendlySize;

 		//	trace(evt.bytesLoaded/ evt.bytesTotal)
		}
	}
}