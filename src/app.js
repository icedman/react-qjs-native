import React from 'react'
import uuid from 'tiny-uuid'
import Text from './text'
import View from './view'

const { Component, Fragment } = React


class App extends Component {
  constructor () {
    super()
    this.state = {
      greet: 'Hello React!',
      number: 0
    }
  }


  render () {
    const { greet, number } = this.state
    // console.log(JSON.stringify(this.state))

    return (
      <View style={{flexDirection: 'column'}}>
        <View style={{flexDirection: 'row'}}>
          <Fragment>
          greet:{greet}
          </Fragment>
          <Fragment>
          number:{number} 
          </Fragment>
        </View>
        <Text style={{color:'red'}} 
          onClick={()=>{
            this.setState({ greet: 'Hello from Flutter!', number: this.state.number + 1 });
          }}>Some other text</Text>
      </View>
    )
  }

  componentDidMount () {
    console.log('APP DID MOUNT!')
    // XXX: Emulate event driven update
    setTimeout(() => this.setState({ greet: 'Hello Flutter!', number: 1 }), 2000)
    setTimeout(() => this.setState({ greet: 'Goodbye!', number: 2 }), 3000)
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
