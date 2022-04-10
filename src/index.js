import "./polyfill.js";
import Reconciler from "react-reconciler";
import React from "react";
import uuid from "tiny-uuid";
// import App from "./app";
import App from "./todo";
import ReactTinyDOM from "./renderer";

ReactTinyDOM.render(<App />, document.getElementById("root"));

