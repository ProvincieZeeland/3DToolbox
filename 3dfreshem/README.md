# 3dfreshem

Dit onderdeel van de 3DtoolboxNL richt zich op FRESHEM data. Meer info over deze dataset en een download is te vinden op: https://dataportaal.zeeland.nl/dataportaal/srv/dut/catalog.search#/metadata/5910b6c9-4020-4763-9586-abbf4a891d36

> Dit bestand bevat de drie dimensionale verdeling van de  chlorideconcentratie van het grondwater met een horizontale resolutie  van 50*50 m2 en een verticale resolutie van 0.5 m.

## Bestandsopbouw

De 3D data bestaat uit 1 groot `.csv` bestand, waarvan de eerste regels er als volgt uit zien:

```
SN+ Sample Number (READONLY)+,XG+ Gravity Center+,YG+ Gravity Center+,ZG+ Gravity Center+,chloride_klassen{laag},chloride_klassen{midden},chloride_klassen{hoog}
2527852,13775.00,370825.00,-40.25,0,0,0
2527853,13775.00,370825.00,-39.75,0,0,0
2527854,13775.00,370825.00,-39.25,0,0,0
2527855,13775.00,370825.00,-38.75,0,0,0
2527856,13775.00,370825.00,-38.25,0,0,0
2527857,13775.00,370825.00,-37.75,0,0,300
2527858,13775.00,370825.00,-37.25,0,0,500
2527859,13775.00,370825.00,-36.75,0,0,500
```

De kolommen zijn:

- `SN+ Sample Number (READONLY)+`: Sample nummer
- `XG+ Gravity Center+`: x coördinaat van het middelpunt van het voxel (in RD)
- `YG+ Gravity Center+`: y coördinaat van het middelpunt van het voxel (in RD)
- `ZG+ Gravity Center+`: z coördinaat van het middelpunt van het voxel (t.o.v. NAP)
- `chloride_klassen{laag}`: chloride concentratie (mg/l) volgens model scenario "laag"
- `chloride_klassen{midden}`: chloride concentratie (mg/l) volgens model scenario "midden"
- `chloride_klassen{hoog}`: chloride concentratie (mg/l) volgens model scenario "hoog"

**Let op**: door de kolomnamen met bijzondere tekens als `+ { }` is deze data niet eenvoudig direct met tools als gdal/ogr te benaderen. Het juist gebruik van enkele en dubbele quotes is essentieel.

Om gebruik gemakkelijker te maken is er ook een `.vrt` bestand beschikbaar dat het direct gebruik in ogr/gdal of zelfs QGIS gemakkelijker maakt. Dit bestand heeft de volgende inhoud:

```xml
<OGRVRTDataSource> 
    <OGRVRTLayer name="chloride_klassen"> 
        <SrcDataSource>sample.csv</SrcDataSource> 
        <GeometryType>wkbPoint</GeometryType> 
        <LayerSRS>EPSG:28992</LayerSRS> 
        <GeometryField encoding="PointFromColumns" x="XG+ Gravity Center+" y="YG+ Gravity Center+" "z"="ZG+ Gravity Center+"/> 
        <Field name="sample" src="SN+ Sample Number (READONLY)+" type="Integer" />   
        <Field name="laag" src="chloride_klassen{laag}" type="Real" />
        <Field name="midden" src="chloride_klassen{midden}" type="Real" />
        <Field name="hoog" src="chloride_klassen{hoog}" type="Real" />
    </OGRVRTLayer> 
</OGRVRTDataSource>
```

**Let op**: de bestandsnaam van het in te lezen `.csv` bestand is hierin opgenomen. 

## freshem2pc

Dit onderdeel van 3dfreshem is een converter om vanuit de csv betanden in de freshem download een point cloud conform de 3dtiles standaard te maken. Zo'n point cloud kan vervolgens eenvoudig in Cesium worden getoond.

### Principe van de conversie

