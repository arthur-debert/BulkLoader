package br.com.stimuli.kisstest.events{
    import flash.events.Event;
    import br.com.stimuli.kisstest.TestCase;
    import br.com.stimuli.kisstest.TestResult;
    public class TestResultEvent extends Event{
        
        public var test : TestCase;
        public var testResult : TestResult;
        
        public function TestResultEvent( test : TestCase, testResult : TestResult, name : String = Event.COMPLETE){
            this.test = test;
            this.testResult = testResult;
            super(name);
        }
        
        override public function toString() : String{
            return "[TestResultEvent] for test " + test ;
        }
    }
}