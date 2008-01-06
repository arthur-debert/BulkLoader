package{
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.BulkProgressEvent;
    import flash.events.*;
    import flash.display.*;
    import flash.media.*;
    import flash.net.*;

    public class SimpleExampleMain extends MovieClip{
        public var loader : BulkLoader;
        public var v : Video;
        public var counter : int = 0;

        // simple example with few features
        // it takes a long time to download everything, it's over 17 mb
        public function SimpleExampleMain() {
            // creates a BulkLoader instance with a name of "main-site", that can be used to retrieve items without having a reference to this instance
            loader = new BulkLoader("main-site");
            // set level to verbose, for debugging only
            loader.logLevel = BulkLoader.LOG_INFO;
            // now add items to load
            // simplest case:
            loader.add("http://www.emptywhite.com/bulkloader-assets/cats.jpg");
            // use an "id" so the item can be retrieved later without a reference to the url
            loader.add("http://www.emptywhite.com/bulkloader-assets/shoes.jpg", {id:"bg"});
            // add an item that should be loaded first (higher priority):
            loader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {priority:20, id:"config-xml"});
            // add a video, and force it to load paused
            loader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {maxTries:6, id:"the-video", pausedAtStart:true});            
            // of course, options can be combined:
            loader.add("http://www.emptywhite.com/bulkloader-assets/chopin.mp3", {"id":"soundtrack", maxTries:1, priority:100});
            
            // dispatched when ALL the items have been loaded:
            loader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
            
            // dispatched when any item has progress:
            loader.addEventListener(BulkLoader.PROGRESS, onAllItemsProgress);
            
            // now start the loading
            loader.start();
        }
        
        public function onAllItemsLoaded(evt : Event) : void{
            trace("every thing is loaded!");
            // attach the vídeo:
            var video : Video = new Video();
            // get the nestream from the bulkloader:
            var theNetStream : NetStream = loader.getNetStream("the-video");
            addChild(video);
            video.attachNetStream(theNetStream);
            theNetStream.resume();
            video.y = 300;
            // grab the images
            
            // you can get the content from the url:
            var bitmapCats : Bitmap = loader.getBitmap("http://www.emptywhite.com/bulkloader-assets/cats.jpg")
            bitmapCats.width = 200;
            bitmapCats.scaleY = bitmapCats.scaleX;
            addChild(bitmapCats);
            
            // you can get by the id as well (easier):
            var bitmapShoes : Bitmap = loader.getBitmap("bg")
            bitmapShoes.width = 200;
            bitmapShoes.scaleY = bitmapShoes.scaleX;
            bitmapShoes.x = 220;
            addChild(bitmapShoes);
            
            // get the sound:
            var soundtrack : Sound = loader.getSound("soundtrack");
            soundtrack.play();
            
            // get an xml file!
            var theXML : XML = loader.getXML("config-xml");
            trace(theXML);
        }
        
        // this evt is a "super" progress event, it has all the information you need to 
        // display progress by many criterias (bytes, items loaded, weight)
        public function onAllItemsProgress(evt : BulkProgressEvent) : void{
            trace(evt.loadingStatus());
        }
    }
}



