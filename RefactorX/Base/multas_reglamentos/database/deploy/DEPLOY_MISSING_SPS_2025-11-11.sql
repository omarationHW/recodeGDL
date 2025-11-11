-- ================================================================
-- DEPLOYMENT SCRIPT: multas_reglamentos
-- SPs Faltantes: 111
-- Fecha: 2025-11-11
-- ================================================================
--
-- INSTRUCCIONES:
-- 1. Revisar cada SP generado en: ../generated/
-- 2. Implementar la lógica específica de cada SP
-- 3. Ejecutar este script en la base de datos: multas_reglamentos
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT: multas_reglamentos - 111 SPs'
\echo '=================================================='
\echo ''

-- Establecer schema
SET search_path TO public;


-- [1/111] recaudadora_get_ejecutores - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_get_ejecutores...'
\i ../generated/recaudadora_get_ejecutores.sql
\echo '   ✓ OK'

-- [2/111] recaudadora_parse_file - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_parse_file...'
\i ../generated/recaudadora_parse_file.sql
\echo '   ✓ OK'

-- [3/111] recaudadora_actualiza_fechas - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_actualiza_fechas...'
\i ../generated/recaudadora_actualiza_fechas.sql
\echo '   ✓ OK'

-- [4/111] recaudadora_consulta_sdos_favor - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_consulta_sdos_favor...'
\i ../generated/recaudadora_consulta_sdos_favor.sql
\echo '   ✓ OK'

-- [5/111] recaudadora_aplica_sdos_favor - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_aplica_sdos_favor...'
\i ../generated/recaudadora_aplica_sdos_favor.sql
\echo '   ✓ OK'

-- [6/111] recaudadora_autdescto - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_autdescto...'
\i ../generated/recaudadora_autdescto.sql
\echo '   ✓ OK'

-- [7/111] recaudadora_bloqctasreqfrm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_bloqctasreqfrm...'
\i ../generated/recaudadora_bloqctasreqfrm.sql
\echo '   ✓ OK'

-- [8/111] recaudadora_bloqueo_multa - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_bloqueo_multa...'
\i ../generated/recaudadora_bloqueo_multa.sql
\echo '   ✓ OK'

-- [9/111] recaudadora_busque - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_busque...'
\i ../generated/recaudadora_busque.sql
\echo '   ✓ OK'

-- [10/111] recaudadora_canc - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_canc...'
\i ../generated/recaudadora_canc.sql
\echo '   ✓ OK'

-- [11/111] recaudadora_captura_dif - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_captura_dif...'
\i ../generated/recaudadora_captura_dif.sql
\echo '   ✓ OK'

-- [12/111] recaudadora_carta_invitacion - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_carta_invitacion...'
\i ../generated/recaudadora_carta_invitacion.sql
\echo '   ✓ OK'

-- [13/111] recaudadora_catastro_dm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_catastro_dm...'
\i ../generated/recaudadora_catastro_dm.sql
\echo '   ✓ OK'

-- [14/111] recaudadora_centrosfrm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_centrosfrm...'
\i ../generated/recaudadora_centrosfrm.sql
\echo '   ✓ OK'

-- [15/111] recaudadora_codificafrm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_codificafrm...'
\i ../generated/recaudadora_codificafrm.sql
\echo '   ✓ OK'

-- [16/111] recaudadora_conscentrosfrm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_conscentrosfrm...'
\i ../generated/recaudadora_conscentrosfrm.sql
\echo '   ✓ OK'

-- [17/111] recaudadora_consdesc - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_consdesc...'
\i ../generated/recaudadora_consdesc.sql
\echo '   ✓ OK'

-- [18/111] recaudadora_descderechos_merc - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_descderechos_merc...'
\i ../generated/recaudadora_descderechos_merc.sql
\echo '   ✓ OK'

-- [19/111] recaudadora_drecgo_fosa - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_drecgo_fosa...'
\i ../generated/recaudadora_drecgo_fosa.sql
\echo '   ✓ OK'

