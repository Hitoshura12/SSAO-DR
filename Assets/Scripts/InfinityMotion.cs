// using UnityEngine;
//
// public class InfinityMotion : MonoBehaviour
// {
//     public float speed = 1.0f; // Controls the speed of the motion
//     public float radius = 1.0f; // Controls the radius of the loop
//     public float height = 1.0f; // Controls the height of the loop
//
//     private Vector3 initialPosition; // Stores the initial position of the object
//
//     private void Start()
//     {
//         initialPosition = transform.position; // Stores the initial position of the object
//     }
//
//     private void Update()
//     {
//         // Calculates the new position of the object based on the infinity loop function
//         Vector3 newPosition = initialPosition + new Vector3(Mathf.Cos(Time.time * speed) * radius, Mathf.Sin(Time.time * speed * 2.0f) * height, Mathf.Sin(Time.time * speed) * radius);
//
//         // Sets the position of the object to the new position
//         transform.position = newPosition;
//     }
// }
//
using UnityEngine;

public class InfinityMotion : MonoBehaviour
{
    public float speed = 1.0f; // Controls the speed of the motion
    public float radius = 1.0f; // Controls the radius of the loop
    public float height = 1.0f; // Controls the height of the loop

    private Vector3 initialPosition;

    private void Start()
    {
        initialPosition = transform.position;
    }

    private void Update()
    {
        // Calculates the new position of the object based on the Lemniscate of Gerono function
        float t = Time.time * speed;
        float x = Mathf.Cos(t);
        float y = Mathf.Sin(t) * radius / 2.0f * height; // Multiply the y component by height
        float z = Mathf.Sin(2.0f * t) / 2.0f;
        Vector3 newPosition = initialPosition + new Vector3(x, y, z);

        // Sets the position of the object to the new position
        transform.position = newPosition;
    }
}

