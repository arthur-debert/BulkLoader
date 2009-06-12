package kisstest.runners
{
    import br.com.stimuli.kisstest.TestRunner;
    import br.com.stimuli.kisstest.TestSuite;
    import br.com.stimuli.kisstest.events.TestEvent;
    import br.com.stimuli.kisstest.events.TestResultEvent;
    
    public class TraceRunner extends TestRunner
    {
        public function TraceRunner(testSuite : TestSuite)
        {
            super(testSuite);
            addEventListener(TestEvent.TEST_FINISHED, onTestDone);
        }
     
         public function onTestDone(evt:TestEvent):void{
            
            //trace("Finished test:: -> " + evt.test, this.finishedTestCount + "/" + this.testCount);
            
        }
    }
}