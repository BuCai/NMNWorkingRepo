using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace SurvivalTemplatePro.Surfaces
{
    [Serializable, CreateAssetMenu(menuName = "Survival Template Pro/Surfaces/Surface Info")]
	public class SurfaceInfo : ScriptableObject
	{
		#region Internal
		[Serializable]
		public class EffectPair
		{
			public SoundPlayer AudioEffect;
			public GameObject VisualEffect;
		}
		#endregion

		[SpaceArea, ReorderableList(elementLabel: "Material", Foldable = true)]
		public Material[] RegisteredMaterials;

		[SpaceArea, ReorderableList(elementLabel: "Layer", Foldable = true)]
		public TerrainLayer[] RegisteredTerrainLayers;

		[IndentArea, SpaceArea]
		public EffectPair SoftFootstepEffect;

		[IndentArea, Line(1f)]
		public EffectPair HardFootstepEffect;

		[IndentArea, Line(1f)]
		public EffectPair FallImpactEffect;

		[IndentArea, Line(1f)]
		public EffectPair BulletHitEffect;

		[IndentArea, Line(1f)]
		public EffectPair SlashEffect;

		[IndentArea, Line(1f)]
		public EffectPair StabEffect;

		private HashSet<Material> m_CachedMaterials = new HashSet<Material>();


		public void CacheTextures()
		{
			m_CachedMaterials = new HashSet<Material>();

			foreach (Material mat in RegisteredMaterials)
				m_CachedMaterials.Add(mat);
		}

		public bool HasMaterial(Material material) => m_CachedMaterials.Contains(material);

		public bool HasTerrainLayer(TerrainLayer layer)
		{
            for (int i = 0; i < RegisteredTerrainLayers.Length; i++)
            {
				if (RegisteredTerrainLayers[i] == layer)
					return true;
			}

			return false;
		}

#if UNITY_EDITOR
        private void OnValidate()
        {
			RegisteredMaterials = RegisteredMaterials.Distinct().ToArray();
			RegisteredTerrainLayers = RegisteredTerrainLayers.Distinct().ToArray();
		}
#endif
    }
}