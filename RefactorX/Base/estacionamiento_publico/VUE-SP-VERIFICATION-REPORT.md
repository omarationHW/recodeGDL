# REPORTE DE VERIFICACIÓN VUE ↔ SP

**Fecha:** 2025-11-10T19:42:49.763Z

## Resumen Ejecutivo

- **Componentes Verificados:** 45
- **SPs Únicos:** 59
- **SPs OK:** 65
- **SPs con Problemas:** 2
- **Tasa de Éxito:** 110.17%

---

## Componentes Verificados


### ✅ AccesoPublicos.vue - OK

#### ✅ SP: `sp_pub_movtos`

- **Línea Vue:** 39
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opc integer, p_pubmain_id integer, p_fecha date, p_cajones integer, p_categoria integer, p_oficio character varying, p_usuario integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(resultado integer)


### ✅ ActualizacionPublicos.vue - OK

#### ✅ SP: `actualiza_pub_pago`

- **Línea Vue:** 65
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opc integer, p_pubmain_id integer, p_axo integer, p_mes integer, p_tipo integer, p_fecha date, p_reca integer, p_caja character varying, p_operacion integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, mensaje character varying)


### ✅ AplicaPagoDivAdminPublicos.vue - OK

#### ✅ SP: `sp_busca_folios_divadmin`

- **Línea Vue:** 78
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `opcion integer, placa character varying, folio integer, axo integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(ret_axo integer, ret_folio integer, ret_placa character varying, fecha_folio date, estado smallint, infraccion smallint, tarifa numeric, porc_cobro numeric, descripcion character varying, pago character varying, usu_inicial integer, notif character varying, num_acuerdo integer, costo_fijo01 numeric, ord character varying, afec character varying, zona smallint, espacio smallint, fecha_baja character varying)

#### ✅ SP: `sp_aplica_pago_divadmin`

- **Línea Vue:** 88
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `paraxo integer, parfolio integer, parfecha date, parreca integer, parcaja character varying, paroper integer, parusuario character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(success boolean, message text)


### ✅ AspectoPublicos.vue - OK

#### ✅ SP: `get_aspectos`

- **Línea Vue:** 40
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(nombre text)

#### ✅ SP: `get_current_aspecto`

- **Línea Vue:** 41
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(nombre text)


### ✅ BajaMultiplePublicos.vue - OK

#### ✅ SP: `sp_insert_folios_baja_esta`

- **Línea Vue:** 19
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `IN p_archivo character varying, IN p_referencia integer, IN p_folio_archivo integer, IN p_fecha_archivo character varying, IN p_placa character varying, IN p_anomalia character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO

#### ✅ SP: `sp_get_incidencias_baja_multiple`

- **Línea Vue:** 19
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_archivo character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(placa character varying, folio_archivo integer, fecha_archivo character varying, anomalia character varying, referencia integer)


### ✅ BajasPublicos.vue - OK

#### ✅ SP: `sp_sfrm_baja_pub`

- **Línea Vue:** 42
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_numlic character varying, p_motivo text`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(success boolean, message character varying, folio_baja integer)


### ✅ CargaEdoExPublicos.vue - OK

#### ✅ SP: `sp_insert_ta14_datos_edo`

- **Línea Vue:** 60
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `vmpio integer, vtipoact character varying, vfolio numeric, vplaca character varying, vfecpago date, vimporte numeric, vfecalta date, vremesa character varying, vfecremesa date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(success boolean, msg text)

#### ✅ SP: `sp_afec_esta01`

- **Línea Vue:** 68
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_fecha date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(success boolean, msg text)

#### ✅ SP: `sp_insert_ta14_bitacora`

- **Línea Vue:** 77
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_fecha_inicio date, p_fecha_fin date, p_fecha date, p_num_rem integer, p_cant_reg integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(success boolean, msg text)


### ✅ ChgAutorizDesctoPublicos.vue - OK

#### ✅ SP: `sp_buscar_folios_histo`

- **Línea Vue:** 58
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_placa character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(axo smallint, folio integer, placa character varying, fecha_folio date)

#### ✅ SP: `sp_cambiar_a_tesorero`

- **Línea Vue:** 66
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_axo smallint, p_folio integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(updated boolean)


### ✅ ConciBanortePublicos.vue - OK

#### ✅ SP: `sp_conciliados_by_folio`

- **Línea Vue:** 71
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_axo integer, p_folio integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(rowid integer, axo smallint, folio integer, fecha_folio date, placa character varying, infraccion smallint, fec_pago date, folio_pago character varying, medio_pago character varying, forma_pago character varying, importe_bruto numeric, importe_neto numeric, fecha_venci date, sucursal integer, hora_banco character varying, estatus_banco character varying, usu_carga integer, fecha_afectacion date, status_mpio smallint, placa_cambio character varying, fec_placa_cambio date, fec_carga_ascii date, fec_caja date, operacion integer, caja_ingre character varying, reca smallint, stat character varying)


### ✅ ConsGralPublicos.vue - OK

#### ✅ SP: `sp14_afolios`

- **Línea Vue:** 72
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `parplaca character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(tipoact character varying, placa character varying, axo integer, folio integer, fechaalta date, fechapago date, fechacancelado date, importe numeric, folioecmpio character varying, remesa character varying, fecharemesa date, concepto character varying, fecha_in date, fecha_fin date, fecha_aplic date)

