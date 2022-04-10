import React from "react";
import uuid from "tiny-uuid";
import { Text, View, TextInput, Button, ScrollView, FlatList } from "./components";

const { Component, Fragment } = React;

class App extends Component {
  constructor() {
    super();
    this.state = {
        edit: '',
      todos: [],
    };
  }

  render() {
    const { greet, todos, edit } = this.state;
    return (
      <View style={{ flexDirection: "column" }}>
        <FlatList>
        {this.state.todos.map((d, idx) => (<View style={{
            height: 40, flexDirection: "row" }}>
            <Text style={{width:80}}>
                {/*`${d.key == edit ? 'edit' : d.key}-${this.state.todos[idx].marked ? 'done' : ''}`*/}
                {this.state.todos[idx].marked ? 'done' : ''}
            </Text>
            <View>
            {d.key != edit && <Text style={{flex:4 }} onClick={() => {
                this.state.todos[idx].marked = !this.state.todos[idx].marked;
                this.setState({
                    todos: this.state.todos
                });
                console.log(this.state.todos);
            }}>{d.name}</Text>}
            {d.key == edit && <TextInput value={d.name}
                onChangeText={(value) => {
                    this.state.todos[idx].name = value;
                    this.setState({
                        todos: this.state.todos
                    });
                    }}
                onSubmitEditing={(value) => {
                    this.setState({
                        edit: ''
                    });
                    }}
                />}
            </View>
            <Button key="edit" style={{width: 80}} onClick={() => {
                this.setState({
                    edit: this.state.todos[idx].key == this.state.edit ? '' : this.state.todos[idx].key
                });
            }}>Edit</Button>
            <Button key="delete" style={{width: 80}} onClick={() => {
                this.state.todos.splice(idx, 1);
                this.setState({
                    todos: this.state.todos
                });
            }}>Delete</Button>
            </View>))} 
        </FlatList>
        <Text>{edit}</Text>
        <Button 
          style={{ color: "#ff00ff", height: 40 }}
          onClick={() => {
            this.setState({
              todos: [
                  { key: uuid(), name: "new todo", marked: false },
                  ...this.state.todos
              ]
            });
          }}>
            Add Todo
        </Button>
      </View>
    );
  }

  componentDidMount() {
  }
}

export default App;
