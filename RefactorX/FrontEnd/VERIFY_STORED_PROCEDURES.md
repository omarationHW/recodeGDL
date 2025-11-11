# 🔍 VERIFICACIÓN: Stored Procedures

**Fecha**: 10/11/2025, 2:52:06 p.m.
**Sistema**: RefactorX Guadalajara - PostgreSQL

---

## 📊 RESUMEN EJECUTIVO

- **Total archivos Vue analizados**: 594
- **Total archivos SQL analizados**: 2508
- **SPs usados en Vue**: 765
- **SPs definidos en SQL**: 1774
- **SPs encontrados**: 318 ✅
- **SPs faltantes**: 447 ❌
- **Problemas de sintaxis**: 7 ⚠️

### Estado General:
❌ **REQUIERE ATENCIÓN**: Hay SPs faltantes o problemas de sintaxis

---

## ❌ STORED PROCEDURES FALTANTES (447)

⚠️  **CRÍTICO**: Los siguientes SPs son usados en componentes Vue pero NO existen en archivos SQL:

| # | Stored Procedure | Usado en |
|---|------------------|----------|
| 1 | `sp_aseo_cves_operacion_list` | 2 archivo(s) |
| 2 | `sp_aseo_cves_operacion_create` | 1 archivo(s) |
| 3 | `sp_aseo_cves_operacion_update` | 1 archivo(s) |
| 4 | `sp_aseo_cves_operacion_delete` | 1 archivo(s) |
| 5 | `sp_aseo_empresas_list` | 18 archivo(s) |
| 6 | `sp_aseo_empresas_create` | 1 archivo(s) |
| 7 | `sp_aseo_empresas_update` | 1 archivo(s) |
| 8 | `sp_aseo_empresas_delete` | 1 archivo(s) |
| 9 | `sp_aseo_gastos_list` | 1 archivo(s) |
| 10 | `sp_aseo_gastos_create` | 1 archivo(s) |
| 11 | `sp_aseo_gastos_update` | 1 archivo(s) |
| 12 | `sp_aseo_gastos_delete` | 1 archivo(s) |
| 13 | `sp_aseo_recargos_list` | 1 archivo(s) |
| 14 | `sp_aseo_recargos_create` | 1 archivo(s) |
| 15 | `sp_aseo_recargos_update` | 1 archivo(s) |
| 16 | `sp_aseo_recargos_delete` | 1 archivo(s) |
| 17 | `sp_aseo_recaudadoras_list` | 3 archivo(s) |
| 18 | `sp_aseo_tipos_list` | 6 archivo(s) |
| 19 | `sp_aseo_tipos_create` | 1 archivo(s) |
| 20 | `sp_aseo_tipos_update` | 1 archivo(s) |
| 21 | `sp_aseo_tipos_delete` | 1 archivo(s) |
| 22 | `sp_aseo_tipos_emp_list` | 1 archivo(s) |
| 23 | `sp_aseo_tipos_emp_create` | 1 archivo(s) |
| 24 | `sp_aseo_tipos_emp_update` | 1 archivo(s) |
| 25 | `sp_aseo_tipos_emp_delete` | 1 archivo(s) |
| 26 | `sp_aseo_unidades_list` | 10 archivo(s) |
| 27 | `sp_aseo_unidades_create` | 1 archivo(s) |
| 28 | `sp_aseo_unidades_update` | 1 archivo(s) |
| 29 | `sp_aseo_unidades_delete` | 1 archivo(s) |
| 30 | `sp_aseo_zonas_list` | 15 archivo(s) |
| 31 | `sp_aseo_zonas_create` | 1 archivo(s) |
| 32 | `sp_aseo_zonas_update` | 1 archivo(s) |
| 33 | `sp_aseo_zonas_delete` | 1 archivo(s) |
| 34 | `sp_aseo_adeudos_buscar_contrato` | 5 archivo(s) |
| 35 | `sp_aseo_adeudos_estado_cuenta` | 9 archivo(s) |
| 36 | `sp_aseo_adeudos_carga_masiva` | 2 archivo(s) |
| 37 | `sp_aseo_adeudos_insertar` | 2 archivo(s) |
| 38 | `sp_aseo_adeudos_generar_recargos` | 1 archivo(s) |
| 39 | `sp_aseo_adeudos_registrar_pago` | 1 archivo(s) |
| 40 | `sp_aseo_contrato_consultar` | 10 archivo(s) |
| 41 | `sp_aseo_adeudos_pendientes` | 3 archivo(s) |
| 42 | `sp_aseo_pago_multiple` | 1 archivo(s) |
| 43 | `sp_aseo_pagos_buscar` | 1 archivo(s) |
| 44 | `sp_aseo_pagos_actualizar_periodos` | 1 archivo(s) |
| 45 | `sp_aseo_pagos_historial_actualizaciones` | 1 archivo(s) |
| 46 | `sp_aseo_adeudos_por_contrato` | 3 archivo(s) |
| 47 | `sp_aseo_aplicar_exencion` | 1 archivo(s) |
| 48 | `sp_aseo_adeudos_vencidos` | 1 archivo(s) |
| 49 | `sp_aseo_multa_aplicar` | 1 archivo(s) |
| 50 | `sp_aseo_consulta_contratos` | 1 archivo(s) |
| 51 | `sp_aseo_detalle_contrato` | 1 archivo(s) |
| 52 | `sp_aseo_consulta_ordenada` | 1 archivo(s) |
| 53 | `sp_aseo_contratos_list` | 1 archivo(s) |
| 54 | `sp_aseo_cancelar_contrato` | 1 archivo(s) |
| 55 | `sp_aseo_estadisticas_contratos` | 1 archivo(s) |
| 56 | `sp_aseo_contratos_create` | 1 archivo(s) |
| 57 | `sp_aseo_contratos_baja` | 1 archivo(s) |
| 58 | `sp_aseo_pagos_por_contrato` | 2 archivo(s) |
| 59 | `sp_aseo_contrato_cancelar` | 1 archivo(s) |
| 60 | `sp_aseo_contratos_consulta_admin` | 1 archivo(s) |
| 61 | `sp_aseo_contratos_por_tipo` | 1 archivo(s) |
| 62 | `sp_aseo_estadisticas_generales` | 1 archivo(s) |
| 63 | `sp_aseo_estadisticas_por_tipo` | 2 archivo(s) |
| 64 | `sp_aseo_estadisticas_por_empresa` | 2 archivo(s) |
| 65 | `sp_aseo_estadisticas_por_zona` | 1 archivo(s) |
| 66 | `sp_aseo_contratos_update` | 1 archivo(s) |
| 67 | `sp_aseo_contratos_para_upd_periodo` | 1 archivo(s) |
| 68 | `sp_aseo_actualizar_periodos_contratos` | 1 archivo(s) |
| 69 | `sp_aseo_contratos_para_upd_unidad` | 1 archivo(s) |
| 70 | `sp_aseo_actualizar_unidades_contratos` | 1 archivo(s) |
| 71 | `sp_aseo_estadisticas_sincronizacion` | 1 archivo(s) |
| 72 | `sp_aseo_convenio_crear` | 1 archivo(s) |
| 73 | `sp_aseo_convenios_consultar` | 1 archivo(s) |
| 74 | `sp_aseo_ejercicios_listar` | 1 archivo(s) |
| 75 | `sp_aseo_ejercicio_estadisticas` | 1 archivo(s) |
| 76 | `sp_aseo_ejercicio_cerrar` | 1 archivo(s) |
| 77 | `sp_aseo_periodos_listar` | 1 archivo(s) |
| 78 | `sp_aseo_periodo_eliminar` | 1 archivo(s) |
| 79 | `sp_aseo_tarifas_listar` | 1 archivo(s) |
| 80 | `sp_aseo_tarifa_eliminar` | 1 archivo(s) |
| 81 | `sp_aseo_tarifas_copiar` | 1 archivo(s) |
| 82 | `sp_aseo_empresas_get` | 1 archivo(s) |
| 83 | `sp_aseo_contratos_por_empresa` | 1 archivo(s) |
| 84 | `sp_aseo_estadisticas_avanzadas` | 1 archivo(s) |
| 85 | `sp_aseo_pagos_por_contrato_asc` | 1 archivo(s) |
| 86 | `sp_aseo_pagos_por_forma_pago` | 1 archivo(s) |
| 87 | `sp_aseo_relaciones_listar` | 1 archivo(s) |
| 88 | `sp_aseo_contratos_vincular` | 1 archivo(s) |
| 89 | `sp_aseo_contratos_desvincular` | 1 archivo(s) |
| 90 | `sp_aseo_grupos_listar` | 1 archivo(s) |
| 91 | `sp_aseo_grupo_contratos_listar` | 1 archivo(s) |
| 92 | `sp_aseo_grupo_agregar_contrato` | 1 archivo(s) |
| 93 | `sp_aseo_grupo_quitar_contrato` | 1 archivo(s) |
| 94 | `sp_aseo_relaciones_consultar` | 1 archivo(s) |
| 95 | `sp_aseo_reporte_adeudos_condonados` | 1 archivo(s) |
| 96 | `sp_aseo_reporte_padron_contratos` | 1 archivo(s) |
| 97 | `sp_aseo_reporte_recaudadoras` | 1 archivo(s) |
| 98 | `sp_aseo_reporte_tipos_aseo` | 1 archivo(s) |
| 99 | `sp_aseo_reporte_por_zonas` | 1 archivo(s) |
| 100 | `sp_aseo_pagos_by_contrato` | 1 archivo(s) |
| 101 | `sp_aseo_buscar_contrato_individual` | 1 archivo(s) |
| 102 | `sp_aseo_actualizar_contrato_individual` | 1 archivo(s) |
| 103 | `sp_aseo_contratos_para_actualizar` | 1 archivo(s) |
| 104 | `sp_aseo_aplicar_actualizaciones_masivas` | 1 archivo(s) |
| 105 | `sp_aseo_contratos_sin_periodo_inicial` | 1 archivo(s) |
| 106 | `sp_cem_listar_cementerios` | 6 archivo(s) |
| 107 | `sp_cem_abc_cementerios` | 2 archivo(s) |
| 108 | `sp_cem_buscar_folio` | 4 archivo(s) |
| 109 | `sp_cem_modificar_folio` | 2 archivo(s) |
| 110 | `sp_cem_baja_folio` | 2 archivo(s) |
| 111 | `sp_cem_buscar_folio_pagos` | 2 archivo(s) |
| 112 | `sp_cem_obtener_adeudos_pendientes` | 2 archivo(s) |
| 113 | `sp_cem_listar_pagos_folio` | 2 archivo(s) |
| 114 | `sp_cem_registrar_pago` | 2 archivo(s) |
| 115 | `sp_cem_abc_pagos_por_folio` | 1 archivo(s) |
| 116 | `sp_validar_usuario` | 1 archivo(s) |
| 117 | `sp_registrar_acceso` | 1 archivo(s) |
| 118 | `sp_cem_consultar_folio` | 8 archivo(s) |
| 119 | `sp_cem_bonificaciones_oficio` | 1 archivo(s) |
| 120 | `sp_cem_buscar_bonificacion` | 2 archivo(s) |
| 121 | `sp_cem_registrar_bonificacion` | 2 archivo(s) |
| 122 | `sp_cem_eliminar_bonificacion` | 2 archivo(s) |
| 123 | `sp_cem_consultar_pagos_folio` | 2 archivo(s) |
| 124 | `sp_cem_consultar_cementerio` | 5 archivo(s) |
| 125 | `sp_cem_obtener_pagos_folio` | 2 archivo(s) |
| 126 | `sp_cem_obtener_adeudos_folio` | 2 archivo(s) |
| 127 | `sp_cem_consultar_por_nombre` | 1 archivo(s) |
| 128 | `sp_cem_buscar_duplicados` | 1 archivo(s) |
| 129 | `sp_cem_verificar_ubicacion_duplicado` | 1 archivo(s) |
| 130 | `sp_cem_trasladar_duplicado` | 1 archivo(s) |
| 131 | `sp_cem_estadisticas_adeudos` | 1 archivo(s) |
| 132 | `sp_cem_calcular_liquidacion` | 2 archivo(s) |
| 133 | `sp_cem_listar_movimientos` | 1 archivo(s) |
| 134 | `sp_cem_consultar_pagos_por_fecha` | 1 archivo(s) |
| 135 | `sp_cem_consultar_folios_por_nombre` | 1 archivo(s) |
| 136 | `sp_cem_consultar_folios_por_ubicacion` | 1 archivo(s) |
| 137 | `sp_cem_reporte_cuentas_cobrar` | 1 archivo(s) |
| 138 | `sp_cem_reporte_bonificaciones` | 1 archivo(s) |
| 139 | `sp_cem_reporte_titulos` | 2 archivo(s) |
| 140 | `sp_validar_password_actual` | 1 archivo(s) |
| 141 | `sp_cambiar_password` | 1 archivo(s) |
| 142 | `sp_cem_listar_titulos` | 2 archivo(s) |
| 143 | `sp_cem_buscar_titulo` | 2 archivo(s) |
| 144 | `sp_cem_actualizar_titulo_extra` | 2 archivo(s) |
| 145 | `sp_cem_generar_titulo` | 1 archivo(s) |
| 146 | `sp_cem_listar_pagos` | 1 archivo(s) |
| 147 | `sp_cem_trasladar_folio` | 1 archivo(s) |
| 148 | `sp_chgpass_historial` | 1 archivo(s) |
| 149 | `sp_sfrm_baja_pub` | 1 archivo(s) |
| 150 | `spubreports` | 2 archivo(s) |
| 151 | `spget_lic_detalles` | 1 archivo(s) |
| 152 | `recaudadora_get_ejecutores` | 1 archivo(s) |
| 153 | `recaudadora_parse_file` | 1 archivo(s) |
| 154 | `recaudadora_actualiza_fechas` | 1 archivo(s) |
| 155 | `recaudadora_consulta_sdos_favor` | 1 archivo(s) |
| 156 | `recaudadora_aplica_sdos_favor` | 1 archivo(s) |
| 157 | `recaudadora_autdescto` | 1 archivo(s) |
| 158 | `recaudadora_bloqctasreqfrm` | 1 archivo(s) |
| 159 | `recaudadora_bloqueo_multa` | 1 archivo(s) |
| 160 | `recaudadora_busque` | 1 archivo(s) |
| 161 | `recaudadora_canc` | 1 archivo(s) |
| 162 | `recaudadora_captura_dif` | 1 archivo(s) |
| 163 | `recaudadora_carta_invitacion` | 1 archivo(s) |
| 164 | `recaudadora_catastro_dm` | 1 archivo(s) |
| 165 | `recaudadora_centrosfrm` | 1 archivo(s) |
| 166 | `recaudadora_codificafrm` | 1 archivo(s) |
| 167 | `recaudadora_conscentrosfrm` | 1 archivo(s) |
| 168 | `recaudadora_consdesc` | 1 archivo(s) |
| 169 | `recaudadora_descderechos_merc` | 1 archivo(s) |
| 170 | `recaudadora_drecgo_fosa` | 1 archivo(s) |
| 171 | `recaudadora_drecgo_trans` | 1 archivo(s) |
| 172 | `recaudadora_ejecutores` | 1 archivo(s) |
| 173 | `recaudadora_empresas` | 1 archivo(s) |
| 174 | `recaudadora_exclusivos_upd` | 1 archivo(s) |
| 175 | `recaudadora_extractos_rpt` | 1 archivo(s) |
| 176 | `recaudadora_firma_electronica` | 1 archivo(s) |
| 177 | `recaudadora_fol_multa` | 1 archivo(s) |
| 178 | `recaudadora_gastos_transmision` | 1 archivo(s) |
| 179 | `recaudadora_hastafrm` | 1 archivo(s) |
| 180 | `recaudadora_imprime_desctos` | 1 archivo(s) |
| 181 | `recaudadora_lista_diferencias` | 1 archivo(s) |
| 182 | `recaudadora_listado_multiple` | 1 archivo(s) |
| 183 | `recaudadora_listana` | 1 archivo(s) |
| 184 | `recaudadora_modif_masiva` | 1 archivo(s) |
| 185 | `recaudadora_multas_dm` | 1 archivo(s) |
| 186 | `recaudadora_otorga_descto` | 1 archivo(s) |
| 187 | `recaudadora_pagos_espe` | 1 archivo(s) |
| 188 | `recaudadora_periodo_inicial` | 1 archivo(s) |
| 189 | `recaudadora_propuestatab` | 1 archivo(s) |
| 190 | `recaudadora_publicos_upd` | 1 archivo(s) |
| 191 | `recaudadora_regsecymas` | 1 archivo(s) |
| 192 | `recaudadora_rep_desc_impto` | 1 archivo(s) |
| 193 | `recaudadora_rep_oper` | 1 archivo(s) |
| 194 | `recaudadora_req` | 1 archivo(s) |
| 195 | `recaudadora_req_frm_save` | 1 archivo(s) |
| 196 | `recaudadora_req_promocion` | 1 archivo(s) |
| 197 | `recaudadora_reqtrans_list` | 1 archivo(s) |
| 198 | `recaudadora_reqtrans_create` | 1 archivo(s) |
| 199 | `recaudadora_reqtrans_update` | 1 archivo(s) |
| 200 | `recaudadora_reqtrans_delete` | 1 archivo(s) |
| 201 | `recaudadora_requerimientos_dm` | 1 archivo(s) |
| 202 | `recaudadora_requerxcvecat` | 1 archivo(s) |
| 203 | `recaudadora_resolucion_juez` | 1 archivo(s) |
| 204 | `recaudadora_sdosfavor_dm` | 1 archivo(s) |
| 205 | `recaudadora_sdosfavor_ctrlexp` | 1 archivo(s) |
| 206 | `recaudadora_sdosfavor_pagos` | 1 archivo(s) |
| 207 | `recaudadora_sinligarfrm` | 1 archivo(s) |
| 208 | `recaudadora_sol_sdos_favor` | 1 archivo(s) |
| 209 | `recaudadora_tdm_conection` | 1 archivo(s) |
| 210 | `recaudadora_ubicodifica` | 1 archivo(s) |
| 211 | `sp_auxrep_tablas_get` | 1 archivo(s) |
| 212 | `sp_auxrep_etiquetas_get` | 1 archivo(s) |
| 213 | `sp_auxrep_vigencias_get` | 1 archivo(s) |
| 214 | `sp_auxrep_padron_get` | 1 archivo(s) |
| 215 | `sp_cargacartera_tablas_get` | 1 archivo(s) |
| 216 | `sp_cargacartera_ejercicios_get` | 1 archivo(s) |
| 217 | `sp_cargacartera_unidades_get` | 1 archivo(s) |
| 218 | `sp_cargacartera_aplica` | 1 archivo(s) |
| 219 | `sp_etiquetas_tablas_get` | 1 archivo(s) |
| 220 | `sp_etiquetas_get` | 1 archivo(s) |
| 221 | `sp_etiquetas_update` | 1 archivo(s) |
| 222 | `sp_otras_oblig_get_etiquetas` | 7 archivo(s) |
| 223 | `sp_otras_oblig_get_tablas` | 7 archivo(s) |
| 224 | `sp_gactualiza_dependencias_get` | 1 archivo(s) |
| 225 | `sp_gactualiza_datos_get` | 1 archivo(s) |
| 226 | `sp_gactualiza_multas_get` | 1 archivo(s) |
| 227 | `sp_gactualiza_suspension_get` | 1 archivo(s) |
| 228 | `sp_gactualiza_multas_update` | 1 archivo(s) |
| 229 | `sp_gactualiza_suspension_create` | 1 archivo(s) |
| 230 | `sp_gadeudos_datos_get` | 1 archivo(s) |
| 231 | `sp_gadeudos_detalle_01` | 1 archivo(s) |
| 232 | `sp_gadeudos_detalle_02` | 1 archivo(s) |
| 233 | `sp_gadeudosgral_tablas_get` | 1 archivo(s) |
| 234 | `sp_gadeudosgral_etiquetas_get` | 1 archivo(s) |
| 235 | `spcon34_gcont_01` | 1 archivo(s) |
| 236 | `sp_gadeudos_opc_mult_recaudadoras_get` | 1 archivo(s) |
| 237 | `sp_gadeudos_opcmult_ra_tablas_get` | 1 archivo(s) |
| 238 | `sp_gadeudos_opcmult_ra_etiquetas_get` | 1 archivo(s) |
| 239 | `sp_gadeudos_opcmult_ra_datos_get` | 1 archivo(s) |
| 240 | `sp_gadeudos_opcmult_ra_reactivar` | 1 archivo(s) |
| 241 | `sp_gbaja_datos_get` | 1 archivo(s) |
| 242 | `sp_gbaja_adeudos_detalle` | 1 archivo(s) |
| 243 | `sp_gbaja_adeudos_totales` | 1 archivo(s) |
| 244 | `sp_gbaja_pagos_get` | 1 archivo(s) |
| 245 | `sp_gbaja_aplicar` | 1 archivo(s) |
| 246 | `sp_gconsulta_datos_get` | 1 archivo(s) |
| 247 | `sp_gconsulta_adeudos_get` | 1 archivo(s) |
| 248 | `sp_gconsulta_pagados_get` | 1 archivo(s) |
| 249 | `sp_otras_oblig_buscar_coincide` | 1 archivo(s) |
| 250 | `sp_otras_oblig_buscar_cont` | 3 archivo(s) |
| 251 | `sp_otras_oblig_buscar_totales` | 2 archivo(s) |
| 252 | `sp_otras_oblig_buscar_adeudos` | 2 archivo(s) |
| 253 | `sp_otras_oblig_buscar_pagados` | 1 archivo(s) |
| 254 | `sp_gfacturacion_datos_get` | 1 archivo(s) |
| 255 | `con34_1datos_03` | 1 archivo(s) |
| 256 | `sp_rfacturacion_obtener` | 1 archivo(s) |
| 257 | `sp_rubros_listar` | 1 archivo(s) |
| 258 | `sp_verifica_firma` | 3 archivo(s) |
| 259 | `sp_consulta_anuncios_licencia` | 1 archivo(s) |
| 260 | `sp_bloquearanuncio_get_anuncio` | 1 archivo(s) |
| 261 | `sp_bloquearanuncio_get_bloqueos` | 1 archivo(s) |
| 262 | `sp_bloquearanuncio_bloquear` | 1 archivo(s) |
| 263 | `sp_bloquearanuncio_desbloquear` | 1 archivo(s) |
| 264 | `sp_bloquearlicencia_get_licencia` | 1 archivo(s) |
| 265 | `sp_bloquearlicencia_get_bloqueos` | 1 archivo(s) |
| 266 | `sp_bloquearlicencia_bloquear` | 1 archivo(s) |
| 267 | `sp_bloquearlicencia_desbloquear` | 1 archivo(s) |
| 268 | `sp_bloqueartramite_get_tramite` | 1 archivo(s) |
| 269 | `sp_bloqueartramite_get_bloqueos` | 1 archivo(s) |
| 270 | `sp_bloqueartramite_get_giro` | 1 archivo(s) |
| 271 | `sp_bloqueartramite_bloquear` | 1 archivo(s) |
| 272 | `sp_bloqueartramite_desbloquear` | 1 archivo(s) |
| 273 | `sp_bloqueodomicilios_update` | 1 archivo(s) |
| 274 | `sp_bloqueodomicilios_list` | 1 archivo(s) |
| 275 | `sp_bloqueodomicilios_create` | 1 archivo(s) |
| 276 | `sp_bloqueodomicilios_cancel` | 1 archivo(s) |
| 277 | `sp_bloqueorfc_list` | 1 archivo(s) |
| 278 | `sp_bloqueorfc_buscar_tramite` | 1 archivo(s) |
| 279 | `sp_bloqueorfc_create` | 1 archivo(s) |
| 280 | `sp_bloqueorfc_desbloquear` | 1 archivo(s) |
| 281 | `consulta_giros_estadisticas` | 1 archivo(s) |
| 282 | `buscagiro_list` | 1 archivo(s) |
| 283 | `carga_imagen_sp_get_tramite_info` | 1 archivo(s) |
| 284 | `carga_imagen_sp_get_tramite_documents` | 1 archivo(s) |
| 285 | `carga_imagen_sp_get_document_types` | 1 archivo(s) |
| 286 | `carga_imagen_sp_upload_document_image` | 1 archivo(s) |
| 287 | `carga_imagen_sp_get_document_image` | 1 archivo(s) |
| 288 | `carga_imagen_sp_delete_document_image` | 1 archivo(s) |
| 289 | `sp_catalogo_actividades_list` | 1 archivo(s) |
| 290 | `sp_catalogo_actividades_create` | 1 archivo(s) |
| 291 | `sp_catalogo_actividades_update` | 1 archivo(s) |
| 292 | `sp_catalogo_actividades_delete` | 1 archivo(s) |
| 293 | `sp_catalogogiros_estadisticas` | 1 archivo(s) |
| 294 | `sp_catalogogiros_list` | 1 archivo(s) |
| 295 | `sp_catalogogiros_get` | 1 archivo(s) |
| 296 | `sp_catalogogiros_create` | 1 archivo(s) |
| 297 | `sp_catalogogiros_update` | 1 archivo(s) |
| 298 | `sp_catalogogiros_cambiar_vigencia` | 1 archivo(s) |
| 299 | `sp_checa_inhabil` | 1 archivo(s) |
| 300 | `sp_generar_dictamen_microgeneradores` | 1 archivo(s) |
| 301 | `sp_imprimir_dictamen_microgeneradores` | 1 archivo(s) |
| 302 | `sp_get_derechos2` | 1 archivo(s) |
| 303 | `sp_refresh_query` | 1 archivo(s) |
| 304 | `certificaciones_list` | 1 archivo(s) |
| 305 | `certificaciones_estadisticas` | 1 archivo(s) |
| 306 | `certificaciones_get_next_folio` | 1 archivo(s) |
| 307 | `certificaciones_create` | 1 archivo(s) |
| 308 | `certificaciones_update` | 1 archivo(s) |
| 309 | `certificaciones_delete` | 1 archivo(s) |
| 310 | `sp_cons_anun_400_frm_get_anuncio_400` | 1 archivo(s) |
| 311 | `sp_cons_anun_400_frm_get_pagos_anun_400` | 1 archivo(s) |
| 312 | `sp_cons_lic_400_frm_get_lic_400` | 1 archivo(s) |
| 313 | `sp_cons_lic_400_frm_get_pago_lic_400` | 1 archivo(s) |
| 314 | `constancias_list` | 1 archivo(s) |
| 315 | `constancias_estadisticas` | 1 archivo(s) |
| 316 | `constancias_get_next_folio` | 1 archivo(s) |
| 317 | `constancias_create` | 1 archivo(s) |
| 318 | `constancias_update` | 1 archivo(s) |
| 319 | `constancias_delete` | 1 archivo(s) |
| 320 | `sp_solicnooficial_list` | 1 archivo(s) |
| 321 | `consulta_anuncios_list` | 1 archivo(s) |
| 322 | `consulta_anuncios_estadisticas` | 1 archivo(s) |
| 323 | `consulta_licencias_estadisticas` | 2 archivo(s) |
| 324 | `consulta_licencias_list` | 2 archivo(s) |
| 325 | `consulta_tramites_list` | 1 archivo(s) |
| 326 | `consulta_tramites_estadisticas` | 1 archivo(s) |
| 327 | `get_all_usuarios` | 1 archivo(s) |
| 328 | `crear_usuario` | 1 archivo(s) |
| 329 | `actualizar_usuario` | 1 archivo(s) |
| 330 | `dar_baja_usuario` | 1 archivo(s) |
| 331 | `sp_dependencias_list` | 1 archivo(s) |
| 332 | `sp_dependencias_create` | 1 archivo(s) |
| 333 | `sp_dependencias_update` | 1 archivo(s) |
| 334 | `sp_dependencias_delete` | 1 archivo(s) |
| 335 | `sp_get_saldo_licencia` | 2 archivo(s) |
| 336 | `sp_dictamenes_estadisticas` | 1 archivo(s) |
| 337 | `sp_dictamenes_list` | 1 archivo(s) |
| 338 | `sp_dictamenes_create` | 1 archivo(s) |
| 339 | `sp_dictamenes_update` | 1 archivo(s) |
| 340 | `sp_empresas_estadisticas` | 1 archivo(s) |
| 341 | `estatusfrm_sp_get_revision_info` | 1 archivo(s) |
| 342 | `estatusfrm_sp_get_historial_estatus` | 1 archivo(s) |
| 343 | `estatusfrm_sp_cambiar_estatus_revision` | 1 archivo(s) |
| 344 | `sp_fechaseg_list` | 1 archivo(s) |
| 345 | `sp_fechaseg_update` | 1 archivo(s) |
| 346 | `sp_fechaseg_create` | 1 archivo(s) |
| 347 | `sp_fechaseg_delete` | 1 archivo(s) |
| 348 | `frmimplicenciareglamentada_sp_get_licencias_reglamentadas` | 1 archivo(s) |
| 349 | `frmimplicenciareglamentada_sp_create_licencia_reglamentada` | 1 archivo(s) |
| 350 | `frmimplicenciareglamentada_sp_get_licencia_reglamentada_by_id` | 1 archivo(s) |
| 351 | `frmimplicenciareglamentada_sp_update_licencia_reglamentada` | 1 archivo(s) |
| 352 | `frmimplicenciareglamentada_sp_delete_licencia_reglamentada` | 1 archivo(s) |
| 353 | `sp_frmselcalle_get_calles` | 1 archivo(s) |
| 354 | `sp_frmselcalle_get_calle_by_ids` | 1 archivo(s) |
| 355 | `sp_giros_dcon_adeudo` | 1 archivo(s) |
| 356 | `sp_report_giros_dcon_adeudo` | 1 archivo(s) |
| 357 | `girosvigentesctexgirofrm_sp_get_catalogo_giros` | 1 archivo(s) |
| 358 | `girosvigentesctexgirofrm_sp_giros_vigentes_cte_x_giro` | 1 archivo(s) |
| 359 | `girosvigentesctexgirofrm_sp_reporte_giros_vigentes_cte_xgiro` | 1 archivo(s) |
| 360 | `grs_dlg_sp_get_giros` | 1 archivo(s) |
| 361 | `grs_dlg_sp_search_giros` | 1 archivo(s) |
| 362 | `gruposanunciosabcfrm_sp_anuncios_grupos_list` | 1 archivo(s) |
| 363 | `gruposanunciosabcfrm_sp_anuncios_grupos_insert` | 1 archivo(s) |
| 364 | `gruposanunciosabcfrm_sp_anuncios_grupos_update` | 1 archivo(s) |
| 365 | `gruposanunciosabcfrm_sp_anuncios_grupos_delete` | 1 archivo(s) |
| 366 | `delete_grupo_anuncio` | 1 archivo(s) |
| 367 | `get_anuncios_grupo` | 1 archivo(s) |
| 368 | `h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom` | 1 archivo(s) |
| 369 | `h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom` | 1 archivo(s) |
| 370 | `h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle` | 1 archivo(s) |
| 371 | `h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel` | 1 archivo(s) |
| 372 | `h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report` | 1 archivo(s) |
| 373 | `implicenciareglamentada_sp_get_license_data` | 1 archivo(s) |
| 374 | `implicenciareglamentada_sp_print_license` | 1 archivo(s) |
| 375 | `sp_get_licencia_reglamentada` | 1 archivo(s) |
| 376 | `sp_check_licencia_bloqueada` | 1 archivo(s) |
| 377 | `sp_calcular_adeudo_licencia` | 1 archivo(s) |
| 378 | `sp_detalle_saldo_licencia` | 1 archivo(s) |
| 379 | `licenciasvigentesfrm_sp_stats` | 1 archivo(s) |
| 380 | `licenciasvigentesfrm_sp_licencias_vigentes` | 1 archivo(s) |
| 381 | `sp_get_licencia_by_id` | 1 archivo(s) |
| 382 | `sp_get_detsal_lic` | 1 archivo(s) |
| 383 | `sp_get_saldos_lic` | 1 archivo(s) |
| 384 | `sp_modlic_buscar_licencia` | 1 archivo(s) |
| 385 | `sp_modlic_buscar_anuncio` | 1 archivo(s) |
| 386 | `sp_get_scian_catalogo` | 1 archivo(s) |
| 387 | `sp_get_actividades_por_scian` | 1 archivo(s) |
| 388 | `sp_get_tipos_anuncio` | 1 archivo(s) |
| 389 | `sp_modlic_actualizar_licencia` | 1 archivo(s) |
| 390 | `sp_modlic_actualizar_anuncio` | 1 archivo(s) |
| 391 | `sp_calc_sdos_lic` | 1 archivo(s) |
| 392 | `sp_modlic_recalcular_adeudo_anuncio` | 1 archivo(s) |
| 393 | `sp_get_session_id` | 1 archivo(s) |
| 394 | `sp_modlic_limpiar_sesion` | 1 archivo(s) |
| 395 | `sp_get_ubicacion_sesion` | 1 archivo(s) |
| 396 | `sp_modlic_actualizar_coordenadas` | 1 archivo(s) |
| 397 | `sp_update_tramite` | 1 archivo(s) |
| 398 | `sp_get_giros_search` | 1 archivo(s) |
| 399 | `sp_get_calles_search` | 1 archivo(s) |
| 400 | `sp_observaciones_list` | 1 archivo(s) |
| 401 | `sp_observaciones_create` | 1 archivo(s) |
| 402 | `sp_observaciones_update` | 1 archivo(s) |
| 403 | `sp_observaciones_delete` | 1 archivo(s) |
| 404 | `privilegios_privilegios_get_permisos_usuario` | 1 archivo(s) |
| 405 | `privilegios_privilegios_get_deptos` | 1 archivo(s) |
| 406 | `privilegios_privilegios_get_mov_licencias` | 1 archivo(s) |
| 407 | `privilegios_privilegios_get_mov_tramites` | 1 archivo(s) |
| 408 | `privilegios_privilegios_get_revisiones` | 1 archivo(s) |
| 409 | `privilegios_privilegios_get_auditoria_usuario` | 1 archivo(s) |
| 410 | `sp_propuestatab_list` | 1 archivo(s) |
| 411 | `sp_propuestatab_condominio` | 1 archivo(s) |
| 412 | `sp_psplash_get_user_info` | 1 archivo(s) |
| 413 | `sp_psplash_get_announcements` | 1 archivo(s) |
| 414 | `sp_psplash_get_stats` | 1 archivo(s) |
| 415 | `sp_reactivar_tramite` | 1 archivo(s) |
| 416 | `reghfrm_sp_get_historic_records` | 1 archivo(s) |
| 417 | `reghfrm_sp_create_historic_record` | 1 archivo(s) |
| 418 | `reghfrm_sp_get_historic_record` | 1 archivo(s) |
| 419 | `reghfrm_sp_delete_historic_record` | 1 archivo(s) |
| 420 | `sfrm_chgfirma_upd_firma` | 1 archivo(s) |
| 421 | `sfrm_chgpass_sp_validate_current` | 1 archivo(s) |
| 422 | `sfrm_chgpass_sp_update` | 1 archivo(s) |
| 423 | `sfrm_chgpass_sp_bitacora` | 1 archivo(s) |
| 424 | `sgcv2_sp_get_quality_indicators` | 1 archivo(s) |
| 425 | `sgcv2_sp_get_processes` | 1 archivo(s) |
| 426 | `sgcv2_sp_save_process` | 1 archivo(s) |
| 427 | `tdmconection_sp_get_connection_status` | 1 archivo(s) |
| 428 | `tdmconection_sp_get_sync_log` | 1 archivo(s) |
| 429 | `tdmconection_sp_sync_tramites` | 1 archivo(s) |
| 430 | `sp_tipobloqueo_list` | 1 archivo(s) |
| 431 | `sp_tipobloqueo_create` | 1 archivo(s) |
| 432 | `sp_tipobloqueo_update` | 1 archivo(s) |
| 433 | `sp_tipobloqueo_delete` | 1 archivo(s) |
| 434 | `tramitebajaanun_sp_tramite_baja_anun_buscar` | 1 archivo(s) |
| 435 | `tramitebajaanun_sp_tramite_baja_anun_tramitar` | 1 archivo(s) |
| 436 | `tramitebajalic_sp_tramite_baja_lic_consulta` | 1 archivo(s) |
| 437 | `tramitebajalic_spget_lic_adeudos` | 1 archivo(s) |
| 438 | `tramitebajalic_sp_tramite_baja_lic_tramitar` | 1 archivo(s) |
| 439 | `tramitebajalic_sp_recalcula_proporcional_baja` | 1 archivo(s) |
| 440 | `tramitebajalic_sp_tramite_baja_lic_recalcula` | 1 archivo(s) |
| 441 | `unidadimg_get_unidad_img` | 1 archivo(s) |
| 442 | `unidadimg_set_unidad_img` | 1 archivo(s) |
| 443 | `unidadimg_get_ruta_dir` | 1 archivo(s) |
| 444 | `unidadimg_rutadir` | 1 archivo(s) |
| 445 | `webbrowser_sp_get_bookmarks` | 1 archivo(s) |
| 446 | `webbrowser_sp_save_bookmark` | 1 archivo(s) |
| 447 | `webbrowser_sp_delete_bookmark` | 1 archivo(s) |

