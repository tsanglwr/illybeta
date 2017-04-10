/**
 * Copyright Qiwibee Inc. 2016 / Symmetry
 *
 * No use permitted for any reason at all. All rights reserved Qiwibee Inc. 2015
 */
var symm = symm || {version: "1.0.1"};

if (typeof document !== 'undefined' && typeof window !== 'undefined') {
    symm.document = document;
    symm.window = window;
}
else {
    // assume we're running under node.js when document/window are not present
    symm.document = require("jsdom")
        .jsdom("<!DOCTYPE html><html><head></head><body></body></html>");

    if (symm.document.createWindow) {
        symm.window = symm.document.createWindow();
    } else {
        symm.window = symm.document.parentWindow;
    }
}

symm.trace = function() {
    var e = new Error();
    return e.stack;
};

var _scMediator = _scMediator || new Mediator();
var _scLogger = _scLogger || Logger;

symm.util = symm.util || {};
symm.util.mediator = _scMediator;
symm.util.logger = _scLogger;
symm.util.logger.useDefaults();

var gon = gon || {};
if (gon != undefined && gon != null && gon.is_production) {
    symm.util.logger.setLevel(Logger.ERROR);
} else {
    symm.util.logger.setLevel(Logger.DEBUG);
}
// Convenience name:
symm.log = symm.util.logger;
symm.log.info('symm.util.logger is running.');
symm.urls = {}; // Store all urls

// Store our static assets here, todo: Change to CDNIFY to get HTTPS and use our own domain name not AWS
symm.urls.base_static_url_prefix = 'https://s3.amazonaws.com/scstaticprod';

// Sample photos
symm.urls.sample_photos_manifest_url = symm.urls.base_static_url_prefix + '/photo_sample_manifest2.json';

