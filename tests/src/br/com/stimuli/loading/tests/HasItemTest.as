package br.com.stimuli.loading.tests {
    import flash.net.URLRequest;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.display.*;
    import br.com.stimuli.kisstest.TestCase;
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
    /**@private*/
    public class HasItemTest extends TestCase { 
    
        public var _bulkLoader : BulkLoader;
        public var lastProgress : Number = 0;


        public var ioError : Event;

        public var dispatchedProgressAfterComplete : Boolean = false;
        public var numHasItems : int = 0;
        public var timer : Timer;
        public function HasItemTest(name : String) : void {
            super(name);
            this.name = name;
        }
        public var items :Array = [
            "http://www.emptywhite.com/bulkloader-assets/some-text.txt",
            "http://www.emptywhite.com/bulkloader-assets/movie.flv" ,
            "http://www.emptywhite.com/bulkloader-assets/samplexml.xml",
            "http://www.emptywhite.com/bulkloader-assets/shoes.jpg", 
            "http://www.emptywhite.com/bulkloader-assets/chopin.mp3" 
        ]
        // Override the run method and begin the request for remote data
        public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            for each(var url : String in items){_bulkLoader.add(url, {"preventCache":true});}
            _bulkLoader.start();
            _bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
            _bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
            for each(url in items){
                if (_bulkLoader.hasItem(url)) numHasItems ++;
            }
        }

        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandler(evt);
            tearDown();
        }

        public function completeHandler(event:Event):void {
            timer = new Timer(2000, 1);
            timer.addEventListener( TimerEvent.TIMER_COMPLETE, runWrapper)
                timer.start();
        }

        public function runWrapper(evt : Event) : void{
            dispatchEvent(new Event(Event.INIT));
        }

        /** This also works as an assertion that event progress will never be NaN
         */
        public function progressHandler(event:ProgressEvent):void {
            //var evt : * = event as Object;
            var current :Number = Math.floor((event as Object).percentLoaded * 100) /100;
            var delta : Number = current - lastProgress;
            if (current > lastProgress && delta > 0.099){
                lastProgress = current;
                if (BulkLoaderTestSuite.LOADING_VERBOSE) trace(current * 100 , "% loaded") ;
            }
            for each(var propName : String in ["percentLoaded", "weightPercent", "ratioLoaded"] ){
                if (isNaN(event[propName]) ){
                    trace(propName, "is not a number" );
                    assertFalse(isNaN(event[propName]));
                }
            }
        }



        override public function tearDown():void {
            _bulkLoader.clear();
            BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
        }

        public function testHasItemsIsFalseAtStart():void {
            assertEquals(numHasItems, 0);
        }


        public function testHasItemsIsTrueOnLoad() : void{
            numHasItems = 0;
            for each(var url :String in items){
                if (_bulkLoader.hasItem(url)) numHasItems ++;
            }
            assertEquals(numHasItems, items.length);
        }
   }
}
