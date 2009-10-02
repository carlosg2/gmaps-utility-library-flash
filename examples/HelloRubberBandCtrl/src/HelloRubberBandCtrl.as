package {

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Point;

import com.google.maps.LatLng;
import com.google.maps.Map;
import com.google.maps.MapEvent;
import com.google.maps.MapOptions;
import com.google.maps.controls.ZoomControl;
import com.google.maps.extras.rubberbandctrl.RubberBandCtrl;

/**
 * The HelloRubberBandCtrl class is a simple but complete Google Map
 * application that demonstrates how to integrate <code>RubberBandCtrl</code>
 * functionality into the map. To understand how to use this control, please
 * consult the documentation for <code>RubberBandCtrl</code>.
 *
 * <p>
 * <strong>Contacts:</strong>
 * <ul>
 * <li>To contact the author of RubberBandCtrl, email kevin.macdonald AT thinkwrap DOT com</li>
 * <li>Visit <code>http://www.spatialdatabox.com</code> for other Google Flash Map demos and related information.</li>
 * </ul>
 * </p>
 * 
 * <p>
 * <strong>Copyright Notice:</strong><br>
 * <br>
 * Copyright 2009 Kevin Macdonald<br>
 * <br>
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at<br>
 * <br>
 *     http://www.apache.org/licenses/LICENSE-2.0<br>
 * <br>
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.<br>
 * </p>
 */
public class HelloRubberBandCtrl extends Sprite
{

public function HelloRubberBandCtrl ()
{
	stage.align = StageAlign.TOP_LEFT;
	stage.scaleMode = StageScaleMode.NO_SCALE;
	
	map.key = " .. your API key goes here .. ";
	map.setSize (MAP_SIZE);
	map.addControl (new ZoomControl ());
	map.addEventListener (MapEvent.MAP_PREINITIALIZE, onMapPreinitialize);
	map.addEventListener (MapEvent.MAP_READY, onMapReady);
	
	addChild (map);
}

private function onMapPreinitialize (event:MapEvent):void
{
	map.setInitOptions (
		new MapOptions ( {
			center: MAP_CENTER,
			zoom: MAP_ZOOM
		}
		));
}

/**
 * This function contains the one integration point between this application and
 * RubberBandCtrl.
 * 
 * <p>
 * RubberBandCtrl provides other functions that allow you to customize its look
 * and behavior. Consult its documentation for more details.
 * </p>
*/
private function onMapReady (event:MapEvent):void
{
	//	Attach the control to the map.
	rbCtrl.enable (map);
}

private static const MAP_SIZE:Point = new Point (1024, 600);
private static const MAP_CENTER:LatLng = new LatLng (30, 0);
private static const MAP_ZOOM:int = 2;

private const map:Map = new Map ();

//	Create one RubberBandCtrl object.
private const rbCtrl:RubberBandCtrl = new RubberBandCtrl ();

}

}
