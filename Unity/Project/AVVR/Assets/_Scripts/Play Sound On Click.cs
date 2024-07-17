using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlaySoundOnClick : MonoBehaviour
{
    [SerializeField] public InputActionReference leftButtonPress = null;
    [SerializeField] public InputActionReference rightButtonPress = null;
    private AudioSource audioSource;

    void Start()
    {
        audioSource = this.GetComponent<AudioSource>();

        leftButtonPress.action.started += ButtonPressed;
        rightButtonPress.action.started += ButtonPressed;
    }

    void OnEnable()
    {
        leftButtonPress.action.Enable();
        rightButtonPress.action.Enable();
    }

    void OnDisable()
    {
        leftButtonPress.action.Disable();
        rightButtonPress.action.Disable();
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            PlayAudio();
        }
    }

    private void ButtonPressed(InputAction.CallbackContext context)
    {
        PlayAudio();
    }

    private void PlayAudio()
    {
        if (audioSource != null && audioSource.clip != null)
        {
            audioSource.Play();
        }
    }
}
