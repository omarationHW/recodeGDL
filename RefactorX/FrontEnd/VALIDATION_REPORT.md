# 🔍 VALIDACIÓN EXHAUSTIVA: SPs por Módulo

**Fecha**: 10/11/2025, 6:14:14 p.m.
**Propósito**: Validar ANTES de correcciones

---

## 📊 RESUMEN DE VALIDACIÓN

- **Total de SPs analizados**: 817
- **✅ Correctos** (nombre correcto): 491 (60.1%)
- **⚠️ Nombre incorrecto** (SP existe, nombre mal): 147 (18.0%)
- **🔄 Cross-module** (existe en otro módulo): 0 (0.0%)
- **❌ Faltantes reales**: 179 (21.9%)
- **🔗 Candidatos para comun**: 0

---

## 📋 VALIDACIÓN POR MÓDULO


### ⚠️ aseo_contratado

**Resumen**:
- SPs en Base: 318
- SPs usados en Vue: 125
- ✅ Correctos: 25
- ⚠️ Nombre incorrecto: 68
- 🔄 Cross-module: 0
- ❌ Faltantes: 32
- 📊 Salud: 20.0%

**⚠️ Correcciones de nombres necesarias** (68):

| Vue usa | Debería usar | Confianza | Usos |
|---------|--------------|-----------|------|
| `sp_aseo_cves_operacion_list` | `sp_aseo_claves_operacion_list` | 93% | 2 |
| `sp_aseo_cves_operacion_create` | `sp_aseo_clave_operacion_create` | 90% | 1 |
| `sp_aseo_cves_operacion_update` | `sp_cves_operacion_update` | 83% | 1 |
| `sp_aseo_cves_operacion_delete` | `sp_cves_operacion_delete` | 83% | 1 |
| `sp_aseo_empresas_create` | `sp_aseo_empresa_create` | 96% | 1 |
| `sp_aseo_empresas_update` | `sp_aseo_empresa_update` | 96% | 1 |
| `sp_aseo_empresas_delete` | `sp_empresas_delete` | 78% | 1 |
| `sp_aseo_gastos_create` | `sp_aseo_gasto_create` | 95% | 1 |
| `sp_aseo_gastos_update` | `sp_aseo_gasto_create` | 81% | 1 |
| `sp_aseo_gastos_delete` | `sp_aseo_gastos_list` | 76% | 1 |
| `sp_aseo_recargos_create` | `sp_aseo_recargo_create` | 96% | 1 |
| `sp_aseo_recargos_update` | `sp_aseo_recargo_create` | 83% | 1 |
| `sp_aseo_recargos_delete` | `sp_recargos_delete` | 78% | 1 |
| `sp_aseo_recaudadoras_list` | `sp_aseo_recaudadoras_create` | 81% | 3 |
| `sp_aseo_tipos_list` | `sp_aseo_gastos_list` | 79% | 6 |
| `sp_aseo_tipos_create` | `sp_aseo_empresa_create` | 77% | 1 |
| `sp_aseo_tipos_update` | `sp_aseo_empresa_update` | 77% | 1 |
| `sp_aseo_tipos_emp_list` | `sp_aseo_tipos_empresa_list` | 85% | 1 |
| `sp_aseo_tipos_emp_create` | `sp_tipos_emp_create` | 79% | 1 |
| `sp_aseo_tipos_emp_update` | `sp_tipos_emp_update` | 79% | 1 |
| ...y 48 más | | | |

**❌ SPs faltantes reales** (32):

| SP | Usos | Componentes |
|----|------|-------------|
| `sp_aseo_tipos_delete` | 1 | ABC_Tipos_Aseo.vue |
| `sp_aseo_adeudos_carga_masiva` | 2 | Adeudos.vue, Adeudos_Carga.vue |
| `sp_aseo_adeudos_generar_recargos` | 1 | Adeudos_Carga.vue |
| `sp_aseo_adeudos_registrar_pago` | 1 | Adeudos_Pag.vue |
| `sp_aseo_pago_multiple` | 1 | Adeudos_PagMult.vue |
| `sp_aseo_pagos_actualizar_periodos` | 1 | Adeudos_PagUpdPer.vue |
| `sp_aseo_pagos_historial_actualizaciones` | 1 | Adeudos_PagUpdPer.vue |
| `sp_aseo_aplicar_exencion` | 1 | Adeudos_UpdExed.vue |
| `sp_aseo_detalle_contrato` | 1 | Cons_Cont.vue |
| `sp_aseo_consulta_ordenada` | 1 | Cons_ContAsc.vue |
| `sp_aseo_contratos_consulta_admin` | 1 | Contratos_Cons_Admin.vue |
| `sp_aseo_contratos_para_upd_periodo` | 1 | Contratos_Upd_Periodo.vue |
| `sp_aseo_actualizar_periodos_contratos` | 1 | Contratos_Upd_Periodo.vue |
| `sp_aseo_estadisticas_sincronizacion` | 1 | Ctrol_Imp_Cat.vue |
| `sp_aseo_convenio_crear` | 1 | DatosConvenio.vue |
| ...y 17 más | | |

