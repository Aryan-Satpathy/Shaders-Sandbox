using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class RayTracingMaster : MonoBehaviour
{
    public ComputeShader RayTracingShader;
    public Texture SkyboxTexture;

    [SerializeField]
    private int _numberOfBounces = 0;

    [SerializeField]
    private Vector3 Albedo = new Vector3(0.6f, 0.6f, 0.6f);

    [SerializeField]
    private bool antiAliasing = true;

    private RenderTexture _target;
    
    private Camera _camera;

    private uint _currentSample = 0;
    private Material _addMaterial;

    private ComputeBuffer sphereBuffer;

    [SerializeField]
    private int numberOfSpheres = 20;
    [SerializeField]
    private float maxRadius = 5f;
    [SerializeField]
    private float minRadius = 1f;

    private Sphere[] spheres = null;

    [SerializeField]
    private Vector3 directionalLight;
    [SerializeField]
    private float directionalLightIntensity;

    struct Sphere
    {
        public Vector3 pos;
        public float radius;
        public Vector3 specular;
        public Vector3 albedo;
    };

    void GenerateSpheres()
    {
        spheres = new Sphere[numberOfSpheres];
        for (int i = 0; i < numberOfSpheres; i ++)
        {
            spheres[i].radius = Random.Range(minRadius, maxRadius);
            spheres[i].pos = new Vector3(Random.Range((float)-(maxRadius + 0f) * 0.5f * numberOfSpheres, (float)(maxRadius + 0f) * 0.5f * numberOfSpheres), 2f * spheres[i].radius, Random.Range((float)-(maxRadius + 0f) * 0.5f * numberOfSpheres, (float)(maxRadius + 0f) * 0.5f * numberOfSpheres));
            Color color = Random.ColorHSV(0f, 1f, 0f, 1f, 0.4f, 1f);
            bool metal = Random.value < 0.5f;
            spheres[i].albedo = metal ? Vector3.zero : new Vector3(color.r, color.g, color.b);
            spheres[i].specular = metal ? new Vector3(color.r, color.g, color.b) : Vector3.one * 0.04f;
            // spheres[i].specular = new Vector3(Random.Range(0.4f, 0.99f), Random.Range(0.4f, 0.99f), Random.Range(0.4f, 0.99f));
            // spheres[i].specular = new Vector3(Random.Range())
        }
    }    

    private void Awake()
    {
        _camera = GetComponent<Camera>();
    }
    
    private void SetShaderParameters()
    {
        var offset = new Vector2(Random.value, Random.value);
        if (antiAliasing) RayTracingShader.SetVector("_PixelOffset", offset);
        else RayTracingShader.SetVector("_PixelOffset", Vector2.zero);
        RayTracingShader.SetTexture(0, "_SkyboxTexture", SkyboxTexture);
        RayTracingShader.SetMatrix("_CameraToWorld", _camera.cameraToWorldMatrix);
        RayTracingShader.SetMatrix("_CameraInverseProjection", _camera.projectionMatrix.inverse);
        RayTracingShader.SetInt("numberOfBounces", 1 + _numberOfBounces);
        RayTracingShader.SetVector("albedo", Albedo);
        RayTracingShader.SetFloat("_time", Time.time);
        RayTracingShader.SetVector("_DirectionalLight", directionalLight);
        RayTracingShader.SetFloat("_DirectionalLightIntensity", directionalLightIntensity);
        if (spheres != null)
        {
            sphereBuffer = new ComputeBuffer(spheres.Length, 10 * sizeof(float));
            sphereBuffer.SetData(spheres);
            int _id = RayTracingShader.FindKernel("CSMain");
            RayTracingShader.SetBuffer(_id, "_Spheres", sphereBuffer);
            RayTracingShader.SetInt("numSphere", numberOfSpheres);
            // sphereBuffer.Release();
        }
    }
    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        SetShaderParameters();
        Render(destination);
    }
    
    private void Render(RenderTexture destination)
    {
        // Make sure we have a current render target
        InitRenderTexture();
        // Set the target and dispatch the compute shader
        RayTracingShader.SetTexture(0, "Result", _target);
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        RayTracingShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);
        // Blit the result texture to the screen
        if (_addMaterial == null)
            _addMaterial = new Material(Shader.Find("Hidden/AddShader"));
        _addMaterial.SetFloat("_Sample", _currentSample);

        if (antiAliasing)
            Graphics.Blit(_target, destination, _addMaterial); 
        else 
            Graphics.Blit(_target, destination);

        sphereBuffer.Release();


        // Graphics.Blit(_target, destination, _addMaterial);
        _currentSample++;
    }
    
    private void InitRenderTexture()
    {
        if (_target == null || _target.width != Screen.width || _target.height != Screen.height)
        {
            // Release render texture if we already have one
            if (_target != null)
                _target.Release();
            // Get a render target for Ray Tracing
            _target = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            _target.enableRandomWrite = true;
            _target.Create();
        }
    }

    private void Start()
    {
        GenerateSpheres();
    }

    private void OnValidate()
    {
        _currentSample = 0;
        GenerateSpheres();
    }

    private void Update()
    {
        if (_currentSample > 15)
            _currentSample = 0;

        if (transform.hasChanged)
        {
            _currentSample = 0;
            transform.hasChanged = false;
        }
    }
}