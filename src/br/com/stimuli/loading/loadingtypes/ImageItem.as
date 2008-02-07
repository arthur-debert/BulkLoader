package br.com.stimuli.loading.loadingtypes {
	
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import br.com.stimuli.loading.BulkLoader;
	import flash.display.*;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
	public class ImageItem extends LoadingItem {
        public var loader : Loader;
        
		public function ImageItem(url : URLRequest, type : String, internalType : String){
			super(url, type, internalType);
		}
		
		override public function parseOptions(props : Object)  : void{
            context = props[BulkLoader.CONTEXT] || null;
            // internal, used to sort items of the same priority
            // checks that we are not adding any inexistent props, aka, typos on props :
            for (var propName :String in props){
                /*if (AVAILABLE_PROPS.indexOf(propName) == -1){
                                    log("add got a wrong property name: " + propName + ", with value:" + props[propName]);
                                }*/
            }
            super.parseOptions(props);
        }
        
		override public function load() : void{
		    super.load();
		    loader = new Loader();
		    loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
            loader.contentLoaderInfo.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);  
            loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandler, false, 0, true);
            loader.load(url, context);
		};
		
        override public function onCompleteHandler(evt : Event) : void {
            _content = loader.content;
            trace("{ImageItem}::method() onCompleteHandler", onCompleteHandler);
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
                var removalTarget : Object = loader.contentLoaderInfo;
                removalTarget.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler, false);
                removalTarget.removeEventListener(Event.COMPLETE, onCompleteHandler, false);
                removalTarget.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false);
                removalTarget.removeEventListener(BulkLoader.OPEN, onStartedHandler, false);
            }
            
        }
        
        override public function isImage(): Boolean{
            return true;
        }
        
        override public function destroy() : void{
            cleanListeners();
            _content = null;
            loader = null;
        }
        
	}
	
}