### ❌ cementerios

**Resumen**:
- SPs en Base: 105
- SPs usados en Vue: 42
- ✅ Correctos: 10
- ⚠️ Nombre incorrecto: 15
- 🔄 Cross-module: 0
- ❌ Faltantes: 17
- 📊 Salud: 23.8%

**⚠️ Correcciones de nombres necesarias** (15):

| Vue usa | Debería usar | Confianza | Usos |
|---------|--------------|-----------|------|
| `sp_cem_abc_cementerios` | `sp_cem_listar_cementerios` | 76% | 4 |
| `sp_cem_modificar_folio` | `sp_cem_consultar_folio` | 73% | 2 |
| `sp_cem_baja_folio` | `sp_cem_buscar_folio` | 79% | 2 |
| `sp_cem_buscar_folio_pagos` | `sp_cem_buscar_folio` | 76% | 2 |
| `sp_cem_listar_pagos_folio` | `sp_cem_consultar_pagos_folio` | 82% | 2 |
| `sp_validar_usuario` | `sp_valida_usuario` | 94% | 1 |
| `sp_cem_registrar_bonificacion` | `sp_cem_reporte_bonificaciones` | 72% | 2 |
| `sp_cem_obtener_pagos_folio` | `sp_cem_consultar_pagos_folio` | 75% | 2 |
| `sp_cem_consultar_por_nombre` | `sp_cem_consultar_folios_por_nombre` | 79% | 1 |
| `sp_cem_buscar_duplicados` | `sp_cem_buscar_folio` | 71% | 1 |
| `sp_cem_consultar_pagos_por_fecha` | `sp_cem_consultar_pagos_folio` | 75% | 1 |
| `sp_cem_consultar_folios_por_ubicacion` | `sp_cem_consultar_folios_por_nombre` | 76% | 2 |
| `sp_cem_buscar_titulo` | `sp_cem_buscar_folio` | 75% | 2 |
| `sp_cem_generar_titulo` | `sp_cem_reporte_titulos` | 73% | 1 |
| `sp_cem_trasladar_folio` | `sp_cem_consultar_folio` | 73% | 1 |

**❌ SPs faltantes reales** (17):

| SP | Usos | Componentes |
|----|------|-------------|
| `sp_cem_obtener_adeudos_pendientes` | 2 | ABCPagos.vue, ABCPagos.vue |
| `sp_cem_registrar_pago` | 4 | ABCPagos.vue, ABCPagos.vue +2 |
| `sp_cem_abc_pagos_por_folio` | 3 | ABCPagosxfol.vue, ABCPagosxfol.vue +1 |
| `sp_registrar_acceso` | 1 | Acceso.vue |
| `sp_cem_bonificaciones_oficio` | 2 | Bonificacion1.vue, Bonificacion1.vue |
| `sp_cem_buscar_bonificacion` | 2 | Bonificaciones.vue, Bonificaciones.vue |
| `sp_cem_eliminar_bonificacion` | 2 | Bonificaciones.vue, Bonificaciones.vue |
| `sp_cem_obtener_adeudos_folio` | 2 | ConsultaFol.vue, ConsultaFol.vue |
| `sp_cem_verificar_ubicacion_duplicado` | 1 | Duplicados.vue |
| `sp_cem_trasladar_duplicado` | 1 | Duplicados.vue |
| `sp_cem_estadisticas_adeudos` | 1 | Estad_adeudo.vue |
| `sp_cem_calcular_liquidacion` | 2 | Liquidaciones.vue, Liquidaciones.vue |
| `sp_validar_password_actual` | 1 | sfrm_chgpass.vue |
| `sp_cambiar_password` | 1 | sfrm_chgpass.vue |
| `sp_cem_listar_titulos` | 2 | Titulos.vue, Titulos.vue |
| ...y 2 más | | |

### ✅ estacionamiento_exclusivo

**Resumen**:
- SPs en Base: 312
- SPs usados en Vue: 69
- ✅ Correctos: 68
- ⚠️ Nombre incorrecto: 0
- 🔄 Cross-module: 0
- ❌ Faltantes: 1
- 📊 Salud: 98.6%

**❌ SPs faltantes reales** (1):

| SP | Usos | Componentes |
|----|------|-------------|
| `sp_chgpass_historial` | 1 | sfrm_chgpass.vue |

### ✅ estacionamiento_publico

**Resumen**:
- SPs en Base: 158
- SPs usados en Vue: 58
- ✅ Correctos: 54
- ⚠️ Nombre incorrecto: 1
- 🔄 Cross-module: 0
- ❌ Faltantes: 3
- 📊 Salud: 93.1%

**⚠️ Correcciones de nombres necesarias** (1):

| Vue usa | Debería usar | Confianza | Usos |
|---------|--------------|-----------|------|
| `spubreports` | `spubreports_list` | 69% | 2 |

