using UnityEngine.Events;

namespace SurvivalTemplatePro.CompanionSystem
{
    public enum ActionType
    {
        Follow,
        Stay,
        LieLow,
        Camp,
        Cook
    }

    public interface IAction
    {
        string Name { get; }
        string Description { get; }
        int Id { get; }
        ActionType Type { get; }
        bool Active { get; set; }
        ICompanion Companion { get; set; }

        void Activate();
    }
}