-- [20/111] recaudadora_drecgo_trans - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_drecgo_trans...'
\i ../generated/recaudadora_drecgo_trans.sql
\echo '   ✓ OK'

-- [21/111] recaudadora_ejecutores - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_ejecutores...'
\i ../generated/recaudadora_ejecutores.sql
\echo '   ✓ OK'

-- [22/111] recaudadora_empresas - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_empresas...'
\i ../generated/recaudadora_empresas.sql
\echo '   ✓ OK'

-- [23/111] recaudadora_exclusivos_upd - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_exclusivos_upd...'
\i ../generated/recaudadora_exclusivos_upd.sql
\echo '   ✓ OK'

-- [24/111] recaudadora_extractos_rpt - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_extractos_rpt...'
\i ../generated/recaudadora_extractos_rpt.sql
\echo '   ✓ OK'

-- [25/111] recaudadora_firma_electronica - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_firma_electronica...'
\i ../generated/recaudadora_firma_electronica.sql
\echo '   ✓ OK'

-- [26/111] recaudadora_fol_multa - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_fol_multa...'
\i ../generated/recaudadora_fol_multa.sql
\echo '   ✓ OK'

-- [27/111] recaudadora_gastos_transmision - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_gastos_transmision...'
\i ../generated/recaudadora_gastos_transmision.sql
\echo '   ✓ OK'

-- [28/111] recaudadora_hastafrm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_hastafrm...'
\i ../generated/recaudadora_hastafrm.sql
\echo '   ✓ OK'

-- [29/111] recaudadora_imprime_desctos - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_imprime_desctos...'
\i ../generated/recaudadora_imprime_desctos.sql
\echo '   ✓ OK'

-- [30/111] recaudadora_lista_diferencias - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_lista_diferencias...'
\i ../generated/recaudadora_lista_diferencias.sql
\echo '   ✓ OK'

-- [31/111] recaudadora_listado_multiple - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_listado_multiple...'
\i ../generated/recaudadora_listado_multiple.sql
\echo '   ✓ OK'

-- [32/111] recaudadora_listana - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_listana...'
\i ../generated/recaudadora_listana.sql
\echo '   ✓ OK'

-- [33/111] recaudadora_modif_masiva - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_modif_masiva...'
\i ../generated/recaudadora_modif_masiva.sql
\echo '   ✓ OK'

-- [34/111] recaudadora_multas_dm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_multas_dm...'
\i ../generated/recaudadora_multas_dm.sql
\echo '   ✓ OK'

-- [35/111] recaudadora_otorga_descto - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_otorga_descto...'
\i ../generated/recaudadora_otorga_descto.sql
\echo '   ✓ OK'

-- [36/111] recaudadora_pagos_espe - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_pagos_espe...'
\i ../generated/recaudadora_pagos_espe.sql
\echo '   ✓ OK'

-- [37/111] recaudadora_periodo_inicial - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_periodo_inicial...'
\i ../generated/recaudadora_periodo_inicial.sql
\echo '   ✓ OK'

-- [38/111] recaudadora_propuestatab - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_propuestatab...'
\i ../generated/recaudadora_propuestatab.sql
\echo '   ✓ OK'

-- [39/111] recaudadora_publicos_upd - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_publicos_upd...'
\i ../generated/recaudadora_publicos_upd.sql
\echo '   ✓ OK'

-- [40/111] recaudadora_regsecymas - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_regsecymas...'
\i ../generated/recaudadora_regsecymas.sql
\echo '   ✓ OK'

-- [41/111] recaudadora_rep_desc_impto - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_rep_desc_impto...'
\i ../generated/recaudadora_rep_desc_impto.sql
\echo '   ✓ OK'

-- [42/111] recaudadora_rep_oper - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_rep_oper...'
\i ../generated/recaudadora_rep_oper.sql
\echo '   ✓ OK'

-- [43/111] recaudadora_req - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_req...'
\i ../generated/recaudadora_req.sql
\echo '   ✓ OK'

