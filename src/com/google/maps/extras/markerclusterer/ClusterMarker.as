/**
 * @name MarkerClusterer for Flash
 * @version 1.0
 * @author Xiaoxi Wu
 * @copyright (c) 2009 Xiaoxi Wu
 * @fileoverview
 * Ported from Javascript to Actionscript 3 by Sean Toru
 * Ported for use in Flex (removal of fl. libraries) by Ian Watkins
 * Reflectored for both Flash and Flex, 
 * and maintained by Juguang XIAO (juguang@gmail.com)
 * 
 * This actionscript library creates and manages per-zoom-level 
 * clusters for large amounts of markers (hundreds or thousands).
 * This library was inspired by the <a href="http://www.maptimize.com">
 * Maptimize</a> hosted clustering solution.
 * <br /><br/>
 * <b>How it works</b>:<br/>
 * The <code>MarkerClusterer</code> will group markers into clusters according to
 * their distance from a cluster's center. When a marker is added,
 * the marker cluster will find a position in all the clusters, and 
 * if it fails to find one, it will create a new cluster with the marker.
 * The number of markers in a cluster will be displayed
 * on the cluster marker. When the map viewport changes,
 * <code>MarkerClusterer</code> will destroy the clusters in the viewport 
 * and regroup them into new clusters.
 *
 */

/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.maps.extras.markerclusterer
{
import com.google.maps.LatLng;
import com.google.maps.Map;
import com.google.maps.PaneId;
import com.google.maps.interfaces.IMap;
import com.google.maps.interfaces.IPane;
import com.google.maps.interfaces.IPaneManager;
import com.google.maps.overlays.OverlayBase;

import flash.events.Event;
import flash.geom.Point;

import mx.controls.Label;
import mx.controls.Image;
/**
 * 
 * This is a presentation class for <code>Cluster</code>.
 * The current implementation is to load images for different level.
 * Later, it can be implemented with other possibilities.
 * 
 * Current implementation is for Flex only, that Flex advantage on auto layout has been taken.
 * Later, it will support both Flash and Flex.
 */  
public class ClusterMarker extends OverlayBase
{
	private var url_ 		: String;
	private var height_ 	: Number;
	private var width_ 		: Number;
	private var latlng_ 	: LatLng;
	private var index_ 		: Number;
	private var styles_ 	: Array;
	private var text_ 		: String;
	private var padding_	: Number;
	private var map_		: Map;
	private var imageLoader	: Image;
	private var label		: Label;
	
	public function ClusterMarker (latlng : LatLng, count : Number, styles : Array, padding : Number)
	{
		var index 	: Number;
		var dv		: Number;
		
		index 	= 0;
		dv 		= count;
		
		while (dv != 0) {
			dv = Math.round(dv / 10);
			index ++;
		}
		
		if (styles.length < index) {
			index = styles.length;
  		}
		
		url_ 							= styles[index - 1].url;
//		textColor_ 						= styles[index - 1].opt_textColor;
//		anchor_ 						= styles[index - 1].opt_anchor;
		latlng_ 						= latlng;
		index_ 							= index;
		styles_ 						= styles;
		text_ 							= String(count);
		padding_ 						= padding;
		
		imageLoader						= new Image();
		imageLoader.autoLoad            = true;
		imageLoader.source 				= url_; 
		imageLoader.scaleContent 		= false;
		imageLoader.addEventListener(Event.COMPLETE, completeHandler);
		addChild(imageLoader);
		
		label							= new Label();
		label.setStyle("textAlign", "center");
		label.setStyle("color", "0x000000");
		label.setStyle("font", "Verdana");
		label.setStyle("bold", "true");
		label.selectable                = false;
		label.text 						= text_;

		addChild(label);
	}
	
	private function completeHandler(event : Event) : void
	{		
		imageLoader.width = event.currentTarget.content.width;
		imageLoader.height = event.currentTarget.content.height;	

		event.currentTarget.move(imageLoader.width/-2, imageLoader.height/-2);
		
		label.width 	= imageLoader.width;
		label.height 	= 14;

		label.x         = imageLoader.width / -2;
		label.y 		= 0 - (label.height / 2);

		label.visible 	= true;
	}
	
	override public function getDefaultPane(map : IMap): IPane
	{
		var i 			: Number;
		var paneManager	: IPaneManager;
		
		paneManager = map.getPaneManager();

		return paneManager.getPaneById(PaneId.PANE_MARKER);
	}
	
	override public function positionOverlay(zoomChanged : Boolean): void
	{
		this.reposition();
	}
	
	private function remove () : void
	{
		parent.removeChild(this);
	}
	/*
	private function copy () : ClusterMarker
	{
		return new ClusterMarker(this.latlng_, this.index_, this.styles_, this.padding_);
	}
	*/
	/**
	 * 
	 * Developer should not call this function. It is managed by Cluster.
	 */ 
	public function redraw (force:Boolean) : void
	{
		if (!force){
			return;
		}

		this.reposition();
	}
	
	private function reposition():void{
		var pos : Point = this.pane.fromLatLngToPaneCoords(latlng_);
		x = pos.x;
		y = pos.y;
	}
}
}