### Detalle de SPs Faltantes:

#### 1. `sp_aseo_cves_operacion_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Cves_Operacion.vue`
- `src\views\modules\aseo_contratado\AdeudosMult_Ins.vue`

**Acción requerida**: Crear el SP `sp_aseo_cves_operacion_list` en la base de datos PostgreSQL.

#### 2. `sp_aseo_cves_operacion_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Cves_Operacion.vue`

**Acción requerida**: Crear el SP `sp_aseo_cves_operacion_create` en la base de datos PostgreSQL.

#### 3. `sp_aseo_cves_operacion_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Cves_Operacion.vue`

**Acción requerida**: Crear el SP `sp_aseo_cves_operacion_update` en la base de datos PostgreSQL.

#### 4. `sp_aseo_cves_operacion_delete`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Cves_Operacion.vue`

**Acción requerida**: Crear el SP `sp_aseo_cves_operacion_delete` en la base de datos PostgreSQL.

#### 5. `sp_aseo_empresas_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Empresas.vue`
- `src\views\modules\aseo_contratado\AdeudosMult_Ins.vue`
- `src\views\modules\aseo_contratado\Adeudos_Venc.vue`
- `src\views\modules\aseo_contratado\Contratos.vue`
- `src\views\modules\aseo_contratado\ContratosEst.vue`
- `src\views\modules\aseo_contratado\Contratos_Alta.vue`
- `src\views\modules\aseo_contratado\Contratos_Cons_Admin.vue`
- `src\views\modules\aseo_contratado\Contratos_Upd_Periodo.vue`
- `src\views\modules\aseo_contratado\Empresas_Contratos.vue`
- `src\views\modules\aseo_contratado\Ins_b.vue`
- `src\views\modules\aseo_contratado\Rep_PadronContratos.vue`
- `src\views\modules\aseo_contratado\Rep_Zonas.vue`
- `src\views\modules\aseo_contratado\Rpt_Adeudos.vue`
- `src\views\modules\aseo_contratado\Rpt_Contratos.vue`
- `src\views\modules\aseo_contratado\Rpt_Empresas.vue`
- `src\views\modules\aseo_contratado\UpdxCont.vue`
- `src\views\modules\aseo_contratado\Upd_01.vue`
- `src\views\modules\aseo_contratado\Upd_IniObl.vue`

**Acción requerida**: Crear el SP `sp_aseo_empresas_list` en la base de datos PostgreSQL.

#### 6. `sp_aseo_empresas_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Empresas.vue`

**Acción requerida**: Crear el SP `sp_aseo_empresas_create` en la base de datos PostgreSQL.

#### 7. `sp_aseo_empresas_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Empresas.vue`

**Acción requerida**: Crear el SP `sp_aseo_empresas_update` en la base de datos PostgreSQL.

#### 8. `sp_aseo_empresas_delete`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Empresas.vue`

**Acción requerida**: Crear el SP `sp_aseo_empresas_delete` en la base de datos PostgreSQL.

#### 9. `sp_aseo_gastos_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Gastos.vue`

**Acción requerida**: Crear el SP `sp_aseo_gastos_list` en la base de datos PostgreSQL.

#### 10. `sp_aseo_gastos_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Gastos.vue`

**Acción requerida**: Crear el SP `sp_aseo_gastos_create` en la base de datos PostgreSQL.

#### 11. `sp_aseo_gastos_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Gastos.vue`

**Acción requerida**: Crear el SP `sp_aseo_gastos_update` en la base de datos PostgreSQL.

#### 12. `sp_aseo_gastos_delete`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Gastos.vue`

**Acción requerida**: Crear el SP `sp_aseo_gastos_delete` en la base de datos PostgreSQL.

