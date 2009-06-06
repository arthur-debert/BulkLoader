package{
    import br.com.stimuli.loading.lazyloaders.LazyXMLLoader;
    import br.com.stimuli.loading.lazyloaders.LazyBulkLoader;
    import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.*;
    import br.com.stimuli.loading.BulkProgressEvent;
    import flash.events.*;
    import flash.display.*;
    import flash.media.Sound;
    import flash.media.Video;
    import flash.net.NetStream;
    
    public class SerializedTestMain extends MovieClip{
        public var lazy : LazyXMLLoader;
        
        public function SerializedTestMain() : void{
            // create a lazy instance
            lazy  = new LazyXMLLoader("http://www.emptywhite.com/bulkloader-assets/lazyloader.xml", "theLazyLoader");
            // special event so that can tell when the xml file is loaded and
            // then attach events to indivudual items
            lazy.addEventListener(LazyBulkLoader.LAZY_COMPLETE, onLazyInfoLoaded)
            // these are just like events to the regular BulkLoader instance
            lazy.addEventListener(Event.COMPLETE, onAllLoaded);
            lazy.addEventListener(ProgressEvent.PROGRESS, onAllProgress);
            // tells lazy loader to start
            lazy.start();

        }
        
        public function onLazyInfoLoaded(evt : Event) : void{
            
            trace("serialized data is ready!", lazy)
            // attach an event listener specific for the video:
            lazy.get("http://www.emptywhite.com/bulkloader-assets/movie.flv").addEventListener(BulkLoader.COMPLETE, onVideoComplete);
        }
        
        public function onVideoComplete(evt : Event) : void{
            var theStream : NetStream = evt.target.content;
            trace("theStream", theStream);
            //...
        }
        
        public function onAllProgress(evt : BulkProgressEvent) : void{
            trace(evt.ratioLoaded);
        }

        function onAllLoaded(evt : Event) : void{
            trace("onAllLoaded", onAllLoaded);
            var xPos : int = 0;
            var yPos : int= 0;
            for each (var item : LoadingItem in lazy.items){
                if (item.isImage()){
                    var b : Bitmap = lazy.getBitmap(item.id);
                    //trace(item.loader.contentLoaderInfo.applicationDomain ==  ApplicationDomain.currentDomain );
                    addChild(b);
                    if (b.width > 200){
                        b.width = 200;
                        b.scaleY = b.scaleX;
                        b.x = xPos;
                        b.y = yPos;
                        xPos += b.width + 10;
                        if(xPos > 800){
                            xPos = 0;
                            yPos += 200;
                        }
                    }
                }else if (item.isSound()){
                    var sound : Sound = lazy.getSound(item.url);
                    sound.play();
            }    
            }
        }

        
    }
}
