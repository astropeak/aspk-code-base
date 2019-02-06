var dest= "http://127.0.0.1:9090";
var src = "http://127.0.0.1:8080";

function receiveMessage(event)
{
    // Do we trust the sender of this message?  (might be
    // different from what we originally opened, for example).
    if (!(event.origin === src ||
         event.origin === "http://localhost:8080")) {
        alert("src not ok: " + event.origin);
        return;

    }

    // event.source is popup
    // event.data is "hi there yourself!  the secret response is: rheeeeet!"
    alert("Data: "+ event.data);
    // This does nothing, assuming the window hasn't changed its location.
    event.source.postMessage("The user is 'bob' and the password is 'secret'",
                             event.origin);


}
window.addEventListener("message", receiveMessage, false);