#### 13. `sp_aseo_recargos_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Recargos.vue`

**Acción requerida**: Crear el SP `sp_aseo_recargos_list` en la base de datos PostgreSQL.

#### 14. `sp_aseo_recargos_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Recargos.vue`

**Acción requerida**: Crear el SP `sp_aseo_recargos_create` en la base de datos PostgreSQL.

#### 15. `sp_aseo_recargos_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Recargos.vue`

**Acción requerida**: Crear el SP `sp_aseo_recargos_update` en la base de datos PostgreSQL.

#### 16. `sp_aseo_recargos_delete`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Recargos.vue`

**Acción requerida**: Crear el SP `sp_aseo_recargos_delete` en la base de datos PostgreSQL.

#### 17. `sp_aseo_recaudadoras_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Recaudadoras.vue`
- `src\views\modules\aseo_contratado\Rep_Recaudadoras.vue`
- `src\views\modules\aseo_contratado\Rpt_Pagos.vue`

**Acción requerida**: Crear el SP `sp_aseo_recaudadoras_list` en la base de datos PostgreSQL.

#### 18. `sp_aseo_tipos_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Tipos_Aseo.vue`
- `src\views\modules\aseo_contratado\ActCont_CR.vue`
- `src\views\modules\aseo_contratado\Contratos_Alta.vue`
- `src\views\modules\aseo_contratado\Contratos_Consulta.vue`
- `src\views\modules\aseo_contratado\Contratos_Mod.vue`
- `src\views\modules\aseo_contratado\Rpt_Adeudos.vue`

**Acción requerida**: Crear el SP `sp_aseo_tipos_list` en la base de datos PostgreSQL.

#### 19. `sp_aseo_tipos_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Tipos_Aseo.vue`

**Acción requerida**: Crear el SP `sp_aseo_tipos_create` en la base de datos PostgreSQL.

#### 20. `sp_aseo_tipos_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Tipos_Aseo.vue`

**Acción requerida**: Crear el SP `sp_aseo_tipos_update` en la base de datos PostgreSQL.

#### 21. `sp_aseo_tipos_delete`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Tipos_Aseo.vue`

**Acción requerida**: Crear el SP `sp_aseo_tipos_delete` en la base de datos PostgreSQL.

#### 22. `sp_aseo_tipos_emp_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Tipos_Emp.vue`

**Acción requerida**: Crear el SP `sp_aseo_tipos_emp_list` en la base de datos PostgreSQL.

#### 23. `sp_aseo_tipos_emp_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Tipos_Emp.vue`

**Acción requerida**: Crear el SP `sp_aseo_tipos_emp_create` en la base de datos PostgreSQL.

#### 24. `sp_aseo_tipos_emp_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Tipos_Emp.vue`

**Acción requerida**: Crear el SP `sp_aseo_tipos_emp_update` en la base de datos PostgreSQL.

#### 25. `sp_aseo_tipos_emp_delete`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Tipos_Emp.vue`

**Acción requerida**: Crear el SP `sp_aseo_tipos_emp_delete` en la base de datos PostgreSQL.

#### 26. `sp_aseo_unidades_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Und_Recolec.vue`
- `src\views\modules\aseo_contratado\ActCont_CR.vue`
- `src\views\modules\aseo_contratado\Contratos.vue`
- `src\views\modules\aseo_contratado\Contratos_Alta.vue`
- `src\views\modules\aseo_contratado\Contratos_Mod.vue`
- `src\views\modules\aseo_contratado\Contratos_Upd_Und.vue`
- `src\views\modules\aseo_contratado\Ins_b.vue`
- `src\views\modules\aseo_contratado\UpdxCont.vue`
- `src\views\modules\aseo_contratado\Upd_01.vue`
- `src\views\modules\aseo_contratado\Upd_UndC.vue`

**Acción requerida**: Crear el SP `sp_aseo_unidades_list` en la base de datos PostgreSQL.

#### 27. `sp_aseo_unidades_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Und_Recolec.vue`

**Acción requerida**: Crear el SP `sp_aseo_unidades_create` en la base de datos PostgreSQL.

#### 28. `sp_aseo_unidades_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Und_Recolec.vue`

**Acción requerida**: Crear el SP `sp_aseo_unidades_update` en la base de datos PostgreSQL.

#### 29. `sp_aseo_unidades_delete`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Und_Recolec.vue`

**Acción requerida**: Crear el SP `sp_aseo_unidades_delete` en la base de datos PostgreSQL.

#### 30. `sp_aseo_zonas_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Zonas.vue`
- `src\views\modules\aseo_contratado\Adeudos_Venc.vue`
- `src\views\modules\aseo_contratado\Cons_Cont.vue`
- `src\views\modules\aseo_contratado\Cons_ContAsc.vue`
- `src\views\modules\aseo_contratado\Contratos.vue`
- `src\views\modules\aseo_contratado\ContratosEst.vue`
- `src\views\modules\aseo_contratado\Contratos_Cons_Admin.vue`
- `src\views\modules\aseo_contratado\Contratos_Cons_Dom.vue`
- `src\views\modules\aseo_contratado\Contratos_Upd_Periodo.vue`
- `src\views\modules\aseo_contratado\Contratos_Upd_Und.vue`
- `src\views\modules\aseo_contratado\Rep_AdeudCond.vue`
- `src\views\modules\aseo_contratado\Rep_Tipos_Aseo.vue`
- `src\views\modules\aseo_contratado\UpdxCont.vue`
- `src\views\modules\aseo_contratado\Upd_01.vue`
- `src\views\modules\aseo_contratado\Upd_IniObl.vue`

**Acción requerida**: Crear el SP `sp_aseo_zonas_list` en la base de datos PostgreSQL.

#### 31. `sp_aseo_zonas_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Zonas.vue`

**Acción requerida**: Crear el SP `sp_aseo_zonas_create` en la base de datos PostgreSQL.

#### 32. `sp_aseo_zonas_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Zonas.vue`

**Acción requerida**: Crear el SP `sp_aseo_zonas_update` en la base de datos PostgreSQL.

#### 33. `sp_aseo_zonas_delete`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ABC_Zonas.vue`

**Acción requerida**: Crear el SP `sp_aseo_zonas_delete` en la base de datos PostgreSQL.

#### 34. `sp_aseo_adeudos_buscar_contrato`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos.vue`
- `src\views\modules\aseo_contratado\Adeudos_EdoCta.vue`
- `src\views\modules\aseo_contratado\Adeudos_Ins.vue`
- `src\views\modules\aseo_contratado\Adeudos_Nvo.vue`
- `src\views\modules\aseo_contratado\Adeudos_Pag.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_buscar_contrato` en la base de datos PostgreSQL.

#### 35. `sp_aseo_adeudos_estado_cuenta`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos.vue`
- `src\views\modules\aseo_contratado\AdeudosCN_Cond.vue`
- `src\views\modules\aseo_contratado\AdeudosEst.vue`
- `src\views\modules\aseo_contratado\Adeudos_EdoCta.vue`
- `src\views\modules\aseo_contratado\Adeudos_Nvo.vue`
- `src\views\modules\aseo_contratado\Adeudos_Pag.vue`
- `src\views\modules\aseo_contratado\Contratos_Baja.vue`
- `src\views\modules\aseo_contratado\Rpt_Adeudos.vue`
- `src\views\modules\aseo_contratado\Rpt_EstadoCuenta.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_estado_cuenta` en la base de datos PostgreSQL.

#### 36. `sp_aseo_adeudos_carga_masiva`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos.vue`
- `src\views\modules\aseo_contratado\Adeudos_Carga.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_carga_masiva` en la base de datos PostgreSQL.

#### 37. `sp_aseo_adeudos_insertar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\AdeudosMult_Ins.vue`
- `src\views\modules\aseo_contratado\Adeudos_Ins.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_insertar` en la base de datos PostgreSQL.

#### 38. `sp_aseo_adeudos_generar_recargos`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_Carga.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_generar_recargos` en la base de datos PostgreSQL.

#### 39. `sp_aseo_adeudos_registrar_pago`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_Pag.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_registrar_pago` en la base de datos PostgreSQL.

#### 40. `sp_aseo_contrato_consultar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_PagMult.vue`
- `src\views\modules\aseo_contratado\Adeudos_UpdExed.vue`
- `src\views\modules\aseo_contratado\AplicaMultas.vue`
- `src\views\modules\aseo_contratado\Contratos_Adeudos.vue`
- `src\views\modules\aseo_contratado\Contratos_Cancela.vue`
- `src\views\modules\aseo_contratado\DatosConvenio.vue`
- `src\views\modules\aseo_contratado\DescuentosPago.vue`
- `src\views\modules\aseo_contratado\Pagos_Cons_Cont.vue`
- `src\views\modules\aseo_contratado\Pagos_Cons_ContAsc.vue`
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_contrato_consultar` en la base de datos PostgreSQL.

#### 41. `sp_aseo_adeudos_pendientes`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_PagMult.vue`
- `src\views\modules\aseo_contratado\DatosConvenio.vue`
- `src\views\modules\aseo_contratado\DescuentosPago.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_pendientes` en la base de datos PostgreSQL.

#### 42. `sp_aseo_pago_multiple`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_PagMult.vue`

**Acción requerida**: Crear el SP `sp_aseo_pago_multiple` en la base de datos PostgreSQL.

#### 43. `sp_aseo_pagos_buscar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_PagUpdPer.vue`

**Acción requerida**: Crear el SP `sp_aseo_pagos_buscar` en la base de datos PostgreSQL.

#### 44. `sp_aseo_pagos_actualizar_periodos`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_PagUpdPer.vue`

**Acción requerida**: Crear el SP `sp_aseo_pagos_actualizar_periodos` en la base de datos PostgreSQL.

#### 45. `sp_aseo_pagos_historial_actualizaciones`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_PagUpdPer.vue`

**Acción requerida**: Crear el SP `sp_aseo_pagos_historial_actualizaciones` en la base de datos PostgreSQL.

#### 46. `sp_aseo_adeudos_por_contrato`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_UpdExed.vue`
- `src\views\modules\aseo_contratado\Contratos_Adeudos.vue`
- `src\views\modules\aseo_contratado\Contratos_Cancela.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_por_contrato` en la base de datos PostgreSQL.

#### 47. `sp_aseo_aplicar_exencion`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_UpdExed.vue`

**Acción requerida**: Crear el SP `sp_aseo_aplicar_exencion` en la base de datos PostgreSQL.

#### 48. `sp_aseo_adeudos_vencidos`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Adeudos_Venc.vue`

**Acción requerida**: Crear el SP `sp_aseo_adeudos_vencidos` en la base de datos PostgreSQL.

#### 49. `sp_aseo_multa_aplicar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\AplicaMultas.vue`

**Acción requerida**: Crear el SP `sp_aseo_multa_aplicar` en la base de datos PostgreSQL.

#### 50. `sp_aseo_consulta_contratos`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Cons_Cont.vue`

**Acción requerida**: Crear el SP `sp_aseo_consulta_contratos` en la base de datos PostgreSQL.

#### 51. `sp_aseo_detalle_contrato`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Cons_Cont.vue`

**Acción requerida**: Crear el SP `sp_aseo_detalle_contrato` en la base de datos PostgreSQL.

#### 52. `sp_aseo_consulta_ordenada`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Cons_ContAsc.vue`

**Acción requerida**: Crear el SP `sp_aseo_consulta_ordenada` en la base de datos PostgreSQL.

#### 53. `sp_aseo_contratos_list`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_list` en la base de datos PostgreSQL.

#### 54. `sp_aseo_cancelar_contrato`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_cancelar_contrato` en la base de datos PostgreSQL.

#### 55. `sp_aseo_estadisticas_contratos`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\ContratosEst.vue`

**Acción requerida**: Crear el SP `sp_aseo_estadisticas_contratos` en la base de datos PostgreSQL.

#### 56. `sp_aseo_contratos_create`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Alta.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_create` en la base de datos PostgreSQL.

#### 57. `sp_aseo_contratos_baja`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Baja.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_baja` en la base de datos PostgreSQL.

#### 58. `sp_aseo_pagos_por_contrato`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Cancela.vue`
- `src\views\modules\aseo_contratado\Pagos_Cons_Cont.vue`

**Acción requerida**: Crear el SP `sp_aseo_pagos_por_contrato` en la base de datos PostgreSQL.

#### 59. `sp_aseo_contrato_cancelar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Cancela.vue`

**Acción requerida**: Crear el SP `sp_aseo_contrato_cancelar` en la base de datos PostgreSQL.

#### 60. `sp_aseo_contratos_consulta_admin`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Cons_Admin.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_consulta_admin` en la base de datos PostgreSQL.

#### 61. `sp_aseo_contratos_por_tipo`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Cons_Dom.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_por_tipo` en la base de datos PostgreSQL.

#### 62. `sp_aseo_estadisticas_generales`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_EstGral.vue`

**Acción requerida**: Crear el SP `sp_aseo_estadisticas_generales` en la base de datos PostgreSQL.

#### 63. `sp_aseo_estadisticas_por_tipo`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_EstGral.vue`
- `src\views\modules\aseo_contratado\EstGral2.vue`

**Acción requerida**: Crear el SP `sp_aseo_estadisticas_por_tipo` en la base de datos PostgreSQL.

#### 64. `sp_aseo_estadisticas_por_empresa`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_EstGral.vue`
- `src\views\modules\aseo_contratado\EstGral2.vue`

**Acción requerida**: Crear el SP `sp_aseo_estadisticas_por_empresa` en la base de datos PostgreSQL.

#### 65. `sp_aseo_estadisticas_por_zona`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_EstGral.vue`

**Acción requerida**: Crear el SP `sp_aseo_estadisticas_por_zona` en la base de datos PostgreSQL.

#### 66. `sp_aseo_contratos_update`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Mod.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_update` en la base de datos PostgreSQL.

#### 67. `sp_aseo_contratos_para_upd_periodo`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Upd_Periodo.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_para_upd_periodo` en la base de datos PostgreSQL.

#### 68. `sp_aseo_actualizar_periodos_contratos`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Upd_Periodo.vue`

**Acción requerida**: Crear el SP `sp_aseo_actualizar_periodos_contratos` en la base de datos PostgreSQL.

#### 69. `sp_aseo_contratos_para_upd_unidad`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Upd_Und.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_para_upd_unidad` en la base de datos PostgreSQL.

#### 70. `sp_aseo_actualizar_unidades_contratos`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Contratos_Upd_Und.vue`

**Acción requerida**: Crear el SP `sp_aseo_actualizar_unidades_contratos` en la base de datos PostgreSQL.

#### 71. `sp_aseo_estadisticas_sincronizacion`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Ctrol_Imp_Cat.vue`

**Acción requerida**: Crear el SP `sp_aseo_estadisticas_sincronizacion` en la base de datos PostgreSQL.

#### 72. `sp_aseo_convenio_crear`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\DatosConvenio.vue`

**Acción requerida**: Crear el SP `sp_aseo_convenio_crear` en la base de datos PostgreSQL.

#### 73. `sp_aseo_convenios_consultar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\DatosConvenio.vue`

**Acción requerida**: Crear el SP `sp_aseo_convenios_consultar` en la base de datos PostgreSQL.

#### 74. `sp_aseo_ejercicios_listar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EjerciciosGestion.vue`

**Acción requerida**: Crear el SP `sp_aseo_ejercicios_listar` en la base de datos PostgreSQL.

#### 75. `sp_aseo_ejercicio_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EjerciciosGestion.vue`

**Acción requerida**: Crear el SP `sp_aseo_ejercicio_estadisticas` en la base de datos PostgreSQL.

#### 76. `sp_aseo_ejercicio_cerrar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EjerciciosGestion.vue`

**Acción requerida**: Crear el SP `sp_aseo_ejercicio_cerrar` en la base de datos PostgreSQL.

#### 77. `sp_aseo_periodos_listar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EjerciciosGestion.vue`

**Acción requerida**: Crear el SP `sp_aseo_periodos_listar` en la base de datos PostgreSQL.

#### 78. `sp_aseo_periodo_eliminar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EjerciciosGestion.vue`

**Acción requerida**: Crear el SP `sp_aseo_periodo_eliminar` en la base de datos PostgreSQL.

#### 79. `sp_aseo_tarifas_listar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EjerciciosGestion.vue`

**Acción requerida**: Crear el SP `sp_aseo_tarifas_listar` en la base de datos PostgreSQL.

#### 80. `sp_aseo_tarifa_eliminar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EjerciciosGestion.vue`

**Acción requerida**: Crear el SP `sp_aseo_tarifa_eliminar` en la base de datos PostgreSQL.

#### 81. `sp_aseo_tarifas_copiar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EjerciciosGestion.vue`

**Acción requerida**: Crear el SP `sp_aseo_tarifas_copiar` en la base de datos PostgreSQL.

#### 82. `sp_aseo_empresas_get`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Empresas_Contratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_empresas_get` en la base de datos PostgreSQL.

#### 83. `sp_aseo_contratos_por_empresa`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Empresas_Contratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_por_empresa` en la base de datos PostgreSQL.

#### 84. `sp_aseo_estadisticas_avanzadas`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\EstGral2.vue`

**Acción requerida**: Crear el SP `sp_aseo_estadisticas_avanzadas` en la base de datos PostgreSQL.

#### 85. `sp_aseo_pagos_por_contrato_asc`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Pagos_Cons_ContAsc.vue`

**Acción requerida**: Crear el SP `sp_aseo_pagos_por_contrato_asc` en la base de datos PostgreSQL.

#### 86. `sp_aseo_pagos_por_forma_pago`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Pagos_Con_FPgo.vue`

**Acción requerida**: Crear el SP `sp_aseo_pagos_por_forma_pago` en la base de datos PostgreSQL.

#### 87. `sp_aseo_relaciones_listar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_relaciones_listar` en la base de datos PostgreSQL.

#### 88. `sp_aseo_contratos_vincular`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_vincular` en la base de datos PostgreSQL.

#### 89. `sp_aseo_contratos_desvincular`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_desvincular` en la base de datos PostgreSQL.

#### 90. `sp_aseo_grupos_listar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_grupos_listar` en la base de datos PostgreSQL.

#### 91. `sp_aseo_grupo_contratos_listar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_grupo_contratos_listar` en la base de datos PostgreSQL.

#### 92. `sp_aseo_grupo_agregar_contrato`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_grupo_agregar_contrato` en la base de datos PostgreSQL.

#### 93. `sp_aseo_grupo_quitar_contrato`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_grupo_quitar_contrato` en la base de datos PostgreSQL.

#### 94. `sp_aseo_relaciones_consultar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\RelacionContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_relaciones_consultar` en la base de datos PostgreSQL.

#### 95. `sp_aseo_reporte_adeudos_condonados`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Rep_AdeudCond.vue`

**Acción requerida**: Crear el SP `sp_aseo_reporte_adeudos_condonados` en la base de datos PostgreSQL.

#### 96. `sp_aseo_reporte_padron_contratos`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Rep_PadronContratos.vue`

**Acción requerida**: Crear el SP `sp_aseo_reporte_padron_contratos` en la base de datos PostgreSQL.

#### 97. `sp_aseo_reporte_recaudadoras`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Rep_Recaudadoras.vue`

**Acción requerida**: Crear el SP `sp_aseo_reporte_recaudadoras` en la base de datos PostgreSQL.

#### 98. `sp_aseo_reporte_tipos_aseo`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Rep_Tipos_Aseo.vue`

**Acción requerida**: Crear el SP `sp_aseo_reporte_tipos_aseo` en la base de datos PostgreSQL.

#### 99. `sp_aseo_reporte_por_zonas`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Rep_Zonas.vue`

**Acción requerida**: Crear el SP `sp_aseo_reporte_por_zonas` en la base de datos PostgreSQL.

#### 100. `sp_aseo_pagos_by_contrato`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Rpt_EstadoCuenta.vue`

**Acción requerida**: Crear el SP `sp_aseo_pagos_by_contrato` en la base de datos PostgreSQL.

#### 101. `sp_aseo_buscar_contrato_individual`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\UpdxCont.vue`

**Acción requerida**: Crear el SP `sp_aseo_buscar_contrato_individual` en la base de datos PostgreSQL.

#### 102. `sp_aseo_actualizar_contrato_individual`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\UpdxCont.vue`

**Acción requerida**: Crear el SP `sp_aseo_actualizar_contrato_individual` en la base de datos PostgreSQL.

#### 103. `sp_aseo_contratos_para_actualizar`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Upd_01.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_para_actualizar` en la base de datos PostgreSQL.

