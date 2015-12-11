package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.ByteArray;
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.support.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	import org.papervision3d.objects.parsers.Collada;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * ...
	 * @author Harsh Patel
	 */
	public class Main extends Sprite 
	{
		[Embed(source = "pat1.pat", mimeType = "application/octet-stream")]
		private var mpattern:Class;
		
		[Embed(source = "camera_para.dat", mimeType = "application/octet-stream")]
		private var params:Class;
		
		private var fparams:FLARParam;
		private var mpat:FLARCode;
		private var raster:FLARRgbRaster_BitmapData;
		private var detector:FLARSingleMarkerDetector;
		
		private var vid:Video;
		private var cam:Camera;
		private var capture:BitmapData;
		
		private var cam3D:FLARCamera3D;
		private var scene:Scene3D;
		private var vp:Viewport3D;
		private var container:FLARBaseNode;
		private var render:LazyRenderEngine;
		private var bre:BasicRenderEngine;
		
		private var trans:FLARTransMatResult;
		private var prevSet:Boolean = false;
		private var prevZ:Number = 0;
		
		private var col:Collada;
		private var dae:DAE;
		
		
		public function Main() 
		{
			/*if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);*/
			
			fparams = new FLARParam();
			fparams.loadARParam(new params() as ByteArray);
			
			mpat = new FLARCode(16, 16);
			mpat.loadARPatt(new mpattern());
			
			cam = Camera.getCamera();
			cam.setMode(640, 480, 30);
			
			vid = new Video();
			vid.width = 640;
			vid.height = 480;
			vid.attachCamera(cam);
			addChild(vid);
			
			capture = new BitmapData(vid.width, vid.height, false, 0x0);
			capture.draw(vid);
			
			raster = new FLARRgbRaster_BitmapData(capture);
			detector = new FLARSingleMarkerDetector(fparams, mpat, 80);
			
			cam3D = new FLARCamera3D(fparams);
			
			scene = new Scene3D();
			
			container = new FLARBaseNode();
			scene.addChild(container);
			
			vp = new Viewport3D(vid.width, vid.height);
			vp.scaleX = vp.scaleY = 2;
			addChild(vp);
			
			bre = new BasicRenderEngine();
			
			render = new LazyRenderEngine(scene, cam3D, vp);
			
			dae = new DAE();
			dae.load("Assets/picnic.dae");
			dae.scale = 0.5;
			dae.rotationZ -= 90;
			container.addChild(dae);
			
			trans = new FLARTransMatResult();
			
			this.addEventListener(Event.ENTER_FRAME, mainEnter);
			
		}
		
		private function mainEnter(e:Event):void
		{
			capture.draw(vid);
			
			try
			{
				if (detector.detectMarkerLite(raster, 80) && detector.getConfidence() > 0.5)
				{
					detector.getTransformMatrix(trans);
					container.setTransformMatrix(trans);
					bre.renderScene(scene, cam3D, vp);
				}
			}
			catch(e:Error){}
		}
		
		/*private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
		}*/
		
	}
	
}