package br.com.stimuli.kisstest{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.getQualifiedClassName;
    
    import br.com.stimuli.kisstest.events.*;
    
    
    
    public class TestCase extends EventDispatcher{
        
        public var name : String;
        public var numTests : Boolean;
        public var assertsRan : int = 0;
        
        public static const STATUS_INIT : String = "init";
        public static const STATUS_SETUP_STARTED : String = "setupStarted";
        public static const STATUS_SETUP_DONE : String = "setupDone";
        public static const STATUS_SUCCESS : String = "success";
        public static const STATUS_FAILURE : String = "failure";
        public static const STATUS_ERROR : String = "error";
        
        public var fails : Array = [];
        public var success : Array = [];
        public var done : Boolean;
        public var error : Error;
        
       public function TestCase(name : String) : void{
           this.name = name;
           //addEventListener(Event.INIT, _triggerRun, false, 0, true);
           addEventListener(AssertionFailedEvent.ASSERT_FAILED, onAssertionFailed);
           addEventListener(AssertionSuccessEvent.ASSERT_SUCCESS, onAssertionSucceeded);
       }
        
       /**
        *   Must dispatch a INIT event when setup is done.
        */
       public function setUp() : void{
           //dispatchEvent(new Event(Event.INIT));
       }
        
       public function tearDown() : void{
           
       }
       
       public function _triggerRun(evt : Event) : void{
           //run();
       }
       public function run() : void{
           try{
               this[name]();
               done = true;
           }catch ( e : Error){
               error = e;
           }
           finalize();
       }
       
       public function onAssertionFailed( e : *): void{
           assertsRan ++;
           fails.push(e);
       }
       
       public function onAssertionSucceeded( e : AssertionSuccessEvent): void{
           assertsRan ++;
           success.push(e);
       }
       
       public function finalize() : void{
           try{
               tearDown();
           }catch(e : Error){
               //throw e;
               //trace("Error tearing down test", e);
           }
           var evt : TestResultEvent = new TestResultEvent(this, new TestResult(this, 1)); 
           dispatchEvent(evt);
       }
       
       public function get status() : String{
           if (error){
               return STATUS_ERROR;
           }else if (fails.length > 0 ){
               return STATUS_FAILURE;
           }else if(done){
               return STATUS_SUCCESS;
           }
           return STATUS_INIT;
       }
       public function assertEquals(val1 : *, val2 : *) : void{
           
           if (val1 == val2){
               dispatchEvent(new AssertionSuccessEvent())
               return;
           }
           dispatchEvent(new AssertionFailedEvent(val1, val2, _getStackTrace()));
       }
       
       public function assertNotNull(val1 : *) : void{
           if (val1 != null){
               dispatchEvent(new AssertionSuccessEvent())
               return;
           }
           dispatchEvent(new AssertionFailedEvent(val1, null, _getStackTrace()));
       }
       
       public function assertNull(val1 : *) : void{
           if (val1 == null){
               dispatchEvent(new AssertionSuccessEvent());
               return;
           }
           dispatchEvent(new AssertionFailedEvent(null, val1, _getStackTrace()));
       }
       
       public function assertTrue(val : *) : void{
           if (val){
               dispatchEvent(new AssertionSuccessEvent());
               return;
            }
            dispatchEvent(new AssertionFailedEvent(true, false, _getStackTrace()));
       }
       
       public function assertFalse(val : *) : void{
              if (!val){
                  dispatchEvent(new AssertionSuccessEvent());
                  return;
               }
               dispatchEvent(new AssertionFailedEvent( false, true, _getStackTrace()));
        }
          
       public function _getStackTrace() : String{
           try{
               throw new Error();
           }catch(e : Error){
               var raw : Array = e.getStackTrace().split("\n");
               raw.splice(1, 2);
               return raw.join("\n");
           }
           return "";
       }
       
       public function get className () : String{
           return getQualifiedClassName(this).slice(getQualifiedClassName(this).lastIndexOf(":")+1);
       }
       
       
       override public function toString():String{
           return "[" + getQualifiedClassName(this) + "]"  + ":" + name;
       }
    }
}