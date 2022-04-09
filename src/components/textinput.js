import React from "react";

const { Component, Fragment } = React;

/*
todo: map the following
onSubmitEditing
onFocus
onChangeText
*/

export default class TextInput extends Component {
  render() {
    return (
      <textinput
        value={this.props.value}
        style={{ ...this.props.style }}
        onChangeText={this.props.onChangeText}
      >
        {this.props.children}
      </textinput>
    );
  }
}
