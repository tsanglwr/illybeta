/// <reference path="../typing/react-global.d.ts" />
/// <reference path="../typing/ace.d.ts" />
/// <reference path="../typing/jquery.d.ts" />

class SpecEditorProps {
  public name:string;
}

class SpecEditorComponent extends React.Component<SpecEditorProps, any> {
  private foo:number;
  constructor(props:SpecEditorProps) {
    super(props);
  }
  render() {
    return (
      <div>
      <input type="text"/>
        Hello world!
      </div>
    );
  }
}
/**
ReactDOM.render(
  <SpecEditorComponent
    name="UNIQUE_ID_OF_DIV"
  />,
  document.getElementById('service_specification_editor')
);
**/