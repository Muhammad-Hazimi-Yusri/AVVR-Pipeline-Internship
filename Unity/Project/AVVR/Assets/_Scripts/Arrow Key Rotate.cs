using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArrowKeyRotate : MonoBehaviour
{
    public float CooldownTime;
    public float cooldownUntilNextPress;

    // Start is called before the first frame update
    void Start()
    {
        this.CooldownTime = 0.5F;
        this.cooldownUntilNextPress = Time.time;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.LeftArrow) && cooldownUntilNextPress < Time.time)
        {
            transform.eulerAngles -= new Vector3(0, y: 45, 0);
            cooldownUntilNextPress = Time.time + CooldownTime;
        }
        if (Input.GetKey(KeyCode.RightArrow) && cooldownUntilNextPress < Time.time)
        {
            transform.eulerAngles -= new Vector3(0, y: -45, 0);
            cooldownUntilNextPress = Time.time + CooldownTime;
        }
    }
}
