// getting-started.js
var mongoose = require('mongoose');
var assert = require('assert');

// mongoose.connect( 'mongodb://localhost:27017/myproject');
mongoose.connect('mongodb://localhost/test');


var db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function() {
    // we're connected!
    var kittySchema = mongoose.Schema({
        name: String,
        job:String
    });

    var Kitten = mongoose.model('Kitten', kittySchema);

    var silence = new Kitten({ name: 'Silence' });
    console.log(silence.name); // 'Silence'

    // silence.save(function (err, silence) {
    // assert.equal(null, err);
    // console.log("saved to db. D: ", silence);
    // });

    Kitten.update({name:'aaaa'}, {name:'aaaa', job:"bbbbb"},function(err, raw){

        assert.equal(null, err);
        console.log("update: raw: ", raw);


        Kitten.find({}, function (err, kittens) {
            assert.equal(null, err);
            console.log("all kittens: ", kittens);
        });
    });

    // Kitten.findOne({ name: 'Silence' }, function (err, doc) {
    //     assert.equal(null, err);
    //     doc.name = 'jason borne';
    //     console.log("find one.");
    //     doc.job="Student";
    //     doc.save(function(err, a){
    //         assert.equal(null, err);
    //         console.log("Saved. a: ", a);
    //     });
    // });

});