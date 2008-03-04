/* AS3
	Copyright 2008 __MyCompanyName__.
*/
package br.com.stimuli.loading.tests {
	import asunit.framework.TestCase;
    import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    import flash.net.*;
    import flash.events.*;
    	public class CollectionTestCase extends TestCase {
    		private var _bulkLoader:BulkLoader;
            private var soundURL : URLRequest ;
            public var name : String;
    		/**
     		 * Constructor
     		 *
     		 * @param testMethod Name of the method to test
     		 */
     		public function CollectionTestCase(testMethod:String) {
     			super(testMethod);
     			name = testMethod;
     		}

    		/**
    	 	 * Prepare for test, create instance of class that we are testing.
    	 	 * Invoked by TestCase.runMethod function.
    	 	 */
    		protected override function setUp():void {
    	 		_bulkLoader = new BulkLoader(BulkLoader.getUniqueName());
    	 		soundURL = new URLRequest("http://www.emptywhite.com/bulkloader-assets/chopin.mp3");
    	 		_bulkLoader.add(soundURL, {id:"the-sound"});
    	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true});
    	 		_bulkLoader.start();
    	 	}

    		/**
    	 	 * Clean up after test, delete instance of class that we were testing.
    	 	 */
    	 	protected override function tearDown():void {
            var theMovie : LoadingItem = _bulkLoader.get("the-movie");
			if(theMovie) theMovie.stop();
            BulkLoader.removeAllLoaders();
            //trace("REMOVED ALL _bulkLoader.itemsTotal", _bulkLoader.itemsTotal);
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
            
            public function testCanAddTwoItemsSameURL() : void{
                var oldNumber : int = _bulkLoader.itemsTotal;
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv");
                assertEquals(oldNumber+ 1, _bulkLoader.itemsTotal);
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
            
            public function testRemoveOneItemLengthCorrect() : void{
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
                return;
                assertTrue(_bulkLoader._hasItemInBulkLoader("the-sound", _bulkLoader));
                
                assertFalse(_bulkLoader._hasItemInBulkLoader("badkey", _bulkLoader));
                
                var newLoader : BulkLoader = new BulkLoader("otherLoader");
                
                assertFalse(newLoader._hasItemInBulkLoader("the-sound", newLoader));
            }
            
            public function testAddWithBadURLType() : void{
                var error : Error;
                try{
                    var item : LoadingItem = _bulkLoader.add(new Event("dsds"));
                }catch (e : Error){
                    error = e;
                }
                assertNotNull( error);
            }
            
            public function testIsFinhisedAfterLoaded() : void{
                assertFalse(_bulkLoader.isFinished);
            }
            
            public function testTotalWight() : void{
                var totalWeight : int = _bulkLoader.totalWeight;
                _bulkLoader.add("some");
                assertEquals(totalWeight + 1, _bulkLoader.totalWeight);
                totalWeight += 1;
                _bulkLoader.add("some-more", {"weight": 10});
                assertEquals(totalWeight + 10, _bulkLoader.totalWeight );
            }
            
            public function testItemsTotal() : void{
                var itemsTotal : int = _bulkLoader.itemsTotal;
                _bulkLoader.add("some");
                assertEquals(itemsTotal + 1, _bulkLoader.itemsTotal);
                itemsTotal += 1;
                _bulkLoader.add("some-more", {"weight": 10});
                assertEquals(itemsTotal + 1, _bulkLoader.itemsTotal );
            }
            
            public function testSortPriorityOnAdd() : void{            
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/shoes.jpg", {"priority":200, id:"photo"});
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {"priority":-200, id:"xml"});
                assertEquals(_bulkLoader.items[_bulkLoader.itemsTotal -1] , _bulkLoader.get("xml"));
                assertEquals(_bulkLoader.items[0] , _bulkLoader.get("photo"));
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/some-text.txt", {"priority":-200, id:"txt"});
                assertTrue(_bulkLoader.items.indexOf(_bulkLoader.get("xml")) > _bulkLoader.items.indexOf(_bulkLoader.get("text")));
            }
            
            public function testGetLeastUrgentItem() : void{
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/some-text.jpg", {"priority":-200, id:"text"});
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/shoes.jpg", {"priority":-200, id:"photo"});
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {"priority":200, id:"xml"});
                _bulkLoader.start();
                assertEquals(_bulkLoader._getLeastUrgentOpenedItem() , _bulkLoader.get("text"));
            }
                        
            public function testHighestPriority() : void{
                assertEquals(_bulkLoader.highestPriority, 0);
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/some-text.jpg", {"priority":-200, id:"text"});
                assertEquals(_bulkLoader.highestPriority,  0);
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {"priority":200, id:"xml"});
                assertEquals(_bulkLoader.highestPriority , 200);    
            }
            

            public function testLogFunctionSet() : void{
                var myFunction : Function = function(msg:String):void{
                    trace("myFunction", msg);
                }
                _bulkLoader.logFunction = myFunction;
                assertEquals(_bulkLoader.logFunction, myFunction)
            }
            
            public function testChangeItemPriority() : void{
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/shoes.jpg", { id:"photo"});
                assertTrue(_bulkLoader.items[0] != _bulkLoader.get("photo"))
                _bulkLoader.changeItemPriority("photo", 100);
                assertEquals(_bulkLoader.items[0], _bulkLoader.get("photo"))
            }
            
            public function testRemovePausedItems ():void{
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/some-text.jpg", {"priority":-200, id:"text"});
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/shoes.jpg", {"priority":-200, id:"photo"});
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {"priority":200, id:"xml"});
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {"priority":200, id:"xml2"});
                _bulkLoader.pause("text");
                _bulkLoader.pause("photo");
                _bulkLoader.pause("xml");
                _bulkLoader.removePausedItems();
                assertNull(_bulkLoader.get("text"));
                assertNull(_bulkLoader.get("photo"));
                assertNull(_bulkLoader.get("xml"));
                // now make sure we have not removed the wrong ones:
                assertNotNull(_bulkLoader.get("the-movie"));
                assertNotNull(_bulkLoader.get("xml2"));
            
            }
    	}
    
	
}
