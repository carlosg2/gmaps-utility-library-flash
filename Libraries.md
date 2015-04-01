Below is a list of the libraries being worked on in this project.


## RubberBandCtrl ##

The RubberBandCtrl class works with Google Maps API for Flash to provide a user with an efficient way to zoom in to a specific area on the map. This class also offers convenient keyboard shortcuts (with support for left and right-handed users) to rewind to previous map views, zoom out, as well as pan in any of four directions.

To zoom in to a specific area on the map, a user would normally click the map and drag it to its desired center point, and then move the mouse to the upper-left corner of the map to select the appropriate zoom level (a few tries might be necessary to get the right fit). RubberBandCtrl provides a more direct way to perform this task, as described below:

  * Hold a Shift key (the cursor changes to a cross).
  * Click and hold the left mouse button to anchor the rubber band to the map.
  * Drag the mouse to stretch the rubber band.
  * Release the mouse button to snap the map to the area enclosed by the rubber band, or release the Shift key to cancel.

[Reference](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/docs/com/google/maps/extras/rubberbandctrl/package-detail.html)

Demos:
  * [RubberBandCtrl Demo](http://www.spatialdatabox.com/map-demos/rubber-band-map.html)


## MarkerManager ##

This library is a AS3 port of the MarkerManager in the JS open-source library. It enables developers to easily manage markers per zoom level/viewport, and is commonly combined with clustering. Though Flash is natively better at rendering large amounts of markers, developers have reported increased performance when using the MarkerManager with thousands of markers.

[Reference](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/docs/com/google/maps/extras/markermanager/package-detail.html)

Demos:
  * [MarkerManagerDemo](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/MarkerManagerDemo/bin-release/MarkerManagerDemo.swf)


## KML Parser ##

This library parses a KML file into objects representing the KML dom, and includes helper code for creating a sidebar using the Flex Tree component. Note that this class ignores elements and attributes that can't be rendered in the Maps API for Flash. It's based on the dom classes in [libkml](http://code.google.com/p/libkml).

[Reference](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/docs/com/google/maps/extras/xmlparsers/kml/package-detail.html)

Demos:
  * [KMLParser](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/KMLParser/bin-release/KMLParser.html)


## Planetary Map Types ##

This library contains map types for Mars, Sky, and Moon, and is a port of all the non-earth map types available in the JS API.

[Reference](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/docs/com/google/maps/extras/planetary/package-detail.html)

Demos:
  * [CustomMapSky](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/CustomMapSky/bin-release/CustomMapSky.html)
  * [CustomMapMars](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/CustomMapMars/bin-release/CustomMapMars.html)
  * [CustomMapMoon](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/CustomMapMoon/bin-release/CustomMapMoon.html)

## DragZoomControl ##

This library is an AS3 version of the DragZoomControl from the JS open-source library. It creates a custom control that lets user drag a rectangle to zoom to a bounds on the map.

[Reference](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/docs/com/google/maps/extras/dragzoomcontrol/package-detail.html)

Demos:
  * [DragZoomControlDemo](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/DragZoomonControl/bin-release/DragZoom.html)


## MarkerTracker ##

This library is an AS3 version of the MarkerTracker from the JS open-source library. You can assign a MarkerTracker to a map/marker, and then when that marker moves out of the visible viewport, a ghost marker and arrow will appear and point in its direction.

[Reference](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/docs/com/google/maps/extras/markertracker/package-detail.html)

Demos
  * [MarkerTrackerDemo](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/MarkerTrackerDemo/bin-release/MarkerTrackerDemo.html)

## GradientControl ##

This library lets you draw thematic maps, setting polygon colors depending on associated numerical values.

[Documentation](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/GradientControl/bin-release/index.html)

[Class Reference](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/docs/com/google/maps/extras/gradients/package-detail.html)

[Demo](http://gmaps-utility-library-flash.googlecode.com/svn/trunk/examples/GradientControl/bin-release/GradientControlDemo.html)