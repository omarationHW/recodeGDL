# 🔍 MAPEO COMPLETO: RefactorX/Base/ → Vue Components

**Fecha**: 10/11/2025, 4:22:57 p.m.

---

## 📊 RESUMEN EJECUTIVO

### Base/:
- Módulos: 8
- SPs definidos: 2475
- Tablas detectadas: 181

### Vue:
- Archivos: 593
- SPs usados: 817

### Cobertura:
- ✅ Encontrados: 505
- ❌ Faltantes: 325
- 📊 Cobertura: 61.8%

---

## 🗂️ MÓDULOS EN BASE/


### aseo_contratado
- SPs: 318
- Tablas: 33
- Archivos SQL: 487

**SPs** (primeros 15):
- `sp_get_tipo_aseo`
- `sp_get_recaudadoras`
- `upd16_ade`
- `sp_buscar_contrato`
- `sp_buscar_apremios`
- `sp_buscar_periodos_apremio`
- `sp_buscar_convenio`
- `sp_pagar_apremio`
- `con16_detade_021`
- `sp_cves_operacion_list`
- `sp_cves_operacion_get`
- `sp_cves_operacion_insert`
- `sp_cves_operacion_update`
- `sp_cves_operacion_delete`
- `sp_empresas_list`
- ...y 303 más

### cementerios
- SPs: 105
- Tablas: 20
- Archivos SQL: 140

**SPs** (primeros 15):
- `sp_consultar_sanandres`
- `sp_consultar_sanandres_paginated`
- `sp_get_usuario_detalle`
- `sp_get_version_detalle`
- `sp_cementerios_list`
- `sp_get_recaudadora`
- `rpt_titulos_get_recaudadora`
- `sp_titulos_view`
- `sp_titulos_extra`
- `sp_titulosin_get_rec`
- `sp_abcf_get_folio`
- `sp_abcf_get_adicional`
- `spd_13_abcdesctos`
- `sp_liquidaciones_calcular`
- `sp_valida_usuario`
- ...y 90 más

### estacionamiento_exclusivo
- SPs: 312
- Tablas: 41
- Archivos SQL: 250

**SPs** (primeros 15):
- `sp_lista_eje_get`
- `sp_listxfec_get_vigencias`
- `sp_listxfec_get_recaudadoras`
- `sp_listxfec_get_ejecutores`
- `sp_get_apremio`
- `sp_historial_apremio`
- `date_to_words`
- `sp_modificar_apremio`
- `sp_get_user_by_credentials`
- `sp_check_new_version`
- `spd_12_gastoscob`
- `spd_12_gastoscobxrec`
- `sp_listxfec_report`
- `sp_ejecutores_list`
- `sp_ejecutores_get`
- ...y 297 más

### estacionamiento_publico
- SPs: 158
- Tablas: 8
- Archivos SQL: 242

**SPs** (primeros 15):
- `get_periodo_diario`
- `get_periodo_altas`
- `sp14_remesa`
- `buscar_folios_remesa`
- `generar_archivo_remesa`
- `sp_login`
- `sp_get_user_info`
- `sp_get_folios_report`
- `sp_register_folio`
- `sp_get_catalog`
- `sp_busca_folios_divadmin`
- `sp_aplica_pago_divadmin`
- `sp_get_incidencias_baja_multiple`
- `sp_insert_folios_baja_esta`
- `sp14_ejecuta_sp`
- ...y 143 más

### mercados
- SPs: 352
- Tablas: 52
- Archivos SQL: 624

**SPs** (primeros 15):
- `sp_get_categorias`
- `sp_get_secciones`
- `sp_get_cve_cuotas`
- `sp_get_mercados`
- `sp_consulta_general_buscar_local`
- `sp_consulta_general_detalle_local`
- `sp_consulta_general_adeudos_local`
- `sp_consulta_general_pagos_local`
- `sp_consulta_general_requerimientos_local`
- `sp_add_categoria`
- `sp_update_categoria`
- `sp_add_seccion`
- `sp_update_seccion`
- `sp_add_cve_cuota`
- `sp_update_cve_cuota`
- ...y 337 más

### multas_reglamentos
- SPs: 283
- Tablas: 2
- Archivos SQL: 473

