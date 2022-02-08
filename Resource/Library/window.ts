/*
 * window.ts
 */

/// <reference path="types/KiwiLibrary.d.ts"/>
/// <reference path="types/Builtin.d.ts"/>

function alert(message: string): number {
	let result = -1 ;
	let sem    = new Semaphore(0) ;
	let cbfunc = function(res: number) {
		result = res ;
		sem.signal() ;  // Tell finish operation
	} ;
	_alert(message, cbfunc) ;
	sem.wait() ; // Wait finish operation
	return result ;
}

function enterView(path: string): any | null {
	let sem    = new Semaphore(0) ;
	let result = null ;
	_enterView(path, function(retval: number) {
		result = retval ;
		sem.signal() ;  // Tell finish operation
	})
	sem.wait() ; // Wait finish operation
	return result ;
}

