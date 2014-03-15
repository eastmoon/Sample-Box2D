/*
	Info:
*/
package section.index
{
	/*import：Flash內建元件庫*/
	import flash.display.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/*external import：外部元件庫、開發人員自定元件庫*/
	import Box2D.Dynamics.b2World;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2FixtureDef;
		
	public class B2Circle extends B2Object
	{
		/*const variable：常數變數*/
		/*member variable：物件內部操作變數*/
		/*display object variable：顯示物件變數，如MovieClip等*/
		
		//
		public function B2Circle( a_world : b2World, 
							  a_worldScale : Number = 30, 
							  a_param : Object = null ) : void
		{
			// 
			super( a_world, a_worldScale, a_param );
		}
		
		/*public function：對外公開函數*/
		public override function Initial( a_param : Object = null ) : void
		{
			if( a_param == null )
				return ;
				
			// 依據傳入參數產生物體
			// x, y : location address，this location is center of object.
			// w, h : width、height, for box.
			// r : radius, for circle.
			// t : dynamic, kinematic, static, and default is static.
			// ud : sprite, user data.
			// phy : [ friction, density, restitution ]
			// friction : 摩擦力, http://en.wikipedia.org/wiki/Friction
			// density : 密度,  http://en.wikipedia.org/wiki/Density
			// restitution : 恢復係數 ( Coefficient of restitution ), http://en.wikipedia.org/wiki/Coefficient_of_restitution
			
			var bodyDef : b2BodyDef= new b2BodyDef();
			var fixtureDef : b2FixtureDef = new b2FixtureDef();
			var shape : b2CircleShape = null;
			var sizeInfo : Rectangle = new Rectangle();
			
			for( var paramStr : String in a_param )
			{
				switch( paramStr )
				{
					case "x" :
						sizeInfo.x = a_param[ paramStr ];
					break;
					
					case "y" :
						sizeInfo.y = a_param[ paramStr ];
					break;
					
					case "r" :
						sizeInfo.width = a_param[ paramStr ];
						sizeInfo.height = a_param[ paramStr ];
					break;
					
					case "t" :
						bodyDef.type = a_param[ paramStr ];
					break;
					
					case "ud" :
						this.m_displauObject = a_param[ paramStr ];
					break;
					
					case "phy" :
						if( a_param[ paramStr ] is Array && ( a_param[ paramStr ] as Array ).length == 3 )
						{
							fixtureDef.friction = ( a_param[ paramStr ] as Array )[0];
							fixtureDef.density = ( a_param[ paramStr ] as Array )[0];
							fixtureDef.restitution = ( a_param[ paramStr ] as Array )[0];
						}
					break;
				}
			}
			
			// 定義物件座標
			bodyDef.position.Set( sizeInfo.x / this.m_worldScale, sizeInfo.y / this.m_worldScale );
			bodyDef.userData = this;
			
			// 定義實體長寬
			if( this.m_displauObject != null)
			{
				this.m_displauObject.width = sizeInfo.width * 2; 
				this.m_displauObject.height = sizeInfo.height * 2; 
			}
			// 建立物理型體
			shape = new b2CircleShape( sizeInfo.width / this.m_worldScale);
			
			// 建立物理定義
			fixtureDef.shape = shape;
			
			// 產出物體，並設定物理參數
			this.m_body = this.m_world.CreateBody( bodyDef );
			this.m_body.CreateFixture( fixtureDef );
		}
		
		// 畫面更新
		
		/*public get/set function：變數存取介面*/
		/*write only：唯寫*/
		/*read only：唯讀*/
		/*read/write：讀寫*/
		
		/*private function：私用函數*/
		/*constructor：建構值*/
		/*private event function：私用事件函數*/
	}
}