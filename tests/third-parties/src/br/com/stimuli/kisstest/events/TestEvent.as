package br.com.stimuli.kisstest.events{
    import flash.events.Event;
    
    import br.com.stimuli.kisstest.TestCase;
    
    
    public class TestEvent extends Event{
        public static const TEST_FINISHED : String = "testFinished";
        public static const TEST_SUCCEEDED : String = "testSucceeded";
        public static const TEST_STARTED : String = "testStarted";
        public static const TEST_FAILED : String = "testFinished";
        public static const TEST_ERROR : String = "testError";
        
        public var test : TestCase;
        public function TestEvent (name : String, test : TestCase){
            super(name);
            this.test = test;
            if (!test){
                throw new Error("Cannot create TestEvent will null test");
            }
        }
}
    }