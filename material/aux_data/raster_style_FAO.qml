<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="2.18.6" minimumScale="inf" maximumScale="1e+08" hasScaleBasedVisibilityFlag="0">
  <pipe>
    <rasterrenderer opacity="1" alphaBand="-1" classificationMax="8" classificationMinMaxOrigin="CumulativeCutFullExtentEstimated" band="1" classificationMin="0" type="singlebandpseudocolor">
      <rasterTransparency/>
      <rastershader>
        <colorrampshader colorRampType="DISCRETE" clip="0">
	  <item alpha="255" value="0" label="Sin clase" color="#000000"/>
          <item alpha="255" value="1" label="Áreas terrestres cultivadas y manejada" color="#b2df8a"/>
          <item alpha="255" value="2" label="Vegetación natural y semi-natural" color="#33a02c"/>
          <item alpha="255" value="3" label="Áreas acuáticas o regularmente inundadas cultivadas" color="#fdbf6f"/>
          <item alpha="255" value="4" label="Vegetación natural y semi-natural acuática o regularmente inundadas" color="#ff7f00"/>
          <item alpha="255" value="5" label="Superficies artificiales y áreas asociadas" color="#fb9a99"/>
          <item alpha="255" value="6" label="Áreas descubiertas o desnudas" color="#e31a1c"/>
          <item alpha="255" value="7" label="Cuerpos artificiales de agua, nieve y hielo" color="#a6cee3"/>
          <item alpha="255" value="8" label="Cuerpos naturales de agua, nieve y hielo" color="#1f78b4"/>
        </colorrampshader>
      </rastershader>
    </rasterrenderer>
    <brightnesscontrast brightness="0" contrast="0"/>
    <huesaturation colorizeGreen="128" colorizeOn="0" colorizeRed="255" colorizeBlue="128" grayscaleMode="0" saturation="0" colorizeStrength="100"/>
    <rasterresampler maxOversampling="2"/>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
