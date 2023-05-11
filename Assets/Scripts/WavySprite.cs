using UnityEngine;

public class WavySprite : MonoBehaviour {

    public float amplitude = 0.1f;      // Amplitude of the wave
    public float frequency = 1f;        // Frequency of the wave
    public float speed = 1f;            // Speed of the wave

    private MeshFilter meshFilter;      // Reference to the mesh filter component
    private Vector3[] originalVertices; // Array of the original vertex positions

    void Start() {
        meshFilter = GetComponent<MeshFilter>();
        originalVertices = meshFilter.mesh.vertices;
    }

    void Update() {
        Vector3[] vertices = meshFilter.mesh.vertices;
        for (int i = 0; i < vertices.Length; i++) {
            Vector3 vertex = originalVertices[i];
            vertex.y += amplitude * Mathf.Sin((vertex.x * frequency) + (Time.time * speed));
            vertices[i] = vertex;
        }
        meshFilter.mesh.vertices = vertices;
    }
}