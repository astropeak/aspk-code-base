var db= require('db');
var _=require('underscore');

var Period = function(param) {
    // L.debug("In transction");
    this.db = db.load('period.db');
    return this;
};


Period.prototype.add = function(period, func) {
    var n=func.name;
    if (!this.db.get(n)) {
        this.db.add(n, new Date(new Date().getTime()));
    }
    return this;
};

Period.prototype.run = function() {
    var that = this;
    _.each(that.db.get_all(), function(trans, idx, obj) {
        //transction expired.
        if (!trans.fetching &&
            new Date(trans.last.getTime() + trans.period) < new Date()) {
            trans.fetching=1;
            trans.func(function (err) {
                trans.fetching=0;
                trans.last = new Date();
                that.db.update_to_db();
            });
        }
    });
    _.delay(that.run, that.period);
};
