/// <reference path="typing/react-global.d.ts"/>
/// <reference path="typing/jquery.d.ts"/>
/// <reference path="typing/ace.d.ts"/>
/// <reference path="spec_editor.ts"/>

$(document).ready(function(){
    var s = new SpecEditor('form', 'service_specification_editor', 'https://s3.amazonaws.com/symmdprod/petstore.yaml');
});