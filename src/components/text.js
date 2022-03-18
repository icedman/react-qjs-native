import React from "react";

const { Component, Fragment } = React;

export default class Text extends Component {
  render() {
    return (
      <text style={{ ...this.props.style }} onClick={this.props.onClick}>
        {this.props.children}
      </text>
    );
  }
}
