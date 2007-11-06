/* BulkLoader: manage multiple loadings in Actioncript 3.
*   
*   
*   @author Arthur Debert
*   @version 0.4
*/

/*
* Licensed under the MIT License
* 
* Copyright (c) 2006-2007 Arthur Debert
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
* 
* http://code.google.com/p/bulk-loader/
* http://www.opensource.org/licenses/mit-license.php
*    
*/

package br.com.stimuli.loading {
	import flash.events.*;

	/**
	*	An event that holds information about the what items have failed <code>BulkLoader</code>.
	*  
	*	@author Arthur Debert
	*	@since  15.09.2007
	*/
	public class BulkErrorEvent extends Event {
	    /* The name of this event */
		public static const ERROR : String = "error";
		
		public var name : String;
        
        /** An array that holds the error LoadingItems that have failed to load. */
        public var errors : Array;
        
		public function BulkErrorEvent( name : String, bubbles:Boolean=true, cancelable:Boolean=false ){
			super(name, bubbles, cancelable);		
			this.name = name;
		}
        
        
        /* Returns an identical copy of this object
        *   @return A cloned instance of this object.
        */
		override public function clone() : Event {
		    var b : BulkErrorEvent = new BulkErrorEvent(name, bubbles, cancelable);
		    b.errors = errors ? errors.slice() : [];
			return b;	
		}
		
		override public function toString() : String{
            return super.toString();
		}
		
	}
	
}
