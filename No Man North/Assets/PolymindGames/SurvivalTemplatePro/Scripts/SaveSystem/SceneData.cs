using System;
using System.Collections.Generic;

namespace SurvivalTemplatePro.SaveSystem
{
	[Serializable]
	public class SceneData
	{
        public string Name;
        public Dictionary<string, SaveableObject.Data> Objects = new Dictionary<string, SaveableObject.Data>();
	}
}