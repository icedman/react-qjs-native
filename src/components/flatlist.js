import React from "react";

const { Component, Fragment } = React;

export default class FlatList extends Component {
  render() {
    return (
      <flatlist
        onClick={this.props.onClick}
        style={{
          display: "flex",
          flexDirection: "column",
          ...this.props.style,
        }}
      >
        {this.props.children}
      </flatlist>
    );
  }
}
