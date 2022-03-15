import React from 'react'
import uuid from 'tiny-uuid'
import Text from './text'
import View from './view'

const { Component, Fragment } = React


class App extends Component {
  constructor () {
    super()
    this.state = {
      _id: uuid(),
      hello: 'Hello React!',
      p: 0
    }
  }

  render () {
    const { hello, p } = this.state
    // console.log(JSON.stringify(this.state))
    return (
      <Fragment>
        <Fragment key='1'>
        greet:{hello}
        </Fragment>
        <Fragment key='2'>
        p:{p} 
        </Fragment>
        <View key='4'><Text key='3'>xxx</Text></View>
      </Fragment>
    )
  }

  componentDidMount () {
    console.log('APP DID MOUNT!')

    // XXX: Emulate event driven update
    setTimeout(() => this.setState({ hello: 'Hello Pi!', p: 42 }), 2000)
    setTimeout(() => this.setState({ hello: '', p: -1 }), 4000)
  }
}

/*

class App extends Component {
  render() {
    return (
      <View
        style={{
          flex: 1,
          justifyContent: 'center',
          alignItems: 'center',
          backgroundColor: '#8BBDD9',
          height: 400
        }}
      >
        <Text>Hello React Native Custom Renderer</Text>
      </View>
    );
  }
}
*/

export default App
