/* global globalThis */
// import * as std from 'std'
// import * as os from 'os'

import uuid from "tiny-uuid";
import { isUnitlessProperty } from "./css";

globalThis.process = { env: { NODE_ENV: "development" } };
if (!globalThis.setTimeout)
  globalThis.setTimeout = globalThis.os
    ? globalThis.os.setTimeout
    : (f, d) => {
        f();
      };
if (!globalThis.console) globalThis.console = {};

try {
  globalThis.console.log = app.log;
  globalThis.console.warn = app.log;
  globalThis.console.error = app.log;
  globalThis.sendMessage = (type, msg) => app.log(msg);
} catch (err) {
  globalThis.console.log = (msg) => sendMessage("log", JSON.stringify(msg));
  globalThis.console.warn = (msg) => sendMessage("log", JSON.stringify(msg));
  globalThis.console.error = (msg) => sendMessage("log", JSON.stringify(msg));
}

function getCircularReplacer() {
  const seen = new WeakSet();
  return (key, value) => {
    if (key === "children") {
      return value.map((c) => c._id);
    }
    return value;
  };
}

const registry = {};

globalThis.onEvent = (id, type, value) => {
  var elm = registry[id];
  if (!elm) return;
  var func = elm.listeners[type];
  if (!func) return;
  func(value);
};

class Elm {
  constructor(t) {
    this._id = uuid();
    this.type = t;
    this.children = [];
    this.attributes = {};
    this.style = {};
    this.listeners = {};
    registry[this._id] = this;
  }

  appendChild(c) {
    c._parent = this._id;
    this.children.push(c);
    sendMessage(
      "onAppend",
      JSON.stringify({ element: this._id, child: c._id })
    );
  }

  removeChild(c) {
    let idx = this.children.indexOf(c);
    if (idx != -1) {
      this.children.splice(idx, 1);
    }

    sendMessage(
      "onRemove",
      JSON.stringify({ element: this._id, child: c._id })
    );
  }

  insertBefore(c, b) {
    let idx = this.children.indexOf(b);
    if (idx != -1) {
      this.children.splice(idx, 0, c);
    }
  }

  setAttribute(a, v) {
    this.attributes[a] = v;
    sendMessage(
      "onUpdate",
      JSON.stringify({ element: this._id, attributes: { [a]: v } })
    );
  }

  removeAttribute(a) {
    erase(this.attributes[a]);
    // sendMessage('onUpdate', JSON.stringify({ element: this._id }));
  }

  addEventListener(eventName, callback) {
    this.listeners[eventName] = callback;
    console.log("listen: " + this._id + ", " + eventName);
    sendMessage(
      "onUpdate",
      JSON.stringify({ element: this._id, events: { [eventName]: "function" } })
    );
  }

  // these are not actually a document function
  toStyleObject(styles) {
    let res = {};
    Object.keys(styles).forEach((name) => {
      // console.log(name);
      const rawValue = styles[name];
      const isEmpty =
        rawValue === null || typeof rawValue === "boolean" || rawValue === "";

      if (isEmpty) res[name] = "";
      else {
        const value =
          typeof rawValue === "number" && !isUnitlessProperty(name)
            ? `${rawValue}px`
            : rawValue;
        res[name] = value;
      }
    });
    return res;
  }
}

class Doc extends Elm {
  constructor() {
    super("document");
    sendMessage("onCreate", JSON.stringify(this, getCircularReplacer()));
  }

  createElement(t,p) {
    let res = new Elm(t);
    Object.keys(p).forEach(k => {
      if (typeof(p[k]) !== 'object') {
        res.attributes[k] = p[k];
      } else if (k == 'style') {
        res.attributes['style'] = this.toStyleObject(p[k]);
      }
    });
    sendMessage("onCreate", JSON.stringify(res, getCircularReplacer()));
    return res;
  }

  createTextNode(t) {
    let res = new Elm("text");
    res.attributes["textContent"] = t;
    sendMessage("onCreate", JSON.stringify(res, getCircularReplacer()));
    return res;
  }

  getElementById() {
    return globalThis.document;
  }
}

globalThis.document = new Doc();
