
package br.com.stimuli.loading.tests  {
	import asunit.textui.TestRunner;
	
	import flash.events.Event;
    
    /**@private*/
	public class BulkLoaderTestRunner extends TestRunner {
		public function BulkLoaderTestRunner() {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		public function onAddedToStage(evt :Event):void{
		  start(BulkLoaderTestSuite, null, TestRunner.SHOW_TRACE);
		}
	}
}