**SPs** (primeros 15):
- `sp_get_cuenta_by_clave`
- `sp_get_usuarios`
- `sp_get_catalogo_descuentos`
- `sp_lista_ejecutores`
- `sp_insert_descuento_predial`
- `sp_cancelar_descuento_predial`
- `sp_descpred_get`
- `sp_descpred_create`
- `sp_descpred_update`
- `sp_descpred_delete`
- `sp_descpred_reactivate`
- `sp_eje_create`
- `sp_eje_update`
- `sp_eje_delete`
- `sp_asignar_requerimientos`
- ...y 268 más

### otras_obligaciones
- SPs: 159
- Tablas: 7
- Archivos SQL: 221

**SPs** (primeros 15):
- `sp_get_apremios`
- `sp_get_periodos_by_control`
- `sp34_tablas`
- `sp34_etiq`
- `sp34_vigencias`
- `sp_gadeudos_tablas`
- `sp_gadeudos_etiquetas`
- `sp_get_tabla_info`
- `sp_get_etiq`
- `sp_get_recaudadoras`
- `sp_get_operaciones`
- `sp_gconsulta2_get_etiquetas`
- `sp_gconsulta2_get_tablas`
- `sp_get_tablas`
- `sp_get_etiquetas`
- ...y 144 más

### padron_licencias
- SPs: 788
- Tablas: 18
- Archivos SQL: 774

**SPs** (primeros 15):
- `sp_get_dependencias`
- `fn_dialetra`
- `buscar_anuncio`
- `consultar_bloqueos`
- `get_tramite`
- `get_bloqueos`
- `get_giro_descripcion`
- `sp_get_bloqueos_rfc`
- `sp_search_bloqueos_rfc`
- `sp_get_tramite_info`
- `sp_buscagiro_list`
- `sp_buscagiro_permisos`
- `buscar_actividades`
- `buscar_actividad_por_id`
- `catalogo_scian_busqueda`
- ...y 773 más

---

## ❌ SPS FALTANTES (325)


### aseo_contratado (100 faltantes)

| SP | Usos | Componentes |
|----|----- |-------------|
| `sp_aseo_cves_operacion_list` | 2 | ABC_Cves_Operacion.vue, AdeudosMult_Ins.vue |
| `sp_aseo_cves_operacion_create` | 1 | ABC_Cves_Operacion.vue |
| `sp_aseo_cves_operacion_update` | 1 | ABC_Cves_Operacion.vue |
| `sp_aseo_cves_operacion_delete` | 1 | ABC_Cves_Operacion.vue |
| `sp_aseo_empresas_create` | 1 | ABC_Empresas.vue |
| `sp_aseo_empresas_update` | 1 | ABC_Empresas.vue |
| `sp_aseo_empresas_delete` | 1 | ABC_Empresas.vue |
| `sp_aseo_gastos_create` | 1 | ABC_Gastos.vue |
| `sp_aseo_gastos_update` | 1 | ABC_Gastos.vue |
| `sp_aseo_gastos_delete` | 1 | ABC_Gastos.vue |
| `sp_aseo_recargos_create` | 1 | ABC_Recargos.vue |
| `sp_aseo_recargos_update` | 1 | ABC_Recargos.vue |
| `sp_aseo_recargos_delete` | 1 | ABC_Recargos.vue |
| `sp_aseo_recaudadoras_list` | 3 | ABC_Recaudadoras.vue, Rep_Recaudadoras.vue +1 |
| `sp_aseo_tipos_list` | 6 | ABC_Tipos_Aseo.vue, ActCont_CR.vue +4 |
| `sp_aseo_tipos_create` | 1 | ABC_Tipos_Aseo.vue |
| `sp_aseo_tipos_update` | 1 | ABC_Tipos_Aseo.vue |
| `sp_aseo_tipos_delete` | 1 | ABC_Tipos_Aseo.vue |
| `sp_aseo_tipos_emp_list` | 1 | ABC_Tipos_Emp.vue |
| `sp_aseo_tipos_emp_create` | 1 | ABC_Tipos_Emp.vue |
| `sp_aseo_tipos_emp_update` | 1 | ABC_Tipos_Emp.vue |
| `sp_aseo_tipos_emp_delete` | 1 | ABC_Tipos_Emp.vue |
| `sp_aseo_unidades_list` | 10 | ABC_Und_Recolec.vue, ActCont_CR.vue +8 |
| `sp_aseo_unidades_create` | 1 | ABC_Und_Recolec.vue |
| `sp_aseo_unidades_update` | 1 | ABC_Und_Recolec.vue |
| `sp_aseo_unidades_delete` | 1 | ABC_Und_Recolec.vue |
| `sp_aseo_zonas_list` | 15 | ABC_Zonas.vue, Adeudos_Venc.vue +13 |
| `sp_aseo_zonas_create` | 1 | ABC_Zonas.vue |
| `sp_aseo_zonas_update` | 1 | ABC_Zonas.vue |
| `sp_aseo_zonas_delete` | 1 | ABC_Zonas.vue |
| ...y 70 más | | |

