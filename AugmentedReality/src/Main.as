package
{
	import com.oskarwicha.images.FaceDetection.FaceDetector;
	import com.oskarwicha.images.FaceDetection.Events.FaceDetectorEvent;
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
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.Collada;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.parsers.Sketchup;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.objects.parsers.Collada;
    import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.view.BasicView;
	

	
	[SWF(width = "640", height = "480", frameRate = "30", backgroundColor = "#FFFFFF")]
	
	/**
	 * ...
	 * @author Harsh Patel 
	   @author Mohit Kumar
	 */
	public class Main extends Sprite 
	{
		[Embed(source = "pat1.pat", mimeType = "application/octet-stream")]
		private var pattern:Class;
		
		[Embed(source = "camera_para.dat", mimeType = "application/octet-stream")]
		private var params:Class;
		
		private var fparams:FLARParam;
		private var mpattern:FLARCode;
		private var vid:Video;
		private var cam:Camera;
		private var bmd:BitmapData;
		private var raster:FLARRgbRaster_BitmapData;
		private var detector:FLARSingleMarkerDetector;
		private var scene:Scene3D;
		private var camera:FLARCamera3D;
		private var container:FLARBaseNode;
		private var vp:Viewport3D;
		private var bre:BasicRenderEngine;
		private var trans:FLARTransMatResult;
		private var col:Collada;
		private var dae:DAE;
		private var _collada:Collada;
	    private var _dae:DAE;
		private var basic_view:BasicView;
		private var cube1:Cube;
		private var fd:FaceDetector;
		//private var paperPlane:PaperPlane;
		
		public function Main() 
		{
			/*if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);*/
			////stage.scaleX *= -1;
			//basic_view.scaleX *= -1;
			//basic_view.x = basic_view.width;
			/////stage.x = stage.width;
			stage.frameRate = 40;
			setupFLAR();
			setupCamera();
			setupBitmap();
			setuppv3d();
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function setupFLAR():void
		{
			fparams = new FLARParam();
			fparams.loadARParam(new params() as ByteArray);
			mpattern = new FLARCode(16, 16);
			mpattern.loadARPatt(new pattern());
		}
		
		private function setupCamera():void
		{
			vid = new Video(640, 480);
			cam = Camera.getCamera();
			cam.setMode(640, 480, 30);
			//vid.scaleX *= -1;
            //vid.x = vid.width;
			vid.attachCamera(cam);
			addChild(vid);
		}
		
		private function setupBitmap():void
		{
			bmd = new BitmapData(640, 480);
			bmd.draw(vid);
			raster = new FLARRgbRaster_BitmapData(bmd);
			detector = new FLARSingleMarkerDetector(fparams, mpattern, 80);
			
		}
		
		private function setuppv3d():void
		{
			scene = new Scene3D();
			camera = new FLARCamera3D(fparams);
			container = new FLARBaseNode();
			scene.addChild(container);
			
			var pl:PointLight3D = new PointLight3D();
			pl.x = 1000;
			pl.y = 1000;
			pl.z = -1000;
			
			var ml:MaterialsList = new MaterialsList( { all:new FlatShadeMaterial(pl) } );
			
			//cube1 = new Cube(ml, 30, 30, 30);
			//var cube2:Cube = new Cube(ml, 30, 30, 30);
			//cube2.z = 50;
			//var cube3:Cube = new Cube(ml, 30, 30, 30);
			//cube3.z = 100;
			
			//paperPlane = new PaperPlane(null,3);
			
			/*container.addChild(cube1);
			container.addChild(cube2);
			container.addChild(cube3);*/
			
			/*col = new Collada("cow.dae");
			col.scale = 0.5;
			col.y = 75;
			//col.rotationZ -= 90;
			container.addChild(col);*/
			
			dae = new DAE();
			dae.load("expermnt_dae.dae");
			dae.scale = 0.85;
			/*dae.rotationZ -= 270;
			dae.rotationX += 90;
			dae.rotationY += 180;
			dae.x = -25;
			dae.y = 30;
			//dae.rotationZ -= 180;
			container.addChild(dae);*/
		
            

			dae.rotationZ -= 180;
			dae.rotationX += 90;
			dae.rotationY -= 90;
			dae.x  = -75;
			dae.y = 100;
			container.addChild(dae);
			
			
			

			/*
			col = new Sketchup("gl.skp");
			col.scale = 0.5;
			col.y = 75;
			//col.rotationZ -= 90;
			container.addChild(col);
			*/
			
			/*_dae = new DAE();
		    _dae.load("expermnt_dae.dae");
		    _dae.rotationZ -= 180;
			_dae.rotationX += 90;
			_dae.rotationY -= 90;
			_dae.x  = -75;
			_dae.y = 60;
		    container.addChild(_dae);*/
			//container.addChild(cube1);
			//container.addChild(cube2);
			//container.addChild(cube3);
			/*container.addChild(paperPlane);
			trace(paperPlane.boundingBox().size);*/
			
			bre = new BasicRenderEngine();
			trans = new FLARTransMatResult();
			
			vp = new Viewport3D();
			addChild(vp);
			
		}
		
		private function loop(e:Event):void
		{
			bmd.draw(vid);
			
			
			
			try
			{
				if (detector.detectMarkerLite(raster, 80) && detector.getConfidence() > 0.5)
				{
					detector.getTransformMatrix(trans);
					container.setTransformMatrix(trans);
					//paperPlane.localRotationZ +=1;
					//trace(paperPlane.boundingBox().size);
					bre.renderScene(scene, camera, vp);
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