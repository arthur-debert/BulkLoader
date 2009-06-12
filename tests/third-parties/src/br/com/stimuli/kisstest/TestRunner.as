package br.com.stimuli.kisstest{
    
    import flash.display.Sprite;
    import flash.events.*;
    import flash.utils.getTimer;
    
    import br.com.stimuli.kisstest.events.TestEvent;
    import br.com.stimuli.kisstest.events.TestResultEvent;
    public class TestRunner extends EventDispatcher{
        public var currentStartTime : int;
        public var currentEndTime : int;
        /**
         *  In seconds!
         */
        public var currentElapsedTime : Number;
        
        public var globalStartTime : int;
        public var globalEndTime : int;
        /**
         *  In seconds!
         */
        public var globalElapsedTime : Number;
        
        
        
        public var allTests : Array;
        
        public var results : Array;
        public var runIndex : int = -1;
        public var currentResult : TestResult;
        public var currentTest : TestCase;
        
        public var ticker : Sprite;


        public function TestRunner(...testSuites){
            allTests = [];
            results = [];
            for each (var suite : TestSuite in testSuites){
                _addTests(suite.allTests.slice());
            }
            ticker = new Sprite();
        }
        
        
        public function _addTests(tests : Array): void{
            
            allTests = allTests.concat( tests);
        }
        
        public function run() : void{
            globalStartTime = getTimer();
            dispatchEvent(new Event(Event.INIT));
            runNext();
            ticker.addEventListener(Event.ENTER_FRAME, onTick);
        }
        
        public function runNext () : void{
            runIndex ++;
            currentTest = allTests[runIndex];
            if(!currentTest){
                finalize();
                return;
            }
            currentTest.addEventListener(Event.INIT, onTestSetupDone, false, 0, true);
            currentStartTime = getTimer();
            dispatchEvent(new TestEvent(TestEvent.TEST_STARTED, currentTest));
            currentTest.setUp();
            
        }
        
        public function onTestSetupDone(evt : Event=null) : void{
            currentTest.removeEventListener(Event.INIT, onTestSetupDone);
            currentTest.addEventListener(Event.COMPLETE, onTestFinished, false, 0, true);
            
            currentEndTime = getTimer();
            currentElapsedTime = (currentEndTime - currentStartTime)/ 1000;
            currentResult  = new TestResult(currentTest, currentElapsedTime);
            currentTest.run();
            //currentResult
        }
        
        public function onTestFinished(evt : TestResultEvent) : void{
            
            currentResult.resultEvent = evt;
            currentResult.elapsedTime = (getTimer() - currentStartTime)/1000;
            results.push(currentResult);
            dispatchEvent(new TestEvent(TestEvent.TEST_FINISHED, allTests[runIndex]));
            currentTest = null; 
            globalElapsedTime = (getTimer() - globalStartTime)/1000;
        }
        
        public function onTick(evt : Event = null) : void{
            if (!currentTest){
                runNext();
            }
        }
        
        public function finalize() : void{
            ticker.removeEventListener(Event.ENTER_FRAME, onTick);
            globalEndTime = getTimer();
            globalElapsedTime = (globalEndTime - globalStartTime)/1000;
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        public function get testCount() : int{
            return allTests.length;
        }
        
        public function get finishedTestCount() : int{
            return results.length;
        }
        
        public function get errorTestCound() : int{
            var count : int = 0;
            for each(var result : TestResult in results){
                if (result.test.error){
                    count ++;
                }
            }
            return count;
        }
        
        public function get failedTestCount() : int{
            var count : int = 0;
            for each(var result : TestResult in results){
                if (result.test.fails.length > 0){
                    count ++;
                }
            }
            return count;
        }
        public function get errorTestCount() : int{
            var count : int = 0;
            for each(var result : TestResult in results){
                if (result.test.error){
                    count ++;
                }
            }
            return count;
        }
        
        
        
        
        public function get numAsserts() : int{
            var asserts : int = 0;
            results.forEach(function(r:TestResult, ...rest):void{
               asserts += r.numAsserts; 
            });
            return asserts;
        }
        
        public function getResult(forTestCase : TestCase) : TestResult{
            for (var i : int = 0 ; i < results.length ; i++){
                if (results[i].test == forTestCase) return results[i];
            }
            return null;
        }
        
        public function get finishedTests() : Array{
            return results.map(function (r : TestResult, ...rest) : TestCase{
               return r.test; 
            });
        }
    }
}