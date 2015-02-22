# (C) Copyright 2012 - The Amdatu Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#!/bin/bash
#
# Copies a staged release into the release repositories. The staged release 
# is identified by the first argument that is interpreted as the directory 
# name releative to the staging dir.



RELEASE_DIR=release		# Base dir of the release repository
SCRRELEASE_DIR=src-release      # Base dir of the source releases
STAGING_DIR=staging		# Base dir of the staging area
VERSION_DIR=$1			# Dir name of the staged version

# Sanity check, only allow this script to be run from root directory
if [[ ! -d "$RELEASE_DIR" || ! -d "$STAGING_DIR" ]]; then
 echo "Run this script in the root of amdatu-repository!"
 echo "Usage : ./promotes.sh <staging name>"
 exit 1
fi

if [[ -z $VERSION_DIR || ! -d "$STAGING_DIR/$VERSION_DIR" ]]; then
 echo "Provide and existing staging directory to promote!"
 echo "Usage : ./promotes.sh <staging name>"
 exit 1
fi

# Guarding against overwriting existing source releases
for scr in `ls $STAGING_DIR/$VERSION_DIR`
do
  if [[ ! -d $STAGING_DIR/$VERSION_DIR/$scr ]]; then
    if [[ -e $SCRRELEASE_DIR/$scr ]]; then
      echo "Source file allready exists in release directory: $scr"
      exit 1;
    fi
  fi
done

# Guarding against overwriting existing binary releases
for bnd in `ls $STAGING_DIR/$VERSION_DIR/repository | grep .jar`
do
  ver=`unzip -p $STAGING_DIR/$VERSION_DIR/repository/$bnd META-INF/MANIFEST.MF | tr -s '\r' '\n' | grep Bundle-Version | sed -e 's/^Bundle-Version:\s*\(.*\)$/\1/'`
  bsn=`unzip -p $STAGING_DIR/$VERSION_DIR/repository/$bnd META-INF/MANIFEST.MF | tr -s '\r' '\n' | grep Bundle-SymbolicName | sed -e 's/^Bundle-SymbolicName:\s*\(.*\)$/\1/'`
  if [[ -e "$RELEASE_DIR/$bsn/$bsn-$ver.jar" ]]; then
    echo "Bundle file allready exists in release directory: $RELEASE_DIR/$bsn/$bsn-$ver.jar"
    exit 1;
  fi
done

# Copying source release
for scr in `ls $STAGING_DIR/$VERSION_DIR`
do
  if [[ ! -d $STAGING_DIR/$VERSION_DIR/$scr ]]; then
    echo "Promoting source file to release dir: $scr"
    cp -v $STAGING_DIR/$VERSION_DIR/$scr $SCRRELEASE_DIR/$scr
  fi
done

# Copying binary release
for bnd in `ls $STAGING_DIR/$VERSION_DIR/repository | grep .jar`
do
 ver=`unzip -p $STAGING_DIR/$VERSION_DIR/repository/$bnd META-INF/MANIFEST.MF | tr -s '\r' '\n' | grep Bundle-Version | sed -e 's/^Bundle-Version:\s*\(.*\)$/\1/'`
 bsn=`unzip -p $STAGING_DIR/$VERSION_DIR/repository/$bnd META-INF/MANIFEST.MF | tr -s '\r' '\n' | grep Bundle-SymbolicName | sed -e 's/^Bundle-SymbolicName:\s*\(.*\)$/\1/'`
 [ -d "$RELEASE_DIR/$bsn" ] || mkdir $RELEASE_DIR/$bsn
 echo "Promoting binary file to release dir: $bnd"
 cp -v $STAGING_DIR/$VERSION_DIR/repository/$bnd $RELEASE_DIR/$bsn/$bsn-$ver.jar 
done