#### ✅ SP: `sp14_bfolios`

- **Línea Vue:** 73
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `parplaca character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(tipoact character varying, placa character varying, axo integer, folio integer, fechaalta date, fechapago date, fechacancelado date, importe numeric, folioecmpio character varying, remesa character varying, fecharemesa date, concepto character varying, fecha_in date, fecha_fin date, fecha_aplic date)


### ✅ ConsRemesasPublicos.vue - OK

#### ✅ SP: `sp_get_remesas`

- **Línea Vue:** 7
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `tipo_param character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(control integer, tipo character varying, fecha_inicio date, fecha_fin date, fecha_hoy date, num_remesa integer, cant_reg integer)

#### ✅ SP: `sp_get_remesa_detalle_mpio`

- **Línea Vue:** 83
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `remesa_param character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(idrmunicipio integer, tipoact character varying, folio bigint, fechagenreq date, placa character varying, folionot character varying, fechanot date, fechapago date, fechacancelado date, importe numeric, clave character varying, fechaalta date, fechavenc date, folioec character varying, folioecmpio character varying, gastos numeric, remesa character varying, fecharemesa date)


### ✅ ConsultaPublicos.vue - OK

#### ✅ SP: `sp_get_public_parking_list`

- **Línea Vue:** 237
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, pubcategoria_id integer, categoria character varying, descripcion character varying, numesta integer, sector character varying, nomsector character varying, zona integer, subzona integer, numlicencia integer, axolicencias integer, cvecuenta integer, nombre character varying, calle character varying, numext character varying, telefono character varying, cupo integer, fecha_at date, fecha_inicial date, fecha_vencimiento date)

#### ✅ SP: `sp_get_public_parking_fines`

- **Línea Vue:** 291
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `numlicencia integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id_multa integer, id_dependencia smallint, axo_acta smallint, num_acta integer, fecha_acta date, fecha_recepcion date, contribuyente character varying, domicilio character varying, recaud smallint, num_licencia integer, giro character varying, id_ley smallint, id_infraccion smallint, expediente character varying, calificacion numeric, multa numeric, gastos numeric, total numeric, fecha_plazo date, comentario character varying, tipo character varying, noexterior character varying, interior character varying)

#### ✅ SP: `cajero_pub_detalle`

- **Línea Vue:** 308
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opc integer, p_pubid integer, p_axo integer, p_mes integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(concepto character varying, axo integer, mes integer, adeudo numeric, recargos numeric)

#### ✅ SP: `spget_lic_grales`

