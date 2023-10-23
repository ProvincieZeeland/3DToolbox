# 3dgeotop

Dit onderdeel van de 3DtoolboxNL richt zich op [GeoTOP (GTM)](https://basisregistratieondergrond.nl/inhoud-bro/registratieobjecten/modellen/geotop-gtm/).

> GeoTOP is een 3D-model dat de ondergrond tot maximaal 50 meter onder NAP in blokken (voxels) van 100 x 100 x 0,5 meter weergeeft. Het model  geeft informatie over de laagopbouw en grondsoort (zand, grind, klei of  veen) van de ondiepe ondergrond van Nederland.

Via het [BROloket](http://www.broloket.nl/) of [PDOK](http://www.pdok.nl/) kan het model als een zip-file gedownload worden.

## gt2pc

Dit onderdeel van 3dgeotop is een converter om vanuit de csv betanden in de GeoTOP download een point cloud conform de 3dtiles standaard te maken. Zo'n point cloud kan vervolgens eenvoudig in Cesium worden getoond.

### Principe van de conversie

`gt2pc` gebruikt [py3dtiles](https://github.com/Oslandia/py3dtiles) voor het construeren van de point cloud in 3dtiles. `py3dtiles` kan helaas niet direct met de GeoTOP `.csv` bestanden uit de voeten. Een aantal zaken moeten aangepast:

- de juiste velden selecteren
- de meest waarschijnlijke lithoklasse omrekenen naar een RGB-waarde
- de meest waarschijnlijke lithoklasse omzetten naar een classificatie
- een verticale overdrijving (x 100) toepassen
- de nodata velden weglaten

 Deze aanpassingen kunnen allemaal uitgevoerd worden in 1 commando:

```bash
ogr2ogr -dialect sqlite \
		-sql "select x,y,z * 100, 1, lut.R, lut.G, lut.B, lut.klasse + 20 FROM sample as sample LEFT JOIN 'lut.csv'.lut as lut ON sample.lithoklasse = lut.klasse" \
		-f "CSV" sample_ready_for_py3dtiles.csv sample.csv 
```

waarbij `lut.csv` een csv bestand is met de volgende inhoud:

```
klasse,R,G,B
0,166,168,172
1,148,65,63
2,46,162,64
3,173,215,80
5,231,231,28
6,231,231,28
7,221,192,31
8,207,155,35
9,47,97,208
10,231,231,28
```

Dit bestand is gebaseerd op https://www.tno.nl/media/1688/productieblad_geotop_modellering.pdf, aangevuld met klasse 9 en 10 opv de kleuren gebruikt in het DINO-loket; resulterend in de volgende tabel:

| Lithoklasse (“categorie”)         | Nummer | R    | G    | B    |
| --------------------------------- | ------ | ---- | ---- | ---- |
| Antropogeen                       | 0      | 166  | 168  | 172  |
| Organisch materiaal (veen)        | 1      | 148  | 65   | 63   |
| Klei                              | 2      | 46   | 162  | 64   |
| Kleiig zand, zandige klei en leem | 3      | 173  | 215  | 80   |
| Fijn zand                         | 5      | 231  | 231  | 28   |
| Midden zand                       | 6      | 231  | 231  | 28   |
| Grof zand                         | 7      | 221  | 192  | 31   |
| Grind                             | 8      | 207  | 155  | 35   |
| Schelpen                          | 9      | 47   | 97   | 208  |
| Zand met onbekende korrelgrootte  | 10     | 231  | 231  | 28   |

Middels het volgende commando wordt de point cloud gemaakt:

```bash
py3dtiles convert -v --srs_in 28992 --srs_out 4978 ./sample_ready_for_py3dtiles.csv
```

Er is een `xonsh` script gemaakt `gt2pc.xsh` om bovenstaande in 1 stap uit te voeren en optioneel nog wat zaken in te stellen als:

- mate van verticale overdrijving
- clippen tov een geometrie of bounding box
- een andere kleurentabel

### `gt2pc.xsh`

`gt2pc.xsh` is een `xonsh` script om bovenstaande eenvoudig uit te voeren. Het heeft een eigen help beschikbaar die getoond wordt door het script uit te voeren zonder argumenten, of met `-h` of met `--help` parameters:

```bash
gt2pc.xsh -h
```

geeft:

```bash
usage: gt2pc [-h] [-v] [--out OUT] [--nodata] [--multiplier MULTIPLIER]
             [--srs_in SRS_IN] [--srs_out SRS_OUT] [--color_table COLOR_TABLE]
             [--clipsrc CLIPSRC] [--clipsrclayer CLIPSRCLAYER]
             file

This converter converts GeoTOP csv files to 3Dtiles.

positional arguments:
  file                  The GeoTOP file to process to convert.

options:
  -h, --help            show this help message and exit
  -v, --verbose         Verbose output (can be very long).
  --out OUT             The folder to store the 3dtiles. Defaults to 3dtiles.
  --nodata              Store nodata values in the 3Dtiles.
  --multiplier MULTIPLIER
                        Z-axis multiplier. Defaults to 100.
  --srs_in SRS_IN       The spatial reference system of the source. Defaults
                        to 28992.
  --srs_out SRS_OUT     The spatial reference system of the destination.
                        Defaults to 4978.
  --color_table COLOR_TABLE
                        Path to a table overriding the RGB values for each
                        litho class.
  --clipsrc CLIPSRC     Clip geometries to one of "xmin ymin xmax ymax"|WKT|datasource. 
  						See: https://gdal.org/programs/ogr2ogr.html#cmdoption-
                        ogr2ogr-clipsrc
  --clipsrclayer CLIPSRCLAYER
                        Select the named layer from the source clip
                        datasource. See:
                        https://gdal.org/programs/ogr2ogr.html#cmdoption-
                        ogr2ogr-clipsrclayer

```

"Normaal gebruik" met default parameters is dan eenvoudig:

```bash
gt2pc.xsh sample.csv
```

Dit geeft een `3dtiles` folder met daarin een 3D tile set met de point cloud met de volgende eigenschappen:

- Spatial reference system EPSG:4978 (geschikt voor Cesium)
- verticale overdrijving: 100x
- Punten zonder data niet opgeslagen
- Kleuren toegekend volgens de standaard kleurentabel
- De intensiteit ingesteld op 1
- De classificatie ingesteld op de meest waarschijnlijke lithoklasse + 20

Bij gebruik van een *boundig box* om te clippen is het correct gebruik van quotes belangrijk; bijvoorbeeld:

```bash
gt2pc.xsh -v --clipsrc "57000 425000 58000 426000" sample.csv
```

### Het gebruik van Docker voor de conversie

Er is een Docker build script (`Dockerfile`) en bijhorende bestanden beschikbaar waarmee bovenstaande gemakkelijk in 1 stap kan worden uitgevoerd, waarbij dan nog verschillende parameters instelbaar zijn.

#### Het bouwen van de container

Na het installeren van Docker kan de container eenvoudig worden gebouwd middels:

```bash
docker build -t 3dgeotop ./3dgeotop
```

Het is vervolgens handig om het shell script `3dgeotop` te plaatsen in het zoekpad en uitvoerbaar te maken. 

#### Het gebruik van de container

##### `gt2pc`

Indien het shell script `3dgeotop` is geplaatst op het zoekpad kan de container worden gebruikt middels een commando als:

```bash
3dgeotop gt2pc -v --clipsrc "57000 425000 58000 426000" sample.csv
```

Eventueel kan de container ook gebruikt worden zonder shell script middels een commando als:

```bash
docker run -u "$UID" -w "$CWD" -v "$CWD":"$CWD" --net host -e PYTHONUNBUFFERED=0 3dgeotop "gt2pc sample.csv"
```

##### `ogr2ogr en py3dtiles`

ogr/gdal en py3dtiles zijn beide beschikbaar in de container. Ze kunnen eenvoudig worden aangeroepen met bijvoorbeeld:

```bash
3dgeotop ogrinfo sample.csv
3dgeotop py3dtiles info ./3dtiles/r4.pnts
```

### Knippen en plakken met point clouds

Point clouds direct gebaseerd op de GeoTOP bestanden kunnen erg groot worden. Het is daarom zinnig om alleen die delen in de point cloud op te nemen die daadwerkelijk nodig zijn. `gt2pc` kan het juiste deel uitsnijden met behulp van  de `--clipsrc` en eventueel de `--clipsrclayer` opties.

Het kan natuurlijk zijn dat het gebied van interesse in meerdere GeoTOP kaartbladen ligt. In dat geval kunnen de volgende werkwijzen worden gevolgd:

-  uitsnijden en samenvoegen met `ogr2ogr` en daarna converteren tot point cloud met `gt2pc`
- uitsnijden en converteren met `gt2pc` en daarna de point clouds samenvoegen met `py3dtiles merge`

### Het gebruik van point clouds in Cesium

Een viewer als Cesium haalt zelf de juiste onderdelen op uit een point cloud. het is dus niet nodig om een speciaal soort server in te richten zoals we dat doen voor WMS- of WFS-services. Het is voldoende om de point cloud ergens op een web server te plaatsen zodat deze bereikbaar is vanaf internet. Daarna kan deze in Cesium ontsloten worden met iets als:

```javascript
Cesium.Cesium3DTileset.fromUrl('https://mijnserver.nl/tiles/3dtiles/tileset.json')
```

