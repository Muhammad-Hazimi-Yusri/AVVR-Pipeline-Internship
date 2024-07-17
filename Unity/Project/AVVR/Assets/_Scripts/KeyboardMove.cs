using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KeyboardMove : MonoBehaviour
{
    private Vector3 moveDirection;
    private Vector3 cameraRotation;
    public float speed;
    private float mouseX;
    private float mouseY;
    public float sens;

    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        //speed = 1e-3f;
        //sens = 2f;
    }

    // Update is called once per frame
    void Update()
    {
        mouseX = Input.GetAxis("Mouse Y");
        mouseY = Input.GetAxis("Mouse X");

        cameraRotation = sens * new Vector3(x: Input.GetAxis("Mouse Y"), y: -Input.GetAxis("Mouse X"), 0);
        transform.eulerAngles -= cameraRotation;

        moveDirection = Vector3.zero;
        
        if (Input.GetKey(KeyCode.W))
        {
            moveDirection += transform.forward;
        }
        if (Input.GetKey(KeyCode.S))
        {
            moveDirection -= transform.forward;
        }
        if (Input.GetKey(KeyCode.A))
        {
            moveDirection -= transform.right;
        }
        if (Input.GetKey(KeyCode.D))
        {
            moveDirection += transform.right;
        }

        this.transform.position += moveDirection * speed;
    }
}
