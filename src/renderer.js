import React from "react";
import Reconciler from "react-reconciler";
import uuid from "tiny-uuid";

function getCircularReplacer() {
  const seen = new WeakSet();
  return (key, value) => {
    if (key === "children") {
      return value.map((c) => c.key);
    }
    return value;
  };
}

// based on react-tiny-dom

function shallowDiff(oldObj, newObj) {
  const uniqueProps = new Set();
  Object.keys(oldObj).forEach((k) => uniqueProps.add(k));
  Object.keys(newObj).forEach((k) => uniqueProps.add(k));
  const changedProps = Array.from(uniqueProps).filter(
    (propName) => oldObj[propName] !== newObj[propName]
  );
  return changedProps;
}

function isUppercase(letter) {
  return /[A-Z]/.test(letter);
}

function isEventName(propName) {
  return propName.startsWith("on");
}

const hostConfig = {
  // appendChild for direct children
  appendInitialChild(parentInstance, child) {
    parentInstance.appendChild(child);
  },

  // Create the DOMElement, but attributes are set in `finalizeInitialChildren`
  createInstance(
    type,
    props,
    rootContainerInstance,
    hostContext,
    internalInstanceHandle
  ) {
    return document.createElement(type, props);
  },

  createTextInstance(text, rootContainerInstance, internalInstanceHandle) {
    // A TextNode instance is returned because literal strings cannot change their value later on update
    return document.createTextNode(text);
  },

  // Actually set the attributes and text content to the domElement and check if
  // it needs focus, which will be eventually set in `commitMount`
  finalizeInitialChildren(domElement, type, props) {
    // Set the prop to the domElement
    Object.keys(props).forEach((propName) => {
      const propValue = props[propName];

      if (propName === "style") {
        domElement.setAttribute("style", domElement.toStyleObject(propValue));
      } else if (propName === "children") {
        // Set the textContent only for literal string or number children, whereas
        // nodes will be appended in `appendChild`
        if (typeof propValue === "string" || typeof propValue === "number") {
          domElement.textContent = propValue;
          domElement.setAttribute("textContent", propValue);
        }
      } else if (propName === "className") {
        domElement.setAttribute("class", propValue);
      } else if (isEventName(propName) && typeof propValue === "function") {
        domElement.addEventListener(propName, propValue);
      } else {
        domElement.setAttribute(propName, propValue);
      }
    });
    return false;
  },

  // Useful only for testing
  getPublicInstance(inst) {
    return inst;
  },

  // Commit hooks, useful mainly for react-dom syntethic events
  prepareForCommit() {},
  resetAfterCommit() {},

  // Calculate the updatePayload
  prepareUpdate(domElement, type, oldProps, newProps) {
    return shallowDiff(oldProps, newProps);
  },

  getRootHostContext(rootInstance) {
    return {};
  },
  getChildHostContext(parentHostContext, type) {
    return {};
  },

  shouldSetTextContent(type, props) {
    return (
      type === "textarea" ||
      typeof props.children === "string" ||
      typeof props.children === "number"
    );
  },

  now: () => {
    // noop
  },

  supportsMutation: true,

  useSyncScheduling: true,

  appendChild(parentInstance, child) {
    parentInstance.appendChild(child);
  },

  // appendChild to root container
  appendChildToContainer(parentInstance, child) {
    parentInstance.appendChild(child);
  },

  removeChild(parentInstance, child) {
    parentInstance.removeChild(child);
  },

  removeChildFromContainer(parentInstance, child) {
    parentInstance.removeChild(child);
  },

  insertBefore(parentInstance, child, beforeChild) {
    parentInstance.insertBefore(child, beforeChild);
  },

  insertInContainerBefore(parentInstance, child, beforeChild) {
    parentInstance.insertBefore(child, beforeChild);
  },

  commitUpdate(
    domElement,
    updatePayload,
    type,
    oldProps,
    newProps,
    internalInstanceHandle
  ) {},

  commitMount(domElement, type, newProps, internalInstanceHandle) {
    domElement.focus();
  },

  commitTextUpdate(domElement, oldText, newText) {
    // textInstance.nodeValue = newText;
    domElement.setAttribute("textContent", newText);
  },

  resetTextContent(domElement) {
    domElement.textContent = "";
    domElement.setAttribute("textContent", "");
  },
};

const TinyDOMRenderer = Reconciler(hostConfig);

export default ReactTinyDOM = {
  render(element, domContainer, callback) {
    let root = domContainer._reactRootContainer;

    if (!root) {
      // Remove all children of the domContainer
      let rootSibling;
      while ((rootSibling = domContainer.lastChild)) {
        domContainer.removeChild(rootSibling);
      }

      const newRoot = TinyDOMRenderer.createContainer(domContainer);
      root = domContainer._reactRootContainer = newRoot;
    }

    return TinyDOMRenderer.updateContainer(element, root, null, callback);
  },
};
