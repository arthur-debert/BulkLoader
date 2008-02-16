package br.com.stimuli.loading.loadingtypes {
	
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import br.com.stimuli.loading.BulkLoader;
	import flash.display.*;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.media.Sound;
	public class SoundItem extends LoadingItem {
        public var loader : Sound;
        
		public function SoundItem(url : URLRequest, type : String){
			super(url, type);
		}
		
		override public function parseOptions(props : Object)  : Array{
		    context = props[BulkLoader.CONTEXT] || null;
		    
            // internal, used to sort items of the same priority
            // checks that we are not adding any inexistent props, aka, typos on props :
            for (var propName :String in props){
                /*if (AVAILABLE_PROPS.indexOf(propName) == -1){
                                    log("add got a wrong property name: " + propName + ", with value:" + props[propName]);
                                }*/
            }
            return super.parseOptions(props);
        }
        
		override public function load() : void{
		    super.load();
		    loader = new Sound();
		    loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
            loader.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
            loader.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
            loader.load(url, context);
		};
		
		override public function onStartedHandler(evt : Event) : void{
            _content = loader;
            super.onStartedHandler(evt);
            //trace("{SoundItem}::method() context", context);
        };
        
        override public function onCompleteHandler(evt : Event) : void {
            _content = loader
            super.onCompleteHandler(evt);
        };
        
        override public function stop() : void{
            try{
                if(loader){
                    loader.close();
                }
            }catch(e : Error){
                
            }
            super.stop();
        };
        
        override public function cleanListeners() : void {
            if (loader){
                loader.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler, false);
                loader.removeEventListener(Event.COMPLETE, onCompleteHandler, false);
                loader.removeEventListener(IOErrorEvent.IO_ERROR, super.onErrorHandler, false);
                loader.removeEventListener(BulkLoader.OPEN, onStartedHandler, false);
            }
            
        }
        
        override public function isStreamable(): Boolean{
            return true;
        }
        
        override public function isSound(): Boolean{
            return true;
        }
        
        override public function destroy() : void{
            cleanListeners();
            _content = null;
            loader = null;
        }
        
	}
	
}
