package asunit.framework {
	import asunit.errors.AssertionFailedError;
	
	public interface TestListener {
		/**
	 	 * An error occurred.
	 	 */
		function addError(test:Test, t:Error):void;
		/**
	 	 * A failure occurred.
	 	 */
	 	function addFailure(test:Test, t:AssertionFailedError):void;  
		/**
		 * A test ended.
		 */
	 	function endTest(test:Test):void; 
		/**
		 * A test started.
		 */
		function startTest(test:Test):void;
	}
}