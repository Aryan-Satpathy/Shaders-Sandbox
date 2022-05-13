using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestMaster : MonoBehaviour
{

    private Material test;
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
        if (test == null)
        {
            test = new Material(Shader.Find("Hidden/TestShader"));
        }
        test.SetFloat("_cameraFarClip", 1000f);
        Graphics.Blit(source, destination, test);
    }
}
