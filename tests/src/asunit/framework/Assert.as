package asunit.framework {
	import asunit.errors.AssertionFailedError;
	
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.utils.Proxy;

	/**
	 * A set of assert methods.  Messages are only displayed when an assert fails.
	 */

	public class Assert extends EventDispatcher {
		/**
		 * Protect constructor since it is a static only class
		 */
		public function Assert() {
		}

		/**
		 * Asserts that a condition is true. If it isn't it throws
		 * an AssertionFailedError with the given message.
		 */
		static public function assertTrue(...args:Array):void {
			var message:String;
			var condition:Boolean;

			if(args.length == 1) {
				message = "";
				condition = Boolean(args[0]);
			}
			else if(args.length == 2) {
				message = args[0];
				condition = Boolean(args[1]);
			}
			else {
				throw new IllegalOperationError("Invalid argument count");
			}

			if(!condition) {
				fail(message);
			}
		}
		/**
		 * Asserts that a condition is false. If it isn't it throws
		 * an AssertionFailedError with the given message.
		 */
		static public function assertFalse(...args:Array):void {
			var message:String;
			var condition:Boolean;

			if(args.length == 1) {
				message = "";
				condition = Boolean(args[0]);
			}
			else if(args.length == 2) {
				message = args[0];
				condition = Boolean(args[1]);
			}
			else {
				throw new IllegalOperationError("Invalid argument count");
			}

			assertTrue(message, !condition);
		}
		/**
		 * Fails a test with the given message.
		 */
		static public function fail(message:String):void {
			throw new AssertionFailedError(message);
		}
		/**
		 * Asserts that two objects are equal. If they are not
		 * an AssertionFailedError is thrown with the given message.
		 */
		static public function assertEquals(...args:Array):void {
			var message:String;
			var expected:Object;
			var actual:Object;

			if(args.length == 2) {
				message = "";
				expected = args[0];
				actual = args[1];
			}
			else if(args.length == 3) {
				message = args[0];
				expected = args[1];
				actual = args[2];
			}
			else {
				throw new IllegalOperationError("Invalid argument count");
			}

			if(expected == null && actual == null) {
				return;
			}

			try {
				if(expected != null && expected.equals(actual)) {
					return;
				}
			}
			catch(e:Error) {
				if(expected != null && expected == actual) {
					return;
				}
			}

			failNotEquals(message, expected, actual);
		}
		/**
		 * Asserts that an object isn't null. If it is
		 * an AssertionFailedError is thrown with the given message.
		 */
		static public function assertNotNull(...args:Array):void {
			var message:String;
			var object:Object;

			if(args.length == 1) {
				message = "";
				object = args[0];
			}
			else if(args.length == 2) {
				message = args[0];
				object = args[1];
			}
			else {
				throw new IllegalOperationError("Invalid argument count");
			}

			assertTrue(message, object != null);
		}
		/**
		 * Asserts that an object is null.  If it is not
		 * an AssertionFailedError is thrown with the given message.
		 */
		static public function assertNull(...args:Array):void {
			var message:String;
			var object:Object;

			if(args.length == 1) {
				message = "";
				object = args[0];
			}
			else if(args.length == 2) {
				message = args[0];
				object = args[1];
			}
			else {
				throw new IllegalOperationError("Invalid argument count");
			}

			assertTrue(message, object == null);
		}
		/**
		 * Asserts that two objects refer to the same object. If they are not
		 * an AssertionFailedError is thrown with the given message.
		 */
		static public function assertSame(...args:Array):void {
			var message:String;
			var expected:Object;
			var actual:Object;

			if(args.length == 2) {
				message = "";
				expected = args[0];
				actual = args[1];
			}
			else if(args.length == 3) {
				message = args[0];
				expected = args[1];
				actual = args[2];
			}
			else {
				throw new IllegalOperationError("Invalid argument count");
			}

			if(expected === actual) {
				return;
			}
			failNotSame(message, expected, actual);
		}
	 	/**
	 	 * Asserts that two objects refer to the same object. If they are not
	 	 * an AssertionFailedError is thrown with the given message.
	 	 */
		static public function assertNotSame(...args:Array):void {
			var message:String;
			var expected:Object;
			var actual:Object;

			if(args.length == 2) {
				message = "";
				expected = args[0];
				actual = args[1];
			}
			else if(args.length == 3) {
				message = args[0];
				expected = args[1];
				actual = args[2];
			}
			else {
				throw new IllegalOperationError("Invalid argument count");
			}

			if(expected === actual)
				failSame(message);
		}

		/**
		 * Asserts that two numerical values are equal within a tolerance range.
		 * If they are not an AssertionFailedError is thrown with the given message.
		 */
		static public function assertEqualsFloat(...args:Array):void {
			var message:String;
			var expected:Number;
			var actual:Number;
			var tolerance:Number = 0;

			if(args.length == 3) {
				message = "";
				expected = args[0];
				actual = args[1];
				tolerance = args[2];
			}
			else if(args.length == 4) {
				message = args[0];
				expected = args[1];
				actual = args[2];
				tolerance = args[3];
			}
			else {
				throw new IllegalOperationError("Invalid argument count");
			}
			if (isNaN(tolerance)) tolerance = 0;
			if(Math.abs(expected - actual) <= tolerance) {
				   return;
			}
			failNotEquals(message, expected, actual);
		}


		static private function failSame(message:String):void {
			var formatted:String = "";
	 		if(message != null) {
	 			formatted = message + " ";
	 		}
	 		fail(formatted + "expected not same");
		}

		static private function failNotSame(message:String, expected:Object, actual:Object):void {
			var formatted:String = "";
			if(message != null) {
				formatted = message + " ";
			}
			fail(formatted + "expected same:<" + expected + "> was not:<" + actual + ">");
		}

		static private function failNotEquals(message:String, expected:Object, actual:Object):void {
			fail(format(message, expected, actual));
		}

		static private function format(message:String, expected:Object, actual:Object):String {
			var formatted:String = "";
			if(message != null) {
				formatted = message + " ";
			}
			return formatted + "expected:<" + expected + "> but was:<" + actual + ">";
		}
	}
}