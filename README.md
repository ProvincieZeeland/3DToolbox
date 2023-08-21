# 3DtoolboxNL

Het project 3DtoolboxNL is gericht op het beschikbaar maken van open source tooling voor het werken met 3D informatie in met name Cesium, in de Nederlandse context.

In dit project wordt niet alleen tooling ontwikkeld en beschikbaar gesteld, maar ook uitgebreid gedocumenteerd, zodat het gemakkelijk wordt om aan de slag te gaan.

Beschikbaar zijn:

- 3dgeotop: Tools voor het werken met GeoTOP.
- 3dfreshem: Tools voor het werken met freshem data
- Cesium Terrain Builder om een "quantized mesh" terreinmodel te maken als ondergrond in Cesium.
- Cesium Terrain Server om een "quantized mesh" terreinmodel te serveren voor gebruik in Cesium.

## 3dgeotop

Dit onderdeel van de 3DtoolboxNL richt zich op [GeoTOP (GTM)](https://basisregistratieondergrond.nl/inhoud-bro/registratieobjecten/modellen/geotop-gtm/). Als eerste is er `gt2pc` beschikbaar gekomen.

Documentatie is [hier](3dgeotop) te vinden.

## 3dfreshem
Dit onderdeel van de 3DtoolboxNL richt zich op FRESHEM data. Meer info over deze dataset en een download is te vinden op: https://dataportaal.zeeland.nl/dataportaal/srv/dut/catalog.search#/metadata/5910b6c9-4020-4763-9586-abbf4a891d36

Documentatie is [hier](3dfreshem) te vinden.

### gt2pc

Deze converter converteert de lithoklassen uit het GeoTop Voxel model naar een 3dtiles point cloud. De converter is geheel gebruiksklaar opgezet middels een Docker build script. Het is ook mogelijk een en ander te installeren en buiten Docker te gebruiken.

## Cesium Terrain Builder

De Cesium Terrain Builder is een bestaande tool  om een "quantized mesh" terreinmodel te maken als ondergrond in Cesium. De tool is ontsloten als Docker container. 3DtoolboxNL voegt alleen wat documentatie toe. 

Deze documentatie is [hier](./ctb) te vinden.

## Cesium Terrain Server

Cesium Terrain Server kan onder meer een "quantized mesh" terrein model uitserveren voor gebruik in Cesium. Dit is bestaande tooling. 3DtoolboxNL voegt alleen wat documentatie toe. 

Deze documentatie is [hier](./cts) te vinden.