### cementerios (32 faltantes)

| SP | Usos | Componentes |
|----|----- |-------------|
| `sp_cem_abc_cementerios` | 4 | ABCementer.vue, ABCementer.vue +2 |
| `sp_cem_modificar_folio` | 2 | ABCFolio.vue, ABCFolio.vue |
| `sp_cem_baja_folio` | 2 | ABCFolio.vue, ABCFolio.vue |
| `sp_cem_buscar_folio_pagos` | 2 | ABCPagos.vue, ABCPagos.vue |
| `sp_cem_obtener_adeudos_pendientes` | 2 | ABCPagos.vue, ABCPagos.vue |
| `sp_cem_listar_pagos_folio` | 2 | ABCPagos.vue, ABCPagos.vue |
| `sp_cem_registrar_pago` | 4 | ABCPagos.vue, ABCPagos.vue +2 |
| `sp_cem_abc_pagos_por_folio` | 3 | ABCPagosxfol.vue, ABCPagosxfol.vue +1 |
| `sp_validar_usuario` | 1 | Acceso.vue |
| `sp_registrar_acceso` | 1 | Acceso.vue |
| `sp_cem_bonificaciones_oficio` | 2 | Bonificacion1.vue, Bonificacion1.vue |
| `sp_cem_buscar_bonificacion` | 2 | Bonificaciones.vue, Bonificaciones.vue |
| `sp_cem_registrar_bonificacion` | 2 | Bonificaciones.vue, Bonificaciones.vue |
| `sp_cem_eliminar_bonificacion` | 2 | Bonificaciones.vue, Bonificaciones.vue |
| `sp_cem_obtener_pagos_folio` | 2 | ConsultaFol.vue, ConsultaFol.vue |
| `sp_cem_obtener_adeudos_folio` | 2 | ConsultaFol.vue, ConsultaFol.vue |
| `sp_cem_consultar_por_nombre` | 1 | ConsultaNombre.vue |
| `sp_cem_buscar_duplicados` | 1 | Duplicados.vue |
| `sp_cem_verificar_ubicacion_duplicado` | 1 | Duplicados.vue |
| `sp_cem_trasladar_duplicado` | 1 | Duplicados.vue |
| `sp_cem_estadisticas_adeudos` | 1 | Estad_adeudo.vue |
| `sp_cem_calcular_liquidacion` | 2 | Liquidaciones.vue, Liquidaciones.vue |
| `sp_cem_consultar_pagos_por_fecha` | 1 | Multiplefecha.vue |
| `sp_cem_consultar_folios_por_ubicacion` | 2 | MultipleRCM.vue, MultipleRCM.vue |
| `sp_validar_password_actual` | 1 | sfrm_chgpass.vue |
| `sp_cambiar_password` | 1 | sfrm_chgpass.vue |
| `sp_cem_listar_titulos` | 2 | Titulos.vue, Titulos.vue |
| `sp_cem_buscar_titulo` | 2 | Titulos.vue, Titulos.vue |
| `sp_cem_actualizar_titulo_extra` | 2 | Titulos.vue, Titulos.vue |
| `sp_cem_generar_titulo` | 1 | TitulosSin.vue |
| ...y 2 más | | |

### estacionamiento_exclusivo (1 faltantes)

| SP | Usos | Componentes |
|----|----- |-------------|
| `sp_chgpass_historial` | 1 | sfrm_chgpass.vue |

### estacionamiento_publico (3 faltantes)

| SP | Usos | Componentes |
|----|----- |-------------|
| `sp_sfrm_baja_pub` | 1 | BajasPublicos.vue |
| `spubreports` | 2 | PagosPublicos.vue, ReportesPublicos.vue |
| `spget_lic_detalles` | 1 | ReportesPublicos.vue |

### multas_reglamentos (111 faltantes)

