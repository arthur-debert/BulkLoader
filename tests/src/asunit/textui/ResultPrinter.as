package asunit.textui {
	import asunit.errors.AssertionFailedError;
	import asunit.framework.Test;
	import asunit.framework.TestFailure;
	import asunit.framework.TestListener;
	import asunit.framework.TestResult;
	import asunit.runner.BaseTestRunner;
	import asunit.runner.Version;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	public class ResultPrinter extends Sprite implements TestListener {
		private var fColumn:int = 0;
		private var textArea:TextField;
		private var gutter:uint = 0;
		private var backgroundColor:uint = 0x333333;
		private var bar:SuccessBar;
		private var barHeight:Number = 3;
		private var showTrace:Boolean;

		public function ResultPrinter(showTrace:Boolean = false) {
			this.showTrace = showTrace;
			configureAssets();
			println();
		}

		private function configureAssets():void {
			textArea = new TextField();
			textArea.background = true;
			textArea.backgroundColor = backgroundColor;
			textArea.border = true;
			textArea.wordWrap = true;
			var format:TextFormat = new TextFormat();
			format.font = "Verdana";
			format.size = 10;
			format.color = 0xFFFFFF;
			textArea.defaultTextFormat = format;
			addChild(textArea);
			println("AsUnit " + Version.id() + " by Luke Bayes and Ali Mills");

			bar = new SuccessBar();
			addChild(bar);
		}

		public function setShowTrace(showTrace:Boolean):void {
			this.showTrace = showTrace;
		}
		
		public override function set width(w:Number):void {
			textArea.x = gutter;
			textArea.width = w - gutter*2;
			bar.x = gutter;
			bar.width = textArea.width;
		}

		public override function set height(h:Number):void {
			textArea.height = h - ((gutter*2) + barHeight);
			textArea.y = gutter;
			bar.y = h - (gutter + barHeight);
			bar.height = barHeight;
		}

		public function println(...args:Array):void {
			textArea.appendText(args.toString() + "\n");
		}

		public function print(...args:Array):void {
			textArea.appendText(args.toString());
		}
		/* API for use by textui.TestRunner
		 */

		public function printResult(result:TestResult, runTime:Number):void {
			printHeader(runTime);
		    printErrors(result);
		    printFailures(result);
		    printFooter(result);

   		    bar.setSuccess(result.wasSuccessful());
   		    if(showTrace) {
			    trace(textArea.text);
   		    }
		}

		/* Internal methods
		 */
		protected function printHeader(runTime:Number):void {
			println();
			println();
			println("Time: " + elapsedTimeAsString(runTime));
		}

		protected function printErrors(result:TestResult):void {
			printDefects(result.errors(), result.errorCount(), "error");
		}

		protected function printFailures(result:TestResult):void {
			printDefects(result.failures(), result.failureCount(), "failure");
		}

		protected function printDefects(booBoos:Object, count:int, type:String):void {
			if (count == 0) {
				return;
			}
			if (count == 1) {
				println("There was " + count + " " + type + ":");
			}
			else {
				println("There were " + count + " " + type + "s:");
			}
			var i:uint;
			for each (var item:TestFailure in booBoos) {
				printDefect(TestFailure(item), i);
				i++;
			}
		}

		public function printDefect(booBoo:TestFailure, count:int ):void { // only public for testing purposes
			printDefectHeader(booBoo, count);
			printDefectTrace(booBoo);
		}

		protected function printDefectHeader(booBoo:TestFailure, count:int):void {
			// I feel like making this a println, then adding a line giving the throwable a chance to print something
			// before we get to the stack trace.
			var startIndex:uint = textArea.text.length;
			println(count + ") " + booBoo.failedTest());
			var endIndex:uint = textArea.text.length;

			var format:TextFormat = textArea.getTextFormat();
			format.bold = true;

			// GROSS HACK because of bug in flash player - TextField isn't accepting formats...
			setTimeout(onFormatTimeout, 1, format, startIndex, endIndex);
		}

		public function onFormatTimeout(format:TextFormat, startIndex:uint, endIndex:uint):void {
			textArea.setTextFormat(format, startIndex, endIndex);
		}

		protected function printDefectTrace(booBoo:TestFailure):void {
			println(BaseTestRunner.getFilteredTrace(booBoo.thrownException().getStackTrace()));
		}

		protected function printFooter(result:TestResult):void {
			println();
			if (result.wasSuccessful()) {
				print("OK");
				println (" (" + result.runCount() + " test" + (result.runCount() == 1 ? "": "s") + ")");
			} else {
				println("FAILURES!!!");
				println("Tests run: " + result.runCount()+
					         ",  Failures: "+result.failureCount()+
					         ",  Errors: "+result.errorCount());
			}
		    println();
		}

		/**
		 * Returns the formatted string of the elapsed time.
		 * Duplicated from BaseTestRunner. Fix it.
		 */
		protected function elapsedTimeAsString(runTime:Number):String {
			return Number(runTime/1000).toString();
		}

		/**
		 * @see junit.framework.TestListener#addError(Test, Throwable)
		 */
		public function addError(test:Test, t:Error):void {
			print("E");
		}

		/**
		 * @see junit.framework.TestListener#addFailure(Test, AssertionFailedError)
		 */
		public function addFailure(test:Test, t:AssertionFailedError):void {
			print("F");
		}

		/**
		 * @see junit.framework.TestListener#endTest(Test)
		 */
		public function endTest(test:Test):void {
		}

		/**
		 * @see junit.framework.TestListener#startTest(Test)
		 */
		public function startTest(test:Test):void {
			var count:uint = test.countTestCases();
			for(var i:uint; i < count; i++) {
				print(".");
				if (fColumn++ >= 80) {
					println();
					fColumn = 0;
				}
			}
		}
	}
}

import flash.display.Sprite;

class SuccessBar extends Sprite {
	private var myWidth:uint;
	private var myHeight:uint;
	private var bgColor:uint;
	private var passingColor:uint = 0x00FF00;
	private var failingColor:uint = 0xFD0000;

	public function SuccessBar() {
	}

	public function setSuccess(success:Boolean):void {
		bgColor = (success) ? passingColor : failingColor;
		draw();
	}

	public override function set width(num:Number):void {
		myWidth = num;
		draw();
	}

	public override function set height(num:Number):void {
		myHeight = num;
		draw();
	}

	private function draw():void {
		graphics.clear();
		graphics.beginFill(bgColor);
		graphics.drawRect(0, 0, myWidth, myHeight);
		graphics.endFill();
	}
}
