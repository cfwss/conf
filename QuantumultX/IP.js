// An example script for finding out the distance from the user to multiple points

// Coordinates and name
var coords = [
	{lat: 40.7127837, lon: -74.0059413, name: 'New York, NY'},
	{lat: 34.0522342, lon: -118.2436849, name: 'Los Angeles, CA'},
	{lat: 37.3382082, lon: -121.8863286, name: 'San Jose, CA'},
	{lat: 41.8781136, lon: -87.6297982, name: 'Chicago, IL'},
	{lat: 47.6062095, lon: -122.3320708, name: 'Seattle, WA'},
	];

// ip-api endpoint URL
// see http://ip-api.com/docs/api:json for documentation
var endpoint = 'http://ip-api.com/json/?fields=status,message,lat,lon';

function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
	var R = 6371; // Radius of the earth in km
	var dLat = deg2rad(lat2-lat1);  // deg2rad below
	var dLon = deg2rad(lon2-lon1); 
	var a = 
		Math.sin(dLat/2) * Math.sin(dLat/2) +
		Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
		Math.sin(dLon/2) * Math.sin(dLon/2); 
	var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
	var d = R * c; // Distance in km
	return d;
}

function deg2rad(deg) {
	return deg * (Math.PI/180)
}

var xhr = new XMLHttpRequest();
xhr.onreadystatechange = function() {
	if(this.readyState == 4 && this.status == 200) {
		var response = JSON.parse(this.responseText);
		if(response.status !== 'success') {
			console.log('query failed: ' + response.message);
			return
		}
		// Distance in kilometers for each coordinate
		for(var i = 0; i < coords.length; i++) {
			var diff = getDistanceFromLatLonInKm(coords[i].lat, coords[i].lon, response.lat, response.lon);
			console.log('distance to ' + coords[i].name + ': ' + diff + 'km');
		}
	}
};
xhr.open('GET', endpoint, true);
xhr.send();
