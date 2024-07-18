using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class NonVRPlayerController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float moveSpeed = 5f;
    public float sprintSpeed = 10f;
    public float jumpForce = 5f;
    public float gravity = -9.81f;

    [Header("Look Settings")]
    public float mouseSensitivity = 2f;
    public float upperLookLimit = 80f;
    public float lowerLookLimit = -80f;

    private CharacterController controller;
    private Camera playerCamera;
    private Vector3 moveDirection;
    private Vector3 velocity;
    private float verticalRotation = 0f;

    private bool isGrounded;
    private bool isSprinting;

    void Start()
    {
        controller = GetComponent<CharacterController>();
        playerCamera = GetComponentInChildren<Camera>();

        if (playerCamera == null)
        {
            Debug.LogError("NonVRPlayerController: No camera found as a child of the player object!");
        }

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        HandleMovementInput();
        HandleMouseLook();
        ApplyMovement();
    }

    private void HandleMovementInput()
    {
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");

        isSprinting = Input.GetKey(KeyCode.LeftShift);
        float currentSpeed = isSprinting ? sprintSpeed : moveSpeed;

        moveDirection = transform.right * moveHorizontal + transform.forward * moveVertical;
        moveDirection *= currentSpeed;

        // Jumping
        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpForce * -2f * gravity);
        }
    }

    private void HandleMouseLook()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity;

        verticalRotation -= mouseY;
        verticalRotation = Mathf.Clamp(verticalRotation, lowerLookLimit, upperLookLimit);

        playerCamera.transform.localRotation = Quaternion.Euler(verticalRotation, 0f, 0f);
        transform.Rotate(Vector3.up * mouseX);
    }

    private void ApplyMovement()
    {
        isGrounded = controller.isGrounded;

        if (isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }

        controller.Move(moveDirection * Time.deltaTime);

        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
    }
}