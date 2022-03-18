import React from "react";

const { Component, Fragment } = React;

export default class ScrollView extends Component {
  render() {
    return (
      <scrollview
        onClick={this.props.onClick}
        style={{
          display: "flex",
          flexDirection: "column",
          ...this.props.style,
        }}
      >
        {this.props.children}
      </scrollview>
    );
  }
}
