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
    private Transform Sun;
    [SerializeField]
    private Transform Planet;
    [SerializeField]
    private float atmosphereRadius;
    [SerializeField]
    private float planetRadius;
    [SerializeField]
    private float densityFallOff;

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
        if (atmosphere == null)
            atmosphere = new Material(Shader.Find("Hidden/Atmosphere"));
        atmosphere.SetInt("numScatterPoints", numScatterPoints);
        atmosphere.SetVector("sunPos", Sun.position);
        atmosphere.SetVector("planetPos", Planet.position);
        atmosphere.SetFloat("atmosphereRadius", atmosphereRadius);
        atmosphere.SetFloat("planetRadius", planetRadius);
        atmosphere.SetFloat("densityFallOff", densityFallOff);
        Graphics.Blit(source, destination, atmosphere);
    }
}
