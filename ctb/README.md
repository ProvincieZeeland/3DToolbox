# Cesium Terrain Builder

De cesium 3D viewer heeft altijd een digitaal terreinmodel (ook wel  hoogtemodel) nodig om te kunnen werken als 3D viewer. Dit terreinmodel zorgt ervoor dat Cesium weet de "ground" is. Dit is nodig om 3D modellen te kunnen plaatsen, maar ook om gegevenslagen als point clouds op de juiste plaats "op te hangen".

Voor Cesium is er voor de hele wereld een terreinmodel beschikbaar. Soms voldoet dit niet of is een ander, meer gedetailleerd, terreinmodel nodig. Zo'n terreinmodel moet daarvoor in het juiste formaat en op de juiste manier geserveerd worden, bijvoorbeeld met de Cesium Terrain Server (meer uitleg daarover [staat hier](../cts).)

De Cesium Terrain Server maakt gebruik van een terrein model, liefst in een ["quantized mesh"](https://github.com/CesiumGS/quantized-mesh) vorm in verband met performance. Met behulp van de [Cesium Terrain Builder](https://github.com/geo-data/cesium-terrain-builder) kan zo'n "quantized mesh" terreinmodel afgeleid worden van bijvoorbeeld een raster als AHN.  In [dit artikel](https://www.linkedin.com/pulse/fast-cesium-terrain-rendering-new-quantized-mesh-output-alvaro-huarte/) wordt op een leesbare manier wat meer achtergrond gegeven.

De [Cesium Terrain Builder](https://github.com/geo-data/cesium-terrain-builder) is al een vrij oude bestaande tool. Het is vrij lastig om deze geïnstalleerd te krijgen, maar gelukkig is deze nu ook als Docker container beschikbaar op [Docker hub](https://hub.docker.com/r/tumgis/ctb-quantized-mesh). Op deze pagina staat ook alle info om de container te gebruiken. 

### tl;dr;


```bash
docker pull tumgis/ctb-quantized-mesh:latest
docker run -it -v $(pwd):/data tumgis/ctb-quantized-mesh ctb-tile -f Mesh -C -o /data/tiles_t1 /data/T1_3857.tif
docker run -it -v $(pwd):/data tumgis/ctb-quantized-mesh ctb-tile -l -f Mesh -C -o /data/tiles_t1 /data/T1_3857.tif
```

### AHN4 naar terreinmodel

Bert Temme heeft beschreven hoe je op deze manier van een AHN4 Geotiff een terrein model kunt maken: https://github.com/bertt/cesium_terrain

# Alternatieven

https://pypi.org/project/quantized-mesh-encoder/

https://github.com/loicgasser/quantized-mesh-tile