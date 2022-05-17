using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Displace : MonoBehaviour
{

    private MeshFilter _mesh;

    [SerializeField] private float scale = 0.2f;
    // Start is called before the first frame update
    void OnEnable()
    {
        _mesh = GetComponent<MeshFilter>();
        Vector3[] vertices = _mesh.mesh.vertices;
        Debug.Log(vertices.Length);
        for (int i = 0; i < vertices.Length; i ++)
        {
            Vector3 posVector = vertices[i] - _mesh.transform.position;
            float x = Vector3.Dot(posVector, Vector3.forward) / _mesh.transform.localScale.x * 2f;
            float y = Vector3.Dot(posVector, Vector3.up) / _mesh.transform.localScale.x * 2f;
            float z = Mathf.PerlinNoise(x, y);
            x = (x + 1f) / 2f;
            y = (y + 1f) / 2f;
            float multiplier = z; // z * 2f - 1f;
            vertices[i] += scale * Vector3.Normalize(posVector) * multiplier;
        }

        // _mesh.mesh.Clear();
        _mesh.mesh.vertices = vertices;
        // _mesh.mesh.RecalculateBounds();
        // _mesh.mesh.RecalculateTangents();
        _mesh.mesh.RecalculateNormals();
        // _mesh.mesh.RecalculateUVDistributionMetrics();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
