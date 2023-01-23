using UnityEngine;

namespace SurvivalTemplatePro
{
    public interface ICharacterBehaviour
    {
        /// <summary>
        /// Initialize this behaviour.
        /// </summary>
        void InititalizeBehaviour(ICharacter character);


        #region Monobehaviour
        GameObject gameObject { get; }
        Transform transform { get; }
        #endregion
    }
}