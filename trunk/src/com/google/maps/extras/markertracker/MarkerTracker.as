/** 
 * MarkerTracker v1.0
 * Author:	Michael Menzel
 * Email:	mugglmenzel@gmail.com
 * 
 * Copyright 2009 Michael Menzel
 * 
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
 *
 */  


package com.google.maps.extras
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapMoveEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.Polyline;
	import com.google.maps.overlays.PolylineOptions;
	import com.google.maps.styles.StrokeStyle;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.utils.ObjectUtil;
	
	
	public class MarkerTracker
	{

		private static const DEFAULT_EDGE_PADDING_:Number = 25;
		private static const DEFAULT_ICON_SCALE_:Number = 0.6;
		private static const DEFAULT_ARROW_COLOR_:Number = 0xff0000;
		private static const DEFAULT_ARROW_WEIGHT_:Number = 20;
		private static const DEFAULT_ARROW_LENGTH_:Number = 20;
		private static const DEFAULT_ARROW_OPACITY_:Number = 0.8;
		private static const DEFAULT_UPDATE_EVENT_:String = MapMoveEvent.MOVE_STEP;
		private static const DEFAULT_PAN_EVENT_:String = MapMouseEvent.CLICK;
		private static const DEFAULT_QUICK_PAN_ENABLED_:Boolean = true;

		private var padding_:Number;
		private var iconScale_:Number;
		private var color_:Number;
		private var weight_:Number;
		private var length_:Number;
		private var opacity_:Number;
		private var updateEvent_:String;
		private var panEvent_:String;
		private var quickPanEnabled_:Boolean;
		
		private var babyMarker_:Marker;
		
		private var map_:Map;
		private var marker_:Marker;
		private var enabled_:Boolean = true;
		private var arrowDisplayed_:Boolean = false;
		private var arrow_:Polyline;
		private var oldArrow_:Polyline;
		private var control_:Object;

		/**
		 *  Creates a MarkerTracker for the given marker and displays it ont he map as needed.
		 *
		 * @constructor
		 * @param {Map} map The map that will display the MarkerTracker. 
		 * @param {Marker} marker the marker to be tracked.
		 * @param {Object} opts? Object that contains the options for coustomizing the 
		 *                  look and behavior of arrows:
		 *   {Number} iconScale Scales the icon size by this value, 0 = no icon.
		 *   {Number} padding The padding between the arrow and the edge of the map.
		 *   {Number} color Color of the arrow.
		 *   {Number} weight Thickness of the lines that make up the arrows.
		 *   {Number} length length of the arrow.
		 *   {Number} opacity opacity of the arrow.
		 *   {String} updateEvent The GMap2 event name that triggers the arrows to update.
		 *   {String} panEvent The GMarker event name that triggers a quick zoom to the tracked marker.
		 *   {Boolean} quickPanEnabled The GMarker event name that triggers a quick zoom to the tracked marker.
		 */

		public function MarkerTracker(marker:Marker, map:Map, opts:Object)
		{

			this.map_ = map;
			this.marker_ = marker;
			this.enabled_ = true;
			this.arrowDisplayed_ = false;
			this.arrow_ = null;
			this.oldArrow_ = null;
			this.control_ = null;
			
			  
			opts = opts || {};
			this.iconScale_ = MarkerTracker.DEFAULT_ICON_SCALE_;
			if (opts.iconScale != undefined ) {
				this.iconScale_ = opts.iconScale;
			}
			this.padding_ = MarkerTracker.DEFAULT_EDGE_PADDING_;
			if (opts.padding != undefined ) {
				this.padding_ = opts.padding;
			}
			this.color_ = MarkerTracker.DEFAULT_ARROW_COLOR_;
			if (opts.color != undefined ) {
				this.color_ = opts.color;
			}
			this.weight_ = MarkerTracker.DEFAULT_ARROW_WEIGHT_;
			if (opts.weight != undefined ) {
				this.weight_ = opts.weight;
			}
			this.length_ = MarkerTracker.DEFAULT_ARROW_LENGTH_;
			if (opts.length != undefined ) {
				this.length_ = opts.length;
			}
			this.opacity_ = MarkerTracker.DEFAULT_ARROW_OPACITY_;
			if (opts.opacity != undefined ) {
				this.opacity_ = opts.opacity;
			}
			this.updateEvent_ = MarkerTracker.DEFAULT_UPDATE_EVENT_;
			if (opts.updateEvent != undefined ) {
				this.updateEvent_ = opts.updateEvent;
			}
			this.panEvent_ = MarkerTracker.DEFAULT_PAN_EVENT_;
			if (opts.panEvent != undefined ) {
				this.panEvent_ = opts.panEvent;
			}
			this.quickPanEnabled_ = MarkerTracker.DEFAULT_QUICK_PAN_ENABLED_;
			if (opts.quickPanEnabled != undefined ) {
				this.quickPanEnabled_ = opts.quickPanEnabled;
			}
			
			this.babyMarker_ = new Marker(new LatLng(0, 0));			
			if(marker.getOptions().icon){
				//replicate a different sized icon 
				var babyIcon:DisplayObject = DisplayObject(ObjectUtil.copy(marker.getOptions().icon));
				babyIcon.width = marker.getOptions().icon.width * this.iconScale_;
				babyIcon.height = marker.getOptions().icon.height * this.iconScale_ ;
				this.babyMarker_.getOptions().icon = babyIcon;				
			} else {
				this.babyMarker_.setOptions(marker.getOptions());
			}
			this.babyMarker_.getOptions().hasShadow = false;
			this.babyMarker_.getOptions().clickable = true;
			
			//bind the update task to the event trigger
			this.map_.addEventListener(this.updateEvent_, this.updateArrow_);
			//update the arrow if the marker moves
			this.marker_.addEventListener(Event.CHANGE, this.updateArrow_);
			if (this.quickPanEnabled_) {
				this.babyMarker_.addEventListener(this.panEvent_, this.panToMarker_);
			}
			
			//do an inital check
			this.updateArrow_(null);
		}



		/**
		 *  Disables the marker tracker.
		 */
		private function disable():void 
		{
			this.enabled_ = false;
			this.updateArrow_(null);
		}
		
		/**
		 *  Enables the marker tracker.
		 */
		private function enable():void 
		{
			this.enabled_ = true;
			this.updateArrow_(null);
		}

		/**
		 *  Called on on the trigger event to update the arrow. Primary function is to
		 *  check if the parent marker is in view, if not draw the tracking arrow.
		 */
		
		private function updateArrow_(event:Event):void 
		{
			if(!this.map_.getLatLngBounds().containsLatLng(this.marker_.getLatLng()) && this.enabled_) {
				this.drawArrow_();
			} else if(this.arrowDisplayed_) {
		    	this.hideArrow_();
		  	}
		}



		/**
		 *  Draws or redraws the arrow as needed, called when the parent marker is
		 *  not with in the map view.
		 */
		
		private function drawArrow_():void 
		{
		
			//convert to pixels
			var bounds:LatLngBounds = this.map_.getLatLngBounds();
			var SW:Point = this.map_.fromLatLngToPoint(bounds.getSouthWest());
			var NE:Point = this.map_.fromLatLngToPoint(bounds.getNorthEast());
			
			//include the padding while deciding on the arrow location
			var minX:Number =  SW.x + this.padding_;
			var minY:Number =  NE.y + this.padding_;
			var maxX:Number =  NE.x - this.padding_;
			var maxY:Number =  SW.y - this.padding_;
			
			// find the geometric info for the marker realative to the center of the map
			var centerPoint:Point = this.map_.fromLatLngToPoint(this.map_.getCenter());
			var locPoint:Point = this.map_.fromLatLngToPoint(this.marker_.getLatLng());
			  
			//get the slope of the line
			var m:Number = (centerPoint.y-locPoint.y) / (centerPoint.x-locPoint.x);
			var b:Number = (centerPoint.y - m*centerPoint.x);
			  
			// end the line within the bounds
			var x:Number = maxX;
			if ( locPoint.x < maxX && locPoint.x > minX ) {
				x = locPoint.x;
			} else if (centerPoint.x > locPoint.x) {
				x = minX; 
			}
			
			//calculate y and check boundaries again  
			var y:Number = m * x + b;
			if( y > maxY ) {
				y = maxY;
				x = (y - b)/m;
			} else if(y < minY) {
				y = minY;
				x = (y - b) / m;
			}
			  
			// get the proper angle of the arrow
			var ang:Number = Math.atan(-m);
			if(x > centerPoint.x) {
				ang = ang + Math.PI; 
			} 
			  
			// define the point of the arrow
			var arrowLoc:LatLng = this.map_.fromPointToLatLng(new Point(x, y));
			
			// left side of marker is at -1,1
			var arrowLeft:LatLng = 	this.map_.fromPointToLatLng(
										this.getRotatedPoint_(((-1) * this.length_), this.length_, ang, x, y) );
			            
			// right side of marker is at -1,-1
			var arrowRight:LatLng = this.map_.fromPointToLatLng( 
			          					this.getRotatedPoint_(((-1)*this.length_), ((-1)*this.length_), ang, x, y));
			
			  
			this.oldArrow_ = this.arrow_;
			this.arrow_ = 	new Polyline([arrowLeft, arrowLoc, arrowRight], 
								new PolylineOptions({strokeStyle: 
			  						new StrokeStyle({color: this.color_, thickness: this.weight_, alpha: this.opacity_})}));
			this.map_.addOverlay(this.arrow_);
			  
			// move the babyMarker to -1,0
			this.babyMarker_.setLatLng(this.map_.fromPointToLatLng(this.getRotatedPoint_(((-2)*this.length_), 0, ang, x, y)));
			          
			if (!this.arrowDisplayed_) {
				this.map_.addOverlay(this.babyMarker_);
				this.arrowDisplayed_ = true;
			}
			if (this.oldArrow_) {
				this.map_.removeOverlay(this.oldArrow_);
			}			
		}
		
		
		
		/**
		 *  Hides the arrows.
		 */
		 
		private function hideArrow_():void 
		{		
			this.map_.removeOverlay(this.babyMarker_);
			if(this.arrow_) {
				this.map_.removeOverlay(this.arrow_);
			}
			if(this.oldArrow_) {
				this.map_.removeOverlay(this.oldArrow_);
			}
			this.arrowDisplayed_ = false;			
		}
		
		
		/**
		 *  Pans the map to the parent marker.
		 */
		
		private function panToMarker_(event:Event):void 
		{
			this.map_.panTo(this.marker_.getLatLng());
		}

		/**
		 *  This applies a counter-clockwise rotation to any point.
		 *  
		 * @param {Number} x The x value of the point.
		 * @param {Number} y The y value of the point.
		 * @param {Number} ang The counter clockwise angle of rotation.
		 * @param {Number} xoffset Adds a position offset to the x position.
		 * @param {Number} yoffset Adds a position offset to the y position.
		 * @return {Point} A rotated GPoint.
		 */
		
		private function getRotatedPoint_(x:Number, y:Number, ang:Number, xoffset:Number, yoffset:Number):Point 
		{
			var newx:Number = y * Math.sin(ang) - x * Math.cos(ang) + xoffset;
			var newy:Number = x * Math.sin(ang) + y * Math.cos(ang) + yoffset;
			return new Point(newx, newy);
		}

	}
}