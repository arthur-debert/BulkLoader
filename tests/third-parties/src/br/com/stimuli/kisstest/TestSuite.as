package br.com.stimuli.kisstest{
    
    import flash.utils.describeType;
    
    public class TestSuite{
       
        public var numAsserts : int = 0;
        
        public var allTestsClasses : Array;
        public var allTests : Array;
        public var results : Array;
        public var runIndex : int = 0;
        
        public function TestSuite(...testClasses){
            allTests = [];
            results = [];
            allTestsClasses = [];
            testClasses.forEach(function(o : Class, ...rest):void{
                addTestCase(o);
            })
        }
        
        public function addTestCase(testOrSuiteKlass : Class) : void{
            var classes : Array = [];
            if (testOrSuiteKlass is TestSuite){
                classes = testOrSuiteKlass.allTestClasses.slice();
            }else{
                classes.push (testOrSuiteKlass)
            }
            for each (var testKlass : Class in classes){
                allTestsClasses.push(testKlass);
                var testsOnThisClass : Array = extractTests(testKlass);
                for each(var test : TestCase in testsOnThisClass){
                    addTest(test);
                }
            }
            
        }
        
        public function addTest(test : TestCase ) : void{
            allTests.push(test);
        }
        
        public function extractTests(fromClass : Class) : Array{
            var tests : Array = [];
            for each (var name : String in describeType(fromClass).factory.method.@name){
	 	        if (name.substr(0, 4) == "test"){
 	                tests.push(new fromClass(name));
 	            }
            }
            return tests;
        }
        

    }
}