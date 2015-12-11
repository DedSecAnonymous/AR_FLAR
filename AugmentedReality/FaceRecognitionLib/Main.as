package {
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.events.MouseEvent;
	// classes to import
	import com.oskarwicha.images.FaceDetection.FaceDetector;
	import com.oskarwicha.images.FaceDetection.Events.FaceDetectorEvent;
	public class Main extends Sprite {
		// face detector constructor
		private var detector:FaceDetector;
		private var imageCanvas:Sprite=new Sprite();
		private var tagCanvas:Sprite=new Sprite();
		private var urlText:TextField = new TextField();
		public function Main() {
			addChild(imageCanvas);
			addChild(tagCanvas);
			urlText.type=TextFieldType.INPUT;
			urlText.border=true;
			urlText.background=true;
			urlText.backgroundColor=0xFFFFFF;
			urlText.x=10;
			urlText.y=450;
			urlText.width=620;
			urlText.height=20;
			urlText.text="http://i1.tribune.com.pk/wp-content/uploads/2011/06/twilight-640x480.jpg";
			addChild(urlText);
			stage.addEventListener(MouseEvent.CLICK,loadImage);
			loadImage(null);
		}
		private function loadImage(e:MouseEvent):void {
			while (imageCanvas.numChildren>0) {
				imageCanvas.removeChildAt(0);
			}
			tagCanvas.graphics.clear();
			var imageLoader:Loader = new Loader();
			var loader:Loader = new Loader();
			loader.load(new URLRequest(urlText.text));
			imageCanvas.addChild(loader);
			detector=new FaceDetector();
			// loading face image from an url. use loadFaceImageFromBitmap if you want to load it from a bitmap  
			detector.loadFaceImageFromUrl(urlText.text);
			// listener which will be called each time a face will be detected.;
			// with EACH TIME I mean if two faces are detected, callback function will be called twice
			detector.addEventListener(FaceDetectorEvent.FACE_CROPPED,facesDetected);
			// listener which will be called when no faces are detected;
			detector.addEventListener(FaceDetectorEvent.NO_FACES_DETECTED,noFacesDetected);
		}
		private function facesDetected(e:FaceDetectorEvent):void {
			imageCanvas.alpha=1;
			// faces detected are stored in an array of rectangles
			var facesDetected:Array=detector.objectDetector.detected;
			for (var i:Number=0; i<facesDetected.length; i++) {
				tagCanvas.graphics.lineStyle(2,0xFF0000);
				tagCanvas.graphics.beginFill(0x000000,0.2);
				var faceRectangle:Rectangle=facesDetected[i];
				tagCanvas.graphics.drawRect(faceRectangle.x,faceRectangle.y,faceRectangle.width,faceRectangle.height);
				tagCanvas.graphics.endFill();
			}
		}
		private function noFacesDetected(e:FaceDetectorEvent):void {
			imageCanvas.alpha=0.5;
		}
	}
}