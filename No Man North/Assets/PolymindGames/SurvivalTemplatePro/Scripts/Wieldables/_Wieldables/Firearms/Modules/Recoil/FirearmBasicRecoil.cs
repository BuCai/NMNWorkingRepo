using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Recoil/Basic Recoil")]
    public class FirearmBasicRecoil : FirearmRecoilBehaviour
    {
        public override float RecoilForce => m_RecoilForce;

        [Space]

        [SerializeField, Range(0f, 10f)]
        private float m_RecoilForce = 1f;
    }
}