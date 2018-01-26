#! /usr/bin/python2.7
# -*- coding: utf-8 -*-

import sys,codecs,re
fin=codecs.open(sys.argv[1],"r","utf-8");lines = fin.read();fin.close()
fout=codecs.open(sys.argv[2],"w","utf-8")

lines=re.sub(ur"\ufeff",u"",lines)
lines=re.sub(ur"\r\n",u"\n",lines)
lines=re.sub(ur"찌익ꠏꠏꠏ깔기는",u"찌익 깔기는",lines)
lines=re.sub(ur"들이켰으면⋯⋯",u"들이켰으면",lines)
lines=re.sub(ur"흐흐흐⋯⋯",u"흐흐흐",lines)
lines=re.sub(ur"삐익ꠏꠏꠏꠏ하고",u"삐익하고",lines)
lines=re.sub(ur"3의",u"삼의",lines)
lines=re.sub(ur"3 배",u"세 배",lines)
lines=re.sub(ur"5호선이",u"오호선이",lines)
lines=re.sub(ur"11월",u"십일월",lines)
lines=re.sub(ur"6․25 전쟁",u"육이오 전쟁",lines)
lines = re.sub(ur"3. 나이 많은 용왕님이 시름시름 앓다가 자리에 누웠기 때문이지요.   4. 신하들은 좋다는 약은 다 써보았지만 용왕님의 병을 낫게 하지는 못했어요.",u"3. 나이 많은 용왕님이 시름시름 앓다가 자리에 누웠기 때문이지요.\n4. 신하들은 좋다는 약은 다 써보았지만 용왕님의 병을 낫게 하지는 못했어요.",lines)
lines = re.sub(ur'11."살려 주세요."',u'11. "살려 주세요."',lines)
lines = re.sub(ur'63. 선녀는 날개옷을 보자 너무나 기뻐서 날개옷을 입어 보았어요.   64. 그런데 이게 웬 일이죠?',u'63. 선녀는 날개옷을 보자 너무나 기뻐서 날개옷을 입어 보았어요.\n64. 그런데 이게 웬 일이죠?',lines)

lines2 = lines.split(")")
lines3 = []
for l in lines2:
  ll=re.sub(ur"\(.*$",u"",l)
  ll=re.sub(ur"[‘“]"," ",ll)
  ll=re.sub(ur" [ ]+"," ",ll)
  lines3.append(re.sub(ur"[’…”「」\"~]+","",ll))
  #lines3.append(re.sub(ur"[‘’…“”「」\"~]+","",ll))

lines4 = "".join(lines3)
lines4=re.sub(ur"\r\n",u"\n",lines4)
fout.write(lines4);fout.close()
