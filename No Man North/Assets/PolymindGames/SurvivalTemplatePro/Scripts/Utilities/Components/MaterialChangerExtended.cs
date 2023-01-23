using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro
{
    public class MaterialChangerExtended : MaterialChanger
    {
        [SpaceArea, SerializeField, ReorderableList]
        private List<Renderer> m_Renderers;


        protected override IList<Renderer> GetAllRenderers() => m_Renderers;

        protected override void SetupMaterials(MaterialChangerInfo info)
        {
            base.SetupMaterials(info);
            m_Renderers.Clear();
        }
    }
}