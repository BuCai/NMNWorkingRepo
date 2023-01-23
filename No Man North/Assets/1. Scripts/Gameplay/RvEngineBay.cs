using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro {

    [System.Serializable]
    public struct EnginePart {
        public bool isEnabled { get => renderer.enabled; set { renderer.enabled = value; } }
        [SerializeField] private MeshRenderer renderer;
    }

    public class RvEngineBay : MonoBehaviour {
        public EnginePart[] parts;

        private void Awake() {
            UpdateCondition();
        }

        public void TogglePart(int index) {
            SetPartEnabled(index, !parts[index].isEnabled);
        }

        public void SetPartEnabled(int index, bool enabled) {
            parts[index].isEnabled = enabled;
            UpdateCondition();
        }

        //Configured to use RVIgnitionInteractable
        [SerializeField] private RVIgnitionInteractable ignition;
        private void UpdateCondition() {
            bool canStart = true;
            foreach (EnginePart part in parts) {
                if (!part.isEnabled) {
                    canStart = false;
                }
            }
            if (ignition != null)
                ignition.engineFunctional = canStart;
        }
    }
}