**❌ SPs faltantes reales** (3):

| SP | Usos | Componentes |
|----|------|-------------|
| `sp_sfrm_baja_pub` | 1 | BajasPublicos.vue |
| `spget_lic_grales` | 1 | ConsultaPublicos.vue |
| `spget_lic_detalles` | 1 | ReportesPublicos.vue |

### ✅ mercados

**Resumen**:
- SPs en Base: 352
- SPs usados en Vue: 0
- ✅ Correctos: 0
- ⚠️ Nombre incorrecto: 0
- 🔄 Cross-module: 0
- ❌ Faltantes: 0
- 📊 Salud: NaN%

### ❌ multas_reglamentos

**Resumen**:
- SPs en Base: 283
- SPs usados en Vue: 111
- ✅ Correctos: 0
- ⚠️ Nombre incorrecto: 22
- 🔄 Cross-module: 0
- ❌ Faltantes: 89
- 📊 Salud: 0.0%

**⚠️ Correcciones de nombres necesarias** (22):

| Vue usa | Debería usar | Confianza | Usos |
|---------|--------------|-----------|------|
| `recaudadora_get_ejecutores` | `sp_get_ejecutores` | 58% | 2 |
| `recaudadora_aplica_sdos_favor` | `sp_recaudadora_aplicar_saldo_favor` | 79% | 2 |
| `recaudadora_autdescto` | `sp_autdescto_list` | 24% | 2 |
| `recaudadora_bloqueo_multa` | `sp_recaudadora_bloquear_cuenta` | 73% | 2 |
| `recaudadora_canc` | `sp_cancelar_descuento_predial` | 21% | 2 |
| `recaudadora_consdesc` | `sp_consdesc_list` | 20% | 2 |
| `recaudadora_consescrit400` | `sp_consescrit400_search_by_folio_fecha` | 16% | 1 |
| `recaudadora_consreq400` | `sp_get_consreq400` | 50% | 1 |
| `recaudadora_ejecutores` | `sp_lista_ejecutores` | 55% | 2 |
| `recaudadora_empresas` | `sp_empresas_folios` | 10% | 2 |
| `recaudadora_impresionnva` | `sp_impresionnva_get_form_data` | 14% | 1 |
| `recaudadora_lista_diferencias` | `sp_lista_diferencias` | 62% | 2 |
| `recaudadora_pagosmultfrm` | `pagosmultfrm_search_pagos_multas` | 34% | 1 |
| `recaudadora_polcon` | `report_polcon` | 61% | 1 |
| `recaudadora_pres` | `sp_marcar_impresos` | 28% | 1 |
| `recaudadora_reg` | `sp_descmultampal_agregar` | 33% | 1 |
| `recaudadora_repavance` | `repavance_generate_report` | 24% | 1 |
| `recaudadora_rep_desc_impto` | `sp_rep_desc_impto_aplicados` | 22% | 2 |
| `recaudadora_req` | `sp_asignar_requerimientos` | 20% | 2 |
| `recaudadora_reqctascanfrm` | `report_reqctascanfrm` | 72% | 1 |
| ...y 2 más | | | |

**❌ SPs faltantes reales** (89):

| SP | Usos | Componentes |
|----|------|-------------|
| `recaudadora_parse_file` | 2 | ActualizaFechaEmpresas.vue, ActualizaFechaEmpresas.vue |
| `recaudadora_actualiza_fechas` | 2 | ActualizaFechaEmpresas.vue, ActualizaFechaEmpresas.vue |
| `recaudadora_consulta_sdos_favor` | 2 | AplicaSdosFavor.vue, AplicaSdosFavor.vue |
| `recaudadora_bloqctasreqfrm` | 2 | bloqctasreqfrm.vue, bloqctasreqfrm.vue |
| `recaudadora_busque` | 2 | busque.vue, busque.vue |
| `recaudadora_captura_dif` | 2 | CapturaDif.vue, CapturaDif.vue |
| `recaudadora_carta_invitacion` | 2 | CartaInvitacion.vue, CartaInvitacion.vue |
| `recaudadora_catastro_dm` | 2 | CatastroDM.vue, CatastroDM.vue |
| `recaudadora_centrosfrm` | 2 | centrosfrm.vue, centrosfrm.vue |
| `recaudadora_codificafrm` | 2 | codificafrm.vue, codificafrm.vue |
| `recaudadora_conscentrosfrm` | 2 | conscentrosfrm.vue, conscentrosfrm.vue |
| `recaudadora_consmulpagos` | 1 | consmulpagos.vue |
| `recaudadora_consobsmulfrm` | 1 | consobsmulfrm.vue |
| `recaudadora_consultapredial` | 1 | consultapredial.vue |
| `recaudadora_dderechoslic` | 1 | dderechosLic.vue |
| ...y 74 más | | |

### ⚠️ otras_obligaciones

