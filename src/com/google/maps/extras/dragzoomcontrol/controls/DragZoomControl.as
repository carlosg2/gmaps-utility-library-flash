/* 
 * DragZoomControl v1.0
 * Author: Brian Richardson
 * Email: irieb@mac.com
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Magifying glass image pulled from the following source:
 * http://commons.wikimedia.org/wiki/File:Gnome-zoom-in.svg
 * Used in this component under their GNU General Public License
 *
 * Enables drag zoom functionality 
 *
 * The control is enabled when a user clicks the magnifying 
 * glass image.
 *
 * When the control is enable the control listens for a mouse click
 * then mouse move to render the selection area
 *
 * On mouseUp the map will center the selection and zoom to the
 * highest possible level on the selected bounds.
 *
 * A second magnifying glass will appear to enable the user to
 * back out to the last map position
 */
package com.google.maps.extras.dragzoomcontrol.controls
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.controls.ControlBase;
	import com.google.maps.controls.ControlPosition;
	import com.google.maps.extras.dragzoomcontrol.events.DragZoomEvent;
	import com.google.maps.interfaces.IMap;
	import com.google.maps.overlays.Polyline;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 *  Dispatched when a Zoom is committed
	 * 
	 *  @eventType mx.events.FlexEvent.DATA_CHANGE
	 */
	[Event(name="zoomCommit", type="com.google.maps.extras.dragzoomcontrol.events.DragZoomEvent")]
	public class DragZoomControl extends ControlBase {
		
		// Static constants
		private static const ACTIVE_ALPHA:Number = 1;
		private static const INACTIVE_ALPHA:Number = .7;
		
		private static const DRAG_BG_COLOR:Number = 0xFFFFFF;
		private static const DRAG_BG_ALPHA:Number = 0.5;
		private static const LINE_COLOR:Number = 0x000000;
		private static const DEFAULT_CONTROL_POSITION:ControlPosition = new ControlPosition(ControlPosition.ANCHOR_TOP_LEFT, MARGIN_TOP, MARGIN_RIGHT); 						
		
		private static const MARGIN_TOP:int = 7;
		private static const MARGIN_RIGHT:int = 7;
		
		//zoom-in image
		[Embed(source="/assets/images/zoom-in.png")]
		public static const ZOOM_IN_IMG:Class;
		
		//zoom-out image
		[Embed(source="/assets/images/zoom-out.png")]
		public static const ZOOM_OUT_IMG:Class;						
		
		private var _map:IMap;
		private var _drawArea:Sprite;
		private var _zoomArea:Shape;
		private var _startXPos:int;
		private var _startYPos:int;
		private var _zoomState:Boolean = false;
		
		private var _nwPoint:Point;
		private var _swPoint:Point;
		private var _nePoint:Point;
		private var _sePoint:Point;
		
		private var _zoomInBtn:Sprite;
		private var _zoomOutBtn:Sprite;
		private var _msg:Sprite;		

		/**
		 * Creates the DragZoom control
		 *
		 * @constructor
		 */
		public function DragZoomControl() {
			super(DEFAULT_CONTROL_POSITION);	
			_drawArea =  new Sprite();
			addChild(_drawArea);
		}		

		/**
		 * Initialize the control
		 *
		 * @param {IMap} pMap The instance of the Map the control is being 
		 * added to
		 */		
		public override function initControlWithMap(pMap:IMap):void {
			super.initControlWithMap(map);
			_map = pMap;
			addControlButton();		
		}
		
		//*****************
		//private functions
		//*****************
		
		/**
		 * @private
		 * Sets the state of the control to listen
		 * for Map events in order to render the selection area
		 * 
		 * Map dragging is disabled as it would interfere with
		 * the drag control of the selection area
		 *
		 * @param {MouseEvent} event The mouse event that triggered the call
		 */			
		private function enableDragZoom(event:MouseEvent):void {
			_msg.visible = true;
			_map.disableDragging();	
			_map.addEventListener(MapMouseEvent.MOUSE_DOWN, startZoom);
			_map.addEventListener(MapMouseEvent.MOUSE_UP, commitZoom);
			_map.addEventListener(MapMouseEvent.MOUSE_MOVE, updateZoom);
		}
		
		/**
		 * @private
		 * Returns the Map to the last saved position
		 *
		 * @param {MouseEvent} event The mouse event
		 */			
		private function returnToSavedPosition(event:MouseEvent):void {
			_zoomOutBtn.visible = false;
			_map.returnToSavedPosition();			
		}

		/**
		 * @private
		 * Removes Map event listener and enables map dragging
		 */			
		private function disableDragZoom():void {			
			_map.removeEventListener(MapMouseEvent.MOUSE_DOWN, startZoom);
			_map.removeEventListener(MapMouseEvent.MOUSE_UP, commitZoom);
			_map.removeEventListener(MapMouseEvent.MOUSE_MOVE, updateZoom);
			_map.enableDragging();
		}		

		/**
		 * @private
		 * Updates the selection area.
		 * Cooridinates are calculated using the latitude/longitude
		 * provided by the MapMouseEvent
		 *
		 * @param {MapMouseEvent} event The mouse event
		 */			
		private function updateZoom(event:MapMouseEvent):void {
			if (_zoomState) {
				var latLgn:LatLng = event.latLng;
				var point:Point = _map.fromLatLngToViewport(latLgn);
							
				var zoomWidth:int = (point.x - _startXPos);
				var zoomHeight:int = (point.y - _startYPos);
				
				resetDrawArea();

				_zoomArea = new Shape();
				
				var recX:int = (point.x - zoomWidth)-8;
				var recY:int = (point.y - zoomHeight)-8;
	
			    _zoomArea.graphics.beginFill(DRAG_BG_COLOR, DRAG_BG_ALPHA);
			    _zoomArea.graphics.lineStyle(1, LINE_COLOR);
			    _zoomArea.graphics.drawRect(recX, recY, zoomWidth, zoomHeight);
			    _zoomArea.graphics.endFill();
			    _drawArea.addChild(_zoomArea);	
			    
			    _nwPoint = new Point(recX, recY);
			    _swPoint = new Point(recX, (recY + _zoomArea.height));
			    _sePoint = new Point((recX + _zoomArea.width), (recY + _zoomArea.height));
			    _nePoint = new Point((recX + _zoomArea.width), recY);
			}		
		}
		
		/**
		 * @private
		 * Commits the Zoom based on the selection area
		 *
		 * @param {MapMouseEvent} event The mouse event
		 */			
		private function commitZoom(event:MapMouseEvent):void {	
			disableDragZoom();	
			_map.savePosition();	
			_zoomState = false;
			resetDrawArea();
						
			var latLngBounds:LatLngBounds = calculatePolyline();
			positionMap(latLngBounds);			
			
			_zoomOutBtn.visible = true;
			_msg.visible = false;
			
			var evt:DragZoomEvent = new DragZoomEvent(DragZoomEvent.ZOOM_COMMIT);
			evt.bounds = latLngBounds;			
			dispatchEvent(evt);	
		}
		
		/**
		 * @private
		 * Position the Map
		 *
		 * @param {LatLngBounds} pLatLngBounds Latitude/Longtitude bounds
		 * used to postion the map
		 */			
		private function positionMap(pLatLngBounds:LatLngBounds):void {
			_map.setCenter(pLatLngBounds.getCenter());
			_map.setZoom(_map.getBoundsZoomLevel(pLatLngBounds));			
		}	
		
		/**
		 * @private
		 * Sets the x/y point of the initial mouse click
		 * on the Map
		 *
		 * @param {MapMouseEvent} event The mouse event
		 */			
		private function startZoom(event:MapMouseEvent):void {
			_zoomState = true;			
			var point:Point = _map.fromLatLngToViewport(event.latLng);
			_startXPos = point.x;
			_startYPos = point.y;		
		}
		
		/**
		 * Removes the selection graphic
		 *
		 */			
		private function resetDrawArea():void {
			if (_zoomArea) {				
				_drawArea.removeChild(_zoomArea);
				_zoomArea = null;
			}					
		}
		
		/**
		 * @private
		 * Creates a Polyline based on the graphic selection
		 * 
		 * The Polyline is then used to create latitude/longtitude bounds
		 * that are used to center the Map and set the highest possible
		 * Zoom level for the selection
		 *
		 */			
		private function calculatePolyline():LatLngBounds {	  						
			var lines:Array = 
				[_map.fromViewportToLatLng(_nwPoint),
				_map.fromViewportToLatLng(_swPoint),
				_map.fromViewportToLatLng(_sePoint),
				_map.fromViewportToLatLng(_nePoint),
				_map.fromViewportToLatLng(_nwPoint)];			
			var polyLine:Polyline = new Polyline(lines);
			return polyLine.getLatLngBounds();
		}	
		
		/**
		 * @private
		 * Used to create the rollover effect
		 *
		 * @param {MouseEvent} event The mouse event
		 */			
		private function mouseOver(event:MouseEvent):void {
			if (event.target is Sprite) {
				var s:Sprite = Sprite(event.target);
				s.alpha = ACTIVE_ALPHA;				
			}
			return;		
		}
		
		/**
		 * @private
		 * Used to create the rollout effect
		 *
		 * @param {MouseEvent} event The mouse event
		 */		
		private function mouseOut(event:MouseEvent):void {
			if (event.target is Sprite) {
				var s:Sprite = Sprite(event.target);
				s.alpha = INACTIVE_ALPHA;				
			}
			return;		
		}		
		
		/**
		 * @private
		 * Creates the control buttons (zoom in/zoom out)
		 *
		 */			
		private function addControlButton():void {			
		    _zoomInBtn = new Sprite();
		    _zoomInBtn.x = 0;
		    _zoomInBtn.y = 0;	   			    		    		    	
			_zoomInBtn.addChild(DisplayObject(new ZOOM_IN_IMG()));
			_zoomInBtn.addEventListener(MouseEvent.CLICK, enableDragZoom);
			_zoomInBtn.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			_zoomInBtn.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			_zoomInBtn.alpha = INACTIVE_ALPHA;
						
		    _zoomOutBtn = new Sprite();
		    _zoomOutBtn.x = _zoomInBtn.width;
		    _zoomOutBtn.y = 0;									    		    
		    _zoomOutBtn.addChild(DisplayObject(new ZOOM_OUT_IMG()));
		    _zoomOutBtn.addEventListener(MouseEvent.CLICK, returnToSavedPosition);
			_zoomOutBtn.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			_zoomOutBtn.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);		    
		    _zoomOutBtn.alpha = INACTIVE_ALPHA;
		    _zoomOutBtn.visible = false;
		    
		    var center:Point = _map.fromLatLngToViewport(_map.getCenter());
		    _msg = new Sprite();
		    _msg.x = center.x;
		    _msg.y = 10;			    		    		
			var label:TextField = new TextField();
			label.text = "click and drag mouse to zoom into area";
			label.selectable = false;
			label.autoSize = TextFieldAutoSize.CENTER;
			var format:TextFormat = new TextFormat("Verdana");
			label.setTextFormat(format);	
			
			var background:Shape = new Shape();
			background.graphics.beginFill(DRAG_BG_COLOR, DRAG_BG_ALPHA);
			background.graphics.lineStyle(1, LINE_COLOR);
			background.graphics.drawRoundRect(label.x, label.y, label.width, label.height, 4);
			background.graphics.endFill();
			
			_msg.addChild(background);	
			_msg.addChild(label);
			_msg.visible = false;				   	    	    

			addChild(_msg);
		    addChild(_zoomInBtn);
		    addChild(_zoomOutBtn);			
		}		
		
	}
}