#### 104. `sp_aseo_aplicar_actualizaciones_masivas`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Upd_01.vue`

**Acción requerida**: Crear el SP `sp_aseo_aplicar_actualizaciones_masivas` en la base de datos PostgreSQL.

#### 105. `sp_aseo_contratos_sin_periodo_inicial`

**Archivos que lo usan**:
- `src\views\modules\aseo_contratado\Upd_IniObl.vue`

**Acción requerida**: Crear el SP `sp_aseo_contratos_sin_periodo_inicial` en la base de datos PostgreSQL.

#### 106. `sp_cem_listar_cementerios`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCementer.vue`
- `src\views\modules\cementerios\ABCFolio.vue`
- `src\views\modules\cementerios\Liquidaciones.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCementer.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCFolio.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Liquidaciones.vue`

**Acción requerida**: Crear el SP `sp_cem_listar_cementerios` en la base de datos PostgreSQL.

#### 107. `sp_cem_abc_cementerios`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCementer.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCementer.vue`

**Acción requerida**: Crear el SP `sp_cem_abc_cementerios` en la base de datos PostgreSQL.

#### 108. `sp_cem_buscar_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCFolio.vue`
- `src\views\modules\cementerios\Bonificaciones.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCFolio.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Bonificaciones.vue`

**Acción requerida**: Crear el SP `sp_cem_buscar_folio` en la base de datos PostgreSQL.

#### 109. `sp_cem_modificar_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCFolio.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCFolio.vue`

**Acción requerida**: Crear el SP `sp_cem_modificar_folio` en la base de datos PostgreSQL.

#### 110. `sp_cem_baja_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCFolio.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCFolio.vue`

**Acción requerida**: Crear el SP `sp_cem_baja_folio` en la base de datos PostgreSQL.

#### 111. `sp_cem_buscar_folio_pagos`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCPagos.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCPagos.vue`

**Acción requerida**: Crear el SP `sp_cem_buscar_folio_pagos` en la base de datos PostgreSQL.

#### 112. `sp_cem_obtener_adeudos_pendientes`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCPagos.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCPagos.vue`

**Acción requerida**: Crear el SP `sp_cem_obtener_adeudos_pendientes` en la base de datos PostgreSQL.

#### 113. `sp_cem_listar_pagos_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCPagos.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCPagos.vue`

**Acción requerida**: Crear el SP `sp_cem_listar_pagos_folio` en la base de datos PostgreSQL.

#### 114. `sp_cem_registrar_pago`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCPagos.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ABCPagos.vue`

**Acción requerida**: Crear el SP `sp_cem_registrar_pago` en la base de datos PostgreSQL.

#### 115. `sp_cem_abc_pagos_por_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ABCPagosxfol.vue`

**Acción requerida**: Crear el SP `sp_cem_abc_pagos_por_folio` en la base de datos PostgreSQL.

#### 116. `sp_validar_usuario`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Acceso.vue`

**Acción requerida**: Crear el SP `sp_validar_usuario` en la base de datos PostgreSQL.

#### 117. `sp_registrar_acceso`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Acceso.vue`

**Acción requerida**: Crear el SP `sp_registrar_acceso` en la base de datos PostgreSQL.

#### 118. `sp_cem_consultar_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Bonificacion1.vue`
- `src\views\modules\cementerios\ConIndividual.vue`
- `src\views\modules\cementerios\ConIndividual_CORREGIDO.vue`
- `src\views\modules\cementerios\ConsultaFol.vue`
- `src\views\modules\cementerios\ConsultaRCM.vue`
- `src\views\modules\cementerios\TitulosSin.vue`
- `src\views\modules\cementerios\TrasladoFolSin.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ConsultaFol.vue`

**Acción requerida**: Crear el SP `sp_cem_consultar_folio` en la base de datos PostgreSQL.

#### 119. `sp_cem_bonificaciones_oficio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Bonificacion1.vue`

**Acción requerida**: Crear el SP `sp_cem_bonificaciones_oficio` en la base de datos PostgreSQL.

#### 120. `sp_cem_buscar_bonificacion`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Bonificaciones.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Bonificaciones.vue`

**Acción requerida**: Crear el SP `sp_cem_buscar_bonificacion` en la base de datos PostgreSQL.

#### 121. `sp_cem_registrar_bonificacion`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Bonificaciones.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Bonificaciones.vue`

**Acción requerida**: Crear el SP `sp_cem_registrar_bonificacion` en la base de datos PostgreSQL.

#### 122. `sp_cem_eliminar_bonificacion`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Bonificaciones.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Bonificaciones.vue`

**Acción requerida**: Crear el SP `sp_cem_eliminar_bonificacion` en la base de datos PostgreSQL.

#### 123. `sp_cem_consultar_pagos_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ConIndividual.vue`
- `src\views\modules\cementerios\ConIndividual_CORREGIDO.vue`

**Acción requerida**: Crear el SP `sp_cem_consultar_pagos_folio` en la base de datos PostgreSQL.

#### 124. `sp_cem_consultar_cementerio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Consulta400.vue`
- `src\views\modules\cementerios\ConsultaGuad.vue`
- `src\views\modules\cementerios\ConsultaJardin.vue`
- `src\views\modules\cementerios\ConsultaMezq.vue`
- `src\views\modules\cementerios\ConsultaSAndres.vue`

**Acción requerida**: Crear el SP `sp_cem_consultar_cementerio` en la base de datos PostgreSQL.

#### 125. `sp_cem_obtener_pagos_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ConsultaFol.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ConsultaFol.vue`

**Acción requerida**: Crear el SP `sp_cem_obtener_pagos_folio` en la base de datos PostgreSQL.

#### 126. `sp_cem_obtener_adeudos_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ConsultaFol.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\ConsultaFol.vue`

**Acción requerida**: Crear el SP `sp_cem_obtener_adeudos_folio` en la base de datos PostgreSQL.

#### 127. `sp_cem_consultar_por_nombre`

**Archivos que lo usan**:
- `src\views\modules\cementerios\ConsultaNombre.vue`

**Acción requerida**: Crear el SP `sp_cem_consultar_por_nombre` en la base de datos PostgreSQL.

#### 128. `sp_cem_buscar_duplicados`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Duplicados.vue`

**Acción requerida**: Crear el SP `sp_cem_buscar_duplicados` en la base de datos PostgreSQL.

#### 129. `sp_cem_verificar_ubicacion_duplicado`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Duplicados.vue`

**Acción requerida**: Crear el SP `sp_cem_verificar_ubicacion_duplicado` en la base de datos PostgreSQL.

#### 130. `sp_cem_trasladar_duplicado`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Duplicados.vue`

**Acción requerida**: Crear el SP `sp_cem_trasladar_duplicado` en la base de datos PostgreSQL.

#### 131. `sp_cem_estadisticas_adeudos`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Estad_adeudo.vue`

**Acción requerida**: Crear el SP `sp_cem_estadisticas_adeudos` en la base de datos PostgreSQL.

#### 132. `sp_cem_calcular_liquidacion`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Liquidaciones.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Liquidaciones.vue`

**Acción requerida**: Crear el SP `sp_cem_calcular_liquidacion` en la base de datos PostgreSQL.

#### 133. `sp_cem_listar_movimientos`

**Archivos que lo usan**:
- `src\views\modules\cementerios\List_Mov.vue`

**Acción requerida**: Crear el SP `sp_cem_listar_movimientos` en la base de datos PostgreSQL.

#### 134. `sp_cem_consultar_pagos_por_fecha`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Multiplefecha.vue`

**Acción requerida**: Crear el SP `sp_cem_consultar_pagos_por_fecha` en la base de datos PostgreSQL.

#### 135. `sp_cem_consultar_folios_por_nombre`

**Archivos que lo usan**:
- `src\views\modules\cementerios\MultipleNombre.vue`

**Acción requerida**: Crear el SP `sp_cem_consultar_folios_por_nombre` en la base de datos PostgreSQL.

#### 136. `sp_cem_consultar_folios_por_ubicacion`

**Archivos que lo usan**:
- `src\views\modules\cementerios\MultipleRCM.vue`

**Acción requerida**: Crear el SP `sp_cem_consultar_folios_por_ubicacion` en la base de datos PostgreSQL.

#### 137. `sp_cem_reporte_cuentas_cobrar`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Rep_a_Cobrar.vue`

**Acción requerida**: Crear el SP `sp_cem_reporte_cuentas_cobrar` en la base de datos PostgreSQL.

#### 138. `sp_cem_reporte_bonificaciones`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Rep_Bon.vue`

**Acción requerida**: Crear el SP `sp_cem_reporte_bonificaciones` en la base de datos PostgreSQL.

#### 139. `sp_cem_reporte_titulos`

**Archivos que lo usan**:
- `src\views\modules\cementerios\RptTitulos.vue`
- `src\views\modules\cementerios\TitulosSin.vue`

**Acción requerida**: Crear el SP `sp_cem_reporte_titulos` en la base de datos PostgreSQL.

#### 140. `sp_validar_password_actual`

**Archivos que lo usan**:
- `src\views\modules\cementerios\sfrm_chgpass.vue`

**Acción requerida**: Crear el SP `sp_validar_password_actual` en la base de datos PostgreSQL.

#### 141. `sp_cambiar_password`

**Archivos que lo usan**:
- `src\views\modules\cementerios\sfrm_chgpass.vue`

**Acción requerida**: Crear el SP `sp_cambiar_password` en la base de datos PostgreSQL.

#### 142. `sp_cem_listar_titulos`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Titulos.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Titulos.vue`

**Acción requerida**: Crear el SP `sp_cem_listar_titulos` en la base de datos PostgreSQL.

#### 143. `sp_cem_buscar_titulo`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Titulos.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Titulos.vue`

**Acción requerida**: Crear el SP `sp_cem_buscar_titulo` en la base de datos PostgreSQL.

#### 144. `sp_cem_actualizar_titulo_extra`

**Archivos que lo usan**:
- `src\views\modules\cementerios\Titulos.vue`
- `src\views\modules\cementerios\_BACKUP_ORIGINAL\Titulos.vue`

**Acción requerida**: Crear el SP `sp_cem_actualizar_titulo_extra` en la base de datos PostgreSQL.

#### 145. `sp_cem_generar_titulo`

**Archivos que lo usan**:
- `src\views\modules\cementerios\TitulosSin.vue`

**Acción requerida**: Crear el SP `sp_cem_generar_titulo` en la base de datos PostgreSQL.

#### 146. `sp_cem_listar_pagos`

**Archivos que lo usan**:
- `src\views\modules\cementerios\TrasladoFolSin.vue`

**Acción requerida**: Crear el SP `sp_cem_listar_pagos` en la base de datos PostgreSQL.

#### 147. `sp_cem_trasladar_folio`

**Archivos que lo usan**:
- `src\views\modules\cementerios\TrasladoFolSin.vue`

**Acción requerida**: Crear el SP `sp_cem_trasladar_folio` en la base de datos PostgreSQL.

#### 148. `sp_chgpass_historial`

**Archivos que lo usan**:
- `src\views\modules\estacionamiento_exclusivo\sfrm_chgpass.vue`

**Acción requerida**: Crear el SP `sp_chgpass_historial` en la base de datos PostgreSQL.

#### 149. `sp_sfrm_baja_pub`

**Archivos que lo usan**:
- `src\views\modules\estacionamiento_publico\BajasPublicos.vue`

**Acción requerida**: Crear el SP `sp_sfrm_baja_pub` en la base de datos PostgreSQL.

#### 150. `spubreports`

**Archivos que lo usan**:
- `src\views\modules\estacionamiento_publico\PagosPublicos.vue`
- `src\views\modules\estacionamiento_publico\ReportesPublicos.vue`

**Acción requerida**: Crear el SP `spubreports` en la base de datos PostgreSQL.

#### 151. `spget_lic_detalles`

**Archivos que lo usan**:
- `src\views\modules\estacionamiento_publico\ReportesPublicos.vue`

**Acción requerida**: Crear el SP `spget_lic_detalles` en la base de datos PostgreSQL.

#### 152. `recaudadora_get_ejecutores`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ActualizaFechaEmpresas.vue`

**Acción requerida**: Crear el SP `recaudadora_get_ejecutores` en la base de datos PostgreSQL.

#### 153. `recaudadora_parse_file`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ActualizaFechaEmpresas.vue`

**Acción requerida**: Crear el SP `recaudadora_parse_file` en la base de datos PostgreSQL.

#### 154. `recaudadora_actualiza_fechas`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ActualizaFechaEmpresas.vue`

**Acción requerida**: Crear el SP `recaudadora_actualiza_fechas` en la base de datos PostgreSQL.

#### 155. `recaudadora_consulta_sdos_favor`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\AplicaSdosFavor.vue`

**Acción requerida**: Crear el SP `recaudadora_consulta_sdos_favor` en la base de datos PostgreSQL.

#### 156. `recaudadora_aplica_sdos_favor`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\AplicaSdosFavor.vue`

**Acción requerida**: Crear el SP `recaudadora_aplica_sdos_favor` en la base de datos PostgreSQL.

#### 157. `recaudadora_autdescto`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\autdescto.vue`

**Acción requerida**: Crear el SP `recaudadora_autdescto` en la base de datos PostgreSQL.

#### 158. `recaudadora_bloqctasreqfrm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\bloqctasreqfrm.vue`

**Acción requerida**: Crear el SP `recaudadora_bloqctasreqfrm` en la base de datos PostgreSQL.

#### 159. `recaudadora_bloqueo_multa`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\BloqueoMulta.vue`

**Acción requerida**: Crear el SP `recaudadora_bloqueo_multa` en la base de datos PostgreSQL.

#### 160. `recaudadora_busque`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\busque.vue`

**Acción requerida**: Crear el SP `recaudadora_busque` en la base de datos PostgreSQL.

#### 161. `recaudadora_canc`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\canc.vue`

**Acción requerida**: Crear el SP `recaudadora_canc` en la base de datos PostgreSQL.

#### 162. `recaudadora_captura_dif`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\CapturaDif.vue`

**Acción requerida**: Crear el SP `recaudadora_captura_dif` en la base de datos PostgreSQL.

#### 163. `recaudadora_carta_invitacion`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\CartaInvitacion.vue`

**Acción requerida**: Crear el SP `recaudadora_carta_invitacion` en la base de datos PostgreSQL.

#### 164. `recaudadora_catastro_dm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\CatastroDM.vue`

**Acción requerida**: Crear el SP `recaudadora_catastro_dm` en la base de datos PostgreSQL.

#### 165. `recaudadora_centrosfrm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\centrosfrm.vue`

**Acción requerida**: Crear el SP `recaudadora_centrosfrm` en la base de datos PostgreSQL.

#### 166. `recaudadora_codificafrm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\codificafrm.vue`

**Acción requerida**: Crear el SP `recaudadora_codificafrm` en la base de datos PostgreSQL.

#### 167. `recaudadora_conscentrosfrm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\conscentrosfrm.vue`

**Acción requerida**: Crear el SP `recaudadora_conscentrosfrm` en la base de datos PostgreSQL.

#### 168. `recaudadora_consdesc`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\consdesc.vue`

**Acción requerida**: Crear el SP `recaudadora_consdesc` en la base de datos PostgreSQL.

#### 169. `recaudadora_descderechos_merc`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\DescDerechosMerc.vue`

**Acción requerida**: Crear el SP `recaudadora_descderechos_merc` en la base de datos PostgreSQL.

#### 170. `recaudadora_drecgo_fosa`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\DrecgoFosa.vue`

**Acción requerida**: Crear el SP `recaudadora_drecgo_fosa` en la base de datos PostgreSQL.

#### 171. `recaudadora_drecgo_trans`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\DrecgoTrans.vue`

**Acción requerida**: Crear el SP `recaudadora_drecgo_trans` en la base de datos PostgreSQL.

#### 172. `recaudadora_ejecutores`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Ejecutores.vue`

**Acción requerida**: Crear el SP `recaudadora_ejecutores` en la base de datos PostgreSQL.

#### 173. `recaudadora_empresas`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Empresas.vue`

**Acción requerida**: Crear el SP `recaudadora_empresas` en la base de datos PostgreSQL.

#### 174. `recaudadora_exclusivos_upd`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Exclusivos_Upd.vue`

**Acción requerida**: Crear el SP `recaudadora_exclusivos_upd` en la base de datos PostgreSQL.

#### 175. `recaudadora_extractos_rpt`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ExtractosRpt.vue`

**Acción requerida**: Crear el SP `recaudadora_extractos_rpt` en la base de datos PostgreSQL.

#### 176. `recaudadora_firma_electronica`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\FirmaElectronica.vue`

**Acción requerida**: Crear el SP `recaudadora_firma_electronica` en la base de datos PostgreSQL.

#### 177. `recaudadora_fol_multa`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\FolMulta.vue`

**Acción requerida**: Crear el SP `recaudadora_fol_multa` en la base de datos PostgreSQL.

#### 178. `recaudadora_gastos_transmision`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\GastosTransmision.vue`

**Acción requerida**: Crear el SP `recaudadora_gastos_transmision` en la base de datos PostgreSQL.

#### 179. `recaudadora_hastafrm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Hastafrm.vue`

**Acción requerida**: Crear el SP `recaudadora_hastafrm` en la base de datos PostgreSQL.

#### 180. `recaudadora_imprime_desctos`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ImprimeDesctos.vue`

**Acción requerida**: Crear el SP `recaudadora_imprime_desctos` en la base de datos PostgreSQL.

#### 181. `recaudadora_lista_diferencias`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ListaDiferencias.vue`

**Acción requerida**: Crear el SP `recaudadora_lista_diferencias` en la base de datos PostgreSQL.

#### 182. `recaudadora_listado_multiple`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ListadoMultiple.vue`

**Acción requerida**: Crear el SP `recaudadora_listado_multiple` en la base de datos PostgreSQL.

#### 183. `recaudadora_listana`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ListAna.vue`

**Acción requerida**: Crear el SP `recaudadora_listana` en la base de datos PostgreSQL.

#### 184. `recaudadora_modif_masiva`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ModifMasiva.vue`

**Acción requerida**: Crear el SP `recaudadora_modif_masiva` en la base de datos PostgreSQL.

#### 185. `recaudadora_multas_dm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\MultasDM.vue`

**Acción requerida**: Crear el SP `recaudadora_multas_dm` en la base de datos PostgreSQL.

#### 186. `recaudadora_otorga_descto`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Otorgadescto.vue`

**Acción requerida**: Crear el SP `recaudadora_otorga_descto` en la base de datos PostgreSQL.

#### 187. `recaudadora_pagos_espe`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\PagosEspe.vue`

**Acción requerida**: Crear el SP `recaudadora_pagos_espe` en la base de datos PostgreSQL.

#### 188. `recaudadora_periodo_inicial`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\PeriodoInicial.vue`

**Acción requerida**: Crear el SP `recaudadora_periodo_inicial` en la base de datos PostgreSQL.

#### 189. `recaudadora_propuestatab`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Propuestatab.vue`

**Acción requerida**: Crear el SP `recaudadora_propuestatab` en la base de datos PostgreSQL.

#### 190. `recaudadora_publicos_upd`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Publicos_Upd.vue`

**Acción requerida**: Crear el SP `recaudadora_publicos_upd` en la base de datos PostgreSQL.

#### 191. `recaudadora_regsecymas`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\RegSecyMas.vue`

**Acción requerida**: Crear el SP `recaudadora_regsecymas` en la base de datos PostgreSQL.

#### 192. `recaudadora_rep_desc_impto`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\RepDescImpto.vue`

**Acción requerida**: Crear el SP `recaudadora_rep_desc_impto` en la base de datos PostgreSQL.

#### 193. `recaudadora_rep_oper`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\RepOper.vue`

**Acción requerida**: Crear el SP `recaudadora_rep_oper` en la base de datos PostgreSQL.

#### 194. `recaudadora_req`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Req.vue`

**Acción requerida**: Crear el SP `recaudadora_req` en la base de datos PostgreSQL.

#### 195. `recaudadora_req_frm_save`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ReqFrm.vue`

**Acción requerida**: Crear el SP `recaudadora_req_frm_save` en la base de datos PostgreSQL.

#### 196. `recaudadora_req_promocion`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ReqPromocion.vue`

**Acción requerida**: Crear el SP `recaudadora_req_promocion` en la base de datos PostgreSQL.

#### 197. `recaudadora_reqtrans_list`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ReqTrans.vue`

