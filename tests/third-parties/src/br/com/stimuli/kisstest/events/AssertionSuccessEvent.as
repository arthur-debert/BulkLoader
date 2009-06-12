package br.com.stimuli.kisstest.events
{
    import flash.events.Event;
    
    import br.com.stimuli.kisstest.TestCase;


    public class AssertionSuccessEvent extends TestResultEvent
    {
        public static const ASSERT_SUCCESS : String = "assertSuccess";
        
        public function AssertionSuccessEvent(test:TestCase=null)
        {
            super(null, null, ASSERT_SUCCESS);
        }
        
    }
}