using System.Collections;
using System.Collections.Generic;
using SurvivalTemplatePro;
using SurvivalTemplatePro.CompanionSystem;
using UnityEngine;

public interface ICompanion
{
    string Name { get; }
    bool IsActive { get; }
    bool IsStaying { get; }
    bool IsInVan { get; }
    ICharacter Player { get; }
    
    Action[] Actions { get; }

    Transform PlayerPosition => Player.transform;
    

    void SetActive(ICharacter player);
    void Stay();
    void Follow();
    void ForgetAboutPlayer();
    void GetInTheVan(Transform seat);
    void GetOutOfTheVan();
}