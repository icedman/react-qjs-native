import React from "react";

const { Component, Fragment } = React;

/*
onSubmitEditing
onFocus
onChangeText
*/

export default class TextInput extends Component {
  render() {
    return (
      <textinput
        style={{ ...this.props.style }}
        onChangeText={this.props.onChangeText}
      >
        {this.props.children}
      </textinput>
    );
  }
}
