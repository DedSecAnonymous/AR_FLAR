package
{
	import com.tastenkunst.as3.brf.nxt.BRFState;
	import com.tastenkunst.as3.brf.nxt.ane.examples.ExampleCandideTrackingANE;
	import com.tastenkunst.as3.brf.nxt.containers.Flare3D_v2_7;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	/**
	 * This is a basic Flare3D example with 2 3D models of glasses
	 * and a occlusion head, that hides the bows and glasses front
	 * when the glasses are rotated.
	 * 
	 * It uses super class ExampleCandideTracking to init BRF.
	 * 
	 * The Flare3D_v2_7 container uses the same rectangles/resolutions
	 * as the 2D examples to place the video and results in its
	 * viewport, so no need to calculate anything for you :)
	 * 
	 * @author Marcel Klammer, Tastenkunst GmbH, 2014
	 */
	public class Main extends ExampleCandideTrackingANE 
	{	
		// the occlusion head model, that hides the bows of the glasses
		public var _occlusionModel : String = "media/f3d/brf_occlusion_head.zf3d";
		// first example glasses model
		public var _model1 : String = "media/f3d/model_1_1495.zf3d";
		// second example glasses model
		public var _model2 : String = "media/f3d/model_7_1669.zf3d";
		// current model
		public var _currentModel : String;
		// 3D scene handler
		public var _container3D : Flare3D_v2_7;
		
		// size and position of 3d viewport
		public var _viewport : Rectangle;
		
		// texture for webcam image as 3d plane
		public var _screenBmd : BitmapData;

		public function Main() 
		{
			//
			// 480p version:
			//

			// set the viewport size and position
			_viewport = new Rectangle(0, 0, 480, 640);
			
			// and the other rectangles (see ExampleBase for more information)
			super(
				new Rectangle(  0,   0,  480, 640),	// Camera resolution
				new Rectangle(  0,   0,  480, 640), // BRF BitmapData size
				new Rectangle( 40,  40,  400, 560),	// BRF region of interest within BRF BitmapData size
				new Rectangle( 40,  40,  400, 560), // BRF face detection region of interest within BRF BitmapData size
				null, //new Rectangle(  0,   0,  480, 640), // Shown video screen rectangle within the 3D scene
				true, true
			);
			_viewport = new Rectangle(0, 0, 
				Capabilities.screenResolutionX, 
				Capabilities.screenResolutionY);
		}
		
		/**
		 * BRF is ready. Lets set the tracking mode to BRFMode.FACE_TRACKING.
		 * and init all necessary stuff for Flare3D.
		 */
		override public function onReadyBRF(event : Event) : void 
		{
			super.onReadyBRF(event);
			
			// visible webcam image
			// on mobile: uploading large textures is slow, also drawing a video to large BitmapData is slow
			// so we make the shown video smaller in size if necessary: eg. 0.5
			var videoQuality : Number = 512 / _screenRect.height; // maybe want to double check with _screenRect.width. 
			
			_screenBmd = new BitmapData(_screenRect.width * videoQuality, _screenRect.height * videoQuality, false, 0x333333);
			_videoToScreenMatrix.scale(videoQuality, videoQuality);
			
			// the actual 3d scene handling container
			_container3D = new Flare3D_v2_7();
			addChild(_container3D);
			
			_container3D.init(_viewport, _cameraResolution, _brfResolution, _screenRect);
			_container3D.initVideoPlane(_screenBmd);
			_container3D.initOcclusion(_occlusionModel);
			
			// set the first model
			_currentModel = _model1;
			_container3D.model = _currentModel;
			
			// add a stage filling button to change the model
			_clickArea.buttonMode = true;
			_clickArea.useHandCursor = true;
			_clickArea.mouseChildren = false;
			_clickArea.addEventListener(MouseEvent.CLICK, onClickedVideo);
			
			// remove the video or brf bitmap, if its on stage, because Stage3D sits
			// below the display list.
			if(_container.contains(_video)) {
				_container.removeChild(_video);
			}
		}
		
		/**
		 * We need to draw the webcam to the texture BitmapData.
		 */
		override public function updateInput() : void 
		{
			super.updateInput();
			
			if(_screenBmd != null) {
				_screenBmd.draw(_video, _videoToScreenMatrix);
			}
		}
		
		/**
		 * Update the 3D content, if a face shape was tracked.
		 * Otherwise hide the 3D content.
		 */
		override public function updateGUI() : void 
		{
			_draw.clear();
			
			if (_brfManager.state == BRFState.FACE_TRACKING) 
			{
				// Draw the underlaying shape (optinal):
//				var faceShape : BRFFaceShape = _brfManager.faceShape;
//				DrawingUtils.drawTriangles(_draw, faceShape.candideShapeVertices, faceShape.candideShapeTriangles, 
//						false, 1.0, 0xffff00, 0.25, 0xffff00, 0.0);
//				DrawingUtils.drawPoint(_draw, new Point(faceShape.translationX, faceShape.translationY), 2, false, 0x00ff00, 0.25);
				
				// We either have a result and show the 3D model,
				_container3D.update(_brfManager.faceShape); 
			} 
			else 
			{
				// Or we don't have a result and hide the 3D model.
				_container3D.idle();
			}
		}
		
		/**
		 * Click handler to change the model.
		 */
		public function onClickedVideo(event : MouseEvent) : void 
		{
			if (_currentModel == _model1) 
			{
				_currentModel = _model2;
			} 
			else 
			{
				_currentModel = _model1;
			}
			_container3D.model = _currentModel;
		}
	}
}