Shader"MyShaders/001-ShaderProperties"{ 
	// Properties里写属性 （固定写法）
	Properties{
		// 第一个 _color 代表属性的名字 是自定义的
		// ("_color",Color) 里面的字符串是在Inspector面板显示的名字 是自定义的
		// ("_color",Color)   , 后面的Color代表定义的属性 是固定的
		// =(1,1,1,1) 这个（）里面设置默认值 R G B A 

		// 颜色类型
		_Color("_Color",Color) = (1,1,1,1)
		// 四维向量类型 X Y Z W
		_Vector("_Vector",Vector) = (1,2,3,4)
		// 整数类型
		_Int("_Int",Int) = 100
		// 小数类型  默认值不加F  shader里面没有double类型
		_Float("_Float",Float)=12.3
		// 范围类型 从哪个范围到哪个范围 这里设置的范围是1-100 默认值是50 可以取到1和100
		_Range("_Range",Range(1,100))=50
		// 指定图片 类型  如果{}里指定图片了会显示图片的颜色 如果没有指定图片会显示为设置的纯色 这里为white
		_2D("_Texture",2D) = "white"{}
		// 立方体纹理 立方体贴图
		_Cube("_Cube",Cube) = "white"{}
		// 3D 纹理 没用过 知道有这东西就行
		_3D("_Texure",3D) = "White"{}

	}
		// SubShader 可以有很多个  里面编写的是渲染的代码 利用属性编写一些 控制 渲染出来的效果
		// 为什么创建多个SubShader  因为不同的SubShader可以实现不同的效果 在不同的显卡上运行时需要
		// 比如不同的显卡对应不同的SubShader 好一点的对应 一个SubShader 差一点的对应一个SubShader
		// 1. 显卡运行效果时，从第一个SubShader开始，如果里面的效果都可以实现，那么就使用第一个SubShader
		// 2. 如果这个SubShader满足不了这个显卡的需求，它会自动跳到下一个 如果没有可以实现的会
		// 3. 调用 Fallback"VertexLit" 默认的
		// 一般第一个SubShader是显示效果最好的  第二个比第一个次一点 以此类推 这样会增加shader的适应能力
		SubShader{
		// SubShader 里面必须有一个 Pass块 也可以有多个
		// 一个Pass块代表一次渲染
		Pass{
		// 在这里编写Shader代码
			CGPROGRAM
			// 使用CG语言编写shader代码

			// 使用属性需要先定义 
			// 语法： 类型 名字   这里的名字需要和属性里面的一致
			// 不需要附默认值 会按 Properties 里面的来
			// 结尾需要带  ;  号
			float4 _Color;   
			// float4 可以使用 float half fixed 代替
			// 还有 float3   float2  float  分别代表里面有几个值 
			// 主要看是要怎么用  比如 float4 可以存储值 也可以存储向量 也可以使用float3存储向量
	        // 这里的float 的使用主要是看你想存储几个值 和 怎么用
	        // 在任何使用float的地方都可以使用 half和fixed 代替 比如 half3 half2 fixed3 fixed2
			// float和half的的区别： 在于范围 精度  不同的精度可以节省不同的内存  优化时候想起
			//  值   二进制 位         范围
			// float    32   -2147483648 到 2147483647
			// half		16          -6万 到 +6万
			// fixed    11          -2   到 +2
			// 一般颜色都使用fixed 存储   位置使用float存储 half使用的较少

			float4 _Vector;
			float _Int;
			float _Float;
			float _Range;
			sampler2D _2D;
			samplerCube _Cube;
			sampler3D _3D;


		ENDCG
	}
	}
	// 上面的SubShader都不执行的时候 执行Fallback
	// Fallback用来指定一个已经存在了的Shader 
	Fallback"VertexLit"
}