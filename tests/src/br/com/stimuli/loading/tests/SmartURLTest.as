package br.com.stimuli.loading.tests {
    import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.utils.SmartURL;
    
    import flash.events.*;
    import flash.net.*;
    
    import br.com.stimuli.kisstest.TestCase;
    /**@private*/
        public class SmartURLTest extends TestCase {
             public var _bulkLoader:BulkLoader;
            private var soundURL : URLRequest ;
            
            public var subs : Object;
            /**
             * Constructor
             *
             * @param testMethod Name of the method to test
             */
            public function SmartURLTest(testMethod:String) {
                // here
                super(testMethod);
            }

            /**
             * Prepare for test, create instance of class that we are testing.
             * Invoked by TestCase.runMethod function.
             */
            override public function setUp():void {
                dispatchEvent( new Event(Event.INIT));
            }

            /**
             * Clean up after test, delete instance of class that we were testing.
             */
            override public function tearDown():void {
            }

            /* ===================================================== */
            /* = Actual testes                                     = */
            /* ===================================================== */
            
            
            
            public function testSmartURLHosts() : void{
                var sm : SmartURL = new SmartURL("http://www.nytimes.com/");
                assertEquals("www.nytimes.com", sm.host);
                sm  = new SmartURL("http://nytimes.com/");
                assertEquals("nytimes.com", sm.host);
                sm  = new SmartURL("http://nytimes.com");
                assertEquals("nytimes.com", sm.host);
                sm  = new SmartURL("http://blah.something.nytimes.com/");
                assertEquals("blah.something.nytimes.com", sm.host);
                sm  = new SmartURL("http://nytimes.com/somePath");
                assertEquals("nytimes.com", sm.host);
                sm  = new SmartURL("http://nytimes.com:1020/somePath");
                assertEquals("nytimes.com", sm.host);
                sm  = new SmartURL("http://nytimes.com:1020/");
                assertEquals("nytimes.com", sm.host);
                sm  = new SmartURL("http://nytimes.com:1020");
                assertEquals("nytimes.com", sm.host);
                sm  = new SmartURL("/somefile.jpg");
                assertEquals(null, sm.host);
            }
            
            public function testSmartURLPorts() : void{
                var sm : SmartURL = new SmartURL("http://www.nytimes.com/");
                assertEquals("www.nytimes.com", sm.host);
                assertEquals(80, sm.port);
                sm = new SmartURL("http://www.nytimes.com:1000/");
                assertEquals("www.nytimes.com", sm.host);
                assertEquals(1000, sm.port);
                sm = new SmartURL("http://www.nytimes.com:1000");
                 assertEquals("www.nytimes.com", sm.host);
                 assertEquals(1000, sm.port);
                sm  = new SmartURL("/somefile.jpg");
                assertEquals(80, sm.port);
            }
            
            public function testSmartURLPaths() : void{
                var sm : SmartURL = new SmartURL("http://www.nytimes.com/some-dir/");
                assertEquals("/some-dir/", sm.path);
                sm  = new SmartURL("http://www.nytimes.com/");
                assertEquals("/", sm.path);
                sm  = new SmartURL("http://www.nytimes.com/some-dir");
                assertEquals("/some-dir", sm.path);
                sm  = new SmartURL("http://www.nytimes.com:1000/some-dir");
                assertEquals("/some-dir", sm.path);
                sm  = new SmartURL("http://www.nytimes.com:1000/some-dir/other/");
                assertEquals("/some-dir/other/", sm.path);
                sm  = new SmartURL("http://www.nytimes.com:1000/some-dir/other/blah.txt");
                assertEquals("/some-dir/other/blah.txt", sm.path);
                sm  = new SmartURL("http://www.nytimes.com:1000/some-dir/other/?value=pair");
                assertEquals("/some-dir/other/", sm.path);
            }
            
            public function testSmartURLQuery() : void{
                var sm : SmartURL = new SmartURL("http://www.nytimes.com/some-dir/");
                assertEquals(null, sm.queryObject);
                sm  = new SmartURL("http://www.nytimes.com/some-dir/?name=arthur");
                assertEquals("arthur", sm.queryObject["name"]);
                sm  = new SmartURL("http://www.nytimes.com/some-dir/?name=arthur&age=30");
                assertEquals("arthur", sm.queryObject["name"]);
                assertEquals("30", sm.queryObject["age"]);
            }
            
            
    }
    
    
}