**Acción requerida**: Crear el SP `recaudadora_reqtrans_list` en la base de datos PostgreSQL.

#### 198. `recaudadora_reqtrans_create`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ReqTrans.vue`

**Acción requerida**: Crear el SP `recaudadora_reqtrans_create` en la base de datos PostgreSQL.

#### 199. `recaudadora_reqtrans_update`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ReqTrans.vue`

**Acción requerida**: Crear el SP `recaudadora_reqtrans_update` en la base de datos PostgreSQL.

#### 200. `recaudadora_reqtrans_delete`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ReqTrans.vue`

**Acción requerida**: Crear el SP `recaudadora_reqtrans_delete` en la base de datos PostgreSQL.

#### 201. `recaudadora_requerimientos_dm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\RequerimientosDM.vue`

**Acción requerida**: Crear el SP `recaudadora_requerimientos_dm` en la base de datos PostgreSQL.

#### 202. `recaudadora_requerxcvecat`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\RequerxCvecat.vue`

**Acción requerida**: Crear el SP `recaudadora_requerxcvecat` en la base de datos PostgreSQL.

#### 203. `recaudadora_resolucion_juez`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\ResolucionJuez.vue`

**Acción requerida**: Crear el SP `recaudadora_resolucion_juez` en la base de datos PostgreSQL.

#### 204. `recaudadora_sdosfavor_dm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\SdosFavorDM.vue`

**Acción requerida**: Crear el SP `recaudadora_sdosfavor_dm` en la base de datos PostgreSQL.

#### 205. `recaudadora_sdosfavor_ctrlexp`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\SdosFavor_CtrlExp.vue`

**Acción requerida**: Crear el SP `recaudadora_sdosfavor_ctrlexp` en la base de datos PostgreSQL.

#### 206. `recaudadora_sdosfavor_pagos`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\SdosFavor_Pagos.vue`

**Acción requerida**: Crear el SP `recaudadora_sdosfavor_pagos` en la base de datos PostgreSQL.

#### 207. `recaudadora_sinligarfrm`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\SinLigarFrm.vue`

**Acción requerida**: Crear el SP `recaudadora_sinligarfrm` en la base de datos PostgreSQL.

#### 208. `recaudadora_sol_sdos_favor`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\SolSdosFavor.vue`

**Acción requerida**: Crear el SP `recaudadora_sol_sdos_favor` en la base de datos PostgreSQL.

#### 209. `recaudadora_tdm_conection`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\TDMConection.vue`

**Acción requerida**: Crear el SP `recaudadora_tdm_conection` en la base de datos PostgreSQL.

#### 210. `recaudadora_ubicodifica`

**Archivos que lo usan**:
- `src\views\modules\multas_reglamentos\Ubicodifica.vue`

**Acción requerida**: Crear el SP `recaudadora_ubicodifica` en la base de datos PostgreSQL.

#### 211. `sp_auxrep_tablas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\AuxRep.vue`

**Acción requerida**: Crear el SP `sp_auxrep_tablas_get` en la base de datos PostgreSQL.

#### 212. `sp_auxrep_etiquetas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\AuxRep.vue`

**Acción requerida**: Crear el SP `sp_auxrep_etiquetas_get` en la base de datos PostgreSQL.

#### 213. `sp_auxrep_vigencias_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\AuxRep.vue`

**Acción requerida**: Crear el SP `sp_auxrep_vigencias_get` en la base de datos PostgreSQL.

#### 214. `sp_auxrep_padron_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\AuxRep.vue`

**Acción requerida**: Crear el SP `sp_auxrep_padron_get` en la base de datos PostgreSQL.

#### 215. `sp_cargacartera_tablas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\CargaCartera.vue`

**Acción requerida**: Crear el SP `sp_cargacartera_tablas_get` en la base de datos PostgreSQL.

#### 216. `sp_cargacartera_ejercicios_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\CargaCartera.vue`

**Acción requerida**: Crear el SP `sp_cargacartera_ejercicios_get` en la base de datos PostgreSQL.

#### 217. `sp_cargacartera_unidades_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\CargaCartera.vue`

**Acción requerida**: Crear el SP `sp_cargacartera_unidades_get` en la base de datos PostgreSQL.

#### 218. `sp_cargacartera_aplica`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\CargaCartera.vue`

**Acción requerida**: Crear el SP `sp_cargacartera_aplica` en la base de datos PostgreSQL.

#### 219. `sp_etiquetas_tablas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\Etiquetas.vue`

**Acción requerida**: Crear el SP `sp_etiquetas_tablas_get` en la base de datos PostgreSQL.

#### 220. `sp_etiquetas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\Etiquetas.vue`

**Acción requerida**: Crear el SP `sp_etiquetas_get` en la base de datos PostgreSQL.

#### 221. `sp_etiquetas_update`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\Etiquetas.vue`

**Acción requerida**: Crear el SP `sp_etiquetas_update` en la base de datos PostgreSQL.

#### 222. `sp_otras_oblig_get_etiquetas`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GActualiza.vue`
- `src\views\modules\otras_obligaciones\GAdeudos.vue`
- `src\views\modules\otras_obligaciones\GBaja.vue`
- `src\views\modules\otras_obligaciones\GConsulta.vue`
- `src\views\modules\otras_obligaciones\GConsulta2.vue`
- `src\views\modules\otras_obligaciones\GFacturacion.vue`
- `src\views\modules\otras_obligaciones\GNuevos.vue`

**Acción requerida**: Crear el SP `sp_otras_oblig_get_etiquetas` en la base de datos PostgreSQL.

#### 223. `sp_otras_oblig_get_tablas`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GActualiza.vue`
- `src\views\modules\otras_obligaciones\GAdeudos.vue`
- `src\views\modules\otras_obligaciones\GBaja.vue`
- `src\views\modules\otras_obligaciones\GConsulta.vue`
- `src\views\modules\otras_obligaciones\GConsulta2.vue`
- `src\views\modules\otras_obligaciones\GFacturacion.vue`
- `src\views\modules\otras_obligaciones\GNuevos.vue`

**Acción requerida**: Crear el SP `sp_otras_oblig_get_tablas` en la base de datos PostgreSQL.

#### 224. `sp_gactualiza_dependencias_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GActualiza.vue`

**Acción requerida**: Crear el SP `sp_gactualiza_dependencias_get` en la base de datos PostgreSQL.

#### 225. `sp_gactualiza_datos_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GActualiza.vue`

**Acción requerida**: Crear el SP `sp_gactualiza_datos_get` en la base de datos PostgreSQL.

#### 226. `sp_gactualiza_multas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GActualiza.vue`

**Acción requerida**: Crear el SP `sp_gactualiza_multas_get` en la base de datos PostgreSQL.

#### 227. `sp_gactualiza_suspension_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GActualiza.vue`

**Acción requerida**: Crear el SP `sp_gactualiza_suspension_get` en la base de datos PostgreSQL.

#### 228. `sp_gactualiza_multas_update`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GActualiza.vue`

**Acción requerida**: Crear el SP `sp_gactualiza_multas_update` en la base de datos PostgreSQL.

#### 229. `sp_gactualiza_suspension_create`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GActualiza.vue`

**Acción requerida**: Crear el SP `sp_gactualiza_suspension_create` en la base de datos PostgreSQL.

#### 230. `sp_gadeudos_datos_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudos.vue`

**Acción requerida**: Crear el SP `sp_gadeudos_datos_get` en la base de datos PostgreSQL.

#### 231. `sp_gadeudos_detalle_01`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudos.vue`

**Acción requerida**: Crear el SP `sp_gadeudos_detalle_01` en la base de datos PostgreSQL.

#### 232. `sp_gadeudos_detalle_02`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudos.vue`

**Acción requerida**: Crear el SP `sp_gadeudos_detalle_02` en la base de datos PostgreSQL.

#### 233. `sp_gadeudosgral_tablas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudosGral.vue`

**Acción requerida**: Crear el SP `sp_gadeudosgral_tablas_get` en la base de datos PostgreSQL.

#### 234. `sp_gadeudosgral_etiquetas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudosGral.vue`

**Acción requerida**: Crear el SP `sp_gadeudosgral_etiquetas_get` en la base de datos PostgreSQL.

#### 235. `spcon34_gcont_01`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudosGral.vue`

**Acción requerida**: Crear el SP `spcon34_gcont_01` en la base de datos PostgreSQL.

#### 236. `sp_gadeudos_opc_mult_recaudadoras_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudos_OpcMult.vue`

**Acción requerida**: Crear el SP `sp_gadeudos_opc_mult_recaudadoras_get` en la base de datos PostgreSQL.

#### 237. `sp_gadeudos_opcmult_ra_tablas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudos_OpcMult_RA.vue`

**Acción requerida**: Crear el SP `sp_gadeudos_opcmult_ra_tablas_get` en la base de datos PostgreSQL.

#### 238. `sp_gadeudos_opcmult_ra_etiquetas_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudos_OpcMult_RA.vue`

**Acción requerida**: Crear el SP `sp_gadeudos_opcmult_ra_etiquetas_get` en la base de datos PostgreSQL.

#### 239. `sp_gadeudos_opcmult_ra_datos_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudos_OpcMult_RA.vue`

**Acción requerida**: Crear el SP `sp_gadeudos_opcmult_ra_datos_get` en la base de datos PostgreSQL.

#### 240. `sp_gadeudos_opcmult_ra_reactivar`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GAdeudos_OpcMult_RA.vue`

**Acción requerida**: Crear el SP `sp_gadeudos_opcmult_ra_reactivar` en la base de datos PostgreSQL.

#### 241. `sp_gbaja_datos_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GBaja.vue`

**Acción requerida**: Crear el SP `sp_gbaja_datos_get` en la base de datos PostgreSQL.

#### 242. `sp_gbaja_adeudos_detalle`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GBaja.vue`

**Acción requerida**: Crear el SP `sp_gbaja_adeudos_detalle` en la base de datos PostgreSQL.

#### 243. `sp_gbaja_adeudos_totales`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GBaja.vue`

**Acción requerida**: Crear el SP `sp_gbaja_adeudos_totales` en la base de datos PostgreSQL.

#### 244. `sp_gbaja_pagos_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GBaja.vue`

**Acción requerida**: Crear el SP `sp_gbaja_pagos_get` en la base de datos PostgreSQL.

#### 245. `sp_gbaja_aplicar`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GBaja.vue`

**Acción requerida**: Crear el SP `sp_gbaja_aplicar` en la base de datos PostgreSQL.

#### 246. `sp_gconsulta_datos_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GConsulta.vue`

**Acción requerida**: Crear el SP `sp_gconsulta_datos_get` en la base de datos PostgreSQL.

#### 247. `sp_gconsulta_adeudos_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GConsulta.vue`

**Acción requerida**: Crear el SP `sp_gconsulta_adeudos_get` en la base de datos PostgreSQL.

#### 248. `sp_gconsulta_pagados_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GConsulta.vue`

**Acción requerida**: Crear el SP `sp_gconsulta_pagados_get` en la base de datos PostgreSQL.

#### 249. `sp_otras_oblig_buscar_coincide`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GConsulta2.vue`

**Acción requerida**: Crear el SP `sp_otras_oblig_buscar_coincide` en la base de datos PostgreSQL.

#### 250. `sp_otras_oblig_buscar_cont`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GConsulta2.vue`
- `src\views\modules\otras_obligaciones\RAdeudos.vue`
- `src\views\modules\otras_obligaciones\RConsulta.vue`

**Acción requerida**: Crear el SP `sp_otras_oblig_buscar_cont` en la base de datos PostgreSQL.

#### 251. `sp_otras_oblig_buscar_totales`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GConsulta2.vue`
- `src\views\modules\otras_obligaciones\RAdeudos.vue`

**Acción requerida**: Crear el SP `sp_otras_oblig_buscar_totales` en la base de datos PostgreSQL.

#### 252. `sp_otras_oblig_buscar_adeudos`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GConsulta2.vue`
- `src\views\modules\otras_obligaciones\RAdeudos.vue`

**Acción requerida**: Crear el SP `sp_otras_oblig_buscar_adeudos` en la base de datos PostgreSQL.

#### 253. `sp_otras_oblig_buscar_pagados`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GConsulta2.vue`

**Acción requerida**: Crear el SP `sp_otras_oblig_buscar_pagados` en la base de datos PostgreSQL.

#### 254. `sp_gfacturacion_datos_get`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\GFacturacion.vue`

**Acción requerida**: Crear el SP `sp_gfacturacion_datos_get` en la base de datos PostgreSQL.

#### 255. `con34_1datos_03`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\RAdeudos_OpcMult.vue`

**Acción requerida**: Crear el SP `con34_1datos_03` en la base de datos PostgreSQL.

#### 256. `sp_rfacturacion_obtener`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\RFacturacion.vue`

**Acción requerida**: Crear el SP `sp_rfacturacion_obtener` en la base de datos PostgreSQL.

#### 257. `sp_rubros_listar`

**Archivos que lo usan**:
- `src\views\modules\otras_obligaciones\Rubros.vue`

**Acción requerida**: Crear el SP `sp_rubros_listar` en la base de datos PostgreSQL.

#### 258. `sp_verifica_firma`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bajaAnunciofrm.vue`
- `src\views\modules\padron_licencias\bajaLicenciafrm.vue`
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_verifica_firma` en la base de datos PostgreSQL.

#### 259. `sp_consulta_anuncios_licencia`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bajaLicenciafrm.vue`

**Acción requerida**: Crear el SP `sp_consulta_anuncios_licencia` en la base de datos PostgreSQL.

#### 260. `sp_bloquearanuncio_get_anuncio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearAnunciorm.vue`

**Acción requerida**: Crear el SP `sp_bloquearanuncio_get_anuncio` en la base de datos PostgreSQL.

#### 261. `sp_bloquearanuncio_get_bloqueos`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearAnunciorm.vue`

**Acción requerida**: Crear el SP `sp_bloquearanuncio_get_bloqueos` en la base de datos PostgreSQL.

#### 262. `sp_bloquearanuncio_bloquear`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearAnunciorm.vue`

**Acción requerida**: Crear el SP `sp_bloquearanuncio_bloquear` en la base de datos PostgreSQL.

#### 263. `sp_bloquearanuncio_desbloquear`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearAnunciorm.vue`

**Acción requerida**: Crear el SP `sp_bloquearanuncio_desbloquear` en la base de datos PostgreSQL.

#### 264. `sp_bloquearlicencia_get_licencia`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearLicenciafrm.vue`

**Acción requerida**: Crear el SP `sp_bloquearlicencia_get_licencia` en la base de datos PostgreSQL.

#### 265. `sp_bloquearlicencia_get_bloqueos`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearLicenciafrm.vue`

**Acción requerida**: Crear el SP `sp_bloquearlicencia_get_bloqueos` en la base de datos PostgreSQL.

#### 266. `sp_bloquearlicencia_bloquear`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearLicenciafrm.vue`

**Acción requerida**: Crear el SP `sp_bloquearlicencia_bloquear` en la base de datos PostgreSQL.

#### 267. `sp_bloquearlicencia_desbloquear`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearLicenciafrm.vue`

**Acción requerida**: Crear el SP `sp_bloquearlicencia_desbloquear` en la base de datos PostgreSQL.

#### 268. `sp_bloqueartramite_get_tramite`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearTramitefrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueartramite_get_tramite` en la base de datos PostgreSQL.

#### 269. `sp_bloqueartramite_get_bloqueos`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearTramitefrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueartramite_get_bloqueos` en la base de datos PostgreSQL.

#### 270. `sp_bloqueartramite_get_giro`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearTramitefrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueartramite_get_giro` en la base de datos PostgreSQL.

#### 271. `sp_bloqueartramite_bloquear`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearTramitefrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueartramite_bloquear` en la base de datos PostgreSQL.

#### 272. `sp_bloqueartramite_desbloquear`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\BloquearTramitefrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueartramite_desbloquear` en la base de datos PostgreSQL.

#### 273. `sp_bloqueodomicilios_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueodomicilios_update` en la base de datos PostgreSQL.

#### 274. `sp_bloqueodomicilios_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueodomicilios_list` en la base de datos PostgreSQL.

#### 275. `sp_bloqueodomicilios_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueodomicilios_create` en la base de datos PostgreSQL.

#### 276. `sp_bloqueodomicilios_cancel`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueodomicilios_cancel` en la base de datos PostgreSQL.

#### 277. `sp_bloqueorfc_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bloqueoRFCfrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueorfc_list` en la base de datos PostgreSQL.

#### 278. `sp_bloqueorfc_buscar_tramite`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bloqueoRFCfrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueorfc_buscar_tramite` en la base de datos PostgreSQL.

#### 279. `sp_bloqueorfc_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bloqueoRFCfrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueorfc_create` en la base de datos PostgreSQL.

#### 280. `sp_bloqueorfc_desbloquear`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\bloqueoRFCfrm.vue`

**Acción requerida**: Crear el SP `sp_bloqueorfc_desbloquear` en la base de datos PostgreSQL.

#### 281. `consulta_giros_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\buscagirofrm.vue`

**Acción requerida**: Crear el SP `consulta_giros_estadisticas` en la base de datos PostgreSQL.

#### 282. `buscagiro_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\buscagirofrm.vue`

**Acción requerida**: Crear el SP `buscagiro_list` en la base de datos PostgreSQL.

#### 283. `carga_imagen_sp_get_tramite_info`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\carga_imagen.vue`

**Acción requerida**: Crear el SP `carga_imagen_sp_get_tramite_info` en la base de datos PostgreSQL.

#### 284. `carga_imagen_sp_get_tramite_documents`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\carga_imagen.vue`

**Acción requerida**: Crear el SP `carga_imagen_sp_get_tramite_documents` en la base de datos PostgreSQL.

#### 285. `carga_imagen_sp_get_document_types`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\carga_imagen.vue`

**Acción requerida**: Crear el SP `carga_imagen_sp_get_document_types` en la base de datos PostgreSQL.

#### 286. `carga_imagen_sp_upload_document_image`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\carga_imagen.vue`

**Acción requerida**: Crear el SP `carga_imagen_sp_upload_document_image` en la base de datos PostgreSQL.

#### 287. `carga_imagen_sp_get_document_image`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\carga_imagen.vue`

**Acción requerida**: Crear el SP `carga_imagen_sp_get_document_image` en la base de datos PostgreSQL.

#### 288. `carga_imagen_sp_delete_document_image`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\carga_imagen.vue`

**Acción requerida**: Crear el SP `carga_imagen_sp_delete_document_image` en la base de datos PostgreSQL.

#### 289. `sp_catalogo_actividades_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatalogoActividadesFrm.vue`

**Acción requerida**: Crear el SP `sp_catalogo_actividades_list` en la base de datos PostgreSQL.

#### 290. `sp_catalogo_actividades_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatalogoActividadesFrm.vue`

**Acción requerida**: Crear el SP `sp_catalogo_actividades_create` en la base de datos PostgreSQL.

#### 291. `sp_catalogo_actividades_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatalogoActividadesFrm.vue`

**Acción requerida**: Crear el SP `sp_catalogo_actividades_update` en la base de datos PostgreSQL.

#### 292. `sp_catalogo_actividades_delete`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatalogoActividadesFrm.vue`

**Acción requerida**: Crear el SP `sp_catalogo_actividades_delete` en la base de datos PostgreSQL.

#### 293. `sp_catalogogiros_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\catalogogirosfrm.vue`

**Acción requerida**: Crear el SP `sp_catalogogiros_estadisticas` en la base de datos PostgreSQL.

#### 294. `sp_catalogogiros_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\catalogogirosfrm.vue`

**Acción requerida**: Crear el SP `sp_catalogogiros_list` en la base de datos PostgreSQL.

#### 295. `sp_catalogogiros_get`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\catalogogirosfrm.vue`

**Acción requerida**: Crear el SP `sp_catalogogiros_get` en la base de datos PostgreSQL.

#### 296. `sp_catalogogiros_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\catalogogirosfrm.vue`

**Acción requerida**: Crear el SP `sp_catalogogiros_create` en la base de datos PostgreSQL.

#### 297. `sp_catalogogiros_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\catalogogirosfrm.vue`

**Acción requerida**: Crear el SP `sp_catalogogiros_update` en la base de datos PostgreSQL.

#### 298. `sp_catalogogiros_cambiar_vigencia`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\catalogogirosfrm.vue`

**Acción requerida**: Crear el SP `sp_catalogogiros_cambiar_vigencia` en la base de datos PostgreSQL.

#### 299. `sp_checa_inhabil`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatastroDM.vue`

