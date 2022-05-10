using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AtmosphereMaster : MonoBehaviour
{
    private Camera _camera;
    private Material atmosphere;

    [SerializeField]
    private int numScatterPoints;
    [SerializeField]
    private int numDensityPoints;
    [SerializeField]
    private Transform Sun;
    [SerializeField]
    private Transform Planet;
    [SerializeField]
    private float atmosphereRadius;
    [SerializeField]
    private float planetRadius;
    [SerializeField]
    private float densityFallOff;
    [SerializeField]
    private Vector3 rgbWavelengths;
    [SerializeField]
    private float scatteringStrength;

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
        float scatterR = scatteringStrength * Mathf.Pow(1 / rgbWavelengths.x, 4);
        float scatterG = scatteringStrength * Mathf.Pow(1 / rgbWavelengths.y, 4);
        float scatterB = scatteringStrength * Mathf.Pow(1 / rgbWavelengths.z, 4);
        if (atmosphere == null)
            atmosphere = new Material(Shader.Find("Hidden/Atmosphere"));
        atmosphere.SetInt("_numScatterPoints", numScatterPoints);
        atmosphere.SetInt("_numDensityPoints", numDensityPoints);
        atmosphere.SetVector("_sunPos", Sun.position);
        atmosphere.SetVector("_planetPos", Planet.position);
        atmosphere.SetFloat("_atmosphereRadius", atmosphereRadius);
        atmosphere.SetFloat("_planetRadius", planetRadius);
        atmosphere.SetFloat("_densityFallOff", densityFallOff);
        atmosphere.SetFloat("scatterR", scatterR);
        atmosphere.SetFloat("scatterG", scatterG);
        atmosphere.SetFloat("scatterB", scatterB);
        Graphics.Blit(source, destination, atmosphere);
        // Graphics.Blit(source, destination);
    }
}
