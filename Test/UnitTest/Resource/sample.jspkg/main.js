/*
 * 
 */

function main(args)
{
	console.log("Hello, world !!\n") ;
	enterView("main", function(val){
		console.log("main view is closed: " + val) ;
	}) ;
}

