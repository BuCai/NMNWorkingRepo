using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [CustomEditor(typeof(FPWieldableAnimator), true)]
    public class FPWieldableAnimatorEditor : STPEventsListenerEditor
    {
        private FPWieldableAnimator m_FPAnimator;

        private const int k_OverlayLayer = 11;


        public override void DrawCustomInspector()
        {
            base.DrawCustomInspector();

            if (m_FPAnimator == null)
                return;

            if (Application.isPlaying)
                GUI.enabled = false;

            EditorGUILayout.Space();
            STPEditorGUI.Separator();

            if (m_FPAnimator.Animator == null)
            {
                EditorGUILayout.HelpBox("Assign an animator controller", MessageType.Error);
                return;
            }

            if (CanShowSetupAnimatorButton())
                DrawSetupGUI();

            if (Application.isPlaying)
                GUI.enabled = true;

            if (m_FPAnimator != null && !Application.isPlaying)
                SetAnimatorController();
        }

        private void OnEnable()
        {
            m_FPAnimator = target as FPWieldableAnimator;
        }

        private void DrawSetupGUI()
        {
            EditorGUILayout.Space();
            STPEditorGUI.Separator();

            GUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.HelpBox("Animator is not properly set up", MessageType.Warning);

            if (GUILayout.Button("Fix First Person Settings"))
            {
                FixModelAndAnimator();

                EditorUtility.SetDirty(m_FPAnimator.gameObject);
                PrefabUtility.RecordPrefabInstancePropertyModifications(m_FPAnimator.gameObject);
            }

            GUILayout.EndVertical();

            STPEditorGUI.Separator();
        }

        private bool CanShowSetupAnimatorButton() 
        {
            if (m_FPAnimator == null)
                return false;

            var animator = m_FPAnimator.Animator;

            bool canShow = animator.GetComponentInChildren<SkinnedMeshRenderer>(true).updateWhenOffscreen == false;
            canShow |= animator.cullingMode != AnimatorCullingMode.AlwaysAnimate;
            canShow |= animator.gameObject.layer != k_OverlayLayer;

            foreach (var renderer in animator.GetComponentsInChildren<MeshRenderer>())
            {
                canShow |= renderer.gameObject.layer != k_OverlayLayer;
                canShow |= (renderer.shadowCastingMode != UnityEngine.Rendering.ShadowCastingMode.Off);

                if (canShow)
                    return true;
            }

            return canShow;
        }

        private void FixModelAndAnimator()
        {
            var animator = m_FPAnimator.Animator;
            var skinnedRenderers = animator.GetComponentsInChildren<SkinnedMeshRenderer>(true);
            var renderers = animator.GetComponentsInChildren<MeshRenderer>(true);

            if (animator != null)
            {
                m_FPAnimator.gameObject.SetLayerRecursively(k_OverlayLayer);

                animator.cullingMode = AnimatorCullingMode.AlwaysAnimate;
                animator.updateMode = AnimatorUpdateMode.Normal;
                animator.applyRootMotion = false;
            }

            if (skinnedRenderers != null)
            {
                foreach (var skinRenderer in skinnedRenderers)
                {
                    skinRenderer.updateWhenOffscreen = true;
                    skinRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                    skinRenderer.skinnedMotionVectors = false;
                    skinRenderer.allowOcclusionWhenDynamic = false;
                }
            }

            if (renderers != null)
            {
                foreach (var renderer in renderers)
                {
                    renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                    renderer.allowOcclusionWhenDynamic = false;
                }
            }
        }

        private void SetAnimatorController() 
        {
            var controller = serializedObject.FindProperty("m_Clips").GetValue<AnimationOverrideClips>().Controller;

            var animator = m_FPAnimator.GetComponentInChildren<Animator>();

            if (animator != null)
                animator.runtimeAnimatorController = controller;
        }
    }
}