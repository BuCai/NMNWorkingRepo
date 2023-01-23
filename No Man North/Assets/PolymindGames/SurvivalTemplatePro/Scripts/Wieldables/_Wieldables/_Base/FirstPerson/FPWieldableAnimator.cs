using System;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Event Listeners/FP Animator")]
    public class FPWieldableAnimator : STPWieldableEventsListener<FPWieldableAnimator>
    {
        #region Internal
        [Serializable]
        protected class AnimatorParamaterEventSettings : STPEventListenerBehaviour
        {
            [NonSerialized]
            public Animator Animator;

            [SerializeField, ReorderableList]
            private AnimatorParameterTrigger[] m_Parameters;


            protected override void OnActionTriggered(float value)
            {
                for (int i = 0; i < m_Parameters.Length; i++)
                    m_Parameters[i].TriggerParameter(Animator);
            }
        }
        #endregion

        public AnimationOverrideClips AnimationClips => m_Clips;
        public Animator Animator => m_Animator;

        [SerializeField]
        private Animator m_Animator;

        [SerializeField]
        private AnimationOverrideClips m_Clips;

        [SpaceArea]

        [SerializeField, ReorderableList]
        private AnimatorParameterTrigger[] m_EquipParams = new AnimatorParameterTrigger[]
        {
            new AnimatorParameterTrigger(AnimatorControllerParameterType.Float, "EquipSpeed", 1f),
            new AnimatorParameterTrigger(AnimatorControllerParameterType.Trigger, "Equip", 1f)
        };

        [SerializeField, ReorderableList]
        private AnimatorParameterTrigger[] m_HolsterParams = new AnimatorParameterTrigger[]
        {
            new AnimatorParameterTrigger(AnimatorControllerParameterType.Float, "HolsterSpeed", 1f),
            new AnimatorParameterTrigger(AnimatorControllerParameterType.Trigger, "Holster", 1f)
        };

        [SpaceArea]

        [SerializeField, ReorderableList(elementLabel: "Animation", Foldable = true)]
        private AnimatorParamaterEventSettings[] m_AnimationSettings;


        protected override IEnumerable<STPEventListenerBehaviour> GetEvents() => m_AnimationSettings;

        protected override void Awake()
        {
            base.Awake();

            if (m_Animator != null && m_Clips.Controller != null)
            {
                var overrideController = new AnimatorOverrideController(m_Clips.Controller);
                var overrides = new List<KeyValuePair<AnimationClip, AnimationClip>>();

                foreach (var clipPair in m_Clips.Clips)
                    overrides.Add(new KeyValuePair<AnimationClip, AnimationClip>(clipPair.Original, clipPair.Override));

                overrideController.ApplyOverrides(overrides);

                m_Animator.runtimeAnimatorController = overrideController;

                if (m_AnimationSettings != null && m_AnimationSettings.Length > 0)
                {
                    foreach (var animSetting in m_AnimationSettings)
                        animSetting.Animator = m_Animator;
                }
            }
        }

        protected override void OnWieldableEquipped()
        {
            base.OnWieldableEquipped();

            m_Animator.ResetTrigger("Holster");

            for (int i = 0; i < m_EquipParams.Length; i++)
                m_EquipParams[i].TriggerParameter(m_Animator);
        }

        protected override void OnWieldableHolstered(float holsterSpeed)
        {
            for (int i = 0; i < m_HolsterParams.Length; i++)
            {
                if (m_HolsterParams[i].ParameterType == AnimatorControllerParameterType.Float)
                    m_HolsterParams[i].TriggerParameter(m_Animator, holsterSpeed);
                else
                    m_HolsterParams[i].TriggerParameter(m_Animator);
            }
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            if (m_Animator == null)
                m_Animator = GetComponentInChildren<Animator>();
        }
#endif
    }
}