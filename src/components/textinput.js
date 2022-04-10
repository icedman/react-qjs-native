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
      <input
        value={this.props.value}
        style={{ ...this.props.style }}
        onChange={this.props.onChangeText}
        onSubmit={this.props.onSubmitEditing}
      >
        {this.props.children}
      </input>
    );
  }
}
