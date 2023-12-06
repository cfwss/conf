// An example script for redirecting users from USA to https://google.com/
// and users from Canada to https://google.ca/

// ip-api endpoint URL
// we need only the countryCode, but you can request more fields
// see http://ip-api.com/docs/api:json for documentation
var endpoint = 'http://ip-api.com/json/?fields=status,message,countryCode';

var xhr = new XMLHttpRequest();
xhr.onreadystatechange = function() {
	if (this.readyState == 4 && this.status == 200) {
		var response = JSON.parse(this.responseText);
		if(response.status !== 'success') {
			console.log('query failed: ' + response.message);
			return
		}
		// Redirect
		if(response.countryCode == "US") {
			window.location.replace("https://google.com/");
		}
		if(response.countryCode == "CA") {
			window.location.replace("https://google.ca/");
		}
	}
};
xhr.open('GET', endpoint, true);
xhr.send();
