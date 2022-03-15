/* global globalThis */
// import * as std from 'std'
// import * as os from 'os'

import uuid from 'tiny-uuid'

globalThis.process = { env: { NODE_ENV: 'development' } }
if (!globalThis.setTimeout) globalThis.setTimeout = globalThis.os ? globalThis.os.setTimeout : 
    (f, d) => { f(); }
if (!globalThis.console) globalThis.console = {}
globalThis.console.log = app.log
globalThis.console.warn = app.log
globalThis.console.error = app.log

class Elm {
    constructor(t) {
        this._id = uuid();
        this.type = t;
        this.children = [];
        this.attributes = {};
        this.style = {};
        console.log(JSON.stringify(this));
    }

    appendChild(c) {
        c._parent = this._id;
        this.children.push(c);
        // console.log(JSON.stringify(c));
    }

    removeChild(c) {
        let idx = this.children.indexOf(c);
        if (idx != -1) {
            this.children.splice(idx, 1);
        }
    }

    insertBefore(c, b) {
        let idx = this.children.indexOf(b);
        if (idx != -1) {
            this.children.splice(idx, 0, c);
        }
    }

    setAttribute(a, v) {
        this.attributes[a] = v;
    }

    removeAttribute(a) {
        erase(this.attributes[a]);
    }
}

class Doc extends Elm {
    constructor() {
        super('document');
    }

    createElement(t) {
        return new Elm(t);
    }

    createTextNode(t) {
        let res = new Elm('text');
        res.contentText = t;
        return res;
    }

    getElementById() {
        return globalThis.document;
    }
}

globalThis.document = new Doc;