`freshem2pc` gebruikt [py3dtiles](https://github.com/Oslandia/py3dtiles) voor het construeren van de point cloud in 3dtiles. `py3dtiles` kan helaas niet direct met de FRESHEM `.csv` bestanden uit de voeten. Een aantal zaken moeten aangepast:

- de juiste velden selecteren
- de saliniteit omrekenen naar een RGB-waarde
- een verticale overdrijving (x 100) toepassen
- de kopregel met veldnamen weglaten

 Deze aanpassingen kunnen allemaal uitgevoerd worden in 1 commando:

```bash
ogr2ogr -a_srs EPSG:28992 -oo AUTODETECT_TYPE=YES \
		-oo "X_POSSIBLE_NAMES=XG+ Gravity Center+" \
        -oo "Y_POSSIBLE_NAMES=YG+ Gravity Center+" \
        -oo "Z_POSSIBLE_NAMES=ZG+ Gravity Center+" \
        -dialect sqlite \
        -sql 'select "XG+ Gravity Center+","YG+ Gravity Center+","ZG+ Gravity Center+" * 100, lut.R, lut.G, lut.B FROM sample as sample JOIN "/home/lut.csv".lut as lut ON "chloride_klassen{midden}" = lut.klasse ' \
        -f CSV /vsistdout/ sample.csv -lco SEPARATOR=SPACE -lco STRING_QUOTING=IF_NEEDED \
        | tail -n +2 >sample.xyz
```

waarbij `lut.csv` een csv bestand is met de volgende inhoud:

```
klasse,R,G,B
0,0,0,127
150,0,0,250
300,0,88,255
500,0,196,255
750,30,226,221
1000,60,255,186
1250,104,255,143
1500,147,255,99
2000,190,255,56
3000,233,254,12
5000,255,159,0
7500,255,134,0
10000,255,109,0
15000,182,0,0
```

Deze kleuren komen overeen met de kleuren in de [FRESHEM viewer](https://kaarten.zeeland.nl/map/freshem).

Middels het volgende commando wordt de point cloud gemaakt:

```bash
py3dtiles convert -v --srs_in 28992 --srs_out 4978 ./sample.xyz 
```

Er is een `xonsh` script gemaakt `freshem2pc.xsh` om bovenstaande in 1 stap uit te voeren en optioneel nog wat zaken in te stellen als:

- mate van verticale overdrijving
- clippen tov een geometrie of bounding box
- een andere kleurentabel

### `freshem2pc.xsh`

`freshem2pc.xsh` is een `xonsh` script om bovenstaande eenvoudig uit te voeren. Het heeft een eigen help beschikbaar die getoond wordt door het script uit te voeren zonder argumenten, of met `-h` of met `--help` parameters:

```bash
freshem2pc.xsh -h
```

geeft:

```bash
usage: freshem2pc [-h] [-v] [--out OUT] [--model {hoog,midden,laag}]
                  [--multiplier MULTIPLIER] [--srs_in SRS_IN]
                  [--srs_out SRS_OUT] [--color_table COLOR_TABLE]
                  [--clipsrc CLIPSRC] [--clipsrclayer CLIPSRCLAYER]
                  file

This converter converts FRESHEM csv files to 3Dtiles.

positional arguments:
  file                  The FRESHEM csv file to convert.

options:
  -h, --help            show this help message and exit
  -v, --verbose         Verbose output (can be very long).
  --out OUT             The folder to store the 3dtiles. Defaults to 3dtiles.
  --model {hoog,midden,laag}
                        Model estimation. Defaults to midden.
  --multiplier MULTIPLIER
                        Z-axis multiplier. Defaults to 100.
  --srs_in SRS_IN       The spatial reference system of the source. Defaults
                        to 28992.
  --srs_out SRS_OUT     The spatial reference system of the destination.
                        Defaults to 4978.
  --color_table COLOR_TABLE
                        Path to a table overriding the RGB values for each
                        salinity class.
  --clipsrc CLIPSRC     Clip geometries to one of "xmin ymin xmax
                        ymax"|WKT|datasource. See:
                        https://gdal.org/programs/ogr2ogr.html#cmdoption-
                        ogr2ogr-clipsrc
  --clipsrclayer CLIPSRCLAYER
                        Select the named layer from the source clip
                        datasource. See:
                        https://gdal.org/programs/ogr2ogr.html#cmdoption-
                        ogr2ogr-clipsrclayer

```

"Normaal gebruik" met default parameters is dan eenvoudig:

```bash
freshem2pc.xsh sample.csv
```

Dit geeft een `3dtiles` folder met daarin een 3D tile set met de point cloud met de volgende eigenschappen:

- Spatial reference system EPSG:4978 (geschikt voor Cesium)
- verticale overdrijving: 100x
- Kleuren toegekend volgens de standaard kleurentabel

Bij gebruik van een *boundig box* om te clippen is het correct gebruik van quotes belangrijk; bijvoorbeeld:

```bash
freshem2pc.xsh -v --clipsrc "57000 425000 58000 426000" sample.csv
```

### Het gebruik van Docker voor de conversie

Er is een Docker build script (`Dockerfile`) en bijhorende bestanden beschikbaar waarmee bovenstaande gemakkelijk in 1 stap kan worden uitgevoerd, waarbij dan nog verschillende parameters instelbaar zijn.

#### Het bouwen van de container

Na het installeren van Docker kan de container eenvoudig worden gebouwd middels:

```bash
docker build -t 3dfreshem ./3dfreshem
```

Het is vervolgens handig om het shell script `3dfreshem` te plaatsen in het zoekpad en uitvoerbaar te maken. 

#### Het gebruik van de container

##### `freshem2pc`

Indien het shell script `3dfreshem` is geplaatst op het zoekpad kan de container worden gebruikt middels een commando als:

```bash
3dfreshem freshem2pc -v --clipsrc "57000 425000 58000 426000" sample.csv
```

Eventueel kan de container ook gebruikt worden zonder shell script middels een commando als:

```bash
docker run -u "$UID" -w "$CWD" -v "$CWD":"$CWD" --net host -e PYTHONUNBUFFERED=0 3dfreshem "freshem2pc sample.csv"
```

##### `ogr2ogr en py3dtiles`

ogr/gdal en py3dtiles zijn beide beschikbaar in de container. Ze kunnen eenvoudig worden aangeroepen met bijvoorbeeld:

```bash
3dfreshem ogrinfo sample.csv
3dfreshem py3dtiles info ./3dtiles/r4.pnts
```

### Knippen en plakken met point clouds

Point clouds direct gebaseerd op de FRESHEM bestanden kunnen erg groot worden. Het is daarom zinnig om alleen die delen in de point cloud op te nemen die daadwerkelijk nodig zijn. `freshem2pc` kan het juiste deel uitsnijden met behulp van  de `--clipsrc` en eventueel de `--clipsrclayer` opties.

### Het gebruik van point clouds in Cesium

Een viewer als Cesium haalt zelf de juiste onderdelen op uit een point cloud. het is dus niet nodig om een speciaal soort server in te richten zoals we dat doen voor WMS- of WFS-services. Het is voldoende om de point cloud ergens op een web server te plaatsen zodat deze bereikbaar is vanaf internet. Daarna kan deze in Cesium ontsloten worden met iets als:

```javascript
Cesium.Cesium3DTileset.fromUrl('https://mijnserver.nl/tiles/3dtiles/tileset.json')
```

### Nog te doen

Het zou fijn zijn als de saliniteit als `classification` veld opgenomen kan worden in de 3Dtiles. Dan hoeven de kleuren er niet bij de conversie al ingerekend te worden, maar kunnen deze in de viewer worden ingesteld. Helaas wordt dit nog niet ondersteund door `py3dtiles`.  Hiervoor is al wel een [issue aangemaakt](https://gitlab.com/Oslandia/py3dtiles/-/issues/136).
