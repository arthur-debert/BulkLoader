
package br.com.stimuli.loading.tests  {
	import asunit.textui.TestRunner;
    

	public class BulkLoaderTestRunner extends TestRunner {
		public function BulkLoaderTestRunner() {
			start(BulkLoaderTestSuite, null, TestRunner.SHOW_TRACE);
		}
	}
}