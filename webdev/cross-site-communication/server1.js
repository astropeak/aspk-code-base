//Lets require/import the HTTP module
var http = require('http');
var fs = require('fs');

//Lets define a port we want to listen to
const PORT=8080;

//We need a function which handles requests and send response
function handleRequest(req, res){
    res.writeHead(200);
    var file= req.url.substring(1);
    if (file === '') {
        file = "index.html";
    }
    console.log("File: "+file);
    if (fs.existsSync(file)) {
        res.end(fs.readFileSync(file));
    } else {
        res.end('It Works!! Path Hit: ' + req.url);
    }
}

//Create a server
var server = http.createServer(handleRequest);

//Lets start our server
server.listen(PORT, function(){
    //Callback triggered when server is successfully listening. Hurray!
    console.log("Server listening on: http://localhost:%s", PORT);
});