-- [44/111] recaudadora_req_frm_save - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_req_frm_save...'
\i ../generated/recaudadora_req_frm_save.sql
\echo '   ✓ OK'

-- [45/111] recaudadora_req_promocion - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_req_promocion...'
\i ../generated/recaudadora_req_promocion.sql
\echo '   ✓ OK'

-- [46/111] recaudadora_reqtrans_list - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_reqtrans_list...'
\i ../generated/recaudadora_reqtrans_list.sql
\echo '   ✓ OK'

-- [47/111] recaudadora_reqtrans_create - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_reqtrans_create...'
\i ../generated/recaudadora_reqtrans_create.sql
\echo '   ✓ OK'

-- [48/111] recaudadora_reqtrans_update - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_reqtrans_update...'
\i ../generated/recaudadora_reqtrans_update.sql
\echo '   ✓ OK'

-- [49/111] recaudadora_reqtrans_delete - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_reqtrans_delete...'
\i ../generated/recaudadora_reqtrans_delete.sql
\echo '   ✓ OK'

-- [50/111] recaudadora_requerimientos_dm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_requerimientos_dm...'
\i ../generated/recaudadora_requerimientos_dm.sql
\echo '   ✓ OK'

-- [51/111] recaudadora_requerxcvecat - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_requerxcvecat...'
\i ../generated/recaudadora_requerxcvecat.sql
\echo '   ✓ OK'

-- [52/111] recaudadora_resolucion_juez - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_resolucion_juez...'
\i ../generated/recaudadora_resolucion_juez.sql
\echo '   ✓ OK'

-- [53/111] recaudadora_sdosfavor_dm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_sdosfavor_dm...'
\i ../generated/recaudadora_sdosfavor_dm.sql
\echo '   ✓ OK'

-- [54/111] recaudadora_sdosfavor_ctrlexp - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_sdosfavor_ctrlexp...'
\i ../generated/recaudadora_sdosfavor_ctrlexp.sql
\echo '   ✓ OK'

-- [55/111] recaudadora_sdosfavor_pagos - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_sdosfavor_pagos...'
\i ../generated/recaudadora_sdosfavor_pagos.sql
\echo '   ✓ OK'

-- [56/111] recaudadora_sinligarfrm - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_sinligarfrm...'
\i ../generated/recaudadora_sinligarfrm.sql
\echo '   ✓ OK'

-- [57/111] recaudadora_sol_sdos_favor - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_sol_sdos_favor...'
\i ../generated/recaudadora_sol_sdos_favor.sql
\echo '   ✓ OK'

-- [58/111] recaudadora_tdm_conection - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_tdm_conection...'
\i ../generated/recaudadora_tdm_conection.sql
\echo '   ✓ OK'

-- [59/111] recaudadora_ubicodifica - 2 usos (🟡 MEDIA)
\echo 'Creando: recaudadora_ubicodifica...'
\i ../generated/recaudadora_ubicodifica.sql
\echo '   ✓ OK'

-- [60/111] recaudadora_consescrit400 - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_consescrit400...'
\i ../generated/recaudadora_consescrit400.sql
\echo '   ✓ OK'

-- [61/111] recaudadora_consmulpagos - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_consmulpagos...'
\i ../generated/recaudadora_consmulpagos.sql
\echo '   ✓ OK'

-- [62/111] recaudadora_consobsmulfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_consobsmulfrm...'
\i ../generated/recaudadora_consobsmulfrm.sql
\echo '   ✓ OK'

-- [63/111] recaudadora_consreq400 - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_consreq400...'
\i ../generated/recaudadora_consreq400.sql
\echo '   ✓ OK'

-- [64/111] recaudadora_consultapredial - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_consultapredial...'
\i ../generated/recaudadora_consultapredial.sql
\echo '   ✓ OK'

-- [65/111] recaudadora_dderechoslic - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_dderechoslic...'
\i ../generated/recaudadora_dderechoslic.sql
\echo '   ✓ OK'

