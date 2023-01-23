using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    /// <summary>
    /// Generates Rays based on the parent character state.
    /// (e.g. shoot direction ray will be more random when moving)
    /// </summary>
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/wieldable#character-ray-generator-module")]
    public class CharacterRayGenerator : CharacterBehaviour, IRayGenerator
    {
        #region Internal
        [System.Serializable]
        private struct SpreadModifier
        {
            [SearchableEnum]
            public MotionStateType StateType;

            [SerializeField, Range(0f, 10f)]
            [Tooltip("How much will being in this state affect (randomly spread) the final wieldable ray (Affects the trajectory of the bullet when using firearms and more).")]
            public float SpreadMod;
        }
        #endregion

        [SerializeField]
        [Tooltip("Anchor: Transform used in determining the base ray position and orientation.")]
        private Transform m_Anchor;

        [Title("Spread Modifiers")]

        [SerializeField]
        [LabelByChild("StateType"), ReorderableList(Foldable = true)]
        private SpreadModifier[] m_SpreadModifiers;

        private IMotionController m_Motion;


        public override void OnInitialized() => GetModule(out m_Motion);

        public Ray GenerateRay(float raySpreadMod, Vector3 localOffset = default)
        {
            float raySpread = GetRaySpread(m_Motion.ActiveStateType) * raySpreadMod;

            Vector3 raySpreadVector = m_Anchor.TransformVector(new Vector3(Random.Range(-raySpread, raySpread), Random.Range(-raySpread, raySpread), 0f));
            Vector3 rayDirection = Quaternion.Euler(raySpreadVector) * m_Anchor.forward;

            return new Ray(m_Anchor.position + m_Anchor.TransformVector(localOffset), rayDirection);
        }

        public float GetRaySpread() => GetRaySpread(m_Motion.ActiveStateType);

        private float GetRaySpread(MotionStateType stateType)
        {
            for (int i = 0; i < m_SpreadModifiers.Length; i++)
            {
                if (m_SpreadModifiers[i].StateType == stateType)
                    return m_SpreadModifiers[i].SpreadMod;
            }

            return 1f;
        }
    }
}