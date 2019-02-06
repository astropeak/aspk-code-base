var MongoClient = require('mongodb').MongoClient
, assert = require('assert');

// Connection URL
var url = 'mongodb://localhost:27017/myproject';
// Use connect method to connect to the Server
MongoClient.connect(url, function(err, db) {
    assert.equal(null, err);
    console.log("Connected correctly to server");

    deleteDocument({d:1}, db, function (result) {
        console.log("delete callback, result: ", result);
        insertDocuments(db, function (result) {
            console.log("insert callback, result: ", result);
            updateDocument(db, function (result) {
                console.log("update callback, result: ", result);
                findDocuments(db, function (docs){
                    console.log("find callback, docs: ", docs);
                    db.close();
                });
            });
        });
    });
    // db.shutdownServer();
});


var insertDocuments = function(db, callback) {
    // Get the documents collection
    var collection = db.collection('documents');
    // Insert some documents
    collection.insertMany([
        {a : 1}, {a : 2}, {a : 3}
    ], function(err, result) {
        assert.equal(err, null);
        assert.equal(3, result.result.n);
        assert.equal(3, result.ops.length);
        console.log("Inserted 3 documents into the document collection");
        callback(result);
    });
};

var updateDocument = function(db, callback) {
    // Get the documents collection
    var collection = db.collection('documents');
    // Update document where a is 2, set b equal to 1
    collection.updateOne({ a : 2 }
                          , { a : 20,b:300  }, function(err, result) {
                              assert.equal(err, null);

                              console.log("Updated the document with the field a equal to 2");
                              callback(result);
                          });
};

var findDocuments = function(db, callback) {
    // Get the documents collection
    var collection = db.collection('documents');
    // Find some documents 
    collection.find({}).toArray(function(err, docs) {
        assert.equal(err, null);
        // assert.equal(2, docs.length);
        console.log("Found the following records");
        console.dir(docs);
        callback(docs);
    });
}

var deleteDocument = function(query, db, callback) {
    // Get the documents collection 
    var collection = db.collection('documents');
    // Insert some documents 
    collection.deleteMany(query, function(err, result) {
        assert.equal(err, null);
        // assert.equal(1, result.result.n);
        console.log("Removed the document with the field a equal to 3");
        callback(result);
    });
}