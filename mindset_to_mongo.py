#!/usr/bin/python

## Scan through csv versions of study data and populate mongodb

import pymongo                          # Mongo database access
from pymongo import MongoClient         # Mongo database access
import csv                              # traversing the input prior to conversion
import argparse                         # parsing the single argument
from os.path import basename            # to get the base name of the csv file

parser = argparse.ArgumentParser( description="Store data from a csv file into mongo" )
parser.add_argument( 'csvfile', help='the file containing csv-formatted data' )
args = parser.parse_args()
csvbase = basename(args.csvfile)[:-4]

client = MongoClient('mongodb://localhost:27017/')
db = client.mind

def updatemind( d, coll, c ):
  c['TOTALED'] += 1
  #print "ID: {0}".format( d['id'] )
  r = ""
  n = db.aric.find( { 'id': d['id'] } ).count()
  if ( n > 0 ):
    print "{0} exists.".format( d['id'] )
    o = db.aric.find( { "{0}.id".format( coll ): d['id'] } ).count()
    if ( o > 0 ):
      c['SKIPPED'] += 1
      print "   {0} exists within {1}; doing nothing.".format( coll, d['id'] )
    else:
      c['UPDATED'] += 1
      print "   but does not contain a {0} section; adding it...".format( coll )
      r = db.aric.update( { 'id': d['id'] },
                          { '$set': { coll: d[coll] } },
                          upsert=False, multi=False )
  else:
    c['CREATED'] += 1
    print "{0} does not exist; creating it...".format( d['id'] )
    r = db.aric.insert( d )
  return r


counts = { 'CREATED': 0, 'UPDATED': 0, 'SKIPPED': 0, 'TOTALED': 0 }
with open(args.csvfile) as csvfile:
  toprow = []
  idreader = csv.reader(csvfile, delimiter=',')
  for row in idreader:
    recid = ""
    recstr = ""
    recdict = {}
    #print ','.join(row)
    #print "{0} items.".format(len(row))
    if ( len(toprow) > 0 ):
      for y, x in enumerate(row):
        beginner = "{ " if y == 0 else "  "
        ender = " }" if y == len(row) - 1 else ",\n"
        recstr = "{0}{1}{2}: '{3}'{4}".format( recstr, beginner, toprow[y].lower(), x, ender )
        recdict[toprow[y].lower()] = x
        if ( toprow[y].lower() == "id" ):
          recid = x
      #print recstr
      resp = updatemind( { 'id': recid, csvbase: recdict }, csvbase, counts )
      #print resp
    else:
      toprow = row

print "Looked at {0} records from {1}:".format( counts['TOTALED'], csvbase )
print "  Created {0} new database objects.".format( counts['CREATED'] )
print "  Updated {0} existing database objects.".format( counts['UPDATED'] )
print "  Skipped {0} duplicate database objects.".format( counts['SKIPPED'] )