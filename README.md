<!-- <style>
figure {
  border: 1px #cccccc solid;
  padding: 4px;
  margin: auto;
}

figcaption {
  background-color: black;
  color: white;
  font-style: italic;
  padding: 2px;
  text-align: center;
}
</style> -->
# Shaders Sandbox
Just experimenting with Unity shaders.

Shaders used in the project : 
- Compute Shader
- Image Effect Shader
		
## Compute Shaders
These do not really render anything, these are just code that run on GPU in parallel processes.
Could be used to do performance heavy tasks in GPU, or could be used to just, render.

In this project, I have implemented a very basic ray tracing with reflections using Compute Shader. Lights are yet to be added.

## Image Effect Shaders
As the name suggests, it applies effects on images. It is mostly used as Post Processing. After all rendering is complete to render an image, the shader is applied on the image and a new output image is generated. This new output image is now rendered. It usually involves built-in unity function OnRenderImage() and the source RenderTexture is passed on to image shader and its output is set as destionation RenderTexture of the function.

In this project, I have written one for Anti Aliasing and one for a kind of colorful fog effect. I am still working on the fog effect.
		
## Ray Tracing | Compute Shader
<p align ="center">
	<img src="https://user-images.githubusercontent.com/86613790/158048885-0ee3eac3-3e93-4aee-b102-e6af6bd638d5.png" width=50% heigth=50%> 
	<br>
    	<em>Figure 1: 10 spheres, 10 number of bounces.</em>
<!-- 	<figcaption align="center">Scene</figcaption> -->
</p>
<p align ="center">
	<img src="https://user-images.githubusercontent.com/86613790/158049251-5697fa2d-bfe1-4e76-b83d-77edee2b3cb9.png" width=50% heigth=50%> 
	<br>
    	<em>Figure 2: Reflections.</em>
<!-- 	<figcaption align="center">Scene</figcaption> -->
</p>
Spheres are not actually in the scenes, they are just rendered by the shader, there are no sphere meshes.

## Anti Aliasing | Image Effect Shader
<p align ="center">
	<img src="https://user-images.githubusercontent.com/86613790/158048958-66c875de-d9c8-4156-a725-ec9d6fa50b72.png" width=50% heigth=50%> 
	<br>
    	<em>Figure 1: Ray tracing scene without Anti Aliasing.</em>
<!-- 	<figcaption align="center">Scene</figcaption> -->
</p>
<p align ="center">
	<img src="https://user-images.githubusercontent.com/86613790/158049050-22670cb0-b438-4685-80b7-a01effdced19.png" width=50% heigth=50%> 
	<br>
    	<em>Figure 2: Ray tracing scene with Anti Aliasing.</em>
<!-- 	<figcaption align="center">Scene</figcaption> -->
</p>
Zoom in to clearly see the effect.

## Fog | Image Effect Shader
<p align ="center">
	<img src="https://user-images.githubusercontent.com/86613790/158047484-a61701b8-975f-4605-8ec3-822766dad12e.png" width=50% heigth=50%> 
	<br>
    	<em>Figure 1: Scene.</em>
<!-- 	<figcaption align="center">Scene</figcaption> -->
</p>
<p align ="center">
	<img src="https://user-images.githubusercontent.com/86613790/158048723-5bac4797-b53f-4d30-a299-2b23f222a762.png" width=50% heigth=50%>
	<br>
    	<em>Figure 2: In playmode, when looked from some distance.</em>
<!-- 	<figcaption align="center">Scene</figcaption> -->
</p>
<p align ="center">
	<img src="https://user-images.githubusercontent.com/86613790/158048801-131419ff-28c4-4cab-ada0-9068d96336f3.png" width=50% heigth=50%>
	<br>
    	<em>Figure 3: In playmode, when we come closer to the objects.</em>
<!-- 	<figcaption align="center">Scene</figcaption> -->
</p>
Yeah I like pink a bit too much.
