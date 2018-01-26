#! /usr/bin/python2.7
# -*- coding: utf-8 -*-

import sys,codecs,re

fin=codecs.open(sys.argv[1],'r','utf-8')

ccn=0
topic_ind=0;topic_detected=0
sent_ind=0;
for c in fin:
  if topic_detected:
    if re.search(u"^\d",c):
      found=re.findall(ur"^\d+",c)
      if int(found[0])<10:
        sent_ind="0"+str(found[0])
      else:
        sent_ind=str(found[0])
      cc = re.sub(ur"^\d+\. ","",c)
      cc = re.sub(ur"^\d+\.","",c)
      cc = re.sub(ur"[\.\?\,\!]","",cc)
      cc = re.sub(ur"[ ]+"," ",cc)
      print("t"+topic_ind+"_s"+sent_ind+" "+cc.encode('utf-8').rstrip())

  if re.search(u"<\d",c):
    topic_detected=1
    found=re.findall(ur"\d+",c)
    if int(found[0])<10:
      topic_ind="0"+str(found[0])
    else:
      topic_ind=str(found[0])

fin.close() 
