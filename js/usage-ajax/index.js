//Lets require/import the HTTP module
var http = require('http');
var fs = require('fs');

//Lets define a port we want to listen to
const PORT=8080;

//We need a function which handles requests and send response
function handleRequest(req, res){
    var file= req.url.substring(1);
    if (file === '') {
        file = "index.html";
    }
    console.log("File: "+file);
    if (fs.existsSync(file)) {
        res.writeHead(200);
        res.end(fs.readFileSync(file));
    } else {
        if (req.url === '/aaa.bbb') {
            console.log('fetch aaa.bbb');
            res.writeHead(200);
            res.end("dddddd");
        } else if(req.url==="/json") {
            res.writeHead(200, {'Content-Type': 'application/json'});
            res.write(JSON.stringify({"name":"Tom", "age":18}));
            res.end('');

        } else {
            res.writeHead(200, {'Content-Type': 'text/text'});
            res.end('It Works!! Path Hit: ' + req.url);
        }
    }
}

//Create a server
var server = http.createServer(handleRequest);

//Lets start our server
server.listen(PORT, function(){
    //Callback triggered when server is successfully listening. Hurray!
    console.log("Server listening on: http://localhost:%s", PORT);
});