**Acción requerida**: Crear el SP `sp_checa_inhabil` en la base de datos PostgreSQL.

#### 300. `sp_generar_dictamen_microgeneradores`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatastroDM.vue`

**Acción requerida**: Crear el SP `sp_generar_dictamen_microgeneradores` en la base de datos PostgreSQL.

#### 301. `sp_imprimir_dictamen_microgeneradores`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatastroDM.vue`

**Acción requerida**: Crear el SP `sp_imprimir_dictamen_microgeneradores` en la base de datos PostgreSQL.

#### 302. `sp_get_derechos2`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatastroDM.vue`

**Acción requerida**: Crear el SP `sp_get_derechos2` en la base de datos PostgreSQL.

#### 303. `sp_refresh_query`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\CatastroDM.vue`

**Acción requerida**: Crear el SP `sp_refresh_query` en la base de datos PostgreSQL.

#### 304. `certificaciones_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\certificacionesfrm.vue`

**Acción requerida**: Crear el SP `certificaciones_list` en la base de datos PostgreSQL.

#### 305. `certificaciones_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\certificacionesfrm.vue`

**Acción requerida**: Crear el SP `certificaciones_estadisticas` en la base de datos PostgreSQL.

#### 306. `certificaciones_get_next_folio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\certificacionesfrm.vue`

**Acción requerida**: Crear el SP `certificaciones_get_next_folio` en la base de datos PostgreSQL.

#### 307. `certificaciones_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\certificacionesfrm.vue`

**Acción requerida**: Crear el SP `certificaciones_create` en la base de datos PostgreSQL.

#### 308. `certificaciones_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\certificacionesfrm.vue`

**Acción requerida**: Crear el SP `certificaciones_update` en la base de datos PostgreSQL.

#### 309. `certificaciones_delete`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\certificacionesfrm.vue`

**Acción requerida**: Crear el SP `certificaciones_delete` en la base de datos PostgreSQL.

#### 310. `sp_cons_anun_400_frm_get_anuncio_400`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consAnun400frm.vue`

**Acción requerida**: Crear el SP `sp_cons_anun_400_frm_get_anuncio_400` en la base de datos PostgreSQL.

#### 311. `sp_cons_anun_400_frm_get_pagos_anun_400`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consAnun400frm.vue`

**Acción requerida**: Crear el SP `sp_cons_anun_400_frm_get_pagos_anun_400` en la base de datos PostgreSQL.

#### 312. `sp_cons_lic_400_frm_get_lic_400`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consLic400frm.vue`

**Acción requerida**: Crear el SP `sp_cons_lic_400_frm_get_lic_400` en la base de datos PostgreSQL.

#### 313. `sp_cons_lic_400_frm_get_pago_lic_400`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consLic400frm.vue`

**Acción requerida**: Crear el SP `sp_cons_lic_400_frm_get_pago_lic_400` en la base de datos PostgreSQL.

#### 314. `constancias_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\constanciafrm.vue`

**Acción requerida**: Crear el SP `constancias_list` en la base de datos PostgreSQL.

#### 315. `constancias_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\constanciafrm.vue`

**Acción requerida**: Crear el SP `constancias_estadisticas` en la base de datos PostgreSQL.

#### 316. `constancias_get_next_folio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\constanciafrm.vue`

**Acción requerida**: Crear el SP `constancias_get_next_folio` en la base de datos PostgreSQL.

#### 317. `constancias_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\constanciafrm.vue`

**Acción requerida**: Crear el SP `constancias_create` en la base de datos PostgreSQL.

#### 318. `constancias_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\constanciafrm.vue`

**Acción requerida**: Crear el SP `constancias_update` en la base de datos PostgreSQL.

#### 319. `constancias_delete`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\constanciafrm.vue`

**Acción requerida**: Crear el SP `constancias_delete` en la base de datos PostgreSQL.

#### 320. `sp_solicnooficial_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\constanciaNoOficialfrm.vue`

**Acción requerida**: Crear el SP `sp_solicnooficial_list` en la base de datos PostgreSQL.

#### 321. `consulta_anuncios_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consultaAnunciofrm.vue`

**Acción requerida**: Crear el SP `consulta_anuncios_list` en la base de datos PostgreSQL.

#### 322. `consulta_anuncios_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consultaAnunciofrm.vue`

**Acción requerida**: Crear el SP `consulta_anuncios_estadisticas` en la base de datos PostgreSQL.

#### 323. `consulta_licencias_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consultaLicenciafrm.vue`
- `src\views\modules\padron_licencias\ConsultaLicenciasfrm.vue`

**Acción requerida**: Crear el SP `consulta_licencias_estadisticas` en la base de datos PostgreSQL.

#### 324. `consulta_licencias_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consultaLicenciafrm.vue`
- `src\views\modules\padron_licencias\ConsultaLicenciasfrm.vue`

**Acción requerida**: Crear el SP `consulta_licencias_list` en la base de datos PostgreSQL.

#### 325. `consulta_tramites_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ConsultaTramitefrm.vue`

**Acción requerida**: Crear el SP `consulta_tramites_list` en la base de datos PostgreSQL.

#### 326. `consulta_tramites_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ConsultaTramitefrm.vue`

**Acción requerida**: Crear el SP `consulta_tramites_estadisticas` en la base de datos PostgreSQL.

#### 327. `get_all_usuarios`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consultausuariosfrm.vue`

**Acción requerida**: Crear el SP `get_all_usuarios` en la base de datos PostgreSQL.

#### 328. `crear_usuario`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consultausuariosfrm.vue`

**Acción requerida**: Crear el SP `crear_usuario` en la base de datos PostgreSQL.

#### 329. `actualizar_usuario`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consultausuariosfrm.vue`

**Acción requerida**: Crear el SP `actualizar_usuario` en la base de datos PostgreSQL.

#### 330. `dar_baja_usuario`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\consultausuariosfrm.vue`

**Acción requerida**: Crear el SP `dar_baja_usuario` en la base de datos PostgreSQL.

#### 331. `sp_dependencias_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\dependenciasfrm.vue`

**Acción requerida**: Crear el SP `sp_dependencias_list` en la base de datos PostgreSQL.

#### 332. `sp_dependencias_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\dependenciasfrm.vue`

**Acción requerida**: Crear el SP `sp_dependencias_create` en la base de datos PostgreSQL.

#### 333. `sp_dependencias_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\dependenciasfrm.vue`

**Acción requerida**: Crear el SP `sp_dependencias_update` en la base de datos PostgreSQL.

#### 334. `sp_dependencias_delete`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\dependenciasfrm.vue`

**Acción requerida**: Crear el SP `sp_dependencias_delete` en la base de datos PostgreSQL.

#### 335. `sp_get_saldo_licencia`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\DetalleLicencia.vue`
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_get_saldo_licencia` en la base de datos PostgreSQL.

#### 336. `sp_dictamenes_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\dictamenfrm.vue`

**Acción requerida**: Crear el SP `sp_dictamenes_estadisticas` en la base de datos PostgreSQL.

#### 337. `sp_dictamenes_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\dictamenfrm.vue`

**Acción requerida**: Crear el SP `sp_dictamenes_list` en la base de datos PostgreSQL.

#### 338. `sp_dictamenes_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\dictamenfrm.vue`

**Acción requerida**: Crear el SP `sp_dictamenes_create` en la base de datos PostgreSQL.

#### 339. `sp_dictamenes_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\dictamenfrm.vue`

**Acción requerida**: Crear el SP `sp_dictamenes_update` en la base de datos PostgreSQL.

#### 340. `sp_empresas_estadisticas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\empresasfrm.vue`

**Acción requerida**: Crear el SP `sp_empresas_estadisticas` en la base de datos PostgreSQL.

#### 341. `estatusfrm_sp_get_revision_info`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\estatusfrm.vue`

**Acción requerida**: Crear el SP `estatusfrm_sp_get_revision_info` en la base de datos PostgreSQL.

#### 342. `estatusfrm_sp_get_historial_estatus`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\estatusfrm.vue`

**Acción requerida**: Crear el SP `estatusfrm_sp_get_historial_estatus` en la base de datos PostgreSQL.

#### 343. `estatusfrm_sp_cambiar_estatus_revision`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\estatusfrm.vue`

**Acción requerida**: Crear el SP `estatusfrm_sp_cambiar_estatus_revision` en la base de datos PostgreSQL.

#### 344. `sp_fechaseg_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\fechasegfrm.vue`

**Acción requerida**: Crear el SP `sp_fechaseg_list` en la base de datos PostgreSQL.

#### 345. `sp_fechaseg_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\fechasegfrm.vue`

**Acción requerida**: Crear el SP `sp_fechaseg_update` en la base de datos PostgreSQL.

#### 346. `sp_fechaseg_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\fechasegfrm.vue`

**Acción requerida**: Crear el SP `sp_fechaseg_create` en la base de datos PostgreSQL.

#### 347. `sp_fechaseg_delete`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\fechasegfrm.vue`

**Acción requerida**: Crear el SP `sp_fechaseg_delete` en la base de datos PostgreSQL.

#### 348. `frmimplicenciareglamentada_sp_get_licencias_reglamentadas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\frmImpLicenciaReglamentada.vue`

**Acción requerida**: Crear el SP `frmimplicenciareglamentada_sp_get_licencias_reglamentadas` en la base de datos PostgreSQL.

#### 349. `frmimplicenciareglamentada_sp_create_licencia_reglamentada`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\frmImpLicenciaReglamentada.vue`

**Acción requerida**: Crear el SP `frmimplicenciareglamentada_sp_create_licencia_reglamentada` en la base de datos PostgreSQL.

#### 350. `frmimplicenciareglamentada_sp_get_licencia_reglamentada_by_id`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\frmImpLicenciaReglamentada.vue`

**Acción requerida**: Crear el SP `frmimplicenciareglamentada_sp_get_licencia_reglamentada_by_id` en la base de datos PostgreSQL.

#### 351. `frmimplicenciareglamentada_sp_update_licencia_reglamentada`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\frmImpLicenciaReglamentada.vue`

**Acción requerida**: Crear el SP `frmimplicenciareglamentada_sp_update_licencia_reglamentada` en la base de datos PostgreSQL.

#### 352. `frmimplicenciareglamentada_sp_delete_licencia_reglamentada`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\frmImpLicenciaReglamentada.vue`

**Acción requerida**: Crear el SP `frmimplicenciareglamentada_sp_delete_licencia_reglamentada` en la base de datos PostgreSQL.

#### 353. `sp_frmselcalle_get_calles`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\frmselcalle.vue`

**Acción requerida**: Crear el SP `sp_frmselcalle_get_calles` en la base de datos PostgreSQL.

#### 354. `sp_frmselcalle_get_calle_by_ids`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\frmselcalle.vue`

**Acción requerida**: Crear el SP `sp_frmselcalle_get_calle_by_ids` en la base de datos PostgreSQL.

#### 355. `sp_giros_dcon_adeudo`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\GirosDconAdeudofrm.vue`

**Acción requerida**: Crear el SP `sp_giros_dcon_adeudo` en la base de datos PostgreSQL.

#### 356. `sp_report_giros_dcon_adeudo`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\GirosDconAdeudofrm.vue`

**Acción requerida**: Crear el SP `sp_report_giros_dcon_adeudo` en la base de datos PostgreSQL.

#### 357. `girosvigentesctexgirofrm_sp_get_catalogo_giros`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\girosVigentesCteXgirofrm.vue`

**Acción requerida**: Crear el SP `girosvigentesctexgirofrm_sp_get_catalogo_giros` en la base de datos PostgreSQL.

#### 358. `girosvigentesctexgirofrm_sp_giros_vigentes_cte_x_giro`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\girosVigentesCteXgirofrm.vue`

**Acción requerida**: Crear el SP `girosvigentesctexgirofrm_sp_giros_vigentes_cte_x_giro` en la base de datos PostgreSQL.

#### 359. `girosvigentesctexgirofrm_sp_reporte_giros_vigentes_cte_xgiro`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\girosVigentesCteXgirofrm.vue`

**Acción requerida**: Crear el SP `girosvigentesctexgirofrm_sp_reporte_giros_vigentes_cte_xgiro` en la base de datos PostgreSQL.

#### 360. `grs_dlg_sp_get_giros`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\grs_dlg.vue`

**Acción requerida**: Crear el SP `grs_dlg_sp_get_giros` en la base de datos PostgreSQL.

#### 361. `grs_dlg_sp_search_giros`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\grs_dlg.vue`

**Acción requerida**: Crear el SP `grs_dlg_sp_search_giros` en la base de datos PostgreSQL.

#### 362. `gruposanunciosabcfrm_sp_anuncios_grupos_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\GruposAnunciosAbcfrm.vue`

**Acción requerida**: Crear el SP `gruposanunciosabcfrm_sp_anuncios_grupos_list` en la base de datos PostgreSQL.

#### 363. `gruposanunciosabcfrm_sp_anuncios_grupos_insert`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\GruposAnunciosAbcfrm.vue`

**Acción requerida**: Crear el SP `gruposanunciosabcfrm_sp_anuncios_grupos_insert` en la base de datos PostgreSQL.

#### 364. `gruposanunciosabcfrm_sp_anuncios_grupos_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\GruposAnunciosAbcfrm.vue`

**Acción requerida**: Crear el SP `gruposanunciosabcfrm_sp_anuncios_grupos_update` en la base de datos PostgreSQL.

#### 365. `gruposanunciosabcfrm_sp_anuncios_grupos_delete`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\GruposAnunciosAbcfrm.vue`

**Acción requerida**: Crear el SP `gruposanunciosabcfrm_sp_anuncios_grupos_delete` en la base de datos PostgreSQL.

#### 366. `delete_grupo_anuncio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\gruposAnunciosfrm.vue`

**Acción requerida**: Crear el SP `delete_grupo_anuncio` en la base de datos PostgreSQL.

#### 367. `get_anuncios_grupo`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\gruposAnunciosfrm.vue`

**Acción requerida**: Crear el SP `get_anuncios_grupo` en la base de datos PostgreSQL.

#### 368. `h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\h_bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom` en la base de datos PostgreSQL.

#### 369. `h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\h_bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom` en la base de datos PostgreSQL.

#### 370. `h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\h_bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle` en la base de datos PostgreSQL.

#### 371. `h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\h_bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel` en la base de datos PostgreSQL.

#### 372. `h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\h_bloqueoDomiciliosfrm.vue`

**Acción requerida**: Crear el SP `h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report` en la base de datos PostgreSQL.

#### 373. `implicenciareglamentada_sp_get_license_data`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ImpLicenciaReglamentada.vue`

**Acción requerida**: Crear el SP `implicenciareglamentada_sp_get_license_data` en la base de datos PostgreSQL.

#### 374. `implicenciareglamentada_sp_print_license`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ImpLicenciaReglamentada.vue`

**Acción requerida**: Crear el SP `implicenciareglamentada_sp_print_license` en la base de datos PostgreSQL.

#### 375. `sp_get_licencia_reglamentada`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ImpLicenciaReglamentadaFrm.vue`

**Acción requerida**: Crear el SP `sp_get_licencia_reglamentada` en la base de datos PostgreSQL.

#### 376. `sp_check_licencia_bloqueada`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ImpLicenciaReglamentadaFrm.vue`

**Acción requerida**: Crear el SP `sp_check_licencia_bloqueada` en la base de datos PostgreSQL.

#### 377. `sp_calcular_adeudo_licencia`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ImpLicenciaReglamentadaFrm.vue`

**Acción requerida**: Crear el SP `sp_calcular_adeudo_licencia` en la base de datos PostgreSQL.

#### 378. `sp_detalle_saldo_licencia`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ImpLicenciaReglamentadaFrm.vue`

**Acción requerida**: Crear el SP `sp_detalle_saldo_licencia` en la base de datos PostgreSQL.

#### 379. `licenciasvigentesfrm_sp_stats`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\LicenciasVigentesfrm.vue`

**Acción requerida**: Crear el SP `licenciasvigentesfrm_sp_stats` en la base de datos PostgreSQL.

#### 380. `licenciasvigentesfrm_sp_licencias_vigentes`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\LicenciasVigentesfrm.vue`

**Acción requerida**: Crear el SP `licenciasvigentesfrm_sp_licencias_vigentes` en la base de datos PostgreSQL.

#### 381. `sp_get_licencia_by_id`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicAdeudofrm.vue`

**Acción requerida**: Crear el SP `sp_get_licencia_by_id` en la base de datos PostgreSQL.

#### 382. `sp_get_detsal_lic`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicAdeudofrm.vue`

**Acción requerida**: Crear el SP `sp_get_detsal_lic` en la base de datos PostgreSQL.

#### 383. `sp_get_saldos_lic`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicAdeudofrm.vue`

**Acción requerida**: Crear el SP `sp_get_saldos_lic` en la base de datos PostgreSQL.

#### 384. `sp_modlic_buscar_licencia`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_modlic_buscar_licencia` en la base de datos PostgreSQL.

#### 385. `sp_modlic_buscar_anuncio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_modlic_buscar_anuncio` en la base de datos PostgreSQL.

#### 386. `sp_get_scian_catalogo`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_get_scian_catalogo` en la base de datos PostgreSQL.

#### 387. `sp_get_actividades_por_scian`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_get_actividades_por_scian` en la base de datos PostgreSQL.

#### 388. `sp_get_tipos_anuncio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_get_tipos_anuncio` en la base de datos PostgreSQL.

#### 389. `sp_modlic_actualizar_licencia`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_modlic_actualizar_licencia` en la base de datos PostgreSQL.

#### 390. `sp_modlic_actualizar_anuncio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_modlic_actualizar_anuncio` en la base de datos PostgreSQL.

#### 391. `sp_calc_sdos_lic`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_calc_sdos_lic` en la base de datos PostgreSQL.

#### 392. `sp_modlic_recalcular_adeudo_anuncio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_modlic_recalcular_adeudo_anuncio` en la base de datos PostgreSQL.

#### 393. `sp_get_session_id`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_get_session_id` en la base de datos PostgreSQL.

#### 394. `sp_modlic_limpiar_sesion`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_modlic_limpiar_sesion` en la base de datos PostgreSQL.

#### 395. `sp_get_ubicacion_sesion`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_get_ubicacion_sesion` en la base de datos PostgreSQL.

#### 396. `sp_modlic_actualizar_coordenadas`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modlicfrm.vue`

**Acción requerida**: Crear el SP `sp_modlic_actualizar_coordenadas` en la base de datos PostgreSQL.

#### 397. `sp_update_tramite`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modtramitefrm.vue`

**Acción requerida**: Crear el SP `sp_update_tramite` en la base de datos PostgreSQL.

#### 398. `sp_get_giros_search`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modtramitefrm.vue`

**Acción requerida**: Crear el SP `sp_get_giros_search` en la base de datos PostgreSQL.

#### 399. `sp_get_calles_search`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\modtramitefrm.vue`

**Acción requerida**: Crear el SP `sp_get_calles_search` en la base de datos PostgreSQL.

#### 400. `sp_observaciones_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\observacionfrm.vue`

**Acción requerida**: Crear el SP `sp_observaciones_list` en la base de datos PostgreSQL.

#### 401. `sp_observaciones_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\observacionfrm.vue`

**Acción requerida**: Crear el SP `sp_observaciones_create` en la base de datos PostgreSQL.

#### 402. `sp_observaciones_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\observacionfrm.vue`

**Acción requerida**: Crear el SP `sp_observaciones_update` en la base de datos PostgreSQL.

#### 403. `sp_observaciones_delete`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\observacionfrm.vue`

**Acción requerida**: Crear el SP `sp_observaciones_delete` en la base de datos PostgreSQL.

#### 404. `privilegios_privilegios_get_permisos_usuario`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\privilegios.vue`

**Acción requerida**: Crear el SP `privilegios_privilegios_get_permisos_usuario` en la base de datos PostgreSQL.

#### 405. `privilegios_privilegios_get_deptos`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\privilegios.vue`

**Acción requerida**: Crear el SP `privilegios_privilegios_get_deptos` en la base de datos PostgreSQL.

#### 406. `privilegios_privilegios_get_mov_licencias`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\privilegios.vue`

**Acción requerida**: Crear el SP `privilegios_privilegios_get_mov_licencias` en la base de datos PostgreSQL.

#### 407. `privilegios_privilegios_get_mov_tramites`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\privilegios.vue`

**Acción requerida**: Crear el SP `privilegios_privilegios_get_mov_tramites` en la base de datos PostgreSQL.

#### 408. `privilegios_privilegios_get_revisiones`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\privilegios.vue`

