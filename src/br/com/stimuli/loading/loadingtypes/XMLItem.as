package br.com.stimuli.loading.loadingtypes {
	
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import br.com.stimuli.loading.BulkLoader;
	import flash.display.*;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    /** @private */
	public class XMLItem extends LoadingItem {
        public var loader : URLLoader;
        
		public function XMLItem(url : URLRequest, type : String, uid : String){
			super(url, type, uid);
		}
		
		override public function _parseOptions(props : Object)  : Array{
            return super._parseOptions(props);
        }
        
		override public function load() : void{
		    super.load();
		    loader = new URLLoader();
		    loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
            loader.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, super.onHttpStatusHandler, false, 0, true);
            loader.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
            loader.load(url);
		};
		
		override public function onErrorHandler(evt : Event) : void{
            super.onErrorHandler(evt);
        }
        
		override public function onStartedHandler(evt : Event) : void{
            super.onStartedHandler(evt);
        };
        
        override public function onCompleteHandler(evt : Event) : void {
            _content = new XML(loader.data);
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
            loader.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler, false);
            loader.removeEventListener(Event.COMPLETE, onCompleteHandler, false);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false);
            loader.removeEventListener(BulkLoader.OPEN, onStartedHandler, false);
            loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, super.onHttpStatusHandler, false);
        }
        
        override public function isText(): Boolean{
            return true;
        }
        
        override public function destroy() : void{
            stop();
            cleanListeners();
            _content = null;
            loader = null;
        }
        
	}
	
}