**Resumen**:
- SPs en Base: 159
- SPs usados en Vue: 74
- ✅ Correctos: 45
- ⚠️ Nombre incorrecto: 8
- 🔄 Cross-module: 0
- ❌ Faltantes: 21
- 📊 Salud: 60.8%

**⚠️ Correcciones de nombres necesarias** (8):

| Vue usa | Debería usar | Confianza | Usos |
|---------|--------------|-----------|------|
| `sp_gadeudos_datos_get` | `sp_gadeudos_detalle` | 71% | 1 |
| `sp_gadeudos_detalle_01` | `sp_gadeudos_detalle` | 86% | 1 |
| `sp_gadeudos_detalle_02` | `sp_gadeudos_detalle` | 86% | 1 |
| `sp_gadeudosgral_etiquetas_get` | `sp_gadeudos_etiquetas` | 72% | 1 |
| `spcon34_gcont_01` | `con34_gcont_01` | 88% | 1 |
| `sp_gbaja_adeudos_detalle` | `sp_get_adeudos_detalle` | 83% | 1 |
| `sp_gbaja_adeudos_totales` | `sp_get_adeudos_totales` | 83% | 1 |
| `con34_1datos_03` | `cob34_gdatosg_02` | 75% | 1 |

**❌ SPs faltantes reales** (21):

| SP | Usos | Componentes |
|----|------|-------------|
| `sp_gactualiza_dependencias_get` | 1 | GActualiza.vue |
| `sp_gactualiza_datos_get` | 1 | GActualiza.vue |
| `sp_gactualiza_multas_get` | 1 | GActualiza.vue |
| `sp_gactualiza_suspension_get` | 1 | GActualiza.vue |
| `sp_gactualiza_multas_update` | 2 | GActualiza.vue, GActualiza.vue |
| `sp_gactualiza_suspension_create` | 2 | GActualiza.vue, GActualiza.vue |
| `sp_gadeudosgral_tablas_get` | 1 | GAdeudosGral.vue |
| `sp_gadeudos_opc_mult_recaudadoras_get` | 1 | GAdeudos_OpcMult.vue |
| `sp_gadeudos_opcmult_ra_tablas_get` | 1 | GAdeudos_OpcMult_RA.vue |
| `sp_gadeudos_opcmult_ra_etiquetas_get` | 1 | GAdeudos_OpcMult_RA.vue |
| `sp_gadeudos_opcmult_ra_datos_get` | 1 | GAdeudos_OpcMult_RA.vue |
| `sp_gadeudos_opcmult_ra_reactivar` | 1 | GAdeudos_OpcMult_RA.vue |
| `sp_gbaja_datos_get` | 1 | GBaja.vue |
| `sp_gbaja_pagos_get` | 1 | GBaja.vue |
| `sp_gbaja_aplicar` | 1 | GBaja.vue |
| ...y 6 más | | |

### ✅ padron_licencias

**Resumen**:
- SPs en Base: 788
- SPs usados en Vue: 338
- ✅ Correctos: 289
- ⚠️ Nombre incorrecto: 33
- 🔄 Cross-module: 0
- ❌ Faltantes: 16
- 📊 Salud: 85.5%

**⚠️ Correcciones de nombres necesarias** (33):

| Vue usa | Debería usar | Confianza | Usos |
|---------|--------------|-----------|------|
| `sp_bloquearanuncio_bloquear` | `sp_bloquearanuncio_list` | 74% | 1 |
| `sp_bloqueartramite_get_bloqueos` | `sp_bloqueartramite_block` | 71% | 1 |
| `sp_bloqueartramite_get_giro` | `sp_bloqueartramite_block` | 70% | 1 |
| `sp_bloqueartramite_bloquear` | `sp_bloqueartramite_block` | 81% | 1 |
| `sp_bloqueartramite_desbloquear` | `sp_bloqueartramite_block` | 73% | 1 |
| `sp_bloqueodomicilios_update` | `sp_bloqueodomicilios_list` | 81% | 1 |
| `sp_bloqueodomicilios_create` | `sp_bloqueodomicilios_list` | 81% | 1 |
| `sp_bloqueodomicilios_cancel` | `sp_bloqueodomicilios_list` | 78% | 1 |
| `sp_bloqueorfc_create` | `sp_bloquearlic_create` | 86% | 1 |
| `certificaciones_list` | `sp_certificaciones_list` | 87% | 1 |
| `certificaciones_create` | `sp_certificaciones_create` | 88% | 1 |
| `certificaciones_update` | `sp_certificaciones_update` | 88% | 1 |
| `certificaciones_delete` | `sp_certificaciones_create` | 72% | 1 |
| `constancias_list` | `sp_constancia_list` | 78% | 1 |
| `constancias_estadisticas` | `sp_constancia_estadisticas` | 85% | 1 |
| `constancias_create` | `sp_constancia_create` | 80% | 1 |
| `constancias_update` | `sp_constancia_update` | 80% | 1 |
| `sp_solicnooficial_list` | `sp_solicnooficial_print` | 87% | 1 |
| `consulta_anuncios_list` | `sp_consultaanuncio_list` | 78% | 1 |
| `consulta_licencias_list` | `sp_consultalicencia_list` | 79% | 2 |
| ...y 13 más | | | |

