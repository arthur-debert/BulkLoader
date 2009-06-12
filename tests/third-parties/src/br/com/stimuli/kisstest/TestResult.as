package br.com.stimuli.kisstest{
    import flash.utils.getQualifiedClassName;
    
    import br.com.stimuli.kisstest.events.*;
    public class TestResult{
        /**
         *  In seconds!
         */
        public var elapsedTime : Number;
        
        public var test : TestCase;
        public var error : Error;
        public var resultEvent : TestResultEvent ;
        
        
        
        public function TestResult(test : TestCase, elapsedTime : int){
            this.test = test;
        }
        
        public function toString(verbose : Boolean = false) : String{
            var simple :String = "[" + getQualifiedClassName(this) + "]" + test.toString(); 
            if(verbose){
                simple += ", status=" + test.status;
            }
            return simple;
        }
        
        public function get stackTrace() : String{
           if (test.error){
               return test.error.message + "\n" + test.error.getStackTrace();
           }else if (test.fails.length > 0){
               return test.fails[0].stack;
           }
           return "";
       }
       
       public function get numAsserts() : int{
           return test.assertsRan;
       }
    }
}