/*
 * In window A's scripts, with A being on <http://example.com:8080>:
 */

// var popup = window.open(...popup details...);

// When the popup has fully loaded, if not blocked by a popup blocker:

var dest= "http://127.0.0.1:9090";
var src = "http://127.0.0.1:8080";

window.addEventListener("load", function(event) {

    var popup = window.open(dest+"/index2.html", "Test");

    // This does nothing, assuming the window hasn't changed its location.

    var rst = popup.postMessage("The user is 'bob' and the password is 'secret'",
                                "https://secure.example.net");
    // alert("Rst: "+rst);
    // This will successfully queue a message to be sent to the popup, assuming
    // the window hasn't changed its location.
    sleep(500).then(() => {
        // Do something after the sleep!
        rst=popup.postMessage("hello there!", dest);
    });
    // alert("Rst: "+rst);

}, false);

function receiveMessage(event)
{
    // Do we trust the sender of this message?  (might be
    // different from what we originally opened, for example).
    if (event.origin !== dest) {
        alert("src not ok: " + event.origin);
        return;

    }

    // event.source is popup
    // event.data is "hi there yourself!  the secret response is: rheeeeet!"
    alert("Data: "+ event.data);
}
window.addEventListener("message", receiveMessage, false);


function sleep (time) {
    return new Promise((resolve) => setTimeout(resolve, time));
}
// sleep(500).then(() => {
//     // Do something after the sleep!
// });