**❌ SPs faltantes reales** (16):

| SP | Usos | Componentes |
|----|------|-------------|
| `sp_bloquearanuncio_get_anuncio` | 1 | BloquearAnunciorm.vue |
| `sp_bloquearanuncio_get_bloqueos` | 1 | BloquearAnunciorm.vue |
| `sp_bloquearanuncio_desbloquear` | 1 | BloquearAnunciorm.vue |
| `sp_bloquearlicencia_get_licencia` | 1 | BloquearLicenciafrm.vue |
| `sp_bloquearlicencia_get_bloqueos` | 1 | BloquearLicenciafrm.vue |
| `sp_bloquearlicencia_bloquear` | 1 | BloquearLicenciafrm.vue |
| `sp_bloquearlicencia_desbloquear` | 1 | BloquearLicenciafrm.vue |
| `sp_bloqueartramite_get_tramite` | 1 | BloquearTramitefrm.vue |
| `sp_bloqueorfc_buscar_tramite` | 1 | bloqueoRFCfrm.vue |
| `sp_bloqueorfc_desbloquear` | 1 | bloqueoRFCfrm.vue |
| `certificaciones_estadisticas` | 1 | certificacionesfrm.vue |
| `certificaciones_get_next_folio` | 1 | certificacionesfrm.vue |
| `constancias_get_next_folio` | 2 | constanciafrm.vue, constanciafrm.vue |
| `constancias_delete` | 1 | constanciafrm.vue |
| `licenciasvigentesfrm_sp_stats` | 1 | LicenciasVigentesfrm.vue |
| ...y 1 más | | |

---

## 🔧 CORRECCIONES PROPUESTAS

Total de correcciones propuestas: 147


### aseo_contratado (68 correcciones)

| # | Vue usa | Cambiar a | Confianza | Evidencia |
|---|---------|-----------|-----------|------------|
| 1 | `sp_aseo_cves_operacion_list` | `sp_aseo_claves_operacion_list` | 93% | Existe en Base como: sp_aseo_claves_operacion_list |
| 2 | `sp_aseo_cves_operacion_create` | `sp_aseo_clave_operacion_create` | 90% | Existe en Base como: sp_aseo_clave_operacion_create |
| 3 | `sp_aseo_cves_operacion_update` | `sp_cves_operacion_update` | 83% | Existe en Base como: sp_cves_operacion_update |
| 4 | `sp_aseo_cves_operacion_delete` | `sp_cves_operacion_delete` | 83% | Existe en Base como: sp_cves_operacion_delete |
| 5 | `sp_aseo_empresas_create` | `sp_aseo_empresa_create` | 96% | Existe en Base como: sp_aseo_empresa_create |
| 6 | `sp_aseo_empresas_update` | `sp_aseo_empresa_update` | 96% | Existe en Base como: sp_aseo_empresa_update |
| 7 | `sp_aseo_empresas_delete` | `sp_empresas_delete` | 78% | Existe en Base como: sp_empresas_delete |
| 8 | `sp_aseo_gastos_create` | `sp_aseo_gasto_create` | 95% | Existe en Base como: sp_aseo_gasto_create |
| 9 | `sp_aseo_gastos_update` | `sp_aseo_gasto_create` | 81% | Existe en Base como: sp_aseo_gasto_create |
| 10 | `sp_aseo_gastos_delete` | `sp_aseo_gastos_list` | 76% | Existe en Base como: sp_aseo_gastos_list |
| 11 | `sp_aseo_recargos_create` | `sp_aseo_recargo_create` | 96% | Existe en Base como: sp_aseo_recargo_create |
| 12 | `sp_aseo_recargos_update` | `sp_aseo_recargo_create` | 83% | Existe en Base como: sp_aseo_recargo_create |
| 13 | `sp_aseo_recargos_delete` | `sp_recargos_delete` | 78% | Existe en Base como: sp_recargos_delete |
| 14 | `sp_aseo_recaudadoras_list` | `sp_aseo_recaudadoras_create` | 81% | Existe en Base como: sp_aseo_recaudadoras_create |
| 15 | `sp_aseo_tipos_list` | `sp_aseo_gastos_list` | 79% | Existe en Base como: sp_aseo_gastos_list |
| 16 | `sp_aseo_tipos_create` | `sp_aseo_empresa_create` | 77% | Existe en Base como: sp_aseo_empresa_create |
| 17 | `sp_aseo_tipos_update` | `sp_aseo_empresa_update` | 77% | Existe en Base como: sp_aseo_empresa_update |
| 18 | `sp_aseo_tipos_emp_list` | `sp_aseo_tipos_empresa_list` | 85% | Existe en Base como: sp_aseo_tipos_empresa_list |
| 19 | `sp_aseo_tipos_emp_create` | `sp_tipos_emp_create` | 79% | Existe en Base como: sp_tipos_emp_create |
| 20 | `sp_aseo_tipos_emp_update` | `sp_tipos_emp_update` | 79% | Existe en Base como: sp_tipos_emp_update |
| 21 | `sp_aseo_tipos_emp_delete` | `sp_tipos_emp_delete` | 79% | Existe en Base como: sp_tipos_emp_delete |
| 22 | `sp_aseo_unidades_list` | `sp_cat_unidades_list` | 81% | Existe en Base como: sp_cat_unidades_list |
| 23 | `sp_aseo_unidades_create` | `sp_cat_unidades_create` | 83% | Existe en Base como: sp_cat_unidades_create |
| 24 | `sp_aseo_unidades_update` | `sp_cat_unidades_update` | 83% | Existe en Base como: sp_cat_unidades_update |
| 25 | `sp_aseo_unidades_delete` | `sp_cat_unidades_delete` | 83% | Existe en Base como: sp_cat_unidades_delete |
| 26 | `sp_aseo_zonas_list` | `sp_aseo_abc_zonas_list` | 82% | Existe en Base como: sp_aseo_abc_zonas_list |
| 27 | `sp_aseo_zonas_create` | `sp_aseo_abc_zonas_create` | 83% | Existe en Base como: sp_aseo_abc_zonas_create |
| 28 | `sp_aseo_zonas_update` | `sp_zonas_update` | 75% | Existe en Base como: sp_zonas_update |
| 29 | `sp_aseo_zonas_delete` | `sp_zonas_delete` | 75% | Existe en Base como: sp_zonas_delete |
| 30 | `sp_aseo_adeudos_buscar_contrato` | `sp_aseo_adeudos_resumen_contrato` | 81% | Existe en Base como: sp_aseo_adeudos_resumen_contrato |
| ... | ...y 38 más | | | |