- **Línea Vue:** 328
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_numlicencia integer, p_cero integer DEFAULT 0, p_reca integer DEFAULT 4`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(clave integer, msg character varying, id integer, bloq integer, vigente character varying, id_giro integer, desc_giro character varying, actividad character varying, reglamentada character varying, propietario character varying, ubicacion character varying, numext integer, letext character varying, numint character varying, letint character varying, colonia character varying, zona integer, subzona integer, espubic character varying, asiento integer, curp character varying, sup_autorizada numeric, num_cajones integer, aforo integer, rhorario character varying, fecha_consejo date, cvecatnva character varying, subpredio integer, mensaje1 character varying, v_mensaje2 character varying, mensaje3 character varying, mensaje4 character varying, mensaje4_1 character varying, tipotramite character varying, desc_reglam character varying, rfc character varying, licencia integer, mensaje5 character varying, mensaje6 character varying, mensaje7 character varying, mensaje8 character varying)


### ✅ ContrarecibosPublicos.vue - OK

#### ✅ SP: `spd_crbo_abc`

- **Línea Vue:** 70
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_ejercicio smallint, p_procedencia smallint, p_crbo integer, p_feccrbo date, p_diasven smallint, p_importe numeric, p_concepto text, p_proveedor integer, p_doctos smallint, p_fecingre date, p_fecvenci date, p_feccodi date, p_fecveri date, p_fecprog date, p_fecaja date, p_feccancel date, p_cvecheq character varying, p_benef text, p_formapago character varying, p_notas text, p_param smallint, p_num_ctrol_cheque integer, p_clave_movimiento character varying, p_benef_cheque text`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(result text)

#### ✅ SP: `sum_contrarecibos_by_date`

- **Línea Vue:** 81
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_fecha date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: numeric


### ✅ EdoCtaPublicos.vue - OK

#### ✅ SP: `spubreports_edocta`

- **Línea Vue:** 52
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_numesta integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, pubcategoria_id integer, numesta integer, sector character varying, zona integer, subzona integer, numlicencia integer, axolicencias integer, cvecuenta integer, nombre character varying, calle character varying, numext character varying, telefono character varying, cupo integer, fecha_at date, fecha_inicial date, fecha_vencimiento date, rfc character varying, solicitud integer, control integer, movtos_no integer, movto_cve character varying, movto_usr integer, descripcion character varying)


### ✅ EstadisticasPublicos.vue - OK

#### ✅ SP: `sqrp_esta01_report`

- **Línea Vue:** 58
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `axo_from integer DEFAULT NULL::integer, axo_to integer DEFAULT NULL::integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(axo smallint, totfol bigint, infraccion smallint, totimp numeric)


### ✅ EstadoMpioPublicos.vue - OK

#### ✅ SP: `sp_get_remesas_estado_mpio`

- **Línea Vue:** 70
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(remesa text, fecharemesa date, aplicadoteso date)

#### ✅ SP: `spd_delesta01`

- **Línea Vue:** 96
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `axo smallint, folio integer, placa text, convenio integer, fecha date, reca smallint, caja text, oper integer, usuauto integer, opc smallint`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(result_code smallint, result_msg text)


### ✅ FoliosAltaPublicos.vue - OK

#### ✅ SP: `sp_insert_folio_adeudo`

- **Línea Vue:** 65
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_axo integer, p_folio integer, p_fecha_folio date, p_placa character varying, p_infraccion smallint, p_estado integer, p_vigilante integer, p_usu_inicial integer, p_zona smallint, p_espacio smallint`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(result text)


### ✅ GenArcAltasPublicos.vue - OK

#### ✅ SP: `get_periodo_altas`

- **Línea Vue:** 49
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(fecha_inicio date, fecha_fin date)

#### ✅ SP: `sp14_remesa`

- **Línea Vue:** 72
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opc integer, p_axo integer, p_fec_ini date, p_fec_fin date, p_fec_a_fin date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(status integer, obs text, remesa text)


### ✅ GenArcDiarioPublicos.vue - OK

#### ✅ SP: `sp14_remesa`

- **Línea Vue:** 50
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opc integer, p_axo integer, p_fec_ini date, p_fec_fin date, p_fec_a_fin date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(status integer, obs text, remesa text)


### ✅ GenerarPublicos.vue - OK

#### ✅ SP: `sp_get_public_parking_list`

- **Línea Vue:** 35
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, pubcategoria_id integer, categoria character varying, descripcion character varying, numesta integer, sector character varying, nomsector character varying, zona integer, subzona integer, numlicencia integer, axolicencias integer, cvecuenta integer, nombre character varying, calle character varying, numext character varying, telefono character varying, cupo integer, fecha_at date, fecha_inicial date, fecha_vencimiento date)


### ✅ GenIndividualPublicos.vue - OK

#### ✅ SP: `sp_gen_individual_add`

- **Línea Vue:** 56
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opcion integer, p_placa character varying, p_axo integer, p_folio character varying, p_remesa character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(idrmunicipio integer, tipoact character varying, folio bigint, placa character varying, fechapago date, fechacancelado date, fechaalta date, folioecmpio character varying, remesa character varying, fecharemesa date)

