"use strict";
/*
 * window.ts
 */
/// <reference path="types/KiwiLibrary.d.ts"/>
/// <reference path="types/Builtin.d.ts"/>
function alert(message) {
    let result = -1;
    let sem = new Semaphore(0);
    let cbfunc = function (res) {
        result = res;
        sem.signal(); // Tell finish operation
    };
    _alert(message, cbfunc);
    sem.wait(); // Wait finish operation
    return result;
}
function enterView(path) {
    let sem = new Semaphore(0);
    let result = -1;
    _enterView(path, function (retval) {
        result = retval;
        sem.signal(); // Tell finish operation
    });
    sem.wait(); // Wait finish operation
    return result;
}
