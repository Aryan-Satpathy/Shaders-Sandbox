using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogMaster : MonoBehaviour
{

    private Camera _camera;

    private RenderTexture _target;

    private Material _fogMaterial;

    [SerializeField]
    private float density;

    [SerializeField]
    private float startDst;

    [SerializeField]
    private Color ColorA;
    [SerializeField]
    private Color ColorB;

    private void Awake()
    {
        _camera = GetComponent<Camera>();
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // _target = source;
        // SetShaderParameters();
        // Render(source, destination);
        if (_fogMaterial == null)
            _fogMaterial = new Material(Shader.Find("Hidden/Fog"));

        _fogMaterial.SetFloat("density", density);
        _fogMaterial.SetFloat("startDst", startDst);

        _fogMaterial.SetColor("ColorA", ColorA);
        _fogMaterial.SetColor("ColorB", ColorB);

        Graphics.Blit(source, destination, _fogMaterial);
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

    private void Render(RenderTexture source, RenderTexture destination)
    {
        if (_fogMaterial == null)
            _fogMaterial = new Material(Shader.Find("Hidden/Fog"));

        _fogMaterial.SetFloat("density", density);
        _fogMaterial.SetFloat("startDst", startDst);

        _fogMaterial.SetColor("ColorA", ColorA);
        _fogMaterial.SetColor("ColorB", ColorB);

        // Graphics.Blit(_target, destination, _fogMaterial);
        Graphics.Blit(source, destination, _fogMaterial);
    }
}
