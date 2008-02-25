/* AS3
	Copyright 2008 __MyCompanyName__.
*/
package br.com.stimuli.loading.tests {
	import asunit.framework.TestCase;
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    import flash.net.*;
    /**@private*/
    	public class GuessTypeTest extends TestCase {
    		private var _bulkLoader:BulkLoader;
            private var soundURL : URLRequest ;
            private var name : String;
    		/**
     		 * Constructor
     		 *
     		 * @param testMethod Name of the method to test
     		 */
     		public function GuessTypeTest(testMethod:String) {
     			super(testMethod);
     			this.name = testMethod;
     		}

    		/**
    	 	 * Prepare for test, create instance of class that we are testing.
    	 	 * Invoked by TestCase.runMethod function.
    	 	 */
    		protected override function setUp():void {
    	 		_bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
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
    	 		_bulkLoader.removeAll();
    	 	}

            /* ===================================================== */
            /* = Actual testes                                     = */
            /* ===================================================== */
            
            
    	 	public function testGuessTypeRelativeSimpleFLV():void {
    	 		assertEquals(BulkLoader.guessType("somehting.flv"), BulkLoader.TYPE_VIDEO);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimpleMP3():void {
    	 		assertEquals(BulkLoader.guessType("somehting.mp3"), BulkLoader.TYPE_SOUND);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimpleSWF():void {
    	 		assertEquals(BulkLoader.guessType("somehting.swf"), BulkLoader.TYPE_MOVIECLIP);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimpleXML():void {
    	 		assertEquals(BulkLoader.guessType("somehting.xml"), BulkLoader.TYPE_XML);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimpleTXT():void {
    	 		assertEquals(BulkLoader.guessType("somehting.txt"), BulkLoader.TYPE_TEXT);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimpleJPG():void {
    	 		assertEquals(BulkLoader.guessType("somehting.jpg"), BulkLoader.TYPE_IMAGE);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimplePNG():void {
    	 		assertEquals(BulkLoader.guessType("somehting.png"), BulkLoader.TYPE_IMAGE);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimpleGIF():void {
    	 		assertEquals(BulkLoader.guessType("somehting.gif"), BulkLoader.TYPE_IMAGE);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimpleJPEG():void {
    	 		assertEquals(BulkLoader.guessType("somehting.jpeg"), BulkLoader.TYPE_IMAGE);
    	 	}
    	 	
    	 	public function testGuessTypeRelativeSimplePNGUpper():void {
    	 		assertEquals(BulkLoader.guessType("somehting.PNG"), BulkLoader.TYPE_IMAGE);
    	 	}
    	 	
    	 	public function testWithQueryString() : void{
    	 	    assertEquals(BulkLoader.guessType("somehting.jpg?some=sds"), BulkLoader.TYPE_IMAGE);
    	 	}
    	 	
    	 	public function testWithEmptyQueryString() : void{
    	 	    assertEquals(BulkLoader.guessType("somehting.jpg?"), BulkLoader.TYPE_IMAGE);
    	 	}
    	 	
    	 	public function testWithNoExtensioAndQueryString() : void{
    	 	    assertEquals(BulkLoader.guessType("somehting?some=theQuery"), BulkLoader.TYPE_TEXT);
    	 	}
    	 	
    	 	public function testWithNoExtensio() : void{
    	 	    assertEquals(BulkLoader.guessType("somehting"), BulkLoader.TYPE_TEXT);
    	 	}
    	 	
    	 	public function testUnknownType() : void{
    	 	    var error : Error;
    	 	    try{
    	 	        _bulkLoader.add("fdfd.fdfsfs", {type:"dsds"})
    	 	    }catch(e : Error){
    	 	        error = e;
    	 	    }
    	 	    assertNotNull(error);
    	 	}
    	 	
    	 	

    	 	    
	}
}
