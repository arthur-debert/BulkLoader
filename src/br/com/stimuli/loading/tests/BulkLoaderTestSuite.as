/* AS3
	Copyright 2008 __MyCompanyName__.
*/
package br.com.stimuli.loading.tests {
	import asunit.framework.TestSuite;
	import flash.events.*;
	import br.com.stimuli.loading.tests.*;
	import flash.utils.*;
	public class BulkLoaderTestSuite extends TestSuite {
	    var testClasses : Array = [
	        LoaderItemAVM1MovieTest,
	        CollectionTestCase, 
	        LoaderImageItemTest,
	        InstanceRetrivalTestCase, 
	        VideoContentPausedAtStartTestCase, 
	        VideoContentTest
	    ];
	    
	    var testsRun : Object = {} ;
        
        public function BulkLoaderTestSuite() {
		    super();
            testClasses.forEach(function(cl : Class, ...rest):void{addTestsFromClass(cl)})
	 		for (var prop : String in testsRun){
	 		    trace(prop.substring(6, prop.length -1) + " (" + testsRun[prop].length + ")", ":");
	 		    for each (var testName : String in testsRun[prop]){
	 		        trace("\t",testName );
	 		    }
	 		}
	 	}
	 	
	 	public function addTestsFromClass(klass : Class) : void{
	 	    for each (var name : String in describeType(klass).factory.method.@name){
	 	        if (name.substr(0, 4) == "test"){
	 	            addTest(new klass(name));
	 	            if(!testsRun[String(klass)]){
	 	                testsRun[String(klass)] = [];
	 	            }
	 	            testsRun[String(klass)].push(name);
	 	        }
	 	    }
	 	}


	}
	
}
