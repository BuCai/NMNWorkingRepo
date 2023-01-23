using UnityEngine;

namespace SurvivalTemplatePro
{
    public interface ICharacterModule
    {
        #region Monobehaviour
        GameObject gameObject { get; }
        Transform transform { get; }
        #endregion
    }
}