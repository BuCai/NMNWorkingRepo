using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public interface ICharacter
    {
        bool IsInitialized { get; }

        Transform ViewTransform { get; }
        Collider[] Colliders { get; }

        CharacterFaction Faction { get; }

        IAudioPlayer AudioPlayer { get; }
        IHealthManager HealthManager { get; }
        IInventory Inventory { get; }
        IActions Actions { get; }

        event UnityAction onInitialized;


        bool TryGetModule<T>(out T module) where T : ICharacterModule;
        void GetModule<T>(out T module) where T : ICharacterModule;
        T GetModule<T>() where T : ICharacterModule;
        bool HasCollider(Collider collider);

        #region Monobehaviour
        GameObject gameObject { get; }
        Transform transform { get; }
        #endregion
    }
}