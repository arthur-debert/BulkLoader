package br.com.stimuli.kisstest.events{
    import flash.events.Event;
    import br.com.stimuli.kisstest.TestCase;
    public class AssertionFailedEvent extends TestResultEvent{
        
        public var expected : *;
        public var returned : *;
        public var stack : String;
        public static const ASSERT_FAILED : String = "assertFailed";
        public function AssertionFailedEvent( expected : *, returned : * = null, stack : String= ""){
            super(new TestCase(""), null, ASSERT_FAILED);
            this.expected = expected;
            this.returned = returned;
            this.stack = stack;
            
        }
        
        override public function toString() : String{
            return "Expected "+( expected != null ? expected.toString() : "") + ", got: " +  (returned != null ? returned.toString() : ""); 
        }
    }
}