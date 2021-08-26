import React from 'react'
import uuid from 'tiny-uuid'

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
    console.log(JSON.stringify(this.state))
    return (
      <Fragment>
        <Fragment key='1'>
        greet:{hello}
        </Fragment>
        <Fragment key='2'>
        p:{p} 
        </Fragment>
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

export default App
