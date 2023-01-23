using EasyCharacterMovement;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.MovementSystem {
    [RequireComponent(typeof(CharacterController))]
    public class CharacterControllerMotor : CharacterBehaviour, ICharacterMotor, ISaveableComponent {
        public bool IsGrounded => m_CController.isGrounded;
        public float LastGroundedChangeTime => m_LastGroundedChangeTime;
        public float Gravity => m_Gravity;
        public float VelocityMod { get; set; } = 1f;
        public Vector3 Velocity => m_CController.velocity;
        public Vector3 SimulatedVelocity => m_SimulatedVelocity;
        public Vector3 GroundNormal => m_GroundNormal;
        public CollisionFlags CollisionFlags => m_CollisionFlags;
        public float GroundSurfaceAngle => Vector3.Angle(Vector3.up, m_GroundNormal);
        public float DefaultHeight => m_DefaultMotorHeight;
        public float SlopeLimit => m_CController.slopeLimit;
        public float Radius => m_CController.radius;
        public float Height {
            get => m_CController.height;
            protected set {
                if (Mathf.Abs(m_CController.height - value) > 0.001f) {
                    m_CController.height = value;
                    m_CController.center = Vector3.up * (value * 0.5f);
                    onHeightChanged?.Invoke(value);


                }
            }
        }

        public event UnityAction onTeleport;
        public event UnityAction<bool> onGroundedStateChanged;
        public event UnityAction<float> onFallImpact;
        public event UnityAction<float> onHeightChanged;

        [SerializeField, Range(0f, 100f)]
        [Tooltip("The strength of the gravity.")]
        private float m_Gravity = 20f;

        [SerializeField] private Transform m_PlayerModel;

        [SerializeField] private float m_RotateSpeed = 540.0f;
        [Title("Sliding")]

        [SerializeField, Range(20f, 90f)]
        [Tooltip("The angle at which the character will start to slide.")]
        private float m_SlideThreshold = 32f;

        [SerializeField, Range(0f, 2f)]
        [Tooltip("The max sliding speed.")]
        private float m_SlideSpeed = 0.1f;

        [Title("Misc")]

        [Tooltip("A force that will be applied to any rigidbody this motor will collide with.")]
        [SerializeField, Range(0f, 10f)]
        private float m_PushForce = 1f;

        [SerializeField]
        [Tooltip("Layers that are considered obstacles.")]
        private LayerMask m_CollisionMask;

        private CharacterController m_CController;
        private MotionInputCallback m_MotionInput;

        private CollisionFlags m_CollisionFlags;
        private Vector3 m_GroundNormal = Vector3.up;
        private Vector3 m_SlideVelocity = Vector3.zero;
        private Vector3 m_SimulatedVelocity = Vector3.zero;
        private Vector3 m_Translation = Vector3.zero;
        private float m_LastGroundedChangeTime;
        private float m_DefaultMotorHeight;
        private bool m_ApplyGravity;
        private bool m_SnapToGround;

        private RaycastHit m_RaycastHit = new RaycastHit();


        public override void OnInitialized() {
            m_CController = GetComponent<CharacterController>();
            m_DefaultMotorHeight = m_CController.height;
        }

        private void Update() {
            bool canMove = IsInitialized && m_CController.enabled;

            if (!canMove)
                return;

            float deltaTime = Time.deltaTime;
            bool wasGrounded = m_CController.isGrounded;
            m_Translation = Vector3.zero;

            if (m_MotionInput != null)
                m_MotionInput.Invoke(ref m_SimulatedVelocity, out m_ApplyGravity, out m_SnapToGround);

            if (wasGrounded && m_SnapToGround) {
                // Sliding...
                m_SimulatedVelocity += GetSlidingVelocty(deltaTime);

                // Grounding force...
                m_Translation.y -= GetGroundingTranslation();
            }

            // Apply a gravity force.
            if (m_ApplyGravity)
                m_SimulatedVelocity.y -= m_Gravity * deltaTime;

            m_Translation += m_SimulatedVelocity * deltaTime;

            // Move the controller.
            m_CollisionFlags = m_CController.Move(m_Translation);

            // Rotate player model to movement direction.

            Vector3 characterUp = transform.up;
            Vector3 direction = m_SimulatedVelocity.normalized.projectedOnPlane(characterUp);
            if (direction.sqrMagnitude > float.Epsilon) {
                Quaternion targetRotation = Quaternion.LookRotation(direction, characterUp);
                m_PlayerModel.rotation = Quaternion.Slerp(m_PlayerModel.rotation, targetRotation,
                    m_RotateSpeed * Mathf.Deg2Rad * Time.deltaTime);
            }
            bool isGrounded = m_CController.isGrounded;

            if (wasGrounded != isGrounded) {
                onGroundedStateChanged?.Invoke(isGrounded);
                m_LastGroundedChangeTime = Time.time;

                // Fall Impact
                if (!wasGrounded && isGrounded)
                    onFallImpact?.Invoke(Mathf.Abs(m_SimulatedVelocity.y));
            }

            //Temporary model desync fix
            m_PlayerModel.transform.localPosition = Vector3.zero;
        }

        private float GetGroundingTranslation() {
            // Predict next world position
            var simulatedPosition = transform.position + m_Translation;
            float distanceToGround = 0.001f;

            if (Physics.Raycast(new Ray(transform.position, Vector3.Scale(simulatedPosition, Vector3.down)), out m_RaycastHit, m_CController.stepOffset, m_CollisionMask, QueryTriggerInteraction.Ignore))
                distanceToGround = m_RaycastHit.distance;
            else
                m_ApplyGravity = true;

            return distanceToGround;
        }

        private Vector3 GetSlidingVelocty(float deltaTime) {
            if (GroundSurfaceAngle > m_SlideThreshold) {
                Vector3 slideDirection = m_GroundNormal + Vector3.down;
                m_SlideVelocity += slideDirection * (m_SlideSpeed * deltaTime);
            } else
                m_SlideVelocity = Vector3.Lerp(m_SlideVelocity, Vector3.zero, deltaTime * 10f);

            return m_SlideVelocity;
        }

        private void OnControllerColliderHit(ControllerColliderHit hit) {
            m_GroundNormal = hit.normal;

            if (hit.rigidbody) {
                float forceMagnitude = Velocity.magnitude * m_PushForce;
                Vector3 impactForce = (hit.moveDirection + Vector3.up * 0.35f) * forceMagnitude;
                hit.rigidbody.AddForceAtPosition(impactForce, hit.point);
            }
        }

        public void SetMotionInput(MotionInputCallback motionInput) => m_MotionInput = motionInput;

        public void Teleport(Vector3 position, Quaternion rotation) {
            m_CController.enabled = false;

            rotation = Quaternion.Euler(0f, rotation.eulerAngles.y, 0f);
            transform.SetPositionAndRotation(position, rotation);

            m_SlideVelocity = Vector3.zero;
            m_SimulatedVelocity = Vector3.zero;

            m_CController.enabled = true;

            onTeleport?.Invoke();
        }

        public bool TrySetHeight(float targetHeight) {
            bool canSetHeight = true;

            if (Height < targetHeight)
                canSetHeight = !DoCollisionCheck(true, targetHeight - Height);

            if (canSetHeight) {
                Height = targetHeight;

                return true;
            }

            return false;
        }

        public bool CanSetHeight(float targetHeight) {
            if (Mathf.Abs(Height - targetHeight) < 0.01f)
                return true;

            if (Height < targetHeight)
                return !DoCollisionCheck(true, targetHeight - Height + 0.1f);

            return true;
        }

        public void SetHeight(float height) => Height = height;

        public bool Raycast(Ray ray, float distance) {
            if (Physics.Raycast(ray, out m_RaycastHit, distance, m_CollisionMask, QueryTriggerInteraction.Ignore))
                return true;

            return false;
        }

        public bool Raycast(Ray ray, float distance, out RaycastHit raycastHit) {
            if (Physics.Raycast(ray, out raycastHit, distance, m_CollisionMask, QueryTriggerInteraction.Ignore))
                return true;

            return false;
        }

        public bool SphereCast(Ray ray, float distance, float radius) {
            if (Physics.SphereCast(ray, radius, distance, m_CollisionMask, QueryTriggerInteraction.Ignore))
                return true;

            return false;
        }

        private bool DoCollisionCheck(bool checkAbove, float maxDistance) {
            Vector3 rayOrigin = transform.position + (checkAbove ? Vector3.up * m_CController.height / 2 : Vector3.up * m_CController.height);
            Vector3 rayDirection = checkAbove ? Vector3.up : Vector3.down;

            Debug.DrawLine(rayOrigin, rayDirection * maxDistance, Color.red, 1f);

            return Physics.SphereCast(new Ray(rayOrigin, rayDirection), m_CController.radius, maxDistance, m_CollisionMask, QueryTriggerInteraction.Ignore);
        }

        #region Save & Load
        public void LoadMembers(object[] members) {
            m_SimulatedVelocity = (Vector3)members[0];
            Height = (float)members[1];
        }

        public object[] SaveMembers() {
            return new object[]
            {
                m_SimulatedVelocity,
                Height
            };
        }
        #endregion
    }
}