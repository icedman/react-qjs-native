// Simple plugin that converts every identifier to "LOL"
function lolizer() {
    return {
      visitor: {
        Identifier(path) {
          path.node.name = "LOL";
        },
      },
    };
  }

Babel.registerPlugin("lolizer", lolizer);

var str = 'function hello() { alert("hello"); }';
var str2 = '<Text>text</Text>';

var res = Babel.transform(str2, {
    presets: [ 'latest' ],
    plugins: [
        'transform-react-jsx'
    ]
}).code;

console.log(res);

