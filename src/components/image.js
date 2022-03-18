import React from "react";

const { Component, Fragment } = React;

export default class Image extends Component {
  render() {
    return (
      <image style={{ ...this.props.style }} onClick={this.props.onClick}>
        {this.props.children}
      </image>
    );
  }
}