-- [66/111] recaudadora_descmultampalfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_descmultampalfrm...'
\i ../generated/recaudadora_descmultampalfrm.sql
\echo '   ✓ OK'

-- [67/111] recaudadora_descpredfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_descpredfrm...'
\i ../generated/recaudadora_descpredfrm.sql
\echo '   ✓ OK'

-- [68/111] recaudadora_desctorec - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_desctorec...'
\i ../generated/recaudadora_desctorec.sql
\echo '   ✓ OK'

-- [69/111] recaudadora_drecgolic - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_drecgolic...'
\i ../generated/recaudadora_drecgolic.sql
\echo '   ✓ OK'

-- [70/111] recaudadora_drecgootrasobligaciones - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_drecgootrasobligaciones...'
\i ../generated/recaudadora_drecgootrasobligaciones.sql
\echo '   ✓ OK'

-- [71/111] recaudadora_entregafrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_entregafrm...'
\i ../generated/recaudadora_entregafrm.sql
\echo '   ✓ OK'

-- [72/111] recaudadora_estadreq - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_estadreq...'
\i ../generated/recaudadora_estadreq.sql
\echo '   ✓ OK'

-- [73/111] recaudadora_frmeje - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_frmeje...'
\i ../generated/recaudadora_frmeje.sql
\echo '   ✓ OK'

-- [74/111] recaudadora_frmpol - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_frmpol...'
\i ../generated/recaudadora_frmpol.sql
\echo '   ✓ OK'

-- [75/111] recaudadora_impreqcvecat - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_impreqcvecat...'
\i ../generated/recaudadora_impreqcvecat.sql
\echo '   ✓ OK'

-- [76/111] recaudadora_impresionnva - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_impresionnva...'
\i ../generated/recaudadora_impresionnva.sql
\echo '   ✓ OK'

-- [77/111] recaudadora_ipor - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_ipor...'
\i ../generated/recaudadora_ipor.sql
\echo '   ✓ OK'

-- [78/111] recaudadora_leyesfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_leyesfrm...'
\i ../generated/recaudadora_leyesfrm.sql
\echo '   ✓ OK'

-- [79/111] recaudadora_licenciamicrogenerador - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_licenciamicrogenerador...'
\i ../generated/recaudadora_licenciamicrogenerador.sql
\echo '   ✓ OK'

-- [80/111] recaudadora_licenciamicrogeneradorecologia - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_licenciamicrogeneradorecologia...'
\i ../generated/recaudadora_licenciamicrogeneradorecologia.sql
\echo '   ✓ OK'

-- [81/111] recaudadora_ligapago - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_ligapago...'
\i ../generated/recaudadora_ligapago.sql
\echo '   ✓ OK'

-- [82/111] recaudadora_ligapagotra - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_ligapagotra...'
\i ../generated/recaudadora_ligapagotra.sql
\echo '   ✓ OK'

-- [83/111] recaudadora_listanotificacionesfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_listanotificacionesfrm...'
\i ../generated/recaudadora_listanotificacionesfrm.sql
\echo '   ✓ OK'

-- [84/111] recaudadora_listareq - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_listareq...'
\i ../generated/recaudadora_listareq.sql
\echo '   ✓ OK'

-- [85/111] recaudadora_listchq - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_listchq...'
\i ../generated/recaudadora_listchq.sql
\echo '   ✓ OK'

-- [86/111] recaudadora_listdesctomultafrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_listdesctomultafrm...'
\i ../generated/recaudadora_listdesctomultafrm.sql
\echo '   ✓ OK'

-- [87/111] recaudadora_multas400frm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_multas400frm...'
\i ../generated/recaudadora_multas400frm.sql
\echo '   ✓ OK'

-- [88/111] recaudadora_multasfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_multasfrm...'
\i ../generated/recaudadora_multasfrm.sql
\echo '   ✓ OK'

