function forwardOauth() {
  var protocol = document.location.protocol;
  var host = document.location.host;
  var port = document.location.port;
  var loc = document.location;
  var endpoint = '/oauth/twitch';

  fetch(endpoint, {
    method: "POST",
    body: loc,
    headers: {
      "Content-type": "application/json; charset=UTF-8"
    }
  });
}