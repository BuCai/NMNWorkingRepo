using System;
using UnityEngine;

namespace SurvivalTemplatePro {
    [Serializable]
    public class SoundPlayer {
        [SerializeField, Reorderable]
        private AudioClipList m_Clips;

        [SerializeField, Range(0f, 2f)]
        private float m_Volume = 0.65f;

        [SerializeField, Range(0f, 2f)]
        private float m_Pitch = 1f;

        [SerializeField, Range(0f, 0.5f)]
        private float m_VolumeJitter = 0.1f;

        [SerializeField, Range(0f, 0.5f)]
        private float m_PitchJitter = 0.1f;

        private int m_LastClipPlayed = -1;


        public void Play(AudioSource audioSource, float volumeFactor = 1f, SelectionType selectionMethod = SelectionType.RandomExcludeLast) {
            if (!audioSource || m_Clips.Length == 0)
                return;

            if (m_LastClipPlayed >= m_Clips.Length)
                m_LastClipPlayed = m_Clips.Length - 1;

            AudioClip clipToPlay = m_Clips.Array.Select(ref m_LastClipPlayed, selectionMethod);

            var volume = m_Volume.Jitter(m_VolumeJitter) * volumeFactor;
            audioSource.pitch = m_Pitch.Jitter(m_PitchJitter);

            audioSource.PlayOneShot(clipToPlay, volume);
        }

        public void Adjust(AudioClip[] clipList, float volume = 0.5f, float pitch = 1f) {
            m_Clips.Clear();
            for (int i = 0; i < clipList.Length; i++)
                m_Clips.Add(clipList[i]);

            m_Volume = volume;
            m_Pitch = pitch;
        }

        public void Adjust(AudioClipList clipList, float volume = 0.5f, float pitch = 1f) {
            m_Clips = clipList;

            m_Volume = volume;
            m_Pitch = pitch;
        }

        /// <summary>
        /// Will use the AudioSource.PlayClipAtPoint() method, which doesn't include pitch variation.
        /// </summary>
        public void PlayAtPosition(Vector3 position, float volumeFactor = 1f, SelectionType selectionMethod = SelectionType.RandomExcludeLast) {
            if (m_Clips.Length == 0)
                return;

            AudioClip clipToPlay = m_Clips.Array.Select(ref m_LastClipPlayed, selectionMethod);

            if (clipToPlay != null)
                AudioSource.PlayClipAtPoint(clipToPlay, position, m_Volume.Jitter(m_VolumeJitter) * volumeFactor);
        }

        public void Play2D(float volumeFactor = 1f, SelectionType selectionMethod = SelectionType.RandomExcludeLast) {
            if (m_Clips.Length == 0)
                return;

            AudioClip clipToPlay = m_Clips.Array.Select(ref m_LastClipPlayed, selectionMethod);
            AudioManager.Instance.Play2D(clipToPlay, m_Volume.Jitter(m_VolumeJitter) * volumeFactor);
        }
    }
}