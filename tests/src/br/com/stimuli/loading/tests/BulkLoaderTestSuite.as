package br.com.stimuli.loading.tests {
	import kisstest.TestSuite;
	import flash.events.*;
	import br.com.stimuli.loading.tests.*;
	import flash.utils.*;
	import flash.media.SoundMixer;
	
	/**@private*/
	public class BulkLoaderTestSuite extends TestSuite {
	    public var testClasses : Array = [
//	    OnErrorTest
	            ResumeAllTest,
	            ResumeTest,
	            RemoveFailedItemTest,
	            CollectionTestCase,
                BulkStartTest,
                GuessTypeTest,
                LoaderImageItemTest,
                InstanceRetrivalTestCase, 
	            
	            OnCompleteTest,
	            AutoIdTest,
	            StringSubstituionTest,        
	            LoadNowTest,
	            LazyJSONLoaderTest,
	            LazyXMLLoaderTest,
	            LazyXMLInternalsTest,
	            XMLItemTest,
	            URLItemTest,
	            AudioContentTest,
	            LoaderItemAVM1MovieTest,
	            VideoContentPausedAtStartTestCase,
	            PauseAllResumeTest,
	            ClearNowTest,
	            VideoContentTest,
	            StartPausedTest,
	            LoaderItemMovieTest,
	            ProgressEventsTest, 
	            RemoveAllTest,
	            ReloadTest,
	    ];
	    
	    public var testsRun : Object = {} ;
        public static var LOADING_VERBOSE  : Boolean = false;
        
        
        public function BulkLoaderTestSuite() {
		    super();
		    SoundMixer.soundTransform.volume = 0;
            testClasses.forEach(function(cl : Class, ...rest):void{addTestCase(cl)})
	 		for (var prop : String in testsRun){
	 		    //trace(prop.substring(6, prop.length -1) + " (" + testsRun[prop].length + ")", ":");
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