| SP | Usos | Componentes |
|----|----- |-------------|
| `recaudadora_get_ejecutores` | 2 | ActualizaFechaEmpresas.vue, ActualizaFechaEmpresas.vue |
| `recaudadora_parse_file` | 2 | ActualizaFechaEmpresas.vue, ActualizaFechaEmpresas.vue |
| `recaudadora_actualiza_fechas` | 2 | ActualizaFechaEmpresas.vue, ActualizaFechaEmpresas.vue |
| `recaudadora_consulta_sdos_favor` | 2 | AplicaSdosFavor.vue, AplicaSdosFavor.vue |
| `recaudadora_aplica_sdos_favor` | 2 | AplicaSdosFavor.vue, AplicaSdosFavor.vue |
| `recaudadora_autdescto` | 2 | autdescto.vue, autdescto.vue |
| `recaudadora_bloqctasreqfrm` | 2 | bloqctasreqfrm.vue, bloqctasreqfrm.vue |
| `recaudadora_bloqueo_multa` | 2 | BloqueoMulta.vue, BloqueoMulta.vue |
| `recaudadora_busque` | 2 | busque.vue, busque.vue |
| `recaudadora_canc` | 2 | canc.vue, canc.vue |
| `recaudadora_captura_dif` | 2 | CapturaDif.vue, CapturaDif.vue |
| `recaudadora_carta_invitacion` | 2 | CartaInvitacion.vue, CartaInvitacion.vue |
| `recaudadora_catastro_dm` | 2 | CatastroDM.vue, CatastroDM.vue |
| `recaudadora_centrosfrm` | 2 | centrosfrm.vue, centrosfrm.vue |
| `recaudadora_codificafrm` | 2 | codificafrm.vue, codificafrm.vue |
| `recaudadora_conscentrosfrm` | 2 | conscentrosfrm.vue, conscentrosfrm.vue |
| `recaudadora_consdesc` | 2 | consdesc.vue, consdesc.vue |
| `recaudadora_consescrit400` | 1 | consescrit400.vue |
| `recaudadora_consmulpagos` | 1 | consmulpagos.vue |
| `recaudadora_consobsmulfrm` | 1 | consobsmulfrm.vue |
| `recaudadora_consreq400` | 1 | ConsReq400.vue |
| `recaudadora_consultapredial` | 1 | consultapredial.vue |
| `recaudadora_dderechoslic` | 1 | dderechosLic.vue |
| `recaudadora_descderechos_merc` | 2 | DescDerechosMerc.vue, DescDerechosMerc.vue |
| `recaudadora_descmultampalfrm` | 1 | descmultampalfrm.vue |
| `recaudadora_descpredfrm` | 1 | descpredfrm.vue |
| `recaudadora_desctorec` | 1 | desctorec.vue |
| `recaudadora_drecgo_fosa` | 2 | DrecgoFosa.vue, DrecgoFosa.vue |
| `recaudadora_drecgolic` | 1 | drecgoLic.vue |
| `recaudadora_drecgootrasobligaciones` | 1 | drecgoOtrasObligaciones.vue |
| ...y 81 más | | |

### otras_obligaciones (29 faltantes)

| SP | Usos | Componentes |
|----|----- |-------------|
| `sp_gactualiza_dependencias_get` | 1 | GActualiza.vue |
| `sp_gactualiza_datos_get` | 1 | GActualiza.vue |
| `sp_gactualiza_multas_get` | 1 | GActualiza.vue |
| `sp_gactualiza_suspension_get` | 1 | GActualiza.vue |
| `sp_gactualiza_multas_update` | 2 | GActualiza.vue, GActualiza.vue |
| `sp_gactualiza_suspension_create` | 2 | GActualiza.vue, GActualiza.vue |
| `sp_gadeudos_datos_get` | 1 | GAdeudos.vue |
| `sp_gadeudos_detalle_01` | 1 | GAdeudos.vue |
| `sp_gadeudos_detalle_02` | 1 | GAdeudos.vue |
| `sp_gadeudosgral_tablas_get` | 1 | GAdeudosGral.vue |
| `sp_gadeudosgral_etiquetas_get` | 1 | GAdeudosGral.vue |
| `spcon34_gcont_01` | 1 | GAdeudosGral.vue |
| `sp_gadeudos_opc_mult_recaudadoras_get` | 1 | GAdeudos_OpcMult.vue |
| `sp_gadeudos_opcmult_ra_tablas_get` | 1 | GAdeudos_OpcMult_RA.vue |
| `sp_gadeudos_opcmult_ra_etiquetas_get` | 1 | GAdeudos_OpcMult_RA.vue |
| `sp_gadeudos_opcmult_ra_datos_get` | 1 | GAdeudos_OpcMult_RA.vue |
| `sp_gadeudos_opcmult_ra_reactivar` | 1 | GAdeudos_OpcMult_RA.vue |
| `sp_gbaja_datos_get` | 1 | GBaja.vue |
| `sp_gbaja_adeudos_detalle` | 1 | GBaja.vue |
| `sp_gbaja_adeudos_totales` | 1 | GBaja.vue |
| `sp_gbaja_pagos_get` | 1 | GBaja.vue |
| `sp_gbaja_aplicar` | 1 | GBaja.vue |
| `sp_gconsulta_datos_get` | 1 | GConsulta.vue |
| `sp_gconsulta_adeudos_get` | 1 | GConsulta.vue |
| `sp_gconsulta_pagados_get` | 1 | GConsulta.vue |
| `sp_gfacturacion_datos_get` | 1 | GFacturacion.vue |
| `con34_1datos_03` | 1 | RAdeudos_OpcMult.vue |
| `sp_rfacturacion_obtener` | 1 | RFacturacion.vue |
| `sp_rubros_listar` | 2 | Rubros.vue, Rubros.vue |

