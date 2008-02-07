package br.com.stimuli.loading.loadingtypes {
	
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import br.com.stimuli.loading.BulkLoader;
	import flash.display.*;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
	public class URLItem extends LoadingItem {
        public var loader : URLLoader;
        
		public function URLItem(url : URLRequest, type : String, internalType : String){
			super(url, type, internalType);
		}
		
		override public function parseOptions(props : Object)  : void{
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
		    loader = new URLLoader();
		    loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
            loader.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
            loader.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
            loader.load(url);
		};
		override public function onStartedHandler(evt : Event) : void{
            super.onStartedHandler(evt);
        };
        
        override public function onCompleteHandler(evt : Event) : void {
            if(_type == BulkLoader.TYPE_XML){
                  _content = new XML(loader.data);
              }else{
                  _content = loader.data;
              }
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
