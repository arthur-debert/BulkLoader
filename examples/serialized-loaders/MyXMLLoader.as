//
//  MyXMLLoader
//
//  Created by Arthur Debert on 2008-01-06.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//
package {
    import br.com.stimuli.loading.*;
    import flash.events.*;

    class MyXMLLoader extends LazyXMLLoader {
	    function MyXMLLoader(url : *){
		    super(url);
	    }
	    
	    public function handlerFromXML(evt : Event) : void{
    	    trace("XXXXXXXXX handlerFromXML", handlerFromXML);
    	}
    	
    	public function onVideoStarted(evt : Event) :void{
    	    trace("on vide started!")
    	}
    	
    	public function onVideoProgress(evt : Event) :void{
    	    trace("on video progress!")
    	}
    	
    	public function onVideoComplete(evt : Event) :void{
    	    trace("on video complete!")
    	}
	}
}