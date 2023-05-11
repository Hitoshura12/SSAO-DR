using UnityEditor;

namespace Editor
{
   [InitializeOnLoad]
   public static class EditorShaderSettings 
   {
      static EditorShaderSettings()
      {
         ShaderGlobals.SetDefaults();
      }
   }
}
