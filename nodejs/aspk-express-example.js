var http = require('http');
var fs = require('fs');
var ff = require('./ff');
// var fileMailerApp = require('./fileMailerApp');

var app = ff();
var s = http.createServer(app);
app.get('/', function(req, res, next) {
    console.log('This is call 0');
    next();
});
app.get('/aaa', function(req, res, next) {
    console.log('This is call 1');
    next();
});

app.all('/', function(req, res, next) {
    console.log('middleware 1');
    next();
});

app.all('/filemailer/*', function(req,res,next){
    console.log('file mailer app, url: ', req.url);
    req.url = req.url.substring(11);
    console.log('file mailer app, url: ', req.url);
    // fileMailerApp(req,res);

    next();
});

app.get('/', function(req, res, next) {
    console.log('This is call 2');
    res.end('Call 2');
});
app.get('/aaa', function(req, res, next) {
    console.log('This is call 3');
    res.end('Call 3');
    next();
});

s.listen(5600, '127.0.0.1');
console.log('Server running at http://127.0.0.1:5600/');