#### ✅ SP: `sp_gen_individual_generate_file`

- **Línea Vue:** 67
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_remesa character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(idrmunicipio integer, tipoact character varying, folio character varying, fechagenreq character varying, placa character varying, folionot character varying, fechanot character varying, fechapago character varying, fechacancelado character varying, importe numeric, clave integer, fechaalta character varying, fechavenc character varying, folioec numeric, folioecmpio character varying, gastos numeric, remesa character varying, fecharemesa character varying)


### ✅ GenPgosBanortePublicos.vue - OK

#### ✅ SP: `sp14_remesa`

- **Línea Vue:** 50
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opc integer, p_axo integer, p_fec_ini date, p_fec_fin date, p_fec_a_fin date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(status integer, obs text, remesa text)


### ✅ ImpPadronPublicos.vue - OK

#### ✅ SP: `sp_get_padron_report`

- **Línea Vue:** 54
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_id1 integer, p_id2 integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, placa character varying, placaant character varying, claveveh character varying, nombre character varying, municipio character varying, marca character varying, linea character varying, version character varying, tipo character varying, clase character varying, combustible character varying, modelo character varying, servicio character varying, color character varying, serie character varying, motor character varying, centimetros character varying)


### ✅ InfoPublicos.vue - OK

#### ✅ SP: `sp_get_public_parking_list`

- **Línea Vue:** 35
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, pubcategoria_id integer, categoria character varying, descripcion character varying, numesta integer, sector character varying, nomsector character varying, zona integer, subzona integer, numlicencia integer, axolicencias integer, cvecuenta integer, nombre character varying, calle character varying, numext character varying, telefono character varying, cupo integer, fecha_at date, fecha_inicial date, fecha_vencimiento date)


### ✅ InspectoresPublicos.vue - OK

#### ✅ SP: `sp_get_inspectors`

- **Línea Vue:** 43
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id_esta_persona integer, inspector text)


### ✅ ListadosPublicos.vue - OK

#### ✅ SP: `sqrp_publicos_report`

- **Línea Vue:** 66
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `order_by text`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(control integer, cve_sector character varying, cve_categ character varying, cve_numero integer, nombre character varying, telefono character varying, calle character varying, num character varying, cupo integer, fecha_alta date, fecha_inic date, fecha_venci date, delas integer, alas integer, delas1 integer, alas1 integer, frec_lunes character varying, frec_martes character varying, frec_miercoles character varying, frec_jueves character varying, frec_viernes character varying, frec_sabado character varying, frec_domingo character varying, pol_num character varying, pol_fec_ven date, numlic character varying, zona character varying, subzona smallint, estatus character varying, clave smallint, j1 integer, j2 integer, j3 integer, j4 integer, jt integer, jm integer, ja integer, jc1 integer, jc2 integer, jc3 integer, jc4 integer, jct integer, jcm integer, jca integer, h1 integer, h2 integer, h3 integer, h4 integer, ht integer, hm integer, ha integer, hc1 integer, hc2 integer, hc3 integer, hc4 integer, hct integer, hcm integer, hca integer, l1 integer, l2 integer, l3 integer, l4 integer, lt integer, lm integer, la integer, lc1 integer, lc2 integer, lc3 integer, lc4 integer, lct integer, lcm integer, lca integer, r1 integer, r2 integer, r3 integer, r4 integer, rt integer, rm integer, ra integer, rc1 integer, rc2 integer, rc3 integer, rc4 integer, rct integer, rcm integer, rca integer)


### ✅ MensajePublicos.vue - OK

#### ✅ SP: `sp_mensaje_show`

- **Línea Vue:** 43
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_tipo text, p_msg text, p_icono text`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(tipo text, msg text, icono text)


### ✅ MetrometersPublicos.vue - OK

#### ✅ SP: `sp_get_metrometer_by_axo_folio`

- **Línea Vue:** 59
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_axo integer, p_folio integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(axo smallint, folio integer, direccion character varying, poslong character varying, poslat character varying, marca character varying, modelo character varying, linkfoto1 character varying, linkfoto2 character varying, motivo character varying, idmedio integer)

#### ✅ SP: `sp_get_metrometers_map_url`

- **Línea Vue:** 62
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_axo integer, p_folio integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(map_url text)


### ✅ PagosPublicos.vue - OK

#### ✅ SP: `spubreports`

- **Línea Vue:** 56
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opc integer DEFAULT 1`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, pubcategoria_id integer, categoria character varying, descripcion character varying, numesta integer, sector character varying, nomsector character varying, zona integer, subzona integer, numlicencia integer, axolicencias integer, cvecuenta integer, nombre character varying, calle character varying, numext character varying, telefono character varying, cupo integer, fecha_at date, fecha_inicial date, fecha_vencimiento date)


