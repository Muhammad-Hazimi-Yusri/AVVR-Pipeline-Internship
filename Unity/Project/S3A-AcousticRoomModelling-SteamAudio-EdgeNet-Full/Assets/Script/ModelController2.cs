﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModelController2 : MonoBehaviour {

    public float moveSpeed;
    public float rotateSpeed;
    private Vector3 target;
    private Vector3 teleport;
    private int room;
    Rigidbody rb;

    void Start ()
    {
        rb = GetComponent<Rigidbody>();
        moveSpeed = 2f;
        target = transform.position;    //gameobjects position before moving
        room = 0;
    }
	
	// Update is called once per frame
	void Update ()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        //transform.Translate(horizontal * moveSpeed * Time.deltaTime, 0f, vertical * moveSpeed * Time.deltaTime);
        transform.Translate(0f, 0f, vertical * moveSpeed * Time.deltaTime);

        //Rotate Player
        transform.Rotate(0f, horizontal, 0f);

        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            if (room == 0)
            {
                teleport = new Vector3(50.0f, 0.0f, 0.0f);
                transform.position = (transform.position + teleport);
                room = 1;
            }
            else
            {
                teleport = new Vector3(-50.0f, 0.0f, 0.0f);
                transform.position = (transform.position + teleport);
                room--;
            }
        }

        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            if (room == 1)
            {
                teleport = new Vector3(-50.0f, 0.0f, 0.0f);
                transform.position = (transform.position + teleport);
                room = 0;
            }
            else
            {
                teleport = new Vector3(50.0f, 0.0f, 0.0f);
                transform.position = (transform.position + teleport);
                room++;
            }

        }


    }
}