-- [89/111] recaudadora_multasfrmcalif - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_multasfrmcalif...'
\i ../generated/recaudadora_multasfrmcalif.sql
\echo '   ✓ OK'

-- [90/111] recaudadora_newsfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_newsfrm...'
\i ../generated/recaudadora_newsfrm.sql
\echo '   ✓ OK'

-- [91/111] recaudadora_pagalicfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_pagalicfrm...'
\i ../generated/recaudadora_pagalicfrm.sql
\echo '   ✓ OK'

-- [92/111] recaudadora_pagosdivfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_pagosdivfrm...'
\i ../generated/recaudadora_pagosdivfrm.sql
\echo '   ✓ OK'

-- [93/111] recaudadora_pagosmultfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_pagosmultfrm...'
\i ../generated/recaudadora_pagosmultfrm.sql
\echo '   ✓ OK'

-- [94/111] recaudadora_polcon - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_polcon...'
\i ../generated/recaudadora_polcon.sql
\echo '   ✓ OK'

-- [95/111] recaudadora_prepagofrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_prepagofrm...'
\i ../generated/recaudadora_prepagofrm.sql
\echo '   ✓ OK'

-- [96/111] recaudadora_pres - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_pres...'
\i ../generated/recaudadora_pres.sql
\echo '   ✓ OK'

-- [97/111] recaudadora_proyecfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_proyecfrm...'
\i ../generated/recaudadora_proyecfrm.sql
\echo '   ✓ OK'

-- [98/111] recaudadora_pruebacalcas - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_pruebacalcas...'
\i ../generated/recaudadora_pruebacalcas.sql
\echo '   ✓ OK'

-- [99/111] recaudadora_reg - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_reg...'
\i ../generated/recaudadora_reg.sql
\echo '   ✓ OK'

-- [100/111] recaudadora_reghfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_reghfrm...'
\i ../generated/recaudadora_reghfrm.sql
\echo '   ✓ OK'

-- [101/111] recaudadora_reimpfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_reimpfrm...'
\i ../generated/recaudadora_reimpfrm.sql
\echo '   ✓ OK'

-- [102/111] recaudadora_relmes - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_relmes...'
\i ../generated/recaudadora_relmes.sql
\echo '   ✓ OK'

-- [103/111] recaudadora_repavance - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_repavance...'
\i ../generated/recaudadora_repavance.sql
\echo '   ✓ OK'

-- [104/111] recaudadora_repmultampalfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_repmultampalfrm...'
\i ../generated/recaudadora_repmultampalfrm.sql
\echo '   ✓ OK'

-- [105/111] recaudadora_reqctascanfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_reqctascanfrm...'
\i ../generated/recaudadora_reqctascanfrm.sql
\echo '   ✓ OK'

-- [106/111] recaudadora_reqmultas400frm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_reqmultas400frm...'
\i ../generated/recaudadora_reqmultas400frm.sql
\echo '   ✓ OK'

-- [107/111] recaudadora_sfrm_calificacionqr - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_sfrm_calificacionqr...'
\i ../generated/recaudadora_sfrm_calificacionqr.sql
\echo '   ✓ OK'

-- [108/111] recaudadora_sfrm_chgpass - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_sfrm_chgpass...'
\i ../generated/recaudadora_sfrm_chgpass.sql
\echo '   ✓ OK'

-- [109/111] recaudadora_sfrm_prescrip_sec01 - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_sfrm_prescrip_sec01...'
\i ../generated/recaudadora_sfrm_prescrip_sec01.sql
\echo '   ✓ OK'

-- [110/111] recaudadora_sgcv2 - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_sgcv2...'
\i ../generated/recaudadora_sgcv2.sql
\echo '   ✓ OK'

-- [111/111] recaudadora_trasladosfrm - 1 usos (⚪ BAJA)
\echo 'Creando: recaudadora_trasladosfrm...'
\i ../generated/recaudadora_trasladosfrm.sql
\echo '   ✓ OK'

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT COMPLETADO: 111 SPs creados'
\echo '=================================================='
\echo ''