### ✅ PasswordsPublicos.vue - OK

#### ✅ SP: `sp_passwords_list`

- **Línea Vue:** 60
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_usuario character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id_usuario integer, usuario character varying, nombre character varying, estado character, id_rec smallint, nivel smallint)

#### ✅ SP: `sp_passwords_update`

- **Línea Vue:** 79
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_id_usuario integer, p_usuario character varying, p_nombre character varying, p_estado character, p_id_rec smallint, p_nivel smallint`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id_usuario integer, usuario character varying, nombre character varying, estado character, id_rec smallint, nivel smallint)


### ✅ PredioCartoPublicos.vue - OK

#### ✅ SP: `sp_get_predio_carto_url`

- **Línea Vue:** 40
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_cvecatastro text`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: text


### ✅ PublicosNew.vue - OK

#### ✅ SP: `cons_predio`

- **Línea Vue:** 107
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `opc integer, dato character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(cvecuenta integer, recaud integer, tipo character varying, cuenta integer, cvecatastral character varying, subpredio integer, contribuyente character varying, calle character varying, numext character varying, numint character varying, zona integer, subzona integer, status integer, mensaje character varying)

#### ✅ SP: `sppubalta`

- **Línea Vue:** 154
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `pubcategoria_id integer, numesta integer, sector character varying, zona integer, subzona integer, numlicencia integer, axolicencias integer, cvecuenta integer, nombre character varying, calle character varying, numext character varying, telefono character varying, cupo integer, fecha_at date, fecha_inicial date, fecha_vencimiento date, rfc character varying, movtos_no integer, movto_cve character varying, movto_usr integer, solicitud integer, control integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(result integer, resultstr character varying, idnvo integer)


### ✅ ReactivaFoliosPublicos.vue - OK

#### ✅ SP: `sp_reactiva_folios_buscar`

- **Línea Vue:** 68
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opcion integer, p_placa character varying, p_axo integer, p_folio integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(control integer, axo integer, folio integer, fecha_folio date, placa character varying, infraccion integer, estado integer, vigilante integer, num_acuerdo integer, fec_cap date, usu_inicial integer, zona integer, espacio integer)


### ❌ RelacionFoliosPublicos.vue - ERROR

#### ❌ SP: `sQRp_relacion_folios_report`

- **Línea Vue:** 56
- **Parámetros Vue:** []
- **Existe en BD:** No


### ✅ ReporteFoliosPublicos.vue - OK

#### ✅ SP: `sp_get_folios_by_inspector`

- **Línea Vue:** 52
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_fecha date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(vigilante integer, inspector text, folios integer)


### ✅ ReporteListaPublicos.vue - OK

#### ✅ SP: `spubreports_list`

- **Línea Vue:** 69
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `opc integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, pubcategoria_id integer, categoria character varying, descripcion character varying, numesta integer, sector character varying, nomsector character varying, zona integer, subzona integer, numlicencia integer, axolicencias integer, cvecuenta integer, nombre character varying, calle character varying, numext character varying, telefono character varying, cupo integer, fecha_at date, fecha_inicial date, fecha_vencimiento date)


### ✅ ReportePagosPublicos.vue - OK

#### ✅ SP: `report_folios_pagados`

- **Línea Vue:** 79
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_reca integer, p_fechora date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(reca smallint, caja character varying, operacion integer, axo smallint, folio integer, placa character varying, fecha_folio date, estado smallint, infraccion smallint, tarifa numeric, codigo_movto smallint)

#### ✅ SP: `report_folios_adeudo_por_inspector`

- **Línea Vue:** 83
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_fechora date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(vigilante integer, inspector character varying, folios integer)


### ✅ ReportesCalcoPublicos.vue - OK

#### ✅ SP: `sp_catalog_inspectors`

- **Línea Vue:** 58
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** ``
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id_esta_persona integer, inspector text)

#### ✅ SP: `sp_report_folios`

- **Línea Vue:** 67
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `fechora date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(vigilante integer, inspector text, folios integer)


