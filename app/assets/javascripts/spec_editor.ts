/// <reference path="typing/ace.d.ts"/>
/**
 * Responsible for the specification editing functions
 */
class SpecEditor {
    url:string;                         // Url of the pre-loaded specification
    formElementId: string;              // formElementId for the form
    textEditorElementId:string;         // textEditorElementId to instantiate editor on (ace)
    createServiceElementId:string;      // createServiceElementId to attach listeners
    editor:AceAjax.Editor;              // Ace editor

    /**
     * Create a new SpecEditor
     *
     * @param formElementIdentifier - DOM element of the form
     * @param textEditorElementId - DOM element to create ACE editor on
     * @param url - Url of default specification/schema to load
     */
    constructor(formElementIdentifier:string, textEditorElementId:string, url:string) {
        this.url = url;
        this.formElementId = formElementIdentifier;
        this.textEditorElementId = textEditorElementId;

        this.editor = ace.edit(textEditorElementId);
        this.editor.setTheme("ace/theme/monokai");
        this.editor.getSession().setMode("ace/mode/yaml");
        this.editor.getSession().setUseWrapMode(true);
        this.editor.getSession().setWrapLimitRange(10, 80);

        // Load the initial startup content
        if (url) {
            var self = this;
            $.get(url, function (data) {
                self.editor.setValue(data, -1); // moves cursor to the start

                //self.editor.setValue($('#service_specification').val());
            });
        }

        $(this.formElementId).submit(function(){
            $('#service_specification').val(self.editor.getSession().getValue());
            return true;
        })

    }
}
