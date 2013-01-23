<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
    <title>Proximity alert simulator</title>
    <script src="jquery-1.9.0.min.js"></script>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAmrty97gLWu-15X5hOU6zLRx3-QJZgbRM&sensor=false"></script>
    <script>
      function initialize() {
        var myLatlng = new google.maps.LatLng(-25.363882,131.044922);
        var mapOptions = {
          zoom: 4,
          center: myLatlng,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        }
        var map = new google.maps.Map(document.getElementById('map_canvas'), mapOptions);

        var marker = new google.maps.Marker({
            position: myLatlng,
            map: map,
            title: 'Hello World!'
        });
      }
    </script>
  </head>
  <body onload="initialize()">
    <div id="map_canvas"></div>
  </body>
</html>