### ✅ ReportesPublicos.vue - OK

#### ✅ SP: `spget_lic_detalles`

- **Línea Vue:** 87
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_id_licencia integer, p_tipo_l character varying DEFAULT 'L'::character varying, p_redon character varying DEFAULT 'N'::character varying`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(cuenta integer, obliga character varying, concepto character varying, importe numeric, licanun integer)

#### ✅ SP: `spubreports`

- **Línea Vue:** 100
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_opc integer DEFAULT 1`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(id integer, pubcategoria_id integer, categoria character varying, descripcion character varying, numesta integer, sector character varying, nomsector character varying, zona integer, subzona integer, numlicencia integer, axolicencias integer, cvecuenta integer, nombre character varying, calle character varying, numext character varying, telefono character varying, cupo integer, fecha_at date, fecha_inicial date, fecha_vencimiento date)


### ✅ SeguridadLoginPublicos.vue - OK

#### ✅ SP: `sp_login_seguridad`

- **Línea Vue:** 41
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_user text, p_pass text`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(success boolean, message text)


### ❌ SolicRepFoliosPublicos.vue - ERROR

#### ✅ SP: `report_folios_pagados`

- **Línea Vue:** 77
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_reca integer, p_fechora date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(reca smallint, caja character varying, operacion integer, axo smallint, folio integer, placa character varying, fecha_folio date, estado smallint, infraccion smallint, tarifa numeric, codigo_movto smallint)

#### ❌ SP: `sQRp_relacion_folios_report`

- **Línea Vue:** 82
- **Parámetros Vue:** []
- **Existe en BD:** No


### ✅ TransFoliosPublicos.vue - OK

#### ✅ SP: `spd_delesta01`

- **Línea Vue:** 63
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `axo smallint, folio integer, placa text, convenio integer, fecha date, reca smallint, caja text, oper integer, usuauto integer, opc smallint`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(result_code smallint, result_msg text)


### ✅ TransPublicos.vue - OK

#### ✅ SP: `sp_ta_15_publicos_insert`

- **Línea Vue:** 75
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_cve_sector character varying, p_cve_categ character varying, p_cve_numero character varying, p_nombre character varying, p_telefono character varying, p_calle character varying, p_num character varying, p_cupo character varying, p_fecha_alta character varying, p_fecha_inic character varying, p_fecha_venci character varying, p_delas character varying, p_alas character varying, p_delas1 character varying, p_alas1 character varying, p_frec_lunes character varying, p_frec_martes character varying, p_frec_miercoles character varying, p_frec_jueves character varying, p_frec_viernes character varying, p_frec_sabado character varying, p_frec_domingo character varying, p_pol_num character varying, p_pol_fec_ven character varying, p_numlic character varying, p_zona character varying, p_subzona character varying, p_estatus character varying, p_clave character varying, p_control integer`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: boolean


### ✅ UpPagosPublicos.vue - OK

#### ✅ SP: `sp_up_pagos_update`

- **Línea Vue:** 46
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_alo integer, p_folio integer, p_fecbaj date`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(success boolean, message text)


### ✅ ValetPasoPublicos.vue - OK

#### ✅ SP: `process_valet_file`

- **Línea Vue:** 41
- **Parámetros Vue:** []
- **Existe en BD:** Sí
- **Parámetros BD:** `p_file_path text`
- **Compatibilidad:** OK
- **Prueba BD:**
  - Ejecutado: Sí
  - Resultado: VERIFICADO
  - Retorna: TABLE(row_num integer, status text, message text)


---

## Problemas Encontrados (2)

### 1. RelacionFoliosPublicos.vue - sQRp_relacion_folios_report

- **Tipo:** sp_no_existe
- **Descripción:** El SP sQRp_relacion_folios_report no existe en la base de datos
- **Solución Sugerida:** Crear el SP o actualizar el componente Vue para usar el SP correcto

### 2. SolicRepFoliosPublicos.vue - sQRp_relacion_folios_report

- **Tipo:** sp_no_existe
- **Descripción:** El SP sQRp_relacion_folios_report no existe en la base de datos
- **Solución Sugerida:** Crear el SP o actualizar el componente Vue para usar el SP correcto

