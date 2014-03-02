/*
	Info:
		- Reference page : http://www.emanueleferonato.com/2010/01/27/box2dflash-2-1a-released-what-changed/
		- Reference page : Box2dFlashAS3 2.1a / Examples / HelloWorld.fla
		- Box2D lib : Box2dFlashAS3 2.1a, http://www.box2dflash.org/
		- use object to create a car and move it.
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
		
	public class Main extends MovieClip
	{
		/*const variable：常數變數*/
		/*member variable：物件內部操作變數*/
		private var m_environment : b2AABB;
		private var m_world : b2World;
		
		public var m_velocityIterations:int = 10;
		public var m_positionIterations:int = 10;
		public var m_timeStep:Number = 1.0/60.0;
		
		private var m_worldScale : Number = 30;
		/*display object variable：顯示物件變數，如MovieClip等*/
		private var m_frontMotor : b2RevoluteJoint;
		private var m_rearMotor : b2RevoluteJoint;
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
			
			// 初始化世界			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			
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
			// px, py : location address，this location is center of object.
			// w, h : width、height
			// r : radius
			// d : is dynamic，this is set object type is dynamice or not. it also can setting with dynamic, kinematic, static, and default is static.
			// friction : 摩擦力, http://en.wikipedia.org/wiki/Friction
			// density : 密度,  http://en.wikipedia.org/wiki/Density
			// restitution : 恢復係數 ( Coefficient of restitution ), http://en.wikipedia.org/wiki/Coefficient_of_restitution
			// allowSleep :
			
			// joint reference : http://ohcoder.com/blog/2012/12/25/joints-overview/
			// joint reference : https://www.iforce2d.net/b2dtut/joints-overview
			// Revolute joint : 旋轉接點, http://en.wikipedia.org/wiki/Revolute_joint
			// Motor Torque : 馬達扭力
			// create obstacle
			draw_box(250,200,500,50,false, 1, 1);
			draw_box(0,200,50,100,false, 1, 1);
			draw_box(500,200,50,100,false, 1, 1);
			
			// create car
			var car_body : b2Body = draw_box( 250, 100, 100, 20, true, 1, 1, 0.1 );
			var car_front_wheel : b2Body = draw_circle_sprite( car_body.GetWorldCenter().x * this.m_worldScale + 40, 
													   car_body.GetWorldCenter().y * this.m_worldScale, 
													   20, true, 1, 5, 1, false );
			var car_rear_wheel : b2Body = draw_circle_sprite( car_body.GetWorldCenter().x * this.m_worldScale - 40, 
													  car_body.GetWorldCenter().y * this.m_worldScale , 20, 
													  true, 1, 5, 0, false );
			// link car joint
			this.m_frontMotor = this.create_joint( car_front_wheel, car_body, 10 ) as b2RevoluteJoint;
			this.m_rearMotor = this.create_joint( car_rear_wheel, car_body, 1 ) as b2RevoluteJoint;
			
		}
		
		// 鍵盤命令
		public function KeyDown( a_event : KeyboardEvent ) : void
		{
			switch (a_event.keyCode) {
				case 39 :
					this.m_frontMotor.SetMotorSpeed(10);
					this.m_rearMotor.SetMotorSpeed(10);
					break;
				case 37 :
					this.m_frontMotor.SetMotorSpeed(-10);
					this.m_rearMotor.SetMotorSpeed(-10);
					break;
			}
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
				if (bb.GetUserData() is Sprite)
				{
					var sprite:Sprite = bb.GetUserData() as Sprite;
					sprite.x = bb.GetPosition().x * this.m_worldScale;
					sprite.y = bb.GetPosition().y * this.m_worldScale;
					sprite.rotation = bb.GetAngle() * (180/Math.PI);
				}
			}
		}
		
		// 建立骨架
		public function create_joint( a_source : b2Body, a_target : b2Body, a_maxMotorTorque : Number = 0 ) : b2Joint
		{
			var motor_def : b2RevoluteJointDef = new b2RevoluteJointDef();
			motor_def.enableMotor = true;
			motor_def.maxMotorTorque = a_maxMotorTorque;
			var anchor : b2Vec2 = new b2Vec2();
			anchor.x = a_source.GetWorldCenter().x;
			anchor.y = a_source.GetWorldCenter().y;
			motor_def.Initialize( a_target, a_source, anchor );
			return this.m_world.CreateJoint( motor_def );
		}
		// 圓形物件
		public function draw_circle(px,py,r,d,friction = 0, density = 0, restitution = 0, a_allowSleep : Boolean = true) : b2Body 
		{
			var my_body : b2BodyDef= new b2BodyDef();
			my_body.allowSleep = a_allowSleep;
			my_body.position.Set(px/this.m_worldScale, py/this.m_worldScale);
			if (d) {
				my_body.type=b2Body.b2_dynamicBody;
			}
			var my_circle : b2CircleShape = new b2CircleShape(r/this.m_worldScale);
			var my_fixture : b2FixtureDef = new b2FixtureDef();
			my_fixture.shape = my_circle;
			my_fixture.friction = friction;
			my_fixture.density = density;
			my_fixture.restitution = restitution;
			var world_body : b2Body= this.m_world.CreateBody(my_body);
			world_body.CreateFixture(my_fixture);
			
			return world_body;
		}
		public function draw_circle_sprite(px,py,r,d,friction = 0, density = 0, restitution = 0, a_allowSleep : Boolean = true) : b2Body 
		{
			// 產生定義物件
			var my_body : b2BodyDef= new b2BodyDef();
			// 定義物件座標
			my_body.allowSleep = a_allowSleep;
			my_body.position.Set(px/this.m_worldScale, py/this.m_worldScale);
			// 定義物件是否為動態物件
			if (d) {
				my_body.type=b2Body.b2_dynamicBody;
			}
			// 產出物件圖像
			my_body.userData = new PhysCircle();
			my_body.userData.width = r * 2; 
			my_body.userData.height = r * 2; 
			this.addChild( my_body.userData );
			// 建立物理型體
			var my_circle : b2CircleShape = new b2CircleShape(r/this.m_worldScale);
			// 建立物理定義
			var my_fixture : b2FixtureDef = new b2FixtureDef();
			my_fixture.shape = my_circle;
			my_fixture.friction = friction;
			my_fixture.density = density;
			my_fixture.restitution = restitution;
			// 產出物體，並設定物理參數
			var world_body : b2Body= this.m_world.CreateBody(my_body);
			world_body.CreateFixture(my_fixture);
			
			return world_body;
		}
		
		// 矩型物件
		public function draw_box(px,py,w,h,d,friction = 0, density = 0, restitution = 0) : b2Body  
		{
			var my_body:b2BodyDef= new b2BodyDef();
			my_body.position.Set(px/this.m_worldScale, py/this.m_worldScale);
			if (d) {
				my_body.type=b2Body.b2_dynamicBody;
			}
			var my_box : b2PolygonShape = new b2PolygonShape();
			my_box.SetAsBox(w/2/this.m_worldScale, h/2/this.m_worldScale);
			var my_fixture : b2FixtureDef = new b2FixtureDef();
			my_fixture.shape=my_box;
			my_fixture.friction = friction;
			my_fixture.density = density;
			my_fixture.restitution = restitution;
			var world_body : b2Body = this.m_world.CreateBody(my_body);
			world_body.CreateFixture(my_fixture);
			
			return world_body;
		}
		public function draw_box_sprite(px,py,w,h,d,friction = 0, density = 0, restitution = 0) : b2Body  
		{
			// 產生定義物件
			var my_body:b2BodyDef= new b2BodyDef();
			// 定義物件座標
			my_body.position.Set(px/this.m_worldScale, py/this.m_worldScale);
			// 定義物件是否為動態物件
			if (d) {
				my_body.type=b2Body.b2_dynamicBody;
			}
			// 產出物件圖像
			my_body.userData = new PhysBox();
			my_body.userData.width = w; 
			my_body.userData.height = h; 
			this.addChild( my_body.userData );
			// 建立物理型體
			var my_box : b2PolygonShape = new b2PolygonShape();
			my_box.SetAsBox(w/2/this.m_worldScale, h/2/this.m_worldScale);
			// 建立物理定義
			var my_fixture : b2FixtureDef = new b2FixtureDef();
			my_fixture.shape=my_box;
			my_fixture.friction = friction;
			my_fixture.density = density;
			my_fixture.restitution = restitution;
			// 產出物體，並設定物理參數
			var world_body : b2Body = this.m_world.CreateBody(my_body);
			world_body.CreateFixture(my_fixture);
			
			return world_body;
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
			debug_draw.SetFlags(b2DebugDraw.e_shapeBit); 
			this.m_world.SetDebugDraw(debug_draw);
		}
		
		/*public function：對外公開函數*/
		/*private function：私用函數*/
		/*constructor：建構值*/
		/*private event function：私用事件函數*/
	}
}