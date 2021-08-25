/* global globalThis */
// import * as std from 'std'
// import * as os from 'os'

globalThis.process = { env: { NODE_ENV: 'development' } }
if (!globalThis.setTimeout) globalThis.setTimeout = globalThis.os ? globalThis.os.setTimeout : 
    (f, d) => { f(); }
if (!globalThis.console) globalThis.console = {}
globalThis.console.log = app.log
globalThis.console.warn = app.log
globalThis.console.error = app.log