### cementerios (15 correcciones)

| # | Vue usa | Cambiar a | Confianza | Evidencia |
|---|---------|-----------|-----------|------------|
| 1 | `sp_cem_abc_cementerios` | `sp_cem_listar_cementerios` | 76% | Existe en Base como: sp_cem_listar_cementerios |
| 2 | `sp_cem_modificar_folio` | `sp_cem_consultar_folio` | 73% | Existe en Base como: sp_cem_consultar_folio |
| 3 | `sp_cem_baja_folio` | `sp_cem_buscar_folio` | 79% | Existe en Base como: sp_cem_buscar_folio |
| 4 | `sp_cem_buscar_folio_pagos` | `sp_cem_buscar_folio` | 76% | Existe en Base como: sp_cem_buscar_folio |
| 5 | `sp_cem_listar_pagos_folio` | `sp_cem_consultar_pagos_folio` | 82% | Existe en Base como: sp_cem_consultar_pagos_folio |
| 6 | `sp_validar_usuario` | `sp_valida_usuario` | 94% | Existe en Base como: sp_valida_usuario |
| 7 | `sp_cem_registrar_bonificacion` | `sp_cem_reporte_bonificaciones` | 72% | Existe en Base como: sp_cem_reporte_bonificaciones |
| 8 | `sp_cem_obtener_pagos_folio` | `sp_cem_consultar_pagos_folio` | 75% | Existe en Base como: sp_cem_consultar_pagos_folio |
| 9 | `sp_cem_consultar_por_nombre` | `sp_cem_consultar_folios_por_nombre` | 79% | Existe en Base como: sp_cem_consultar_folios_por_nombre |
| 10 | `sp_cem_buscar_duplicados` | `sp_cem_buscar_folio` | 71% | Existe en Base como: sp_cem_buscar_folio |
| 11 | `sp_cem_consultar_pagos_por_fecha` | `sp_cem_consultar_pagos_folio` | 75% | Existe en Base como: sp_cem_consultar_pagos_folio |
| 12 | `sp_cem_consultar_folios_por_ubicacion` | `sp_cem_consultar_folios_por_nombre` | 76% | Existe en Base como: sp_cem_consultar_folios_por_nombre |
| 13 | `sp_cem_buscar_titulo` | `sp_cem_buscar_folio` | 75% | Existe en Base como: sp_cem_buscar_folio |
| 14 | `sp_cem_generar_titulo` | `sp_cem_reporte_titulos` | 73% | Existe en Base como: sp_cem_reporte_titulos |
| 15 | `sp_cem_trasladar_folio` | `sp_cem_consultar_folio` | 73% | Existe en Base como: sp_cem_consultar_folio |

### estacionamiento_publico (1 correcciones)

| # | Vue usa | Cambiar a | Confianza | Evidencia |
|---|---------|-----------|-----------|------------|
| 1 | `spubreports` | `spubreports_list` | 69% | Existe en Base como: spubreports_list |

### multas_reglamentos (22 correcciones)

