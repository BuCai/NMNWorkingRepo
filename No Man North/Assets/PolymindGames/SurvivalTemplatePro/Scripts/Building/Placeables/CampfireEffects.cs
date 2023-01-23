using UnityEngine;

namespace SurvivalTemplatePro.BuildingSystem
{
    [RequireComponent(typeof(Campfire))]
    public class CampfireEffects : MonoBehaviour
    {
        [SerializeField]
        private GameObject m_Wood;

        [SpaceArea]

        [SerializeField, ReorderableList]
        private ParticleSystem[] m_ParticleEffects;

        [Title("Audio")]

        [SerializeField]
        private AudioClip m_FireLoopSound;

        [SerializeField, Range(0f, 1f)]
        private float m_MinFireVolume = 0.5f;

        [SerializeField]
        private SoundPlayer m_FuelAddAudio;

        [SerializeField]
        private SoundPlayer m_FireExtinguishedAudio;

        [Title("Light")]

        [SerializeField]
        private LightEffect m_LightEffect;

        [SerializeField, Range(0f, 1f)]
        private float m_MinLightIntensity = 0.5f;

        [Title("Material")]

        [SerializeField]
        private Material m_WoodMaterial;

        [SerializeField, Range(0f, 600f)]
        private float m_WoodBurnDuration = 60f;

        private Campfire m_Campfire;
        private AudioSource m_AudioSource;

        private float m_LastFuelAddTime;
        private int m_BurnedAmountShaderId;


        private void Awake()
        {
            m_Campfire = GetComponent<Campfire>();

            m_BurnedAmountShaderId = Shader.PropertyToID("_BurnedAmount");

            CreateAudioSource();
            CreateWoodMaterial();
        }

        private void OnEnable()
        {
            m_Campfire.onFireStarted += OnFireStarted;
            m_Campfire.onFireStopped += OnFireStopped;
            m_Campfire.onFuelAdded += OnFuelAdded;
        }

        private void OnDisable()
        {
            m_Campfire.onFireStarted -= OnFireStarted;
            m_Campfire.onFireStopped -= OnFireStopped;
            m_Campfire.onFuelAdded -= OnFuelAdded;
        }

        private void CreateAudioSource()
        {
            m_AudioSource = gameObject.AddComponent<AudioSource>();
            m_AudioSource.spatialBlend = 1f;
            m_AudioSource.clip = m_FireLoopSound;
            m_AudioSource.loop = true;
            m_AudioSource.volume = 0f;
            m_AudioSource.Play();
        }

        private void CreateWoodMaterial()
        {
            // Create material
            m_WoodMaterial = new Material(m_WoodMaterial);
            m_WoodMaterial.name += "_Instance";
            m_WoodMaterial.SetFloat(m_BurnedAmountShaderId, 0f);

            // Assign it
            var renderers = m_Wood.GetComponentsInChildren<Renderer>(true);

            foreach (var renderer in renderers)
                renderer.material = m_WoodMaterial;
        }

        private void Update()
        {
            if (m_Campfire.FireActive)
            {
                m_AudioSource.volume = Mathf.Lerp(m_AudioSource.volume, Mathf.Max(m_Campfire.TemperatureStrength, m_MinFireVolume), Time.deltaTime * 1f);

                // Shader effects
                float burnedAmount = (Time.time - m_LastFuelAddTime) / m_WoodBurnDuration;
                burnedAmount = Mathf.Clamp01(burnedAmount);
                m_WoodMaterial.SetFloat("_BurnedAmount", burnedAmount);

                m_LightEffect.IntensityMultiplier = Mathf.Max(m_MinLightIntensity, m_Campfire.TemperatureStrength);
            }
            else
                m_AudioSource.volume = Mathf.Lerp(m_AudioSource.volume, 0f, Time.deltaTime * 1f);
        }

        private void OnFireStarted()
        {
            foreach (var effect in m_ParticleEffects)
                effect.Play(true);

            m_Wood.SetActive(true);
            m_LightEffect.Play(true);
        }

        private void OnFireStopped()
        {
            foreach(var effect in m_ParticleEffects)
                effect.Stop(true);

            m_FireExtinguishedAudio.Play2D();
            m_LightEffect.Stop(true);
        }

        private void OnFuelAdded(float fuelDuration)
        {
            m_FuelAddAudio.Play(m_AudioSource);
            m_LastFuelAddTime = Time.time;
        }
    }
}