### padron_licencias (49 faltantes)

| SP | Usos | Componentes |
|----|----- |-------------|
| `sp_bloquearanuncio_get_anuncio` | 1 | BloquearAnunciorm.vue |
| `sp_bloquearanuncio_get_bloqueos` | 1 | BloquearAnunciorm.vue |
| `sp_bloquearanuncio_bloquear` | 1 | BloquearAnunciorm.vue |
| `sp_bloquearanuncio_desbloquear` | 1 | BloquearAnunciorm.vue |
| `sp_bloquearlicencia_get_licencia` | 1 | BloquearLicenciafrm.vue |
| `sp_bloquearlicencia_get_bloqueos` | 1 | BloquearLicenciafrm.vue |
| `sp_bloquearlicencia_bloquear` | 1 | BloquearLicenciafrm.vue |
| `sp_bloquearlicencia_desbloquear` | 1 | BloquearLicenciafrm.vue |
| `sp_bloqueartramite_get_tramite` | 1 | BloquearTramitefrm.vue |
| `sp_bloqueartramite_get_bloqueos` | 1 | BloquearTramitefrm.vue |
| `sp_bloqueartramite_get_giro` | 1 | BloquearTramitefrm.vue |
| `sp_bloqueartramite_bloquear` | 1 | BloquearTramitefrm.vue |
| `sp_bloqueartramite_desbloquear` | 1 | BloquearTramitefrm.vue |
| `sp_bloqueodomicilios_update` | 1 | bloqueoDomiciliosfrm.vue |
| `sp_bloqueodomicilios_create` | 1 | bloqueoDomiciliosfrm.vue |
| `sp_bloqueodomicilios_cancel` | 1 | bloqueoDomiciliosfrm.vue |
| `sp_bloqueorfc_buscar_tramite` | 1 | bloqueoRFCfrm.vue |
| `sp_bloqueorfc_create` | 1 | bloqueoRFCfrm.vue |
| `sp_bloqueorfc_desbloquear` | 1 | bloqueoRFCfrm.vue |
| `certificaciones_list` | 1 | certificacionesfrm.vue |
| `certificaciones_estadisticas` | 1 | certificacionesfrm.vue |
| `certificaciones_get_next_folio` | 1 | certificacionesfrm.vue |
| `certificaciones_create` | 1 | certificacionesfrm.vue |
| `certificaciones_update` | 1 | certificacionesfrm.vue |
| `certificaciones_delete` | 1 | certificacionesfrm.vue |
| `constancias_list` | 1 | constanciafrm.vue |
| `constancias_estadisticas` | 1 | constanciafrm.vue |
| `constancias_get_next_folio` | 2 | constanciafrm.vue, constanciafrm.vue |
| `constancias_create` | 1 | constanciafrm.vue |
| `constancias_update` | 1 | constanciafrm.vue |
| ...y 19 más | | |

---

## 📈 ESTADÍSTICAS POR MÓDULO

| Módulo | SPs en Base | SPs Usados en Vue | Faltantes |
|--------|-------------|-------------------|-----------|
| aseo_contratado | 318 | 125 | 100 |
| cementerios | 105 | 42 | 32 |
| estacionamiento_exclusivo | 312 | 69 | 1 |
| estacionamiento_publico | 158 | 58 | 3 |
| mercados | 352 | 0 | 0 |
| multas_reglamentos | 283 | 111 | 111 |
| otras_obligaciones | 159 | 75 | 29 |
| padron_licencias | 788 | 350 | 49 |

---

**Generado por**: RefactorX Mapping System v1.0
