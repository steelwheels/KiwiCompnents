/*
 * Library.js: Library functions for component scripting
 */

function waitUntilActivate() {
	while(!viewState.isActive){
		sleep(0.5) ;	// wait 500ms
	}
	return viewState.returnValue ;
} ;

