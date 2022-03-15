import React from 'react'

const { Component, Fragment } = React

export default class Text extends Component {
  render() {
    return <text>{this.props.children}</text>;
  }
}
