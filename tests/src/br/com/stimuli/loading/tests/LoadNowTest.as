/* AS3
	Copyright 2008 __MyCompanyName__.
*/
package br.com.stimuli.loading.tests {
	import kisstest.TestCase;
    import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    import flash.net.*;
    import flash.events.*;
    /**@private*/
    	public class LoadNowTest extends TestCase {
    		 public var _bulkLoader:BulkLoader;
            private var soundURL : URLRequest ;
            
    		/**
     		 * Constructor
     		 *
     		 * @param testMethod Name of the method to test
     		 */
     		public function LoadNowTest(testMethod:String) {
     			super(testMethod);
     			name = testMethod;
     		}

    		/**
    	 	 * Prepare for test, create instance of class that we are testing.
    	 	 * Invoked by TestCase.runMethod function.
    	 	 */
    		override public function setUp():void {
    	 		_bulkLoader = new BulkLoader(BulkLoader.getUniqueName(), 1);
    	 		soundURL = new URLRequest("http://www.emptywhite.com/bulkloader-assets/chopin.mp3");
    	 		_bulkLoader.add(soundURL, {id:"the-sound", priority:100, preventCache:true});
    	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true, priority:200, preventCache:true});
    	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/some-text.txt", {id:"text", preventCache:true});
    	 		_bulkLoader.start();
    	 		// make sure loadNow wont fail before items are loaded:
                _bulkLoader.loadNow("the-movie");
    	 		dispatchEvent(new Event(Event.INIT));
    	 	}

    		/**
    	 	 * Clean up after test, delete instance of class that we were testing.
    	 	 */
    	 	override public function tearDown():void {
            var theMovie : LoadingItem = _bulkLoader.get("the-movie");
			if(theMovie) theMovie.stop();
            BulkLoader.removeAllLoaders();
            	_bulkLoader = null;
    	 	}

            /* ===================================================== */
            /* = Actual testes                                     = */
            /* ===================================================== */
            
            
    	 	public function testLoadNow():void {
    	 	    var item : LoadingItem = _bulkLoader.get("text");
    	 	    var status : String = item.status
    	 	    assertTrue(item.status == null);
    	 	    assertFalse(item._isLoading);
    	 	    // now force load
    	 	    _bulkLoader.loadNow("text");
    	 	    assertTrue(item._isLoading);
    	 	    assertTrue(_bulkLoader._connections.indexOf(item) >= 0);
	 	    }
    	}
    
	
}
