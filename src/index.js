import './polyfill.js'

import Reconciler from 'react-reconciler'
import React from 'react'

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
    // appendNativeElement(parent, stateNode)
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
    return {}
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
    app.log('commitTextUpdate')
  },
  commitUpdate (
    instance, updatePayload, type, oldProps, newProps, finishedWork
  ) {
    app.log('commitUpdate')
    // updateNativeElement(instance, newProps)
  },
  removeChildFromContainer (parent, stateNode) {
    app.log('removeChildFromContainer')
    // removeNativeElement(parent, stateNode)
  },

  useSyncScheduling: true,
  supportsMutation: true
}

class NativeContainer {
  constructor () {
    this.elements = []
    this.synced = true
    // init()
    // clear()
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
    app.log('tick..')
    // app.log('Native frame tick!')
    if (!this.synced) this.render()
    this.synced = true
  }

  render () {
    app.log('render..')
    // clear()
    // for (let i = 0; i < this.elements.length; i++) {
    //   const element = this.elements[i]
    //   if (element instanceof NativeTextElement) {
    //     const { children, row, col } = element.props
    //     drawText(children, row, col)
    //   } else if (element instanceof NativePixelElement) {
    //     drawPixel(element.props.x, element.props.y)
    //   }
    //   console.log(JSON.stringify(element.props))
    // }
  }
}

const reconciler = Reconciler(hostConfig)
const root = new NativeContainer()
const container = reconciler.createContainer(root, false)

const { Component, Fragment } = React
class App extends Component {
  constructor () {
    super()
    this.state = {
      hello: 'Hello React!',
      p: 0
    }
  }

  render () {
    const { hello, p } = this.state
    console.log(JSON.stringify(this.state))
    return (
      <Fragment>
          {hello}
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

// console.log(<App hello={'QuickJS'} />)

const MyRenderer = {
  render (reactElement) {
    return reconciler.updateContainer(reactElement, container)
  }
}

// app.log('inside the app...')

MyRenderer.render(<App/>)

// console.log(JSON.stringify(globalThis.os, null, 4));