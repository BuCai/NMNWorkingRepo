using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations.Rigging;

namespace MLC.NoManNorth.Eric
{
    public class PlayerAnimationHelper : MonoBehaviour
    {

        #region Variables
        public static PlayerAnimationHelper Instance { get; private set; }

        [SerializeField] private Animator playerAnimator;

        [SerializeField] private PlayerInteractor playerInteractor;
        [SerializeField] private EventChannelFloat OnFrostPercentageChange;

        [SerializeField] private HitDetection MeleeHitDetection;
        [SerializeField] private TwoBoneIKConstraint rightHandIK;
        [SerializeField] private TwoBoneIKConstraint leftHandIK;
        #endregion

        #region Unity Methods

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(this);
            }
            else
            {
                Instance = this;
            }

            OnFrostPercentageChange.OnEvent += OnFrostPercentageChange_OnEvent;
        }

        private void OnDestroy()
        {
            OnFrostPercentageChange.OnEvent -= OnFrostPercentageChange_OnEvent;
        }

        #endregion

        #region Methods

        public void OnTimeToTriggerCurrentInteracrable()
        {
            playerInteractor.OnAnimationFireInteract();
        }

        public void OnDonePickingUpItem()
        {
            PlayerItemDisplayer.Instance.hideHandObject();
        }

        Tween tween;
        private void OnFrostPercentageChange_OnEvent(float obj)
        {
            
            float target = obj;
            float start = playerAnimator.GetFloat("Frost");
            tween.Kill();
            tween = DOVirtual.Float(start, obj, 1f, current => {
                if (obj < .25f) current = .25f;
                playerAnimator.SetFloat("Frost", current);
                

            } );
        }

        public void OpenInvintory()
        {
            playerAnimator.SetTrigger("OpenInvintory");
            playerAnimator.ResetTrigger("CloseInvintory");
        }

        public void CloseInvintory()
        {
            playerAnimator.SetTrigger("CloseInvintory");
        }

        public void AxeAttack()
        {
            playerAnimator.SetTrigger("AxeAttack");
        }

        public void MeleeAttackActivateHurtBoxes()
        {
            MeleeHitDetection.setUpHitData(UNIT_TEAM.PLAYER, this.gameObject, InvintoryPlayer.Instance.getAttackDamageOfCurrentEquiptedItem(), InvintoryPlayer.Instance.getDamageTypeOfCurrentEquiptedItem());
            MeleeHitDetection.gameObject.SetActive(true);
        }

        public void MeleeAttackDeActivateHurtBoxes()
        {
            MeleeHitDetection.gameObject.SetActive(false);
        }

        public void EquipRifle()
        {
            playerAnimator.SetTrigger("EquipRifle");
        }

        public void SetRightHandIKTarget(Transform transform)
        {
            rightHandIK.data.target = transform;
        }

        public void SetLeftHandIKTarget(Transform transform)
        {
            leftHandIK.data.target = transform;
        }
        
        public void UnEquipRifle()
        {
            playerAnimator.SetTrigger("UnequipRifle");
        }

        public void TriggerShot()
        {
            playerAnimator.SetTrigger("TriggerShot");
        }

        #endregion
    }
}