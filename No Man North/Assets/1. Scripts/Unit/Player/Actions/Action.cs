using System;
using UnityEngine;

namespace SurvivalTemplatePro.CompanionSystem
{
    /// <summary>
    /// 
    /// </summary>
    [Serializable]
	public class Action : IAction
	{
		public string Name => name;
		public string Description => description;
		public int Id => id;
		public ActionType Type => type;
		public bool Active { get; set; }
		public ICompanion Companion { get; set; }

		[SerializeField] private string name;
		[SerializeField] private string description;
		private int id = UnityEngine.Random.Range(0, int.MaxValue);
		[SerializeField] private ActionType type;
		
		public static implicit operator bool(Action action) => action != null;

		/// <summary>
		/// 
		/// </summary>
		public Action(string name, ActionType type)
		{
			this.name = name;
			id = UnityEngine.Random.Range(0, int.MaxValue);
			this.type = type;
		}

		public void Activate()
		{
			// FIXME: There has to be a prettier way to do this.
			
			// Reset active actions and set the current one to active
			foreach (var action in Companion.Actions)
				action.Active = false;
			Active = true;
			HitchhikerCompanion hitchhikerCompanion = Companion as HitchhikerCompanion;
			DogCompanion dogCompanion = Companion as DogCompanion;
			
			switch (type)
			{
				case ActionType.Stay:
					Companion.Stay();
					break;
				case ActionType.Follow:
					Companion.Follow();
					break;
				case ActionType.LieLow:
					if (hitchhikerCompanion)
						hitchhikerCompanion.LieLow();
					break;
				case ActionType.Camp:
					if (hitchhikerCompanion)
						hitchhikerCompanion.SetupCamp();
					break;
				case ActionType.Cook:
					if (hitchhikerCompanion)
						hitchhikerCompanion.Cook();
					break;
				default:
					throw new ArgumentOutOfRangeException();
			}
		}
		
	}
}