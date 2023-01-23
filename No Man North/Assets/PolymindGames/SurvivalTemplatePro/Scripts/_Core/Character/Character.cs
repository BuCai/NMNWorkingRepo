using System;
using System.Collections.Generic;
using SurvivalTemplatePro.CompanionSystem;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    /// <summary>
    /// Main character class used by every entity in the game.
    /// It acts as a hub for accessing modules.
    /// </summary>
    public class Character : MonoBehaviour, ICharacter
    {
        public bool IsInitialized { get; private set; }

        public Transform ViewTransform => m_View;
        public Collider[] Colliders { get; private set; }
        public CharacterFaction Faction => m_Faction;

        public IAudioPlayer AudioPlayer { get; private set; }
        public IHealthManager HealthManager { get; private set; }
        public IInventory Inventory { get; private set; }
        public IActions Actions { get; private set; }

        /// <summary>
        /// This message will be sent after all modules are created and initialized.
        /// </summary>
        public event UnityAction onInitialized;

        [SerializeField]
        [Tooltip("The view transform, you can think of it as the eyes of the character")]
        private Transform m_View;

        [SerializeField]
        private CharacterFaction m_Faction;

        private List<ICharacterBehaviour> m_Behaviours;
        private Dictionary<Type, ICharacterModule> m_ModulesByType;


        /// <summary>
        /// <para> Returns child module of specified type from this character. </para>
        /// Use this if you are NOT sure this character has a module of the given type.
        /// </summary>
        public bool TryGetModule<T>(out T module) where T : ICharacterModule
        {
            if (m_ModulesByType != null && m_ModulesByType.TryGetValue(typeof(T), out ICharacterModule charModule))
            {
                module = (T)charModule;
                return true;
            }
            else
            {
                module = default;
                return false;
            }
        }

        /// <summary>
        /// <para> Returns child module of specified type from this character. </para>
        /// Use this if you ARE sure this character has a module of the given type.
        /// </summary>
        public void GetModule<T>(out T module) where T : ICharacterModule
        {
            if (m_ModulesByType != null && m_ModulesByType.TryGetValue(typeof(T), out ICharacterModule charModule))
            {
                module = (T)charModule;
                return;
            }

            module = default;
        }

        /// <summary>
        /// <para> Returns child module of specified type from this character. </para>
        /// Use this if you ARE sure this character has a module of the given type.
        /// </summary>
        public T GetModule<T>() where T : ICharacterModule
        {
            if (m_ModulesByType != null && m_ModulesByType.TryGetValue(typeof(T), out ICharacterModule charModule))
                return (T)charModule;

            return default;
        }

        /// <summary>
        /// Returns true if the passed collider is part of this character.
        /// </summary>
        public bool HasCollider(Collider collider)
        {
            for (int i = 0; i < Colliders.Length; i++)
            {
                if (Colliders[i] == collider)
                    return true;
            }

            return false;
        }

        protected virtual void Awake()
        {
            SetupModules();
            SetupBaseReferences();

            SetupBehaviours();
        }

        protected virtual void Start()
        {
            SetupSubBehaviours();

            IsInitialized = true;
            onInitialized?.Invoke();
        }

        protected virtual void SetupBehaviours()
        {
            m_Behaviours = new List<ICharacterBehaviour>();

            // Find all of the behaviours
            m_Behaviours.AddRange(GetComponentsInChildren<ICharacterBehaviour>(true));

            // Setup the behaviours
            foreach (var behaviour in m_Behaviours)
                behaviour.InititalizeBehaviour(this);
        }

        protected virtual void SetupSubBehaviours()
        {
            // Initialize the module instantiated behaviours
            foreach (var module in m_ModulesByType.Values)
            {
                foreach (var behaviour in module.gameObject.GetComponentsInChildren<ICharacterBehaviour>(true))
                {
                    if (!m_Behaviours.Contains(behaviour))
                    {
                        behaviour.InititalizeBehaviour(this);
                        m_Behaviours.Add(behaviour);
                    }
                }
            }
        }

        protected virtual void SetupModules()
        {
            // Find & Setup all of the Modules
            foreach (var module in GetComponentsInChildren<ICharacterModule>(true))
            {
                var moduleType = typeof(ICharacterModule);

                foreach (var interfaceType in module.GetType().GetInterfaces())
                {
                    if (interfaceType.GetInterface(moduleType.Name) != null)
                    {
                        if (m_ModulesByType == null)
                            m_ModulesByType = new Dictionary<Type, ICharacterModule>();

                        if (!m_ModulesByType.ContainsKey(interfaceType))
                            m_ModulesByType.Add(interfaceType, module);
                    }
                }
            }
        }

        protected virtual void SetupBaseReferences()
        {
            AudioPlayer = GetModule<IAudioPlayer>();
            HealthManager = GetModule<IHealthManager>();
            Inventory = GetModule<IInventory>();
            Actions = GetModule<IActions>();

            Colliders = GetComponentsInChildren<Collider>(true);
        }

#if UNITY_EDITOR
        protected virtual void OnValidate() 
        {
            int characterLayer = LayerMask.NameToLayer("Character");

            if (gameObject.layer != characterLayer)
                gameObject.layer = characterLayer;
        }
#endif
    }
}