**Acción requerida**: Crear el SP `privilegios_privilegios_get_revisiones` en la base de datos PostgreSQL.

#### 409. `privilegios_privilegios_get_auditoria_usuario`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\privilegios.vue`

**Acción requerida**: Crear el SP `privilegios_privilegios_get_auditoria_usuario` en la base de datos PostgreSQL.

#### 410. `sp_propuestatab_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\Propuestatab.vue`

**Acción requerida**: Crear el SP `sp_propuestatab_list` en la base de datos PostgreSQL.

#### 411. `sp_propuestatab_condominio`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\Propuestatab.vue`

**Acción requerida**: Crear el SP `sp_propuestatab_condominio` en la base de datos PostgreSQL.

#### 412. `sp_psplash_get_user_info`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\psplash.vue`

**Acción requerida**: Crear el SP `sp_psplash_get_user_info` en la base de datos PostgreSQL.

#### 413. `sp_psplash_get_announcements`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\psplash.vue`

**Acción requerida**: Crear el SP `sp_psplash_get_announcements` en la base de datos PostgreSQL.

#### 414. `sp_psplash_get_stats`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\psplash.vue`

**Acción requerida**: Crear el SP `sp_psplash_get_stats` en la base de datos PostgreSQL.

#### 415. `sp_reactivar_tramite`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\ReactivaTramite.vue`

**Acción requerida**: Crear el SP `sp_reactivar_tramite` en la base de datos PostgreSQL.

#### 416. `reghfrm_sp_get_historic_records`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\regHfrm.vue`

**Acción requerida**: Crear el SP `reghfrm_sp_get_historic_records` en la base de datos PostgreSQL.

#### 417. `reghfrm_sp_create_historic_record`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\regHfrm.vue`

**Acción requerida**: Crear el SP `reghfrm_sp_create_historic_record` en la base de datos PostgreSQL.

#### 418. `reghfrm_sp_get_historic_record`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\regHfrm.vue`

**Acción requerida**: Crear el SP `reghfrm_sp_get_historic_record` en la base de datos PostgreSQL.

#### 419. `reghfrm_sp_delete_historic_record`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\regHfrm.vue`

**Acción requerida**: Crear el SP `reghfrm_sp_delete_historic_record` en la base de datos PostgreSQL.

#### 420. `sfrm_chgfirma_upd_firma`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\sfrm_chgfirma.vue`

**Acción requerida**: Crear el SP `sfrm_chgfirma_upd_firma` en la base de datos PostgreSQL.

#### 421. `sfrm_chgpass_sp_validate_current`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\sfrm_chgpass.vue`

**Acción requerida**: Crear el SP `sfrm_chgpass_sp_validate_current` en la base de datos PostgreSQL.

#### 422. `sfrm_chgpass_sp_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\sfrm_chgpass.vue`

**Acción requerida**: Crear el SP `sfrm_chgpass_sp_update` en la base de datos PostgreSQL.

#### 423. `sfrm_chgpass_sp_bitacora`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\sfrm_chgpass.vue`

**Acción requerida**: Crear el SP `sfrm_chgpass_sp_bitacora` en la base de datos PostgreSQL.

#### 424. `sgcv2_sp_get_quality_indicators`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\SGCv2.vue`

**Acción requerida**: Crear el SP `sgcv2_sp_get_quality_indicators` en la base de datos PostgreSQL.

#### 425. `sgcv2_sp_get_processes`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\SGCv2.vue`

**Acción requerida**: Crear el SP `sgcv2_sp_get_processes` en la base de datos PostgreSQL.

#### 426. `sgcv2_sp_save_process`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\SGCv2.vue`

**Acción requerida**: Crear el SP `sgcv2_sp_save_process` en la base de datos PostgreSQL.

#### 427. `tdmconection_sp_get_connection_status`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TDMConection.vue`

**Acción requerida**: Crear el SP `tdmconection_sp_get_connection_status` en la base de datos PostgreSQL.

#### 428. `tdmconection_sp_get_sync_log`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TDMConection.vue`

**Acción requerida**: Crear el SP `tdmconection_sp_get_sync_log` en la base de datos PostgreSQL.

#### 429. `tdmconection_sp_sync_tramites`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TDMConection.vue`

**Acción requerida**: Crear el SP `tdmconection_sp_sync_tramites` en la base de datos PostgreSQL.

#### 430. `sp_tipobloqueo_list`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\tipobloqueofrm.vue`

**Acción requerida**: Crear el SP `sp_tipobloqueo_list` en la base de datos PostgreSQL.

#### 431. `sp_tipobloqueo_create`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\tipobloqueofrm.vue`

**Acción requerida**: Crear el SP `sp_tipobloqueo_create` en la base de datos PostgreSQL.

#### 432. `sp_tipobloqueo_update`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\tipobloqueofrm.vue`

**Acción requerida**: Crear el SP `sp_tipobloqueo_update` en la base de datos PostgreSQL.

#### 433. `sp_tipobloqueo_delete`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\tipobloqueofrm.vue`

**Acción requerida**: Crear el SP `sp_tipobloqueo_delete` en la base de datos PostgreSQL.

#### 434. `tramitebajaanun_sp_tramite_baja_anun_buscar`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TramiteBajaAnun.vue`

**Acción requerida**: Crear el SP `tramitebajaanun_sp_tramite_baja_anun_buscar` en la base de datos PostgreSQL.

#### 435. `tramitebajaanun_sp_tramite_baja_anun_tramitar`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TramiteBajaAnun.vue`

**Acción requerida**: Crear el SP `tramitebajaanun_sp_tramite_baja_anun_tramitar` en la base de datos PostgreSQL.

#### 436. `tramitebajalic_sp_tramite_baja_lic_consulta`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TramiteBajaLic.vue`

**Acción requerida**: Crear el SP `tramitebajalic_sp_tramite_baja_lic_consulta` en la base de datos PostgreSQL.

#### 437. `tramitebajalic_spget_lic_adeudos`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TramiteBajaLic.vue`

**Acción requerida**: Crear el SP `tramitebajalic_spget_lic_adeudos` en la base de datos PostgreSQL.

#### 438. `tramitebajalic_sp_tramite_baja_lic_tramitar`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TramiteBajaLic.vue`

**Acción requerida**: Crear el SP `tramitebajalic_sp_tramite_baja_lic_tramitar` en la base de datos PostgreSQL.

#### 439. `tramitebajalic_sp_recalcula_proporcional_baja`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TramiteBajaLic.vue`

**Acción requerida**: Crear el SP `tramitebajalic_sp_recalcula_proporcional_baja` en la base de datos PostgreSQL.

#### 440. `tramitebajalic_sp_tramite_baja_lic_recalcula`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\TramiteBajaLic.vue`

**Acción requerida**: Crear el SP `tramitebajalic_sp_tramite_baja_lic_recalcula` en la base de datos PostgreSQL.

#### 441. `unidadimg_get_unidad_img`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\UnidadImg.vue`

**Acción requerida**: Crear el SP `unidadimg_get_unidad_img` en la base de datos PostgreSQL.

#### 442. `unidadimg_set_unidad_img`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\UnidadImg.vue`

**Acción requerida**: Crear el SP `unidadimg_set_unidad_img` en la base de datos PostgreSQL.

#### 443. `unidadimg_get_ruta_dir`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\UnidadImg.vue`

**Acción requerida**: Crear el SP `unidadimg_get_ruta_dir` en la base de datos PostgreSQL.

#### 444. `unidadimg_rutadir`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\UnidadImg.vue`

**Acción requerida**: Crear el SP `unidadimg_rutadir` en la base de datos PostgreSQL.

#### 445. `webbrowser_sp_get_bookmarks`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\webBrowser.vue`

**Acción requerida**: Crear el SP `webbrowser_sp_get_bookmarks` en la base de datos PostgreSQL.

#### 446. `webbrowser_sp_save_bookmark`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\webBrowser.vue`

**Acción requerida**: Crear el SP `webbrowser_sp_save_bookmark` en la base de datos PostgreSQL.

#### 447. `webbrowser_sp_delete_bookmark`

**Archivos que lo usan**:
- `src\views\modules\padron_licencias\webBrowser.vue`

**Acción requerida**: Crear el SP `webbrowser_sp_delete_bookmark` en la base de datos PostgreSQL.


---

## ✅ STORED PROCEDURES ENCONTRADOS (318)

### Por Tipo:

- **FUNCTION** (PostgreSQL): 307
- **PROCEDURE** (Informix legacy): 11

⚠️  **Advertencia**: 11 SP(s) usan sintaxis PROCEDURE (deberían ser FUNCTION en PostgreSQL)

### Lista Completa:

