import './polyfill.js'
import Reconciler from 'react-reconciler'
import React from 'react'
import uuid from 'tiny-uuid'

import App from './app'

const FPS = 30
const mainLoop = async (onTick, delay = 1000 / FPS) => {
  const nativeTick = () => new Promise(resolve => {
    onTick()
    setTimeout(resolve, delay)
  })
  while (true) await nativeTick()
}

const hostConfig = {
  appendInitialChild (parent, stateNode) {
    app.log('appendInitialChild')
  },
  appendChildToContainer (parent, stateNode) {
    app.log('appendChildToContainer')
    // app.log(JSON.stringify(parent,null,4));
    // app.log(stateNode);
    // appendNativeElement(parent, stateNode)
    parent.appendElement(stateNode);
  },
  appendChild (parent, stateNode) {
    app.log('appendChild')
  },
  createInstance (type, props, internalInstanceHandle) {
    app.log('createInstance')
    // return createNativeInstance(type, props)
    return {}
  },
  createTextInstance (text, rootContainerInstance, internalInstanceHandle) {
    app.log('createTextInstance')
    return text
  },
  finalizeInitialChildren (wordElement, type, props) {
    app.log('finalizeInitialChildren')
    return false
  },
  getPublicInstance (instance) {
    app.log('getPublicInstance')
    return instance
  },
  now: Date.now,
  prepareForCommit () {
    app.log('prepareForCommit')
  },
  prepareUpdate (wordElement, type, oldProps, newProps) {
    app.log('prepareUpdate')
    return true
  },
  resetAfterCommit () {
    app.log('resetAfterCommit')
  },
  resetTextContent (wordElement) {
    app.log('resetTextContent')
  },
  getRootHostContext (instance) {
    app.log('getRootHostContext')
    return null
    // return getHostContextNode(instance)
  },
  getChildHostContext (instance) {
    app.log('getChildHostContext')
    return {}
  },
  shouldSetTextContent (type, props) {
    app.log('shouldSetTextContent')
    return false
  },

  // Methods for updating state
  // --------------------------
  commitTextUpdate (textInstance, oldText, newText) {
    app.log('commitTextUpdate:' + newText)
    app.log(textInstance);
  },
  commitUpdate (
    instance, updatePayload, type, oldProps, newProps, finishedWork
  ) {
    app.log('commitUpdate')
    app.log(newProps);
    // updateNativeElement(instance, newProps)
  },
  removeChildFromContainer (parent, stateNode) {
    app.log('removeChildFromContainer')
    parent.removeElement(stateNode);
    // removeNativeElement(parent, stateNode)
  },

  useSyncScheduling: true,
  supportsMutation: true
}

class NativeContainer {
  constructor () {
    this.elements = []
    this.synced = true
    mainLoop(() => this.onFrameTick())
  }

  appendElement (element) {
    this.synced = false
    this.elements.push(element)
    app.log('add..')
  }

  removeElement (element) {
    this.synced = false
    const i = this.elements.indexOf(element)
    if (i !== -1) this.elements.splice(i, 1)
  }

  onFrameTick () {
    if (!this.synced) this.render()
    this.synced = true
  }

  render () {
    app.log('render..')
  }
}

const reconciler = Reconciler(hostConfig)
const root = new NativeContainer()
const container = reconciler.createContainer(root, false)

/*
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
    // setTimeout(() => this.setState({ hello: 'Hello Pi!', p: 42 }), 2000)
    // setTimeout(() => this.setState({ hello: '', p: -1 }), 4000)
  }
}
*/

// console.log(<App hello={'QuickJS'} />)

const MyRenderer = {
  render (reactElement) {
    return reconciler.updateContainer(reactElement, container)
  }
}

// app.log('inside the app...')

MyRenderer.render(<App/>)

// console.log(JSON.stringify(globalThis.os, null, 4));
// console.log(uuid())