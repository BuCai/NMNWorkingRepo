using UnityEngine;
using UnityEngine.EventSystems;

namespace SurvivalTemplatePro
{
    public class PointeEventsReceiverUI : MonoBehaviour, IDragHandler, IScrollHandler
    {
        public event PointerEventCallback onDrag;
        public event PointerEventCallback onScroll;


        public void OnDrag(PointerEventData eventData) => onDrag?.Invoke(eventData);
        public void OnScroll(PointerEventData eventData) => onScroll?.Invoke(eventData);
    }

    public delegate void PointerEventCallback(PointerEventData eventData);
}