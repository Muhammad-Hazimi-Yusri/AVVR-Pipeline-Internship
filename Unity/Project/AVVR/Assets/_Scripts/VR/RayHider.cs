using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit;

public class RayHider : MonoBehaviour
{
    public XRInteractorLineVisual leftLineVisual;
    public XRInteractorLineVisual rightLineVisual;
    
    // Start is called before the first frame update
    void Start()
    {        
        HideLine(leftLineVisual);
        HideLine(rightLineVisual);
    }

    void HideLine(XRInteractorLineVisual lineVisual)
    {
        if (lineVisual != null)
        {
            lineVisual.enabled = false;
            
            // Disable the Line Visual component
            LineRenderer lineRenderer = lineVisual.GetComponent<LineRenderer>();
            if (lineRenderer != null)
            {
                lineRenderer.enabled = false;
            }
        }
    }
}
