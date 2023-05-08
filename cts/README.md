# Cesium Terrain Server

De cesium 3D viewer heeft altijd een digitaal terreinmodel (ook wel  hoogtemodel) nodig om te kunnen werken als 3D viewer. Dit terreinmodel zorgt ervoor dat Cesium weet de "ground" is. Dit is nodig om 3D modellen te kunnen plaatsen, maar ook om gegevenslagen als point clouds op de juiste plaats "op te hangen".

Voor Cesium is er voor de hele wereld een terreinmodel beschikbaar. Soms voldoet dit niet of is een ander, meer gedetailleerd, terreinmodel nodig. Zo'n terreinmodel moet daarvoor in het juiste formaat en op de juiste manier geserveerd worden, bijvoorbeeld met de Cesium Terrain Server.

De Cesium Terrain Server maakt gebruik van een terrein model, liefst in een ["quantized mesh"](https://github.com/CesiumGS/quantized-mesh) vorm in verband met performance. Met behulp van de [Cesium Terrain Builder](https://github.com/geo-data/cesium-terrain-builder) kan zo'n "quantized mesh" terreinmodel afgeleid worden van bijvoorbeeld een raster als AHN.  Meer uitleg daarover [staat hier](../ctb).

De Cesium Terrain Server is een enkele executable geschreven in GO. Na het installeren van GO is het installeren van deze server dan ook eenvoudig. Er is ook een Docker container beschikbaar.

Een en ander staat hier helder en duidelijk uitgelegd: https://github.com/geo-data/cesium-terrain-server .