| # | Vue usa | Cambiar a | Confianza | Evidencia |
|---|---------|-----------|-----------|------------|
| 1 | `recaudadora_get_ejecutores` | `sp_get_ejecutores` | 58% | Existe en Base como: sp_get_ejecutores |
| 2 | `recaudadora_aplica_sdos_favor` | `sp_recaudadora_aplicar_saldo_favor` | 79% | Existe en Base como: sp_recaudadora_aplicar_saldo_favor |
| 3 | `recaudadora_autdescto` | `sp_autdescto_list` | 24% | Existe en Base como: sp_autdescto_list |
| 4 | `recaudadora_bloqueo_multa` | `sp_recaudadora_bloquear_cuenta` | 73% | Existe en Base como: sp_recaudadora_bloquear_cuenta |
| 5 | `recaudadora_canc` | `sp_cancelar_descuento_predial` | 21% | Existe en Base como: sp_cancelar_descuento_predial |
| 6 | `recaudadora_consdesc` | `sp_consdesc_list` | 20% | Existe en Base como: sp_consdesc_list |
| 7 | `recaudadora_consescrit400` | `sp_consescrit400_search_by_folio_fecha` | 16% | Existe en Base como: sp_consescrit400_search_by_folio_fecha |
| 8 | `recaudadora_consreq400` | `sp_get_consreq400` | 50% | Existe en Base como: sp_get_consreq400 |
| 9 | `recaudadora_ejecutores` | `sp_lista_ejecutores` | 55% | Existe en Base como: sp_lista_ejecutores |
| 10 | `recaudadora_empresas` | `sp_empresas_folios` | 10% | Existe en Base como: sp_empresas_folios |
| 11 | `recaudadora_impresionnva` | `sp_impresionnva_get_form_data` | 14% | Existe en Base como: sp_impresionnva_get_form_data |
| 12 | `recaudadora_lista_diferencias` | `sp_lista_diferencias` | 62% | Existe en Base como: sp_lista_diferencias |
| 13 | `recaudadora_pagosmultfrm` | `pagosmultfrm_search_pagos_multas` | 34% | Existe en Base como: pagosmultfrm_search_pagos_multas |
| 14 | `recaudadora_polcon` | `report_polcon` | 61% | Existe en Base como: report_polcon |
| 15 | `recaudadora_pres` | `sp_marcar_impresos` | 28% | Existe en Base como: sp_marcar_impresos |
| 16 | `recaudadora_reg` | `sp_descmultampal_agregar` | 33% | Existe en Base como: sp_descmultampal_agregar |
| 17 | `recaudadora_repavance` | `repavance_generate_report` | 24% | Existe en Base como: repavance_generate_report |
| 18 | `recaudadora_rep_desc_impto` | `sp_rep_desc_impto_aplicados` | 22% | Existe en Base como: sp_rep_desc_impto_aplicados |
| 19 | `recaudadora_req` | `sp_asignar_requerimientos` | 20% | Existe en Base como: sp_asignar_requerimientos |
| 20 | `recaudadora_reqctascanfrm` | `report_reqctascanfrm` | 72% | Existe en Base como: report_reqctascanfrm |
| 21 | `recaudadora_sdosfavor_pagos` | `sp_sdosfavor_pagos_create` | 33% | Existe en Base como: sp_sdosfavor_pagos_create |
| 22 | `recaudadora_ubicodifica` | `sp_get_ubicodifica_data` | 30% | Existe en Base como: sp_get_ubicodifica_data |

### otras_obligaciones (8 correcciones)

| # | Vue usa | Cambiar a | Confianza | Evidencia |
|---|---------|-----------|-----------|------------|
| 1 | `sp_gadeudos_datos_get` | `sp_gadeudos_detalle` | 71% | Existe en Base como: sp_gadeudos_detalle |
| 2 | `sp_gadeudos_detalle_01` | `sp_gadeudos_detalle` | 86% | Existe en Base como: sp_gadeudos_detalle |
| 3 | `sp_gadeudos_detalle_02` | `sp_gadeudos_detalle` | 86% | Existe en Base como: sp_gadeudos_detalle |
| 4 | `sp_gadeudosgral_etiquetas_get` | `sp_gadeudos_etiquetas` | 72% | Existe en Base como: sp_gadeudos_etiquetas |
| 5 | `spcon34_gcont_01` | `con34_gcont_01` | 88% | Existe en Base como: con34_gcont_01 |
| 6 | `sp_gbaja_adeudos_detalle` | `sp_get_adeudos_detalle` | 83% | Existe en Base como: sp_get_adeudos_detalle |
| 7 | `sp_gbaja_adeudos_totales` | `sp_get_adeudos_totales` | 83% | Existe en Base como: sp_get_adeudos_totales |
| 8 | `con34_1datos_03` | `cob34_gdatosg_02` | 75% | Existe en Base como: cob34_gdatosg_02 |

### padron_licencias (33 correcciones)

