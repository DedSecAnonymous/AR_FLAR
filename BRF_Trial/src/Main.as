package
{
	import com.tastenkunst.as3.brf.nxt.BRFState;
	import com.tastenkunst.as3.brf.nxt.containers.Flare3D_v2_7;
	import com.tastenkunst.as3.brf.nxt.examples.ExampleCandideTracking;
	import flash.sampler.NewObjectSample;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLLoaderDataFormat;
	
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
	public class Main extends ExampleCandideTracking {
		
		// the occlusion head model, that hides the bows of the glasses
		public var _occlusionModel : String = "media/f3d/brf_occlusion_head.zf3d";
		// first example glasses model
		/*public var _model1 : String = "media/f3d/model_1_1495.zf3d";
		// second example glasses model
		public var _model2 : String = "media/f3d/model_7_1669.zf3d";*/
		// current model
		public var _currentModel : String;
		
		//Model location array
		public var model:Array = ["media/f3d/model_1_1495.zf3d","media/f3d/model_7_1669.zf3d","media/f3d/gen.zf3d"];
		
	    public var _slide: Sprite;
		// 3D scene handler
		public var _container3D : Flare3D_v2_7;
		
		// size and position of 3d viewport
		public var _viewport : Rectangle;
		
		// texture for webcam image as 3d plane
		public var _screenBmd : BitmapData;
		
		/*public var cur:String = "1.png";
		public var pre:String = "2.png";
		public var nxt:String = "3.png";*/
		
		//Array of model names
		public var mod:Array = ["1.png","2.png","3.png"];
		
		public var loader:Loader = new Loader();
		public var prev:Loader = new Loader();
		public var next:Loader = new Loader();
		

		public function Main() {
//			//
//			// 480p version:
//			//
//
//			// set the viewport size and position
			_viewport = new Rectangle(0, 0, 640, 480);
			_slide = new Sprite();
			
			
//			
//			// and the other rectangles (see ExampleBase for more information)
			super(
				new Rectangle(  0,   0,  640, 480),	// Camera resolution
				new Rectangle(  0,   0,  640, 480), // BRF BitmapData size
			    new Rectangle( 80,   0,  480, 480), // BRF region of interest within BRF BitmapData size
				new Rectangle(120,  40,  400, 400), // BRF face detection region of interest within BRF BitmapData size
			    new Rectangle(  0,   0,  640, 480), // Shown video screen rectangle within the 3D scene
				
				true, true
			);
			
			_slide.graphics.beginFill(0x0000FF);
			
			/*
			//
			// 720p version
			//
			
			// set the viewport size and position
			_viewport = new Rectangle(0, 0, 1280, 720);
			
			// and the other rectangles (see ExampleBase for more information)
			super(
				new Rectangle(  0,   0, 1280, 720),	// Camera resolution
				new Rectangle(  0,   0,  640, 480), // BRF BitmapData size
				new Rectangle(  0,   0,  640, 480), // BRF region of interest within BRF BitmapData size
				new Rectangle(120,  40,  400, 400), // BRF face detection region of interest within BRF BitmapData size
				new Rectangle(  0,   0, 1280, 720), // Shown video screen rectangle within the 3D scene
				true, true
			); */
		}
		
		/**
		 * BRF is ready. Lets set the tracking mode to BRFMode.FACE_TRACKING.
		 * and init all necessary stuff for Flare3D.
		 */
		override public function onReadyBRF(event : Event) : void {
			trace("Main.as says : OVErride onReadyBRF of super (ExampleCandietracking) but calls super.onReady");
			super.onReadyBRF(event);
			
			
		    var loader:Loader = new Loader();
			var prev:Loader = new Loader();
			var next:Loader = new Loader();
			//var next:Loader = new Loader();
			this.addChild(loader);
            this.addChild(prev);
			this.addChild(next);
			loader.x=520;
            loader.y = 120;
			prev.x = 520;
			prev.y = 0;
			next.x = 520;
			next.y = 240;
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE,doneLoad);
			
			// visible webcam image
			// on mobile: uploading large textures is slow, also drawing a video to large BitmapData is slow
			// so we make the shown video smaller in size if necessary: eg. 0.5
			var videoQuality : Number = 1.0; 
			
			_screenBmd = new BitmapData(_screenRect.width * videoQuality, _screenRect.height * videoQuality, false, 0x333333);
			_videoToScreenMatrix.scale(videoQuality, videoQuality);
			
			// the actual 3d scene handling container
			_container3D = new Flare3D_v2_7();
			addChild(_container3D);
			
			_container3D.init(_viewport, _cameraResolution, _brfResolution, _screenRect);
			_container3D.initVideoPlane(_screenBmd);
			_container3D.initOcclusion(_occlusionModel);
			
			// set the first model
			_currentModel = model[1];
			_container3D.model = _currentModel;
			
			// add a stage filling button to change the model
			_clickArea.buttonMode = true;
			_clickArea.useHandCursor = true;
			_clickArea.mouseChildren = false;
			_clickArea.addEventListener(MouseEvent.CLICK, doLoad);
			
			function doLoad(e:MouseEvent):void 
			{
				loader.load(new URLRequest(mod[1]));
				prev.load(new URLRequest(mod[0]));
				next.load(new URLRequest(mod[2]));
				_clickArea.addEventListener(MouseEvent.CLICK,onClickedVideo);
				_clickArea.visible=true;
			}
			
			/*
			function doneLoad(e:Event):void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,doneLoad);
				
				}
				
				*/
			
			// remove the video or brf bitmap, if its on stage, because Stage3D sits
			// below the display list.
			if (_container.contains(_video)) 
			{
				_container.removeChild(_video);
			}
		}
		
		/**
		 * We need to draw the webcam to the texture BitmapData.
		 */
		override public function updateInput() : void {
			super.updateInput();
			
			_screenBmd.draw(_video, _videoToScreenMatrix);
		}
		
		/**
		 * Update the 3D content, if a face shape was tracked.
		 * Otherwise hide the 3D content.
		 */
		override public function updateGUI() : void {
			_draw.clear();
			
			if(_brfManager.state == BRFState.FACE_TRACKING) {
				// Draw the underlaying shape (optinal):
//				var faceShape : BRFFaceShape = _brfManager.faceShape;
//				DrawingUtils.drawTriangles(_draw, faceShape.candideShapeVertices, faceShape.candideShapeTriangles, 
//						false, 1.0, 0xffff00, 0.25, 0xffff00, 0.0);
//				DrawingUtils.drawPoint(_draw, new Point(faceShape.translationX, faceShape.translationY), 2, false, 0x00ff00, 0.25);
				
				// We either have a result and show the 3D model,
				_container3D.update(_brfManager.faceShape); 
			} else {
				// Or we don't have a result and hide the 3D model.
				_container3D.idle();
			}
		}
		
		/**
		 * Click handler to change the model.
		 */
		/*public function onClickedVideo(event : MouseEvent) : void {
			if (_currentModel == _model1) {
				//loader.load(new URLRequest(pre));
				//_clickArea.visible=true;
				var temp:String = pre;
				pre = _pre;
				_pre = temp;
				
				_currentModel = _model2;
			} else 
			{
				temp = pre;
				pre = _pre;
				_pre = temp;
				_currentModel = _model1;
				
			}
			_container3D.model = _currentModel;
		}*/
			public function onClickedVideo(event:MouseEvent):void
			{
				if (_currentModel == model[1])
				{
					_currentModel = model[2];
					var temp:String = mod[0];
					mod[0] = mod[1];
					mod[1] = mod[2];
					mod[2] = temp;
				}
				else if (_currentModel == model[0])
				{
					_currentModel = model[1];
					temp = mod[2];
					mod[2] = mod[0];
					mod[0] = mod[1];
					mod[1] = temp;
				}
				else
				{
					_currentModel = model[0];
					temp = mod[1];
					mod[1] = mod[2];
					mod[2] = mod[0];
					mod[0] = temp;
				}
				_container3D.model = _currentModel;
			}
	}
}