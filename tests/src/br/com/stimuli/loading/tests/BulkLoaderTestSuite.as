package br.com.stimuli.loading.tests {
	import asunit.framework.TestSuite;
	import flash.events.*;
	import br.com.stimuli.loading.tests.*;
	import flash.utils.*;
	import flash.media.SoundMixer;
	
	/**@private*/
	public class BulkLoaderTestSuite extends TestSuite {
	    public var testClasses : Array = [
            ProgressEventsTest, 
            ReloadTest,
            LazyJSONLoaderTest,
            LazyXMLLoaderTest,
            LazyXMLInternalsTest,
            OnCompleteTest,
            AutoIdTest,
            StringSubstituionTest,        
            LoadNowTest,
            ResumeAllTest,
            ResumeTest,
            PauseAllResumeTest,
            RemoveFailedItemTest,
            CollectionTestCase,
            InstanceRetrivalTestCase, 
            GuessTypeTest,
            BulkStartTest,
            XMLItemTest,
            URLItemTest,
            AudioContentTest,
            LoaderItemAVM1MovieTest,
            LoaderImageItemTest,
            VideoContentPausedAtStartTestCase, 
            VideoContentTest
	    ];
	    
	    public var testsRun : Object = {} ;
        public static var LOADING_VERBOSE  : Boolean = false;
        
        
        public function BulkLoaderTestSuite() {
		    super();
		    SoundMixer.soundTransform.volume = 0;
            testClasses.forEach(function(cl : Class, ...rest):void{addTestsFromClass(cl)})
	 		for (var prop : String in testsRun){
	 		    trace(prop.substring(6, prop.length -1) + " (" + testsRun[prop].length + ")", ":");
	 		    for each (var testName : String in testsRun[prop]){
	 		        //trace("\t",testName );
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
