﻿/**
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
import com.google.maps.LatLngBounds;
import com.google.maps.Map;
import com.google.maps.interfaces.IPane;

import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

public class MarkerClusterer
{
	private  var clusters_ 		: Array;
	private  var map_ 			: Map;

	private  var leftMarkers_ 	: Array;
	private var _pane:IPane;
	public var options:MarkerClustererOptions;
	public function MarkerClusterer (map : Map, markers : Array, opts : MarkerClustererOptions = null)
	{
		clusters_ 		= new Array();
		map_ 			= map;
		leftMarkers_ 	= new Array();
		this._pane = map_.getPaneManager().createPane();
		
		if(opts == null)		opts = new MarkerClustererOptions;
		this.options = opts;

		
		if(options.styles.length == 0){
			var styles:Array		= new Array();
			for (var i:int = 1; i <= 5; ++i)
			{
				styles.push({'url': "assets/images/m" + i + ".png"});
			}
			options.styles = styles;
		}

		if (markers != null){
			addMarkers(markers);
		}
		
		map_.addEventListener("mapevent_moveend", mapMoved);
	}
	
	public function mapMoved (event : Event) :void
	{
		resetViewport();
	}
	
	public function addLeftMarkers_ () : void
	{
		var leftMarkers : Array = [];
		
		if (leftMarkers_.length < 1) {
			return;
		}
		
		for (var i:int = 0; i < leftMarkers_.length; ++i) {
			addMarker(leftMarkers_[i], true, false, null, true);
		}
		
		leftMarkers_ = leftMarkers;
	}
	
	public function getStyles_ () : Array
	{
		return this.options.styles; // (styles_);
	}
	
	public function clearMarkers () : void 
	{

		for (var i:int = 0; i < clusters_.length; ++i)
		{
			if (clusters_[i] != undefined && clusters_[i] != null)
			{
				clusters_[i].clearMarkers();
			}
		}
		
		clusters_ 		= new Array();;
		leftMarkers_ 	= new Array();
	}
	
	public function isMarkerInViewport_(marker : UnitMarker) : Boolean 
	{
		return map_.getLatLngBounds().containsLatLng(marker.getLatLng());
	}
	
	public function reAddMarkers_(markers : Array) : void
	{
		var len:int 		= markers.length;
		var clusters :Array	= new Array();
		
	//	for (var i:int = len - 1; i >= 0; --i) {
		for each(var marker:UnitMarker in markers){
			addMarker(marker, true, marker.isAdded, clusters, true);
		}
		
		addLeftMarkers_();
	}
	
	public function addMarker (marker : UnitMarker, opt_isNodraw : Boolean,
		isAdded : Boolean, clusters : Array, opt_isNoCheck : Boolean) : void
	{

		var centrePoint	: Point;
		var length		: Number;
		var cluster 	: Cluster;
		var center		: LatLng;
		
		if (opt_isNoCheck != true)
		{
			if (!isMarkerInViewport_(marker)) {
				leftMarkers_.push(marker);
				return;
			}
		}
		var pos			: Point= map_.fromLatLngToViewport(marker.getLatLng());
		
		if (clusters == null)
		{
			clusters = clusters_;
		}
		
		length 		= clusters.length;
		cluster 	= null;
		
		for (var i:int = length - 1; i >= 0; i--)
		{
			cluster 	= clusters[i];
			center 		= cluster.getCenter();
			
			if (center == null)
			{
				continue;
			}
		
			centrePoint = map_.fromLatLngToViewport(center);
			
			// Found a cluster which contains the marker.
			if (pos.x >= centrePoint.x - options.gridSize 
			&& pos.x <= centrePoint.x + options.gridSize 
			&& pos.y >= centrePoint.y - options.gridSize 
			&& pos.y <= centrePoint.y + options.gridSize){
				marker.isAdded = isAdded;
				cluster.addMarker(marker);
				
				if (!opt_isNodraw)
				{
					cluster.redraw_(false);
				}
				
				return;
			}
		}
		
		// No cluster contain the marker, create a new cluster.
		cluster 		= new Cluster(this, _pane);
		marker.isAdded 	= isAdded;
		cluster.addMarker(marker);
		
		if (!opt_isNodraw)
		{
			cluster.redraw_(false);
		}
		
		// Add this cluster both in clusters provided and clusters_
		clusters.push(cluster);
		
		if (clusters != clusters_)
		{
			clusters_.push(cluster);
		}
	}
	
	public function removeMarker (marker : UnitMarker)  : void
	{
		
		for (var i:int = 0; i < clusters_.length; ++i)
		{
			if (clusters_[i].remove(marker))
			{
				clusters_[i].redraw_();
				return;
			}
		}
	}
	
	public function redraw_ () : void
	{
		for each(var cluster:Cluster in getClustersInViewport_()){
			cluster.redraw_(true);
		}
	}
	
	public function getClustersInViewport_ () : Array
	{
		var clusters 	: Array = [];

		var curBounds:LatLngBounds 	= map_.getLatLngBounds();
		var nw:Point = map_.fromLatLngToViewport(curBounds.getNorthWest());
		var se:Point = map_.fromLatLngToViewport(curBounds.getSouthEast());
		var rect:Rectangle = new Rectangle(nw.x, nw.y, se.x - nw.x, se.y - nw.y);				
	
		//for (i = 0; i < clusters_.length; i ++)
		for each(var cluster:Cluster in this.clusters_){
			if (cluster.isInBounds(curBounds))
		//	if((clusters_[i] as Cluster).isInRectangle(rect))
			{
				clusters.push(cluster);
			}
		}
		
		return clusters;
	
	}
	
	public function getMaxZoom_ () : Number
	{
		return this.options.maxZoom;
	}
	public function getZoom():Number{
		return map_.getZoom();
	}
	public function getMaxZ():Number{
		return map_.getCurrentMapType().getMaximumResolution(); 
	}
	// this will be removed!!
	// if cluster needs any info of map, this class should provide methods for it,
	// not to provide whole map object. 
	public function getMap_ () : Map
	{
		return map_;
	}
	
	public function getGridSize_ () : Number
	{
		return this.options.gridSize;
	}
	
	public function getTotalMarkers () : int
	{
		var result 	: int = 0;
		for each(var cluster:Cluster in clusters_){
			result += cluster.getTotalMarkers();
		}
		return result;
	}
	
	public function getTotalClusters () : int
	{
		return clusters_.length;
	}
	
	public function resetViewport (force:Boolean=false) : void
	{
		var clusters 	: Array = getClustersInViewport_();
		var tmpMarkers 	: Array = [];
		var removed 	: Number = 0;

		for each(var cluster:Cluster in clusters)
		{
		//	cluster = clusters[i];
			var oldZoom		: Number = cluster.getCurrentZoom();
			
			if (isNaN(oldZoom))
			{
				continue;
			}
			
			var curZoom 	: Number = map_.getZoom();
			
			if (curZoom != oldZoom || force)
			{
				
				// If the cluster zoom level changed then destroy the cluster
    			// and collect its markers.
    			for each(var mk:UnitMarker in cluster.getMarkers()){
					tmpMarkers.push(mk);
				}
				
				cluster.clearMarkers();
				removed++;
				
				for (var j:int = 0; j < clusters_.length; ++j){
					if (cluster == clusters_[j]){
						clusters_.splice(j, 1);
					}
				}
			}
		}
		
		reAddMarkers_(tmpMarkers);
		redraw_();
	}
	
	public function addMarkers (markers : Array) : void
	{
		for each(var marker:UnitMarker in markers){
			this.addMarker(marker, true, false, new Array(), true);
		}
		redraw_();
	}
}
}