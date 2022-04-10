import React from "react";
import uuid from "tiny-uuid";
import {
  Text,
  View,
  TextInput,
  Button,
  ScrollView,
  FlatList,
  Icon
} from "./components";

const { Component, Fragment } = React;

class App extends Component {
  constructor() {
    super();
    this.state = {
      greet: "Hello React!",
      number: 2,
      other: "Some other text",
      items: [{ key: "_0", name: "iii" }],
    };
  }

  render() {
    const { greet, number, other } = this.state;
    return (
      <View style={{ flexDirection: "column" }}>
        <View style={{ flexDirection: "row" }}>
          <Fragment>greet:{greet}</Fragment>
          <Fragment>number:{number}</Fragment>
        </View>

        <FlatList>
          {this.state.items.map((d) => (
            <Text style={{ height: 32 }}>
              {d.id} {d.name}
            </Text>
          ))}
        </FlatList>

        <TextInput
          value="xxx"
          onChangeText={(value) => {
            this.setState({ other: value });
          }}
        />
        <TextInput
          value="yyy"
          onChangeText={(value) => {
            this.setState({ other: value });
          }}
        />
        <Text
          style={{ color: "#ff0000", borderColor: "#ff0000" }}
          onClick={() => {
            this.setState({
              greet: "Hello from Flutter!",
              number: this.state.number + 1,
              items: [
                { key: uuid(), name: `xxx_${this.state.items.length}` },
                ...this.state.items,
              ],
            });
          }}
        >
          {other}
        </Text>
        <Button
          style={{ color: "#ff00ff", flex: 3 }}
          onClick={() => {
            // this.setState({
            //   greet: "Hello from Flutter!",
            //   number: this.state.number + 1,
            // });
            console.log("tap!!!");
          }}
        >
          Hello
        </Button>
      </View>
    );
  }

  componentDidMount() {
    console.log("APP DID MOUNT!");
    // XXX: Emulate event driven update
    setTimeout(
      () => this.setState({ greet: "Hello Flutter!", number: 1 }),
      2000
    );
    setTimeout(() => this.setState({ greet: "Goodbye!", number: 2 }), 3000);
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

export default App;