| # | Vue usa | Cambiar a | Confianza | Evidencia |
|---|---------|-----------|-----------|------------|
| 1 | `sp_bloquearanuncio_bloquear` | `sp_bloquearanuncio_list` | 74% | Existe en Base como: sp_bloquearanuncio_list |
| 2 | `sp_bloqueartramite_get_bloqueos` | `sp_bloqueartramite_block` | 71% | Existe en Base como: sp_bloqueartramite_block |
| 3 | `sp_bloqueartramite_get_giro` | `sp_bloqueartramite_block` | 70% | Existe en Base como: sp_bloqueartramite_block |
| 4 | `sp_bloqueartramite_bloquear` | `sp_bloqueartramite_block` | 81% | Existe en Base como: sp_bloqueartramite_block |
| 5 | `sp_bloqueartramite_desbloquear` | `sp_bloqueartramite_block` | 73% | Existe en Base como: sp_bloqueartramite_block |
| 6 | `sp_bloqueodomicilios_update` | `sp_bloqueodomicilios_list` | 81% | Existe en Base como: sp_bloqueodomicilios_list |
| 7 | `sp_bloqueodomicilios_create` | `sp_bloqueodomicilios_list` | 81% | Existe en Base como: sp_bloqueodomicilios_list |
| 8 | `sp_bloqueodomicilios_cancel` | `sp_bloqueodomicilios_list` | 78% | Existe en Base como: sp_bloqueodomicilios_list |
| 9 | `sp_bloqueorfc_create` | `sp_bloquearlic_create` | 86% | Existe en Base como: sp_bloquearlic_create |
| 10 | `certificaciones_list` | `sp_certificaciones_list` | 87% | Existe en Base como: sp_certificaciones_list |
| 11 | `certificaciones_create` | `sp_certificaciones_create` | 88% | Existe en Base como: sp_certificaciones_create |
| 12 | `certificaciones_update` | `sp_certificaciones_update` | 88% | Existe en Base como: sp_certificaciones_update |
| 13 | `certificaciones_delete` | `sp_certificaciones_create` | 72% | Existe en Base como: sp_certificaciones_create |
| 14 | `constancias_list` | `sp_constancia_list` | 78% | Existe en Base como: sp_constancia_list |
| 15 | `constancias_estadisticas` | `sp_constancia_estadisticas` | 85% | Existe en Base como: sp_constancia_estadisticas |
| 16 | `constancias_create` | `sp_constancia_create` | 80% | Existe en Base como: sp_constancia_create |
| 17 | `constancias_update` | `sp_constancia_update` | 80% | Existe en Base como: sp_constancia_update |
| 18 | `sp_solicnooficial_list` | `sp_solicnooficial_print` | 87% | Existe en Base como: sp_solicnooficial_print |
| 19 | `consulta_anuncios_list` | `sp_consultaanuncio_list` | 78% | Existe en Base como: sp_consultaanuncio_list |
| 20 | `consulta_licencias_list` | `sp_consultalicencia_list` | 79% | Existe en Base como: sp_consultalicencia_list |
| 21 | `consulta_tramites_list` | `sp_consultatramite_list` | 78% | Existe en Base como: sp_consultatramite_list |
| 22 | `sp_giros_dcon_adeudo` | `report_giros_dcon_adeudo` | 79% | Existe en Base como: report_giros_dcon_adeudo |
| 23 | `sp_report_giros_dcon_adeudo` | `report_giros_dcon_adeudo` | 89% | Existe en Base como: report_giros_dcon_adeudo |
| 24 | `h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom` | `h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom` | 91% | Existe en Base como: h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom |
| 25 | `h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle` | `h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom` | 72% | Existe en Base como: h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom |
| 26 | `h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel` | `h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom` | 76% | Existe en Base como: h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom |
| 27 | `h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report` | `h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom` | 75% | Existe en Base como: h_bloqueodomiciliosfrm_sp_list_h_bloqueo_dom |
| 28 | `sp_get_licencia_reglamentada` | `get_licencia_reglamentada_by_id` | 71% | Existe en Base como: get_licencia_reglamentada_by_id |
| 29 | `sp_check_licencia_bloqueada` | `checklicenciabloqueada` | 81% | Existe en Base como: checklicenciabloqueada |
| 30 | `sp_calcular_adeudo_licencia` | `sp_recalcula_saldo_licencia` | 74% | Existe en Base como: sp_recalcula_saldo_licencia |
| ... | ...y 3 más | | | |

---

## 🔗 SPs CANDIDATOS PARA padron_licencias.comun

No se detectaron SPs compartidos que deban moverse a comun.

---

## ✅ PRÓXIMO PASO

**VALIDACIÓN COMPLETA** ✅

**Correcciones verificadas**:
- 147 cambios de nombres (con evidencia del SP correcto)
- 179 SPs realmente faltantes (necesitan crearse)

**Seguro para aplicar correcciones**: SÍ

---

**Generado por**: RefactorX Validation System v1.0
