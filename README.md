# 3DtoolboxNL

Het project 3DtoolboxNL is gericht op het beschikbaar maken van open source tooling voor het werken met 3D informatie in met name Cesium, in de Nederlandse context.

In dit project wordt niet alleen tooling ontwikkeld en beschikbaar gesteld, maar ook uitgebreid gedocumenteerd, zodat het gemakkelijk wordt om aan de slag te gaan.

Beschikbaar zijn:

- gt2pc: Een converter voor GeoTOP naar pointcloud in 3dtiles
- Cesium Terrain Builder om een "quantized mesh" terreinmodel te maken als ondergrond in Cesium.
- Cesium Terrain Server om een "quantized mesh" terreinmodel te serveren voor gebruik in Cesium.

## 3dgeotop

### gt2pc

Deze converter converteert de lithoklassen uit het GeoTop Voxel model naar een 3dtiles point cloud. De converter is geheel gebruiksklaar opgezet middels een Docker build script. Het is ook mogelijk een en ander te installeren en buiten Docker te gebruiken.

Documentatie is [hier](3dgeotop) te vinden.

## Cesium Terrain Builder

De Cesium Terrain Builder is een bestaande tool  om een "quantized mesh" terreinmodel te maken als ondergrond in Cesium. De tool is ontsloten als Docker container. 3DtoolboxNL voegt alleen wat documentatie toe. 

Deze documentatie is hier te vinden.

## Cesium Terrain Server

Cesium Terrain Server kan onder meer een "quantized mesh" terrein model uitserveren voor gebruik in Cesium. Dit is bestaande tooling. 3DtoolboxNL voegt alleen wat documentatie toe. 

Deze documentatie is hier te vinden.