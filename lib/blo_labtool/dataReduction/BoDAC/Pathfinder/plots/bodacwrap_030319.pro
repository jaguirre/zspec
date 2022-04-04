
inpath = '/home/bschulz/data/project/spire/bolo/data/hfi/225303/'

!p.multi=[0,3,1]

psinit, /landscape, /color
spawn, "rm "+inpath+'225303_a.log'
bolodark_wrap, inpath, /whiteback, $
	exclude=['72mK','77mK','88mK', '1_3K_', '1_52K_', $
		'1_93K_', '2_15Kdark', '4Kclosed'], logfile=inpath+'225303_a.log'
psterm, file=inpath+'225303_a.ps'

psinit, /landscape
bolodark_wrap, inpath, $
	exclude=['72mK','77mK','85mK','88mK', '1_3K_', '1_52K_', $
          '90mK', '100mK', $
		'1_93K_', '2_15Kdark', '4Kclosed'], logfile=inpath+'225303_b.log'
psterm, file=inpath+'225303_b.ps'



inpath = '/home/bschulz/data/project/spire/bolo/data/hfi/20020802/'

psinit, /landscape
spawn, "rm "+inpath+'20020802_a.log'
bolodark_wrap, inpath, logfile=inpath+'20020802_a.log'
psterm, file=inpath+'20020802_a.ps'

psinit, /landscape
spawn, "rm "+inpath+'20020802_b.log'
bolodark_wrap, inpath, logfile=inpath+'20020802_b.log', $
	exclude=['darkfine']
psterm, file=inpath+'20020802_b.ps'

psinit, /landscape
spawn, "rm "+inpath+'20020802_c.log'
bolodark_wrap, inpath, logfile=inpath+'20020802_c.log', $
	exclude=['71mK','75mK','83mK','86mK','92mK']
psterm, file=inpath+'20020802_c.ps'

psinit, /landscape
spawn, "rm "+inpath+'20020802_d.log'
bolodark_wrap, inpath, logfile=inpath+'20020802_d.log', $
	exclude=['71mK','75mK','83mK','86mK','92mK']
psterm, file=inpath+'20020802_d.ps'

psinit, /landscape
spawn, "rm "+inpath+'20020802_e.log'
bolodark_wrap, inpath, logfile=inpath+'20020802_e.log', $
	exclude=['71mK','75mK','83mK','86mK','92mK',$
     		'1809mK','1149mK','1148mK']
psterm, file=inpath+'20020802_e.ps'

psinit, /landscape
spawn, "rm "+inpath+'20020802_f.log'
bolodark_wrap, inpath, logfile=inpath+'20020802_f.log', $
	exclude=['darkfine','71mK','75mK','83mK','86mK','92mK',$
     		'1809mK','1149mK','1148mK']
psterm, file=inpath+'20020802_f.ps'

psinit, /landscape
spawn, "rm "+inpath+'20020802_g.log'
bolodark_wrap, inpath, logfile=inpath+'20020802_g.log', $
	exclude=['darkfine','71mK','75mK','83mK','86mK','92mK',$
     		'100mK','110mK','123mK','139mK','155mK','179mK', $
     		'1809mK','1149mK','1148mK']
psterm, file=inpath+'20020802_g.ps'



