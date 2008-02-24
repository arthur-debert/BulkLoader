package br.com.stimuli.loading.tests {
	import asunit.framework.TestCase;
    import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    import flash.net.*;
    import flash.events.*;
    	public class AutoIdTest extends TestCase {
    		private var _bulkLoader:BulkLoader;
            private var soundURL : URLRequest ;
            public var name : String;
            public var subs : Object;
    		/**
     		 * Constructor
     		 *
     		 * @param testMethod Name of the method to test
     		 */
     		public function AutoIdTest(testMethod:String) {
     			super(testMethod);
     			name = testMethod;
     		}

    		/**
    	 	 * Prepare for test, create instance of class that we are testing.
    	 	 * Invoked by TestCase.runMethod function.
    	 	 */
    		protected override function setUp():void {
    	 		_bulkLoader = new BulkLoader(BulkLoader.getUniqueName()); 
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
            
            
            
    	 	public function testNoAutoID():void {
    	 	    // test stuff no no subs are ok 
    	 	    _bulkLoader.alowsAutoIDFromFileName = false;
    	 	    var item : LoadingItem = _bulkLoader.add("some-url.jpg");
    	 	    assertNull(item.id);
	 	    }
	 	    
	 	    public function testAutoWontOverwriteNormalID():void {
    	 	    // test stuff no no subs are ok 
    	 	    _bulkLoader.alowsAutoIDFromFileName = true;
    	 	    var item : LoadingItem = _bulkLoader.add("some-url.jpg", {id:"image"});
    	 	    assertEquals(item.id, "image");
	 	    }
	 	    
	 	    public function testFileNameGuessing() : void{
	 	        assertEquals(BulkLoader.getFileName("http:/dsdsd/dsdsd/image"), "image");
	 	    }
	 	    
	 	    public function testFileNameGuessingWithExtension() : void{
	 	        assertEquals(BulkLoader.getFileName("http:/dsdsd/dsdsd/image.jpg"), "image");
	 	    }
	 	    
	 	    public function testFileNameGuessingWithExtensionAndQuery() : void{
	 	        assertEquals(BulkLoader.getFileName("http:/dsdsd/dsdsd/image.jpg?dsds=jhdjs"), "image");
	 	    }
	 	    
	 	    public function testFileNameGuessingWithQuery() : void{
	 	        assertEquals(BulkLoader.getFileName("http:/dsdsd/dsdsd/image?dsds-dsd"), "image");
	 	    }
	 	    
	 	    public function testFileNameGuessingEndingWithSlash() : void{
	 	        assertEquals(BulkLoader.getFileName("http:/dsdsd/dsdsd/image/"), "image");
	 	    }
	 	    
	 	    public function testFileNameGuessingRelative() : void{
	 	        assertEquals(BulkLoader.getFileName("image.jpg"), "image");
	 	    }
	 	    
	 	    public function testFileNameGuessingRelativeWithDash() : void{
	 	        assertEquals(BulkLoader.getFileName("/image.jpg"), "image");
	 	    }
	 	    
	 	    public function testAutoWorks():void {
	 	     // test stuff no no subs are ok 
                 _bulkLoader.alowsAutoIDFromFileName = true;
                 var item : LoadingItem = _bulkLoader.add("theImage.jpg");
                 assertEquals(item.id, "theImage");
             }
    
	 	    
    }
    
	
}
