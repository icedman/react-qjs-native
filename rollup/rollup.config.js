const jsx = require('./jsx-plugin.js')
const commonjs = require('rollup-plugin-commonjs')
const nodeResolve = require('rollup-plugin-node-resolve')
const nodeBuiltins = require('rollup-plugin-node-builtins')
const nodeGlobals = require('rollup-plugin-node-globals')

module.exports = {
  input: 'src/index.js',
  output: {
    file: 'dist/app.js',
    format: 'esm'
  },
  external: ['os', 'std'],
  plugins: [
    jsx(),
    commonjs({ include: 'node_modules/**', sourceMap: false }),
    // nodeGlobals(),
    // nodeBuiltins(),
    nodeResolve({ preferBuiltins: true })
  ]
}
