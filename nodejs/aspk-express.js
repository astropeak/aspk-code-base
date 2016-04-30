function ff() {
    var match = function(a, b) {
        if (a[a.length-1] === '*') {
            console.log('in match: a:', a, ' ,b:',b);
            return a.substring(0, a.length-1) ===b.substring(0,a.length-1);
        }
        return a===b;
    };

    var matchMethod = function(a, b) {
        if (a === 'ALL') return true;
        else return a===b;
    };
    var that = function(req, res) {
        var i=0;
        var next = function() {
            while (i<tab.length && !(match(tab[i].path, req.url)
                                     && matchMethod(tab[i].method, req.method))) {
                ++i;
            }
            if (i<tab.length) {
                ++i;
                tab[i-1].fn(req, res, next);
            }
        };

        next();
    };

    var tab = [];
    var genFt = function(method) {
        return function(path, fn) {
            if (typeof path === 'function') {
                path = '/';
                fn = path;
            }
            tab.push({method:method, path:path, fn:fn});
        };
    };
    that.get = genFt('GET');
    that.post = genFt('POST');
    that.all = genFt('ALL');

    return that;
}
module.exports = ff;