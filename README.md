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
As the name suggests, it applies effects on images. It is mostly used as postprocessing. After all rendering is complete to render an image, the shader is applied on the image and a new output image is generated. This new output image is now rendered. It usually involves built-in unity function OnRenderImage() and the source RenderTexture is passed on to image shader and its output is set as destionation RenderTexture of the function.

In this project, I have written one for Anti Aliasing and one for a kind of colorful fog effect. I am still working on the fog effect.
		
