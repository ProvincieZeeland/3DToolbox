#!/usr/bin/env xonsh

import argparse
import os

parser = argparse.ArgumentParser(
    description='This converter converts GeoTOP xyz files to 3Dtiles.')

parser.add_argument(  "-v", "--verbose", 
                      default = False, 
                      action = "store_true",
                      help = "Verbose output (can be very long).")
parser.add_argument(  "--out", 
                      default = '3dtiles', 
                      help = "The folder to store the 3dtiles. Defaults to 3dtiles.")
parser.add_argument(  "--nodata", 
                      dest = "join_type",
                      default = "",
                      const = "LEFT",
                      help = "Store nodata values in the 3Dtiles.",
                      action = "store_const")
parser.add_argument(  "--multiplier", 
                      type = float, 
                      default = 100,
                      help = "Z-axis multiplier. Defaults to 100.")
parser.add_argument(  "--srs_in", 
                      type = int, 
                      default = 28992,
                      help = "The spatial reference system of the source. Defaults to 28992.")
parser.add_argument(  "--srs_out", 
                      type = int, 
                      default = 4978,
                      help = "The spatial reference system of the destination. Defaults to 4978.")
parser.add_argument(  "--color_table",
                      default = '/home/lut.csv',
                      help = "Path to a table overriding the RGB values for each litho class.")
parser.add_argument(  "--clipsrc",
                      default = None,
                      help = 'Clip geometries to one of "xmin ymin xmax ymax"|WKT|datasource.\nSee: https://gdal.org/programs/ogr2ogr.html#cmdoption-ogr2ogr-clipsrc')
parser.add_argument(  "--clipsrclayer",
                      default = None,
                      help = "Select the named layer from the source clip datasource.\nSee: https://gdal.org/programs/ogr2ogr.html#cmdoption-ogr2ogr-clipsrclayer")
parser.add_argument(  "file",       
                      help = "The GeoTOP file to process to convert.")          

args = parser.parse_args()

if args.verbose:
  $XONSH_TRACE_SUBPROC = True

# Gather all arguments for the ogr2ogr command line pre processing: 
ogr_args = []
 
where = ""
if args.clipsrc: 
  if " " in args.clipsrc and len(args.clipsrc.strip().split()) == 4:
    # we have a bounding box, which we will add to the sql WHERE clause
    where = f"WHERE ST_EnvelopesIntersects(sample.geometry, { ','.join(args.clipsrc.strip().split()) })"
  else:
    # we have a path or WKT
    ogr_args.extend(["-clipsrc", args.clipsrc])
if args.clipsrclayer: ogr_args.extend(["-clipsrclayer", args.clipsrclayer])

ogr_args.extend(['-a_srs',f"EPSG:{ args.srs_in }", '-oo', 'AUTODETECT_TYPE=YES', '-oo', 'X_POSSIBLE_NAMES=x', '-oo', 'Y_POSSIBLE_NAMES=y', '-oo', 'Z_POSSIBLE_NAMES=z'])
ogr_args.extend(['-dialect', 'sqlite'])
# Build query that prepares file according to format accepted by py3dtiles (X,Y,Z,Intensity,R,G,B,Class)
# Class is raised with 100 to not interfere with standard point classes from LAS-specification
ogr_args.extend(['-sql', f"select x,y,z * { args.multiplier }, 1, lut.R, lut.G, lut.B, lut.klasse + 100 FROM { os.path.splitext(os.path.basename(args.file))[0] } as sample { args.join_type } JOIN '{ args.color_table }'.lut as lut ON sample.lithoklasse = lut.klasse { where }" ])
ogr_args.extend(['-f', "CSV"])
ogr_args.extend(["/tmp/sample.csv", args.file])
ogr_args.extend(["-lco", "STRING_QUOTING=IF_NEEDED"])

# pre processing in ogr2ogr
ogr2ogr @(ogr_args)

if args.verbose:
  cat /tmp/sample.csv

# Gather all arguments for py3dtiles command
py3dt_args = []
if args.verbose:
  py3dt_args.append("-v")
py3dt_args.append("--classification")
py3dt_args.extend(["--srs_in", args.srs_in])
py3dt_args.extend(["--srs_out", args.srs_out])
py3dt_args.extend(["--out", args.out])
py3dt_args.append("/tmp/sample.csv")

# do the real processing
py3dtiles convert @(py3dt_args)

# Done
print('\nDone\n')

