/*
	Info:
		- Reference page : http://blog.allanbishop.com/box2d-2-1a-tutorial-part-2-joints/
		- Reference page : http://www.emanueleferonato.com/2012/08/23/box2d-and-the-wraparound-effect/
		- Reference page : Box2dFlashAS3 2.1a / Examples / HelloWorld.fla
		- Box2D lib : Box2dFlashAS3 2.1a, http://www.box2dflash.org/
		- use object to create a car and move it.
		
		- Introduction : 
*/

package section.index
{
	/*import：Flash內建元件庫*/
	import flash.display.*;
	import flash.media.*;
	import flash.events.*;
	import flash.net.*;
		
	/*external import：外部元件庫、開發人員自定元件庫*/
	import Box2D.Dynamics.b2World;
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.b2BroadPhase;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2Joint;
	import flash.text.TextField;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
		
	public class Main extends MovieClip
	{
		/*const variable：常數變數*/
		private const c_intro : String = "Drag the ball.";
		/*member variable：物件內部操作變數*/
		private var m_world : b2World;
		
		public var m_velocityIterations:int = 10;
		public var m_positionIterations:int = 10;
		public var m_timeStep:Number = 1.0/60.0;
		
		private var m_worldScale : Number = 30;
		
		private var m_applyType : Number = 1;
		
		private var m_ball : b2Body;        
		
		private var m_mouseJoint : b2MouseJoint;
		
		/*display object variable：顯示物件變數，如MovieClip等*/
		public var tf_text : TextField;
		//
		public function Main()
		{
			trace("It is Index Page");
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.Initial );
		}
		
		public function Initial( a_event : Event = null ) : void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.Initial);
			this.addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, MouseDown);
			
			// 初始化世界			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			this.m_world = new b2World( gravity, doSleep);
			// Use the given object as a broadphase. 
			// boardphase : http://http.developer.nvidia.com/GPUGems3/gpugems3_ch32.html
			//this.m_world.SetBroadPhase(new b2BroadPhase(this.m_worldAABB));
			// nable/disable warm starting. For testing. 
			this.m_world.SetWarmStarting(true);
			
			debug_draw();
			
			// create obstacle
			var wall_t : B2Object = new B2Box( this.m_world, this.m_worldScale,
										{ "x" : this.stage.stageWidth / 2, "y" : 0, "w" : this.stage.stageWidth, "h" : 50, "phy" : [1,1,0] } );
										
			var wall_b : B2Object = new B2Box( this.m_world, this.m_worldScale,
										{ "x" : this.stage.stageWidth / 2, "y" : this.stage.stageHeight, "w" : this.stage.stageWidth, "h" : 50, "phy" : [1,1,0] } );
										
			var wall_l : B2Object = new B2Box( this.m_world, this.m_worldScale,
										{ "x" : 0, "y" : this.stage.stageHeight / 2, "w" : 50, "h" : this.stage.stageHeight, "phy" : [1,1,0] } );
										
			var wall_r : B2Object = new B2Box( this.m_world, this.m_worldScale,
										{ "x" : this.stage.stageWidth, "y" : this.stage.stageHeight / 2, "w" : 50, "h" : this.stage.stageHeight, "phy" : [1,1,0] } );
			
			// create ball
			var ball : B2Object = new B2Circle( this.m_world, this.m_worldScale, 
											   {"x" : this.stage.stageWidth / 2, "y" : this.stage.stageHeight / 2, "r" : 20, 
											   "t" : b2Body.b2_dynamicBody, "phy":[0.1,1,0.1], "ud" : new PhysCircle() } );
			this.m_ball = ball.body;
			if( ball.displayObject != null )
			{
				this.addChild( ball.displayObject );
			}
			// create kinematic spheres
			// create B2Box
			// 說明文字
			this.tf_text = new TextField();
			this.tf_text.x = 25;
			this.tf_text.y = 50;
			this.tf_text.text = c_intro;
			this.tf_text.width = 500;
			this.addChild( this.tf_text );
		}
		
		// 鍵盤命令
		public function KeyDown( a_event : KeyboardEvent ) : void
		{
		}
		
		// 滑鼠命令
		public function MouseDown( a_event : MouseEvent ) : void
		{
			this.m_world.QueryPoint(queryCallback, new b2Vec2( this.mouseX / this.m_worldScale, this.mouseY / this.m_worldScale));
		}
		private function queryCallback( fixture : b2Fixture ):Boolean {
            var touchedBody:b2Body=fixture.GetBody();
            if (touchedBody.GetType()==b2Body.b2_dynamicBody) {
                var jointDef : b2MouseJointDef = new b2MouseJointDef();
                jointDef.bodyA = this.m_world.GetGroundBody();
                jointDef.bodyB = touchedBody;
                jointDef.target = new b2Vec2( this.mouseX / this.m_worldScale, this.mouseY / this.m_worldScale);
                jointDef.maxForce = 200 * touchedBody.GetMass();
				
                this.m_mouseJoint = this.m_world.CreateJoint(jointDef) as b2MouseJoint;
				
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.MouseMove);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, MouseUp);
            }
            return false;
        }
		private function MouseMove( a_event : MouseEvent ) : void
		{
			if( this.m_mouseJoint != null )
	            this.m_mouseJoint.SetTarget( new b2Vec2( this.mouseX / this.m_worldScale, this.mouseY / this.m_worldScale) );
        }
		public function MouseUp( a_event : MouseEvent ) : void
		{
            this.m_world.DestroyJoint( this.m_mouseJoint );
            this.m_mouseJoint = null;
            this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.MouseMove);
            this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.MouseUp);
		}
		// 畫面更新
		public function Update( a_event : Event):void{
			
			this.m_world.Step(m_timeStep, m_velocityIterations, m_positionIterations);
			this.m_world.ClearForces();
			// 繪製Debug data
			this.m_world.DrawDebugData();
			
			// Go through body list and update sprite positions/rotations
			for(var bb:b2Body = m_world.GetBodyList(); bb; bb = bb.GetNext())
			{
				if( bb.GetUserData() is B2Object )
				{
					(bb.GetUserData() as B2Object).Update();
				}
			}
		}
		
		
		// 偵錯系統
		public function debug_draw():void {
			
			var debug_draw:b2DebugDraw = new b2DebugDraw();
			var debug_sprite:Sprite = new Sprite();
			this.addChild(debug_sprite);
			
			debug_draw.SetSprite(debug_sprite);
			debug_draw.SetDrawScale(this.m_worldScale);  
			debug_draw.SetFillAlpha( 0.5 );
			debug_draw.SetLineThickness( 1 )
			debug_draw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit); 
			this.m_world.SetDebugDraw(debug_draw);
		}
		
		/*public function：對外公開函數*/
		/*private function：私用函數*/
		/*constructor：建構值*/
		/*private event function：私用事件函數*/
	}
}