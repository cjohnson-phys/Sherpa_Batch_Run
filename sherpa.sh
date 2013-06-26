#!/bin/bash

### These are the parameters given by ATLAS in the Sherpa_Base_Fragment.py
export ATLASPARAMS="MASS[6]=172.5 MASS[23]=91.1876 MASS[24]=80.399 WIDTH[23]=2.4952 WIDTH[24]=2.085 EVENTS=1 FRAGMENTATION=Off PRETTY_PRINT=Off SIN2THETAW=0.23113 WIDTH[6]=1.47211 WIDTH[24]=2.035169 MASS[25]=125.0"

Sherpa $ATLASPARAMS
