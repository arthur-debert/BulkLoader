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
	*	An event that holds information about the status of a <code>BulkLoader</code>.
	*  
	*   As this event subclasses <code>ProgressEvent</code>, you can choose to listen to <code>BulkProgressEvent</code> or <code>ProgressEvent</code> instances, but this class provides more useful information about loading status.
	*  
	*	@langversion ActionScript 3.0
	*	@playerversion Flash 9.0
	*
	*	@author Arthur Debert
	*	@since  15.09.2007
	*/
	public class BulkProgressEvent extends ProgressEvent {
	    /* The name of this event */
		public static const PROGRESS : String = "progress";
		public static const COMPLETE : String = "complete";
		
		/** How many bytes have loaded so far.*/
		public var bytesTotalCurrent : int;
		/** @private */
		public var _ratioLoaded : Number;
		/** @private */
		
	    public var _percentLoaded : Number;
	    /** @private */
	    public var _weightPercent : Number;
	    /** Number of items already loaded */
	    public var itemsLoaded : int;
	    /** Number of items to be loaded */
	    public var itemsTotal : int;

        public var name : String;

		public function BulkProgressEvent( name : String, bubbles:Boolean=true, cancelable:Boolean=false ){
			super(name, bubbles, cancelable);		
			this.name = name;
		}
        
        /** Sets loading information.*/
        public function setInfo(
                    bytesLoaded : int ,
                    bytesTotal : int,
                    bytesTotalCurrent : int, 
                    itemsLoaded : int ,
                    itemsTotal : int,
                    weightPercent : Number
                    ): void{
            this.bytesLoaded = bytesLoaded;
            this.bytesTotal = bytesTotal;
            this.bytesTotalCurrent = bytesTotalCurrent;
            this.itemsLoaded = itemsLoaded;
            this.itemsTotal = itemsTotal;
            this.weightPercent = weightPercent;
            this.percentLoaded = bytesTotal > 0 ? (bytesLoaded / bytesTotal) : 0;
            ratioLoaded = itemsTotal == 0 ? 0 : itemsLoaded / itemsTotal;
        }
        
        /* Returns an identical copy of this object
        *   @return A cloned instance of this object.
        */
		override public function clone() : Event {
		    var b : BulkProgressEvent = new BulkProgressEvent(name, bubbles, cancelable)
		    b.setInfo(bytesLoaded, bytesTotal, bytesTotalCurrent, itemsLoaded, itemsTotal, weightPercent);
			return b;	
		}
		
		/** Returns a <code>String</code> will all available information for this event.
		* @return A code>String</code> will loading information.
		*/
		public function loadingStatus () : String{
		    var names : Array = [];
            names.push("bytesLoaded: " + bytesLoaded);
		    names.push("bytesTotal: " + bytesTotal);
            names.push("itemsLoaded: " + itemsLoaded);
            names.push("itemsTotal: " + itemsTotal);
		    names.push("bytesTotalCurrent: " + bytesTotalCurrent);
		    names.push("percentLoaded: " + BulkLoader.truncateNumber(percentLoaded));
		    names.push("weightPercent: " + BulkLoader.truncateNumber(weightPercent));
		    names.push("ratioLoaded: " + BulkLoader.truncateNumber(ratioLoaded))
		    return "BulkProgressEvent " + names.join(", ") + ";"
		}
		
		/** A number between 0 - 1 that indicates progress regarding weights */
		public function get weightPercent() : Number { 
		  return _weightPercent; 
		}
		
		
		public function set weightPercent(value:Number) : void { 
		if (isNaN(value) || !isFinite(value)) value = 0;		
		  _weightPercent = value; 
		}
		
		/** A number between 0 - 1 that indicates progress regarding bytes */
		public function get percentLoaded() : Number { 
		  return _percentLoaded; 
		}
		
		public function set percentLoaded(value:Number) : void {
		    if (isNaN(value) || !isFinite(value)) value = 0;		 
		  _percentLoaded = value; 
		}
		/** The ratio (0-1) loaded (number of items loaded / number of items total) */
		public function get ratioLoaded() : Number { 
		  return _ratioLoaded; 
		}
		
		public function set ratioLoaded(value:Number) : void { 
           if (isNaN(value) || !isFinite(value)) value = 0;		
		  _ratioLoaded = value; 
		}
		override public function toString() : String{
            return super.toString();
		}
		
	}
	
}
