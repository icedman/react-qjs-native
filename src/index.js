import "./polyfill.js";
import Reconciler from "react-reconciler";
import React from "react";
import uuid from "tiny-uuid";
import App from "./app";
import ReactTinyDOM from "./renderer";

// app.log('inside the app...')

ReactTinyDOM.render(<App />, document.getElementById("root"));

// console.log(JSON.stringify(globalThis.os, null, 4))
// console.log(uuid())
