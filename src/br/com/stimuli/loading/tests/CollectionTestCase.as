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
            

            
    	}
    
	
}
