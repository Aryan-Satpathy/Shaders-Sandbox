using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanetGen : MonoBehaviour
{
    [Range(2, 104)]
    public int resolution = 10;
    public float radius = 5f;
    [Range(0f, 1f)]
    public float scale = 0.6f;
    [SerializeField, Range(0f, 1f)]
    private float frequency = 0.28f;
    [SerializeField, Range(0f, 1f)]
    private float amplitude = 0.7f;
    Vector3[] directions = { Vector3.up, Vector3.down, Vector3.left, Vector3.right, Vector3.forward, Vector3.back };

    private void OnValidate()
    {
        GenerateMesh();
    }

    void GenerateMesh()
    {
        Vector3[] vertices = new Vector3[resolution * resolution * 6];
        int[] triangles = new int[(resolution - 1) * (resolution - 1) * 36];
        int triIndex = 0;

        Vector3 localUp;
        Vector3 axisA;
        Vector3 axisB;
        
        Mesh mesh = GetComponent<MeshFilter>().mesh;

        for (int d = 0; d < 6; d++)
        {
            localUp = directions[d];
            axisA = new Vector3(localUp.y, localUp.z, localUp.x);
            axisB = Vector3.Cross(localUp, axisA);

            for (int y = 0; y < resolution; y++)
            {
                for (int x = 0; x < resolution; x++)
                {
                    int i = x + y * resolution + d * resolution * resolution ;
                    Vector2 percent = new Vector2(x, y) / (resolution - 1);
                    Vector3 pointOnUnitCube = localUp + (percent.x - .5f) * 2 * axisA + (percent.y - .5f) * 2 * axisB;
                    Vector3 pointOnUnitSphere = pointOnUnitCube.normalized * radius;
                    vertices[i] = terrain(pointOnUnitSphere);

                    if (x != resolution - 1 && y != resolution - 1)
                    {
                        triangles[triIndex] = i;
                        triangles[triIndex + 1] = i + resolution + 1;
                        triangles[triIndex + 2] = i + resolution;
                        triangles[triIndex + 3] = i;
                        triangles[triIndex + 4] = i + 1;
                        triangles[triIndex + 5] = i + resolution + 1;
                        triIndex += 6;
                    }
                }
            }
        }
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
    }

    Vector3 terrain(Vector3 pos)
    {
        float res = _noise(pos, 6);
        if (res > 0.7f) Debug.Log(res);
        res *= scale;
        if (res > 0f) res = Mathf.Pow(res, 2.3f);
        return pos * (1f + res);
    }

    float _noise(Vector3 a, int rep)
    {
        float noise = 0;
        float _amplitude = amplitude;
        float _frequency = frequency;
        for (int i = 0; i < rep; i++)
        {
            noise += Perlin.Noise(a * _frequency) * _amplitude;
            _frequency *= 2f;
            _amplitude *= 0.5f;
        }
        return noise;
    }
}