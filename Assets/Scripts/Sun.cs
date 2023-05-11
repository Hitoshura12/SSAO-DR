using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Taka
{
   [ExecuteAlways,RequireComponent(typeof(Light))]
   public class Sun : MonoBehaviour
   {
      #region VarDeclarations

      public const string SUN_DIRECTION = "_SunDirection";
      public const string LIGHT_COLOR = "_GlobalLightColor";
      public const string SCREEN_SPACE_SHADOWS = "_GlobalScreenSpaceShadows";

      private static Sun instance;
      private static List<Sun> suns= new List<Sun>();
      private static Color lightColor;
      #endregion

      #region Properties

      public static bool Ready =>  Instance && instance.isActiveAndEnabled;

      public static Sun Instance
      {
         get => instance;
         set
         {
            if (instance!=value)
            {
               if(instance)instance.SetInactive();
               instance = value;
               if(instance)instance.SetActive();
            }
         } 
      }

      public static Color LightColor
      {
         get => lightColor;
         set
         {
            if (Ready && instance.GetComponent<Light>()!=null&& lightColor!=value)
            {
               lightColor = instance.GetComponent<Light>().color=value;
               Shader.SetGlobalColor(LIGHT_COLOR,value);
            } 
         }  
      }

      public static Vector3 Direction
      {
         get => Ready ? Instance.transform.forward :
            RenderSettings.sun ? RenderSettings.sun.transform.forward :
            Vector3.zero;
         private set => Shader.SetGlobalVector(SUN_DIRECTION, value);
      }

      public LightBuffer[] buffers = new LightBuffer[]
      {
         new LightBuffer()
         {
            lightEvent = LightEvent.AfterScreenspaceMask,
            name = "Screen Space Shadows",
            texProperty = SCREEN_SPACE_SHADOWS
         }
      };

       private new Light light;
      #endregion

      #region Methods

      private void OnEnable()
      {
         if (!Instance) Instance = this;
         if(!suns.Contains(this)) suns.Add(this);
         
      }

      private void OnDisable()
      {
         if (suns.Contains(this)) suns.Remove(this);
         if (Instance == this) Instance = suns.Find(s => s != this && s.isActiveAndEnabled);
      }

      private void OnDestroy()
      {
         foreach (LightBuffer buffer in buffers)
         {
            buffer.Release();
         }
      }

      private void LateUpdate()
      {
         if (Instance == this)
         {
            LightColor = this.light.color;
            if (transform.hasChanged)
            {
               Direction = transform.forward;
               transform.hasChanged = false;
            }
         }
      }

      public static implicit operator Vector3(Sun sun)
      {
         return sun.transform.forward;
      }

      private void SetActive()
      {
         if (!light) light = GetComponent<Light>();
         if (light)
         {
            LightColor = light.color;
            light.enabled = true;
            foreach (LightBuffer buffer in buffers)
            {
               buffer.Add(light);
            }
         }

         Direction = transform.forward;
      }

      private void SetInactive()
      {
         foreach (LightBuffer buffer in buffers)
         {
            LightColor=Color.white;
            Direction= Vector3.zero;
         }
      }
      #endregion
   }
}