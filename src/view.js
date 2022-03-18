import React from 'react'

const { Component, Fragment } = React

export default class View extends Component {
  render() {
    return (
      <view
        onClick={this.props.onClick}
        style={{
          display: 'flex',
          flexDirection: 'column',
          ...this.props.style
        }}
      >
        {this.props.children}
      </view>
    );
  }
}