using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class MusicPulse : MonoBehaviour
{
    [Range(0.1f,30)]
    public float speed = 0.5f;
    private float lastRms;
    private AudioSource audioSource;

    private const int SAMPLES = 512;
    private const string GLOBALRMS = "_GlobalRMS";
    // Start is called before the first frame update
    void Awake()
    {
        audioSource = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        float rms = Mathf.Lerp(lastRms, GetRMS(), Time.deltaTime * speed);
        Shader.SetGlobalFloat(GLOBALRMS,rms);
        lastRms = rms;
    }

    private float GetRMS()
    {
        float[] samples = new float[SAMPLES];
        audioSource.GetOutputData(samples, 0);
        float total = 0;
        foreach (var sample in samples)
        {
            total += sample * sample;
        }

        return Mathf.Sqrt(total/samples.Length);
    }


}
