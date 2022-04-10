import React from "react";
import uuid from "tiny-uuid";
import {
  Text,
  View,
  TextInput,
  Button,
  FlatList,
  Icon
} from "./components";

const { Component, Fragment } = React;

class App extends Component {
  constructor() {
    super();
    this.state = {
      edit: "",
      todos: [],
    };
  }

  render() {
    const { edit } = this.state;
    return (
      <View style={{ flexDirection: "column" }}>
        <FlatList>
          {this.state.todos.map((d, idx) => (
            <View
              style={{
                height: 40,
                flexDirection: "row",
              }}
            >
              <Icon key="icon" data={this.state.todos[idx].marked ? 0xe159 : 0xe485} style={{ width: 40 }}/>
              <View key="item">
                {d.key != edit && (
                  <Text
                    style={{ flex: 4, strikethrough: this.state.todos[idx].marked ? "true" : "false" }}
                    onClick={() => {
                      this.state.todos[idx].marked =
                        !this.state.todos[idx].marked;
                      this.setState({
                        todos: this.state.todos,
                      });
                    }}
                  >
                    {d.name}
                  </Text>
                )}
                {d.key == edit && (
                  <TextInput
                    key="input"
                    value={d.name}
                    onChangeText={(value) => {
                      if (typeof(value) === 'object') {
                        value = value.target.value;
                      }
                      this.state.todos[idx].name = value;
                      this.setState({
                        todos: this.state.todos,
                      });
                    }}
                    onSubmitEditing={(value) => {
                      this.setState({
                        edit: "",
                      });
                    }}
                  />
                )}
              </View>
              <Button
                key="edit"
                style={{ width: 80 }}
                onClick={() => {
                  this.setState({
                    edit:
                      this.state.todos[idx].key == this.state.edit
                        ? ""
                        : this.state.todos[idx].key,
                  });
                }}
              >
                Edit
              </Button>
              <Button
                key="delete"
                style={{ width: 80 }}
                onClick={() => {
                  this.state.todos.splice(idx, 1);
                  this.setState({
                    todos: this.state.todos,
                  });
                }}
              >
                Delete
              </Button>
            </View>
          ))}
        </FlatList>
        <Button
          style={{ color: "#ff00ff", height: 40 }}
          onClick={() => {
            let key = uuid();
            this.setState({
              edit: key,
              todos: [
                { key: key, name: "new todo", marked: false },
                ...this.state.todos
              ]
            });
          }}
        >
          Add Todo
        </Button>
      </View>
    );
  }

  componentDidMount() {}
}

export default App;
