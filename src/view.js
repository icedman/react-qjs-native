import React from 'react'

const { Component, Fragment } = React

export default class View extends Component {
  render() {
    return <view>{this.props.children}</view>;
  }
}