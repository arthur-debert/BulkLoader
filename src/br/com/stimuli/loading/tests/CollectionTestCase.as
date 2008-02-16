/* AS3
	Copyright 2008 __MyCompanyName__.
*/
package br.com.stimuli.loading.tests {
	import asunit.framework.TestCase;
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    import flash.net.*;
    	public class CollectionTestCase extends TestCase {
    		private var _bulkLoader:BulkLoader;
            private var soundURL : URLRequest ;
    		/**
     		 * Constructor
     		 *
     		 * @param testMethod Name of the method to test
     		 */
     		public function CollectionTestCase(testMethod:String) {
     			super(testMethod);
     		}

    		/**
    	 	 * Prepare for test, create instance of class that we are testing.
    	 	 * Invoked by TestCase.runMethod function.
    	 	 */
    		protected override function setUp():void {
    	 		_bulkLoader = new BulkLoader("test-loader");
    	 		soundURL = new URLRequest("http://www.emptywhite.com/bulkloader-assets/chopin.mp3");
    	 		_bulkLoader.add(soundURL, {id:"the-sound"});
    	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true});
    	 		_bulkLoader.start();
    	 	}

    		/**
    	 	 * Clean up after test, delete instance of class that we were testing.
    	 	 */
    	 	protected override function tearDown():void {
    	 		_bulkLoader.removeAll();
    	 	}

            /* ===================================================== */
            /* = Actual testes                                     = */
            /* ===================================================== */
            
            
    	 	public function testGetById():void {
    	 		assertNotNull("Get by id", _bulkLoader.get("the-movie"));
    	 	}

    	 	public function testGetByURL():void {
    	 		assertNotNull("Get by URL", _bulkLoader.get(soundURL));
    	 	}
    	 	
            public function testCorrectNumber() : void{
                assertEquals(_bulkLoader.items.length, 2);
            }
            
            public function testCannotAddTwoItemsWithTheSameID() : void{
                var lenghtBeforeAdding : int = _bulkLoader.items.length;
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/other-movie.flv", {id:"the-movie", pausedAtStart:true});
                var lenghtAfterAdding : int = _bulkLoader.items.length;
                assertEquals(lenghtBeforeAdding, lenghtAfterAdding);
            }
            
            public function testCannotCreateEmptyItem() : void{
                var error : Error;
                try{
                    var item : LoadingItem = _bulkLoader.add(null);
                }catch (e : Error){
                    error = e;
                }
                assertNotNull( error);
            }
            
            public function testRemoveOneItem() : void{
                var lenghtBeforeRemoving : int = _bulkLoader.items.length;
                _bulkLoader.remove("the-movie");
                var lenghtAfterRemoving : int = _bulkLoader.items.length;
                assertEquals(lenghtBeforeRemoving, lenghtAfterRemoving + 1);
            }

            public function testRemoveAllLength() : void{
                _bulkLoader.removeAll();
                assertTrue(_bulkLoader.items.length == 0)
            }
            
            public function testConnectionsNotNullOnRemoveAll() : void{
                _bulkLoader.removeAll();
                assertTrue(_bulkLoader._connections.length == 0)
            }
            
            public function testPauseAllIsRunning() : void{
                assertTrue(_bulkLoader.isRunning)
                _bulkLoader.pauseAll();
                assertFalse(_bulkLoader.isRunning)
            }
            
            public function testPauseHarmlessAfterAllIsLoaded() : void{
                _bulkLoader.pauseAll();
                // we need to be able to get access to loaded items:
                assertNotNull(_bulkLoader.get("the-sound"));
                assertNotNull(_bulkLoader.get("the-movie"));
            }
            
            public function testHasItemInLoader() : void{
                trace(0)
                return;
                assertTrue(_bulkLoader._hasItemInBulkLoader("the-sound", _bulkLoader));
                trace(1)
                assertFalse(_bulkLoader._hasItemInBulkLoader("badkey", _bulkLoader));
                trace(2)
                var newLoader : BulkLoader = new BulkLoader("otherLoader");
                trace(3)
                assertFalse(newLoader._hasItemInBulkLoader("the-sound", newLoader));
            }
    	}
    
	
}