| # | Stored Procedure | Tipo | Usado en | Definido en |
|---|------------------|------|----------|-------------|
| 1 | `sp_aseo_recaudadoras_create` | FUNCTION | 1 | 1 |
| 2 | `sp_aseo_recaudadoras_update` | FUNCTION | 1 | 1 |
| 3 | `sp_aseo_recaudadoras_delete` | FUNCTION | 1 | 1 |
| 4 | `sp16_contratos` | FUNCTION | 7 | 4 |
| 5 | `sp16_contratos_buscar` | FUNCTION | 6 | 2 |
| 6 | `sp_aseo_contrato_por_predial` | FUNCTION | 2 | 1 |
| 7 | `sp_aseo_multas_consultar` | FUNCTION | 1 | 1 |
| 8 | `sp_aseo_multa_cancelar` | FUNCTION | 1 | 1 |
| 9 | `sp_aseo_verificar_sincronizacion_catastro` | FUNCTION | 1 | 1 |
| 10 | `sp_aseo_actualizar_desde_catastro` | FUNCTION | 1 | 1 |
| 11 | `sp_aseo_descuentos_config_listar` | FUNCTION | 1 | 1 |
| 12 | `sp_aseo_descuento_aplicar` | FUNCTION | 1 | 1 |
| 13 | `sp_aseo_descuentos_consultar` | FUNCTION | 1 | 1 |
| 14 | `sp_aseo_buscar_datos_catastro` | FUNCTION | 1 | 1 |
| 15 | `sp_aseo_verificar_contrato_existente` | FUNCTION | 1 | 1 |
| 16 | `sp_aseo_insertar_contrato_rapido` | FUNCTION | 1 | 1 |
| 17 | `sp_aseo_inicializar_obligaciones` | FUNCTION | 1 | 1 |
| 18 | `sp_aseo_contratos_por_colonia` | FUNCTION | 1 | 1 |
| 19 | `sp_aseo_actualizar_unidad_por_colonia` | FUNCTION | 1 | 1 |
| 20 | `sp_aseo_colonias_con_contratos` | FUNCTION | 1 | 1 |
| 21 | `sp_ejecutores_list` | FUNCTION | 1 | 2 |
| 22 | `apremiossvn_ejecutores_estadisticas` | PROCEDURE | 1 | 2 |
| 23 | `sp_actuaciones_list` | FUNCTION | 1 | 1 |
| 24 | `apremiossvn_apremios_estadisticas` | FUNCTION | 59 | 2 |
| 25 | `apremiossvn_expedientes_list` | FUNCTION | 1 | 1 |
| 26 | `apremiossvn_expedientes_estadisticas` | PROCEDURE | 1 | 2 |
| 27 | `sp_cambiar_fase` | FUNCTION | 1 | 1 |
| 28 | `sp_fases_list` | FUNCTION | 1 | 1 |
| 29 | `apremiossvn_notificaciones_list` | FUNCTION | 1 | 1 |
| 30 | `apremiossvn_notificaciones_estadisticas` | PROCEDURE | 1 | 2 |
| 31 | `apremiossvn_pagos_list` | FUNCTION | 1 | 1 |
| 32 | `apremiossvn_pagos_estadisticas` | PROCEDURE | 1 | 2 |
| 33 | `sp_estadisticas_generales` | FUNCTION | 1 | 1 |
| 34 | `sp_autorizades_search` | FUNCTION | 1 | 2 |
| 35 | `sp_carta_invitacion` | FUNCTION | 1 | 1 |
| 36 | `sp_cmultemision_search` | FUNCTION | 1 | 2 |
| 37 | `sp_cmultfolio_search` | FUNCTION | 1 | 2 |
| 38 | `sp_consultareg_mercados` | FUNCTION | 1 | 2 |
| 39 | `sp_get_cons_his` | FUNCTION | 1 | 2 |
| 40 | `sp_ejecutores_listar` | FUNCTION | 1 | 2 |
| 41 | `estadxfolio_stats` | FUNCTION | 1 | 2 |
| 42 | `spd_15_foliospag` | FUNCTION | 1 | 2 |
| 43 | `sp_facturacion_list` | FUNCTION | 1 | 2 |
| 44 | `sp_firmaelectronica_listar_folios` | FUNCTION | 1 | 2 |
| 45 | `get_individual_folio` | FUNCTION | 1 | 2 |
| 46 | `sp_individual_folio_search` | FUNCTION | 1 | 2 |
| 47 | `sp_listados_get_listados` | FUNCTION | 1 | 2 |
| 48 | `sp_listados_ade_aseo` | PROCEDURE | 1 | 2 |
| 49 | `sp_listados_ade_exclusivos` | PROCEDURE | 1 | 2 |
| 50 | `sp_listados_ade_infracciones` | PROCEDURE | 1 | 2 |
| 51 | `sp_listados_ade_mercados` | PROCEDURE | 1 | 2 |
| 52 | `sp_listados_ade_publicos` | PROCEDURE | 1 | 2 |
| 53 | `sp_listados_sin_adereq` | FUNCTION | 1 | 2 |
| 54 | `apremiossvn_listados_ade` | FUNCTION | 1 | 1 |
| 55 | `sp_lista_eje_get` | FUNCTION | 2 | 6 |
| 56 | `spd_12_gastoscob` | FUNCTION | 1 | 5 |
| 57 | `sp_listxfec_report` | FUNCTION | 1 | 5 |
| 58 | `sp_listxreg_report` | FUNCTION | 1 | 1 |
| 59 | `sp_get_apremio` | FUNCTION | 1 | 5 |
| 60 | `sp_modificar_bien` | FUNCTION | 1 | 1 |
| 61 | `sp_modif_masiva_aplicar` | FUNCTION | 1 | 1 |
| 62 | `sp_notificaciones_list` | FUNCTION | 1 | 1 |
| 63 | `spd_15_notif_mes` | FUNCTION | 1 | 2 |
| 64 | `sp_prenomina_report` | FUNCTION | 1 | 2 |
| 65 | `sp_buscar_folios` | FUNCTION | 1 | 2 |
| 66 | `sp_recuperacion_report` | FUNCTION | 1 | 1 |
| 67 | `sp_report_autorizados` | FUNCTION | 1 | 2 |
| 68 | `sp_buscar_mercados_adeudos` | FUNCTION | 1 | 2 |
| 69 | `rpt_catal_eje` | FUNCTION | 1 | 2 |
| 70 | `rpt_estadxfolio` | FUNCTION | 1 | 2 |
| 71 | `rprt_listados` | FUNCTION | 1 | 2 |
| 72 | `rprt_listaxfec` | FUNCTION | 1 | 2 |
| 73 | `sp_rprt_listax_reg_aseo` | FUNCTION | 1 | 2 |
| 74 | `rpt_listaxreg_estacionometro` | FUNCTION | 1 | 2 |
| 75 | `rpt_listax_reg_mer` | FUNCTION | 1 | 2 |
| 76 | `rprtlist_eje_report` | FUNCTION | 1 | 2 |
| 77 | `rptfact_merc_get_report` | FUNCTION | 1 | 2 |
| 78 | `rpt_listado_aseo` | FUNCTION | 1 | 2 |
| 79 | `rpt_listaxregpub_get_report` | FUNCTION | 1 | 2 |
| 80 | `rpt_lista_mercados` | FUNCTION | 1 | 2 |
| 81 | `rpt_prenomina` | FUNCTION | 1 | 2 |
| 82 | `rptrecup_aseo_report` | FUNCTION | 1 | 2 |
| 83 | `rptrecup_merc_report` | FUNCTION | 1 | 2 |
| 84 | `rptreq_aseo_report` | FUNCTION | 1 | 2 |
| 85 | `rptreq_merc_reporte` | FUNCTION | 1 | 2 |
| 86 | `rptreq_pba_get_report_data` | FUNCTION | 1 | 2 |
| 87 | `rptreq_pba_aseo_get_report` | FUNCTION | 1 | 2 |
| 88 | `sp_change_password` | FUNCTION | 1 | 2 |
| 89 | `sp_pub_movtos` | FUNCTION | 1 | 2 |
| 90 | `actualiza_pub_pago` | FUNCTION | 1 | 2 |
| 91 | `sp_busca_folios_divadmin` | FUNCTION | 1 | 2 |
| 92 | `sp_aplica_pago_divadmin` | FUNCTION | 1 | 2 |
| 93 | `get_aspectos` | FUNCTION | 1 | 2 |
| 94 | `get_current_aspecto` | FUNCTION | 1 | 2 |
| 95 | `sp_get_incidencias_baja_multiple` | FUNCTION | 1 | 2 |
| 96 | `sp_insert_ta14_datos_edo` | FUNCTION | 1 | 2 |
| 97 | `sp_afec_esta01` | FUNCTION | 1 | 2 |
| 98 | `sp_insert_ta14_bitacora` | FUNCTION | 1 | 2 |
| 99 | `sp_buscar_folios_histo` | FUNCTION | 1 | 2 |
| 100 | `sp_cambiar_a_tesorero` | FUNCTION | 1 | 2 |
| 101 | `sp_conciliados_by_folio` | FUNCTION | 1 | 2 |
| 102 | `sp14_afolios` | FUNCTION | 1 | 2 |
| 103 | `sp14_bfolios` | FUNCTION | 1 | 2 |
| 104 | `sp_get_remesas` | FUNCTION | 1 | 2 |
| 105 | `sp_get_remesa_detalle_mpio` | FUNCTION | 1 | 2 |
| 106 | `sp_get_public_parking_list` | FUNCTION | 3 | 2 |
| 107 | `sp_get_public_parking_fines` | FUNCTION | 1 | 2 |
| 108 | `cajero_pub_detalle` | FUNCTION | 1 | 2 |
| 109 | `spget_lic_grales` | FUNCTION | 1 | 2 |
| 110 | `spd_crbo_abc` | FUNCTION | 1 | 2 |
| 111 | `sum_contrarecibos_by_date` | FUNCTION | 1 | 2 |
| 112 | `spubreports_edocta` | FUNCTION | 1 | 2 |
| 113 | `sqrp_esta01_report` | FUNCTION | 1 | 2 |
| 114 | `sp_get_remesas_estado_mpio` | FUNCTION | 1 | 2 |
| 115 | `spd_delesta01` | FUNCTION | 2 | 2 |
| 116 | `sp_insert_folio_adeudo` | FUNCTION | 1 | 2 |
| 117 | `get_periodo_altas` | FUNCTION | 1 | 7 |
| 118 | `sp14_remesa` | FUNCTION | 3 | 9 |
| 119 | `sp_gen_individual_add` | FUNCTION | 1 | 2 |
| 120 | `sp_gen_individual_generate_file` | FUNCTION | 1 | 2 |
| 121 | `sp_get_padron_report` | FUNCTION | 1 | 2 |
| 122 | `sp_get_inspectors` | FUNCTION | 1 | 2 |
| 123 | `sqrp_publicos_report` | FUNCTION | 1 | 2 |
| 124 | `sp_mensaje_show` | FUNCTION | 1 | 2 |
| 125 | `sp_get_metrometer_by_axo_folio` | FUNCTION | 1 | 2 |
| 126 | `sp_get_metrometers_map_url` | FUNCTION | 1 | 2 |
| 127 | `sp_passwords_list` | FUNCTION | 1 | 2 |
| 128 | `sp_passwords_update` | FUNCTION | 1 | 2 |
| 129 | `sp_get_predio_carto_url` | FUNCTION | 1 | 2 |
| 130 | `cons_predio` | FUNCTION | 1 | 2 |
| 131 | `sppubalta` | FUNCTION | 1 | 2 |
| 132 | `sp_reactiva_folios_buscar` | FUNCTION | 1 | 2 |
| 133 | `sqrp_relacion_folios_report` | FUNCTION | 2 | 2 |
| 134 | `sp_get_folios_by_inspector` | FUNCTION | 1 | 2 |
| 135 | `spubreports_list` | FUNCTION | 1 | 2 |
| 136 | `report_folios_pagados` | FUNCTION | 2 | 2 |
| 137 | `report_folios_adeudo_por_inspector` | FUNCTION | 1 | 2 |
| 138 | `sp_catalog_inspectors` | FUNCTION | 1 | 2 |
| 139 | `sp_report_folios` | FUNCTION | 1 | 2 |
| 140 | `sp_login_seguridad` | FUNCTION | 1 | 2 |
| 141 | `sp_ta_15_publicos_insert` | FUNCTION | 1 | 2 |
| 142 | `sp_up_pagos_update` | FUNCTION | 1 | 2 |
| 143 | `process_valet_file` | FUNCTION | 1 | 2 |
| 144 | `sp_get_apremios` | FUNCTION | 1 | 5 |
| 145 | `sp_get_periodos_by_control` | FUNCTION | 1 | 5 |
| 146 | `sp_get_tablas` | FUNCTION | 1 | 10 |
| 147 | `sp_get_unidades_by_tabla` | FUNCTION | 1 | 1 |
| 148 | `sp_insert_unidades` | FUNCTION | 1 | 1 |
| 149 | `sp34_adeudototal` | FUNCTION | 1 | 5 |
| 150 | `get_tablas` | FUNCTION | 1 | 1 |
| 151 | `get_etiquetas` | FUNCTION | 1 | 1 |
| 152 | `cob34_gdatosg_02` | FUNCTION | 1 | 9 |
| 153 | `cob34_gdetade_01` | FUNCTION | 1 | 5 |
| 154 | `sp_get_pagados` | FUNCTION | 1 | 9 |
| 155 | `upd34_gen_adeudos_ind` | FUNCTION | 1 | 5 |
| 156 | `sp_gnuevos_alta` | FUNCTION | 1 | 5 |
| 157 | `sp_padron_vigencias` | FUNCTION | 1 | 1 |
| 158 | `sp_padron_etiquetas` | FUNCTION | 1 | 1 |
| 159 | `sp_padron_concesiones_get` | FUNCTION | 1 | 1 |
| 160 | `sp_padron_adeudos_get` | FUNCTION | 1 | 1 |
| 161 | `buscar_concesion` | FUNCTION | 1 | 5 |
| 162 | `verificar_pagos` | FUNCTION | 1 | 5 |
| 163 | `actualizar_concesion` | FUNCTION | 1 | 5 |
| 164 | `con34_rdetade_021` | FUNCTION | 1 | 5 |
| 165 | `upd34_ade_01` | FUNCTION | 1 | 5 |
| 166 | `sp_rbaja_buscar_local` | FUNCTION | 1 | 5 |
| 167 | `sp_rbaja_verificar_adeudos_post` | FUNCTION | 1 | 5 |
| 168 | `sp_rbaja_cancelar_local` | FUNCTION | 1 | 5 |
| 169 | `sp_ins34_rastro_01` | FUNCTION | 1 | 5 |
| 170 | `ins34_rubro_01` | FUNCTION | 1 | 5 |
| 171 | `sp_get_dependencias` | FUNCTION | 1 | 6 |
| 172 | `sp_get_agenda_visitas` | FUNCTION | 1 | 2 |
| 173 | `sp_baja_anuncio_buscar` | FUNCTION | 1 | 3 |
| 174 | `sp_baja_anuncio_procesar` | FUNCTION | 1 | 3 |
| 175 | `sp_consulta_licencia` | FUNCTION | 1 | 3 |
| 176 | `sp_baja_licencia` | FUNCTION | 1 | 6 |
| 177 | `sp_busque_search_by_owner` | FUNCTION | 1 | 1 |
| 178 | `sp_busque_search_by_location` | FUNCTION | 1 | 1 |
| 179 | `sp_busque_search_by_account` | FUNCTION | 1 | 1 |
| 180 | `sp_busque_search_by_rfc` | FUNCTION | 1 | 1 |
| 181 | `sp_busque_search_by_cadastral_key` | FUNCTION | 1 | 1 |
| 182 | `sp_busque_get_detail` | FUNCTION | 1 | 1 |
| 183 | `buscar_actividad_por_id` | FUNCTION | 1 | 3 |
| 184 | `buscar_actividades` | FUNCTION | 1 | 3 |
| 185 | `catalogo_scian_busqueda` | FUNCTION | 1 | 3 |
| 186 | `sp_get_tramite_by_id` | FUNCTION | 4 | 6 |
| 187 | `sp_get_giro_by_id` | FUNCTION | 3 | 4 |
| 188 | `sp_cancel_tramite` | FUNCTION | 1 | 3 |
| 189 | `carga_search_predio` | FUNCTION | 1 | 1 |
| 190 | `get_construcciones` | FUNCTION | 1 | 5 |
| 191 | `get_avaluo` | FUNCTION | 1 | 2 |
| 192 | `get_cartografia_predial` | FUNCTION | 1 | 2 |
| 193 | `carga_delete_predio` | FUNCTION | 1 | 1 |
| 194 | `sp_get_cargadatos` | FUNCTION | 1 | 1 |
| 195 | `sp_save_cargadatos` | FUNCTION | 1 | 1 |
| 196 | `sp_get_avaluos` | FUNCTION | 1 | 1 |
| 197 | `sp_get_construcciones` | FUNCTION | 1 | 1 |
| 198 | `sp_get_area_carto` | FUNCTION | 1 | 1 |
| 199 | `sp_get_cuenta_by_cvecuenta` | FUNCTION | 1 | 3 |
| 200 | `sp_get_convcta_by_cvecuenta` | FUNCTION | 1 | 1 |
| 201 | `sp_get_convcta_by_cvecatnva_subpredio` | FUNCTION | 1 | 1 |
| 202 | `sp_get_cartografia_predial` | FUNCTION | 1 | 3 |
| 203 | `sp_catrequisitos_list` | FUNCTION | 1 | 1 |
| 204 | `sp_catrequisitos_create` | FUNCTION | 1 | 1 |
| 205 | `sp_catrequisitos_update` | FUNCTION | 1 | 1 |
| 206 | `sp_catrequisitos_delete` | FUNCTION | 1 | 1 |
| 207 | `sp_solicnooficial_create` | FUNCTION | 1 | 3 |
| 208 | `sp_solicnooficial_update` | FUNCTION | 1 | 3 |
| 209 | `sp_solicnooficial_cancel` | FUNCTION | 1 | 3 |
| 210 | `consulta_usuario_por_usuario` | FUNCTION | 1 | 2 |
| 211 | `consulta_usuario_por_nombre` | FUNCTION | 1 | 2 |
| 212 | `consulta_usuario_por_depto` | FUNCTION | 1 | 2 |
| 213 | `get_dependencias` | FUNCTION | 1 | 3 |
| 214 | `get_deptos_by_dependencia` | FUNCTION | 1 | 3 |
| 215 | `sp_cruces_search_calle1` | FUNCTION | 1 | 3 |
| 216 | `sp_cruces_search_calle2` | FUNCTION | 1 | 3 |
| 217 | `sp_cruces_localiza_calle` | FUNCTION | 1 | 3 |
| 218 | `sp_list_constancias` | FUNCTION | 1 | 1 |
| 219 | `sp_create_constancia` | FUNCTION | 1 | 1 |
| 220 | `sp_update_constancia` | FUNCTION | 1 | 1 |
| 221 | `sp_cancel_constancia` | FUNCTION | 1 | 1 |
| 222 | `sp_doctos_list` | FUNCTION | 1 | 1 |
| 223 | `sp_doctos_create` | FUNCTION | 1 | 1 |
| 224 | `sp_doctos_update` | FUNCTION | 1 | 1 |
| 225 | `sp_doctos_delete` | FUNCTION | 1 | 1 |
| 226 | `sp_empresas_list` | FUNCTION | 1 | 6 |
| 227 | `sp_empresas_create` | FUNCTION | 1 | 6 |
| 228 | `sp_empresas_update` | FUNCTION | 1 | 6 |
| 229 | `sp_empresas_delete` | FUNCTION | 1 | 6 |
| 230 | `sp_firma_save` | FUNCTION | 1 | 3 |
| 231 | `sp_firma_validate` | FUNCTION | 1 | 3 |
| 232 | `sp_validate_firma_usuario` | FUNCTION | 1 | 3 |
| 233 | `sp_listar_calles` | FUNCTION | 1 | 3 |
| 234 | `sp_buscar_calles` | FUNCTION | 1 | 3 |
| 235 | `sp_listar_colonias` | FUNCTION | 1 | 1 |
| 236 | `sp_buscar_colonias` | FUNCTION | 1 | 3 |
| 237 | `sp_obtener_colonia_seleccionada` | FUNCTION | 1 | 3 |
| 238 | `sp_get_tramites_by_fecha` | FUNCTION | 1 | 2 |
| 239 | `sp_get_cruce_calles_by_tramite` | FUNCTION | 1 | 2 |
| 240 | `get_grupos_anuncios` | FUNCTION | 1 | 2 |
| 241 | `get_giros` | FUNCTION | 2 | 5 |
| 242 | `insert_grupo_anuncio` | FUNCTION | 1 | 2 |
| 243 | `update_grupo_anuncio` | FUNCTION | 1 | 2 |
| 244 | `get_anuncios_disponibles` | FUNCTION | 1 | 2 |
| 245 | `add_anuncios_to_grupo` | FUNCTION | 1 | 2 |
| 246 | `remove_anuncios_from_grupo` | FUNCTION | 1 | 2 |
| 247 | `sp_list_grupos_licencias` | FUNCTION | 1 | 3 |
| 248 | `sp_insert_grupo_licencia` | FUNCTION | 1 | 3 |
| 249 | `sp_update_grupo_licencia` | FUNCTION | 1 | 3 |
| 250 | `sp_delete_grupo_licencia` | FUNCTION | 1 | 3 |
| 251 | `get_grupos_licencias` | FUNCTION | 1 | 5 |
| 252 | `insert_grupo_licencia` | FUNCTION | 1 | 5 |
| 253 | `update_grupo_licencia` | FUNCTION | 1 | 5 |
| 254 | `delete_grupo_licencia` | FUNCTION | 1 | 3 |
| 255 | `get_licencias_disponibles` | FUNCTION | 1 | 3 |
| 256 | `get_licencias_grupo` | FUNCTION | 1 | 3 |
| 257 | `add_licencias_to_grupo` | FUNCTION | 1 | 3 |
| 258 | `remove_licencias_from_grupo` | FUNCTION | 1 | 3 |
| 259 | `sp_validate_hasta_form` | FUNCTION | 1 | 5 |
| 260 | `sp_get_tramite_info` | FUNCTION | 1 | 10 |
| 261 | `sp_imp_oficio_tramite_info` | FUNCTION | 1 | 1 |
| 262 | `sp_imp_oficio_register` | FUNCTION | 1 | 3 |
| 263 | `sp_buscar_licencia` | FUNCTION | 1 | 4 |
| 264 | `sp_get_licencia_recibo` | FUNCTION | 1 | 3 |
| 265 | `sp_get_parametros_recibo` | FUNCTION | 1 | 3 |
| 266 | `sp_numero_a_letras` | FUNCTION | 1 | 3 |
| 267 | `sp_buscar_anuncio` | FUNCTION | 1 | 4 |
| 268 | `sp_ligar_anuncio` | PROCEDURE | 1 | 3 |
| 269 | `sp_ligarequisitos_giros` | FUNCTION | 1 | 1 |
| 270 | `sp_ligarequisitos_available` | FUNCTION | 1 | 1 |
| 271 | `sp_ligarequisitos_list` | FUNCTION | 1 | 1 |
| 272 | `sp_ligarequisitos_add` | FUNCTION | 1 | 1 |
| 273 | `sp_ligarequisitos_remove` | FUNCTION | 1 | 1 |
| 274 | `calc_sdoslsr` | PROCEDURE | 1 | 3 |
| 275 | `sp_prepago_get_data` | FUNCTION | 1 | 3 |
| 276 | `sp_prepago_get_ultimo_requerimiento` | FUNCTION | 1 | 3 |
| 277 | `sp_prepago_calcular_descpred` | FUNCTION | 1 | 3 |
| 278 | `sp_prepago_recalcular_dpp` | FUNCTION | 1 | 3 |
| 279 | `sp_prepago_liquidacion_parcial` | FUNCTION | 1 | 3 |
| 280 | `sp_prepago_eliminar_dpp` | FUNCTION | 1 | 3 |
| 281 | `get_contribholog_list` | FUNCTION | 1 | 3 |
| 282 | `sp_c_contribholog_list` | FUNCTION | 1 | 1 |
| 283 | `sp_c_contribholog_create` | FUNCTION | 1 | 1 |
| 284 | `sp_c_contribholog_update` | FUNCTION | 1 | 1 |
| 285 | `sp_c_contribholog_delete` | FUNCTION | 1 | 1 |
| 286 | `sp_get_cuenta_historico` | FUNCTION | 1 | 1 |
| 287 | `sp_get_predial_historico` | FUNCTION | 1 | 1 |
| 288 | `sp_get_ubicacion_historico` | FUNCTION | 1 | 1 |
| 289 | `sp_get_valores_historico` | FUNCTION | 1 | 1 |
| 290 | `sp_get_diferencias_historico` | FUNCTION | 1 | 1 |
| 291 | `sp_get_regimen_propiedad_historico` | FUNCTION | 1 | 1 |
| 292 | `sp_registro_solicitud` | FUNCTION | 1 | 2 |
| 293 | `sp_agregar_documento` | FUNCTION | 1 | 2 |
| 294 | `sp_repdoc_get_giros` | FUNCTION | 1 | 3 |
| 295 | `sp_repdoc_get_requisitos_by_giro` | FUNCTION | 1 | 2 |
| 296 | `sp_get_tramite_estado` | FUNCTION | 1 | 1 |
| 297 | `sp_get_tramite_revisiones` | FUNCTION | 1 | 1 |
| 298 | `sp_reporte_anuncios_excel` | FUNCTION | 1 | 2 |
| 299 | `report_licencias_suspendidas` | FUNCTION | 1 | 2 |
| 300 | `buscar_licencia_responsiva` | FUNCTION | 1 | 3 |
| 301 | `buscar_responsiva_licencia` | FUNCTION | 1 | 3 |
| 302 | `buscar_responsiva_folio` | FUNCTION | 1 | 3 |
| 303 | `crear_responsiva` | FUNCTION | 1 | 3 |
| 304 | `cancelar_responsiva` | FUNCTION | 1 | 3 |
| 305 | `sp_semaforo_get_random_color` | FUNCTION | 1 | 3 |
| 306 | `sp_semaforo_register_color_result` | FUNCTION | 1 | 3 |
| 307 | `sp_semaforo_save` | FUNCTION | 1 | 1 |
| 308 | `sp_semaforo_get_stats` | FUNCTION | 1 | 2 |
| 309 | `sp_semaforo_history` | FUNCTION | 1 | 1 |
| 310 | `sp_zonaanuncio_list` | FUNCTION | 1 | 3 |
| 311 | `sp_zonaanuncio_create` | FUNCTION | 1 | 3 |
| 312 | `sp_zonaanuncio_update` | FUNCTION | 1 | 3 |
| 313 | `sp_zonaanuncio_delete` | FUNCTION | 1 | 3 |
| 314 | `sp_get_recaudadoras` | FUNCTION | 1 | 25 |
| 315 | `sp_get_zonas` | FUNCTION | 1 | 5 |
| 316 | `sp_get_subzonas` | FUNCTION | 1 | 3 |
| 317 | `sp_get_licencia` | FUNCTION | 1 | 4 |
| 318 | `sp_save_licencias_zona` | FUNCTION | 1 | 3 |

---

## ⚠️  PROBLEMAS DE SINTAXIS (7)

- **Alta prioridad** (sintaxis Informix): 5
- **Media prioridad** (mejoras): 2

### 🔴 Alta Prioridad (Sintaxis Informix):

| Archivo | Problema |
|---------|----------|
| `..\Base\estacionamiento_exclusivo\database\database\ABCEjec_sp_estadisticas.sql` | Contiene "WITH RESUME" (sintaxis Informix) |
| `..\Base\estacionamiento_exclusivo\database\database\ApremiosSvnExpedientes_sp_estadisticas.sql` | Contiene "WITH RESUME" (sintaxis Informix) |
| `..\Base\estacionamiento_exclusivo\database\database\ApremiosSvnNotificaciones_sp_estadisticas.sql` | Contiene "WITH RESUME" (sintaxis Informix) |
| `..\Base\estacionamiento_exclusivo\database\database\ApremiosSvnPagos_sp_estadisticas.sql` | Contiene "WITH RESUME" (sintaxis Informix) |
| `..\Base\estacionamiento_exclusivo\database\database\ConsultaReg_sp_estadisticas.sql` | Contiene "WITH RESUME" (sintaxis Informix) |

**Acción requerida**: Migrar estos SPs de Informix a PostgreSQL.

### 🟡 Media Prioridad (Mejoras):

| Archivo | Problema |
|---------|----------|
| `..\Base\aseo_contratado\database\database\AdeudosExe_Del_sp_adeudos_exe_del_list_contrato.sql` | Function sin "LANGUAGE plpgsql" |
| `..\Base\aseo_contratado\database\database\Prueba_sp_prueba_query.sql` | Function sin "LANGUAGE plpgsql" |

---

## 📋 STORED PROCEDURES POR MÓDULO


### aseo_contratado

- **Total de SPs**: 26
- **SPs**: `sp_aseo_recaudadoras_create`, `sp_aseo_recaudadoras_update`, `sp_aseo_recaudadoras_delete`, `sp16_contratos`, `sp16_contratos_buscar` y 21 más...

### estacionamiento_exclusivo

- **Total de SPs**: 69
- **SPs**: `sp_ejecutores_list`, `apremiossvn_ejecutores_estadisticas`, `sp_actuaciones_list`, `apremiossvn_apremios_estadisticas`, `apremiossvn_expedientes_list` y 64 más...

### estacionamiento_publico

- **Total de SPs**: 54
- **SPs**: `sp_pub_movtos`, `actualiza_pub_pago`, `sp_busca_folios_divadmin`, `sp_aplica_pago_divadmin`, `get_aspectos` y 49 más...

### mercados

- **Total de SPs**: 1
- **SPs**: `sp_get_recaudadoras`

### multas_reglamentos

- **Total de SPs**: 5
- **SPs**: `spget_lic_grales`, `cob34_gdatosg_02`, `sp_validate_hasta_form`, `sp_buscar_licencia`, `sp_buscar_anuncio`

### otras_obligaciones

- **Total de SPs**: 28
- **SPs**: `sp_get_apremios`, `sp_get_periodos_by_control`, `sp_get_tablas`, `sp_get_unidades_by_tabla`, `sp_insert_unidades` y 23 más...

### padron_licencias

- **Total de SPs**: 147
- **SPs**: `sp_get_dependencias`, `sp_get_agenda_visitas`, `sp_baja_anuncio_buscar`, `sp_baja_anuncio_procesar`, `sp_consulta_licencia` y 142 más...

---

## 🎯 COBERTURA DE STORED PROCEDURES


- **Cobertura**: 41.6%
- **SPs requeridos**: 765
- **SPs disponibles**: 318
- **SPs faltantes**: 447

⚠️  **Acción requerida**: Crear los 447 SP(s) faltante(s) para alcanzar 100% de cobertura.

---

## 🔧 RECOMENDACIONES


### 1. Crear SPs Faltantes

Para cada SP faltante, crear un archivo SQL con la siguiente estructura:

```sql
-- =====================================================
-- SP: {nombre_sp}
-- Descripción: {descripción}
-- Base: {nombre_base}
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION {nombre_sp}(
  -- parámetros
)
RETURNS TABLE (
  -- columnas de retorno
) AS $$
BEGIN
  RETURN QUERY
  SELECT ...;
END;
$$ LANGUAGE plpgsql;
```

### 2. Migrar Sintaxis Informix → PostgreSQL

Convertir:
```sql
-- ❌ Informix
CREATE PROCEDURE sp_name()
RETURNING ...
WITH RESUME;

-- ✅ PostgreSQL
CREATE OR REPLACE FUNCTION sp_name()
RETURNS TABLE (...) AS $$
BEGIN
  RETURN QUERY ...;
END;
$$ LANGUAGE plpgsql;
```

---

## 📈 ESTADÍSTICAS DETALLADAS

- **Archivos Vue con SPs**: 78%
- **Archivos SQL con definiciones**: 2508
- **Promedio de SPs por módulo**: 45.4
- **Reutilización de SPs**: 2.41x

---

**Generado por**: RefactorX Verification System
**Versión**: 1.0.0
