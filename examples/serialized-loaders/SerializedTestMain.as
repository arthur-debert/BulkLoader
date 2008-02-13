package{
    import br.com.stimuli.loading.LazyXMLLoader;
    import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.BulkProgressEvent;
    import flash.events.*;
    import flash.display.*;
    import flash.media.Sound;
    import flash.media.Video;
    import flash.net.NetStream;
    
    public class SerializedTestMain extends MovieClip{
        public var bulkLoader : BulkLoader;
        public var lazy : MyXMLLoader;
        
        public function SerializedTestMain() : void{
            lazy  = new MyXMLLoader("sample-lazy.xml");
            trace("lazy started", lazy);
            lazy.addEventListener(Event.COMPLETE, onLazyLoaded);
            lazy.addEventListener(ProgressEvent.PROGRESS, onLazyProgress);
            lazy.start();

        }
        
        public function onLazyLoaded(evt : Event) : void{

            bulkLoader = evt.target.bulkLoader;
                        trace("serialized data is ready!", bulkLoader)
            bulkLoader.addEventListener(BulkLoader.PROGRESS, onAllProgress);
            bulkLoader.start();
        }

        public  function onLazyProgress(evt: ProgressEvent) : void{
            trace("lazy progress", evt.bytesLoaded, evt.bytesTotal, evt.bytesLoaded/ evt.bytesTotal);
        }


        public function onAllProgress(evt : BulkProgressEvent) : void{
            //trace(evt.ratioLoaded);
        }

        function onAllLoaded(evt : Event) : void{

            var xPos : int = 0;
            var yPos : int= 0;
            for each (var item : LoadingItem in bulkLoader.items){
                if (item.isImage()){
                    var b : Bitmap = bulkLoader.getBitmap(item.id);
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
                    var sound : Sound = bulkLoader.getSound("soundtrack");
                    sound.play();
            }    else if (item.isVideo()){
                    var video : Video = new Video();
                    var netStream : NetStream = bulkLoader.getNetStream("the-video");
                    netStream.resume();
                    trace("{loader_test}::method()  video",  video, netStream);
                    addChild(video);
                    video.attachNetStream(netStream);
                    if (video.width > 200){
                        video.width = 200;
                        video.scaleY = video.scaleX;
                        video.x = xPos;
                        video.y = yPos;
                        xPos += video.width + 10;
                        if(xPos > 800){
                            xPos = 0;
                            yPos += 200;
                        }
                    }
                }
            }
        }

        
    }
}
