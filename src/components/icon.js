import React from "react";

const { Component, Fragment } = React;

export default class Icon extends Component {
  render() {
    return (
      <icon data={this.props.data} style={{ ...this.props.style }} onClick={this.props.onClick}></icon>
    );
  }
}
