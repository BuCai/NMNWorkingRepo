using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class WorldColdLisener : MonoBehaviour
    {
        #region Variables
        protected bool isInFrostWall = false;

        private List<heatSource> heatSources = new List<heatSource>();

        #endregion

        #region Unity Methods

        #endregion

        #region Methods

        public virtual void inFrostWall(float frostWallDamage)
        {
            
        }

        public void enteredFrostWall()
        {
            isInFrostWall = true;
        }

        public void leftFrostWall()
        {
            isInFrostWall = false;
        }

        public void enterHeatSoruce(heatSource heat)
        {
            heatSources.Add(heat);
            
        }

        public void exitHeatSource(heatSource heat)
        {
            if (heatSources.Contains(heat))
            {
                heatSources.Remove(heat);
            }
        }

        protected bool isInHeatedArea()
        {
            
            if (heatSources.Count > 0)
            {
                return true;
            }
            return false;
        }

        #endregion
    }
}