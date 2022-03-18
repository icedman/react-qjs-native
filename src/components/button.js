import React from "react";

const { Component, Fragment } = React;

export default class Button extends Component {
  render() {
    return (
      <button style={{ ...this.props.style }} onClick={this.props.onClick}>
        {this.props.children}
      </button>
    );
  }
}
