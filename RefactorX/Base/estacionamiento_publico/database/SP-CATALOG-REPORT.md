# CATÁLOGO DE STORED PROCEDURES - MÓDULO ESTACIONAMIENTO PÚBLICO

**Fecha de Análisis:** 2025-11-09

---

## RESUMEN EJECUTIVO

| Métrica | Cantidad |
|---------|----------|
| Archivos .pas analizados | 50 |
| Archivos SQL procesados | 182 |
| SPs únicos encontrados | 110 |
| Archivos procesados | 45 |
| Archivos PENDIENTES | 5 |

---

## ARCHIVOS PENDIENTES POR PROCESAR

Los siguientes archivos **NO tienen** sus archivos `_all_procedures.sql` correspondientes:


### 1. sFrm_UpExclus.pas

**Estado:** PENDIENTE

**Archivo SQL esperado:** `sFrm_UpExclus_all_procedures.sql`

**SPs encontrados en el código (24):**

- `sp_actualizaexcpago`
- `sp_actualizaexcpagoid`
- `sp_actualizaexcpagomensaje`
- `sp_adeudos`
- `sp_adeudosadeudo`
- `sp_adeudosaxo`
- `sp_adeudosconcepto`
- `sp_adeudosdescto_recgos`
- `sp_adeudosid_adeudo`
- `sp_adeudosmes`
- `sp_adeudosrecargos`
- `sp_adeudostipo`
- `sp_genera_adeudo`
- `sp_genera_adeudoid`
- `sp_genera_adeudomensaje`
- `sp_mod_contrato`
- `sp_mod_contratoid`
- `sp_mod_contratomensaje`
- `sp_ubicacion`
- `sp_ubicacionid`
- `sp_ubicacionmensaje`
- `sp_verifica`
- `sp_verificaid`
- `sp_verificamensaje`

---

### 2. sFrm_consulta_folios.pas

**Estado:** PENDIENTE

**Archivo SQL esperado:** `sFrm_consulta_folios_all_procedures.sql`

**SPs encontrados en el código (3):**

- `sp_sp14_cons_apremio`
- `sp_st_baja_reca`
- `sp_storedproc1`

---

### 3. sfrm_EXC_alta.pas

**Estado:** PENDIENTE

**Archivo SQL esperado:** `sfrm_EXC_alta_all_procedures.sql`

**SPs encontrados en el código (3):**

- `sp_altacontrato`
- `sp_altacontratoid`
- `sp_altacontratomensaje`

---

### 4. sfrm_excConsulta.pas

**Estado:** PENDIENTE

**Archivo SQL esperado:** `sfrm_excConsulta_all_procedures.sql`

**SPs encontrados en el código (18):**

- `sp_actualizaexcpago`
- `sp_actualizaexcpagoid`
- `sp_actualizaexcpagomensaje`
- `sp_adeudos`
- `sp_adeudosadeudo`
- `sp_adeudosaxo`
- `sp_adeudosconcepto`
- `sp_adeudosdescto_recgos`
- `sp_adeudosid_adeudo`
- `sp_adeudosmes`
- `sp_adeudosrecargos`
- `sp_adeudostipo`
- `sp_genera_adeudo`
- `sp_genera_adeudoid`
- `sp_genera_adeudomensaje`
- `sp_ubicacion`
- `sp_ubicacionid`
- `sp_ubicacionmensaje`

---

### 5. sfrm_exc_mod_contrato.pas

**Estado:** PENDIENTE

**Archivo SQL esperado:** `sfrm_exc_mod_contrato_all_procedures.sql`

**SPs encontrados en el código (3):**

- `sp_mod_contrato`
- `sp_mod_contratoid`
- `sp_mod_contratomensaje`

---

## ARCHIVOS PROCESADOS (Top 10 con más SPs)

1. **sfrm_consultapublicos.pas** - 48 SPs - `sfrm_consultapublicos_all_procedures.sql`
2. **spubActualizacionfrm.pas** - 20 SPs - `spubActualizacionfrm_all_procedures.sql`
3. **spublicosnewfrm.pas** - 15 SPs - `spublicosnewfrm_all_procedures.sql`
4. **SFRM_REPORTES_EXEC.pas** - 11 SPs - `SFRM_REPORTES_EXEC_all_procedures.sql`
5. **sfrm_alta_ubicaciones.pas** - 3 SPs - `sfrm_alta_ubicaciones_all_procedures.sql`
6. **ConsGral.pas** - 2 SPs - `ConsGral_all_procedures.sql`
7. **Reportes_Folios.pas** - 2 SPs - `Reportes_Folios_all_procedures.sql`
8. **srfrm_conci_banorte.pas** - 2 SPs - `srfrm_conci_banorte_all_procedures.sql`
9. **AplicaPgo_DivAdmin.pas** - 1 SPs - `AplicaPgo_DivAdmin_all_procedures.sql`
10. **Bja_Multiple.pas** - 1 SPs - `Bja_Multiple_all_procedures.sql`

---

## LISTA COMPLETA DE SPs ÚNICOS (110)

```
sp_actualizaexcpago
sp_actualizaexcpagoid
sp_actualizaexcpagomensaje
sp_actualizapubpago
sp_actualizapubpagoid
sp_actualizapubpagomensaje
sp_adeudos
sp_adeudosadeudo
sp_adeudosaxo
sp_adeudoscalcfields
sp_adeudosconcepto
sp_adeudosdescto_recgos
sp_adeudosid_adeudo
sp_adeudosmes
sp_adeudosrecargos
sp_adeudostipo
sp_adeudostotal
sp_altacontrato
sp_altacontratoid
sp_altacontratomensaje
sp_cambio
sp_cambioclave
sp_cons14_solicrep
sp_cons14_solicrep_c
sp_conspredio
sp_consprediocalle
sp_consprediocontribuyente
sp_consprediocuenta
sp_consprediocvecatastral
sp_consprediocvecuenta
sp_consprediomensaje
sp_conspredionumext
sp_conspredionumint
sp_consprediorecaud
sp_consprediostatus
sp_consprediosubpredio
sp_consprediosubzona
sp_consprediotipo
sp_consprediozona
sp_genera_adeudo
sp_genera_adeudoid
sp_genera_adeudomensaje
sp_licgrales
sp_licgralesactividad
sp_licgralesaforo
sp_licgralesasiento
sp_licgralesbloq
sp_licgralesclave
sp_licgralescolonia
sp_licgralescurp
sp_licgralescvecatnva
sp_licgralesdesc_giro
sp_licgralesdesc_reglam
sp_licgralesespubic
sp_licgralesfecha_consejo
sp_licgralesid
sp_licgralesid_giro
sp_licgralesletext
sp_licgralesletint
sp_licgraleslicencia
sp_licgralesmensaje1
sp_licgralesmensaje3
sp_licgralesmensaje4
sp_licgralesmensaje4_1
sp_licgralesmensaje5
sp_licgralesmensaje6
sp_licgralesmensaje7
sp_licgralesmensaje8
sp_licgralesmsg
sp_licgralesnum_cajones
sp_licgralesnumext
sp_licgralesnumint
sp_licgralespropietario
sp_licgralesreglamentada
sp_licgralesrfc
sp_licgralesrhorario
sp_licgralessubpredio
sp_licgralessubzona
sp_licgralessup_autorizada
sp_licgralestipotramite
sp_licgralesubicacion
sp_licgralesv_mensaje2
sp_licgralesvigente
sp_licgraleszona
sp_lictotales
sp_lictotalesconcepto
sp_lictotalescuenta
sp_lictotalesimporte
sp_lictotaleslicanun
sp_lictotalesobliga
sp_mod_contrato
sp_mod_contratoid
sp_mod_contratomensaje
sp_movtos
sp_movtosresultado
sp_sp14_afolios
sp_sp14_aplpgo_divadmin
sp_sp14_bfolios
sp_sp14_cons_apremio
sp_sp14_ejecuta_sp
sp_sp14_remesa
sp_st_baja_reca
sp_storedproc1
sp_ubicacion
sp_ubicacionid
sp_ubicacionmensaje
sp_verifica
sp_verificaid
sp_verificamensaje
spd_afec_esta01
```

---

## ARCHIVOS SQL PROCESADOS

Total: 182 archivos

### Archivos Consolidados (47)

- Acceso_all_procedures.sql
- AplicaPgo_DivAdmin_all_procedures.sql
- Bja_Multiple_all_procedures.sql
- Cga_ArcEdoEx_all_procedures.sql
- ConsGral_all_procedures.sql
- ConsRemesas_all_procedures.sql
- DM_Crbos_all_procedures.sql
- DsDBGasto_all_procedures.sql
- Dspasswords_all_procedures.sql
- Gen_ArcAltas_all_procedures.sql
- Gen_ArcDiario_all_procedures.sql
- Gen_Individual_all_procedures.sql
- Gen_PgosBanorte_all_procedures.sql
- Reactiva_Folios_all_procedures.sql
- Reportes_Folios_all_procedures.sql
- SFRM_REPORTES_EXEC_all_procedures.sql
- UNIT9_all_procedures.sql
- Unit1_all_procedures.sql
- frmMetrometers_all_procedures.sql
- mensaje_all_procedures.sql
- sQRp_relacion_folios_all_procedures.sql
- sQRt_imp_padron_all_procedures.sql
- s_trans_exclu_all_procedures.sql
- sdmWebService_all_procedures.sql
- sfolios_alta_all_procedures.sql
- sfrmMetrometers_all_procedures.sql
- sfrm_abc_propietario_all_procedures.sql
- sfrm_alta_ubicaciones_all_procedures.sql
- sfrm_aspecto_all_procedures.sql
- sfrm_chg_autorizadescto_all_procedures.sql
- sfrm_consultapublicos_all_procedures.sql
- sfrm_prop_exclusivo_all_procedures.sql
- sfrm_rep_folio_all_procedures.sql
- sfrm_report_pagos_all_procedures.sql
- sfrm_reportescalco_all_procedures.sql
- sfrm_tr_estado_mpio_all_procedures.sql
- sfrm_trans_pub_all_procedures.sql
- sfrm_transfolios_all_procedures.sql
- sfrm_up_pagos_all_procedures.sql
- sfrm_valet_paso_all_procedures.sql
- sfrmprediocarto_all_procedures.sql
- spubActualizacionfrm_all_procedures.sql
- spublicosnewfrm_all_procedures.sql
- spubreports_all_procedures.sql
- sqrp_esta01_all_procedures.sql
- sqrp_publicos_all_procedures.sql
- srfrm_conci_banorte_all_procedures.sql

### Archivos de Catálogos/Instalación (5)

- 01_catalogs.sql
- 02_crud.sql
- 03_reports.sql
- INSTALL_QuickSetup.sql
- MASTER_StoredProcedures.sql

### SPs Individuales (130)

- Acceso_sp_get_catalog.sql
- Acceso_sp_get_folios_report.sql
- Acceso_sp_get_user_info.sql
- Acceso_sp_login.sql
- Acceso_sp_register_folio.sql
- AplicaPgo_DivAdmin_sp_aplica_pago_divadmin.sql
- AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql
- Bja_Multiple_sp14_ejecuta_sp.sql
- Bja_Multiple_sp_get_incidencias_baja_multiple.sql
- Bja_Multiple_sp_insert_folios_baja_esta.sql
- Cga_ArcEdoEx_sp_afec_esta01.sql
- Cga_ArcEdoEx_sp_insert_ta14_bitacora.sql
- Cga_ArcEdoEx_sp_insert_ta14_datos_edo.sql
- ConsGral_sp14_afolios.sql
- ConsGral_sp14_bfolios.sql
- ConsRemesas_sp_get_remesa_detalle_edo.sql
- ConsRemesas_sp_get_remesa_detalle_mpio.sql
- ConsRemesas_sp_get_remesas.sql
- DM_Crbos_get_contrarecibos_by_date.sql
- DM_Crbos_spd_crbo_abc.sql
- DM_Crbos_spd_proveedor_abc.sql
- DM_Crbos_sum_contrarecibos_by_date.sql
- DsDBGasto_sp_connect_estacion.sql
- DsDBGasto_sp_login_seguridad.sql
- Dspasswords_sp_passwords_create.sql
- Dspasswords_sp_passwords_delete.sql
- Dspasswords_sp_passwords_list.sql
- Dspasswords_sp_passwords_update.sql
- Gen_ArcAltas_contar_folios_remesa.sql
- Gen_ArcAltas_generar_archivo_remesa.sql
- Gen_ArcAltas_get_periodo_altas.sql
- Gen_ArcAltas_sp14_remesa.sql
- Gen_ArcDiario_buscar_folios_remesa.sql
- Gen_ArcDiario_generar_archivo_remesa.sql
- Gen_ArcDiario_get_periodo_altas.sql
- Gen_ArcDiario_get_periodo_diario.sql
- Gen_ArcDiario_sp14_remesa.sql
- Gen_Individual_sp_gen_individual_add.sql
- Gen_Individual_sp_gen_individual_execute.sql
- Gen_Individual_sp_gen_individual_generate_file.sql
- Gen_PgosBanorte_sp14_remesa.sql
- Reactiva_Folios_sp_reactiva_folios_aplicar.sql
- Reactiva_Folios_sp_reactiva_folios_buscar.sql
- Reportes_Folios_cons14_solicrep.sql
- Reportes_Folios_cons14_solicrep_c.sql
- SFRM_REPORTES_EXEC_sp_adeudos_detalle.sql
- SFRM_REPORTES_EXEC_sp_get_adeudos_exec.sql
- SFRM_REPORTES_EXEC_sp_get_deudores_exec.sql
- SFRM_REPORTES_EXEC_sp_get_estado_cuenta.sql
- SFRM_REPORTES_EXEC_sp_get_reportes_exec.sql
- UNIT9_sp_unit9_preview_load.sql
- UNIT9_sp_unit9_preview_navigate.sql
- UNIT9_sp_unit9_preview_onepage.sql
- UNIT9_sp_unit9_preview_pagewidth.sql
- UNIT9_sp_unit9_preview_print.sql
- UNIT9_sp_unit9_preview_save.sql
- UNIT9_sp_unit9_preview_zoom.sql
- Unit1_report_unit1.sql
- frmMetrometers_sp_get_metrometer_by_axo_folio.sql
- frmMetrometers_sp_update_metrometer.sql
- mensaje_sp_mensaje_show.sql
- sQRp_relacion_folios_sQRp_relacion_folios_report.sql
- sQRt_imp_padron_sp_get_padron_report.sql
- s_trans_exclu_sp_insert_ta_18_exclusivo.sql
- s_trans_exclu_sp_update_ta_15_publicos_fecha_venci.sql
- sdmWebService_predio_virtual.sql
- sdmWebService_sp_insert_predio_virtual.sql
- sfolios_alta_sp_insert_folio_adeudo.sql
- sfrmMetrometers_sp_get_metrometers_by_axo_folio.sql
- sfrmMetrometers_sp_get_metrometers_map_url.sql
- sfrmMetrometers_sp_get_metrometers_photo.sql
- sfrm_abc_propietario_check_rfc_exists.sql
- sfrm_abc_propietario_insert_persona.sql
- sfrm_alta_ubicaciones_sp_exc_ubicacion.sql
- sfrm_aspecto_get_aspectos.sql
- sfrm_aspecto_get_current_aspecto.sql
- sfrm_aspecto_set_aspecto.sql
- sfrm_chg_autorizadescto_sp_buscar_folios_free.sql
- sfrm_chg_autorizadescto_sp_buscar_folios_histo.sql
- sfrm_chg_autorizadescto_sp_cambiar_a_tesorero.sql
- sfrm_consultapublicos_sp_get_license_general.sql
- sfrm_consultapublicos_sp_get_license_totals.sql
- sfrm_consultapublicos_sp_get_public_parking_debts.sql
- sfrm_consultapublicos_sp_get_public_parking_fines.sql
- sfrm_consultapublicos_sp_get_public_parking_list.sql
- sfrm_prop_exclusivo_ex_propietario_by_id.sql
- sfrm_prop_exclusivo_ex_propietario_by_rfc.sql
- sfrm_prop_exclusivo_ex_propietario_create.sql
- sfrm_prop_exclusivo_ex_propietario_update.sql
- sfrm_rep_folio_sp_get_folios_by_inspector.sql
- sfrm_rep_folio_sp_get_folios_report.sql
- sfrm_rep_folio_sp_get_inspectors.sql
- sfrm_rep_folio_sp_get_usuarios.sql
- sfrm_report_pagos_report_folios_adeudo_por_inspector.sql
- sfrm_report_pagos_report_folios_elaborados_usuario.sql
- sfrm_report_pagos_report_folios_pagados.sql
- sfrm_reportescalco_sp_catalog_inspectors.sql
- sfrm_reportescalco_sp_report_calcomanias.sql
- sfrm_reportescalco_sp_report_folios.sql
- sfrm_tr_estado_mpio_sp_get_remesas_estado_mpio.sql
- sfrm_tr_estado_mpio_sp_insert_folios_estado_mpio.sql
- sfrm_tr_estado_mpio_spd_delesta01.sql
- sfrm_trans_pub_sp_ta_15_publicos_insert.sql
- sfrm_trans_pub_sp_ta_15_publicos_update_pol_fec_ven.sql
- sfrm_transfolios_sp_altas_calcomanias.sql
- sfrm_transfolios_sp_altas_folios.sql
- sfrm_transfolios_sp_bajas_folios.sql
- sfrm_up_pagos_sp_up_pagos_update.sql
- sfrm_valet_paso_process_valet_file.sql
- sfrmprediocarto_sp_get_predio_carto_url.sql
- spubActualizacionfrm_actualiza_pub_pago.sql
- spubActualizacionfrm_cajero_pub_detalle.sql
- spubActualizacionfrm_delete_pubadeudo.sql
- spubActualizacionfrm_insert_pubadeudo.sql
- spubActualizacionfrm_sp_pub_movtos.sql
- spubActualizacionfrm_sppubbaja.sql
- spubActualizacionfrm_sppubmodi.sql
- spublicosnewfrm_cons_predio.sql
- spublicosnewfrm_sp_pubadeudo_forma.sql
- spublicosnewfrm_sppubalta.sql
- spubreports_spubreports_adeudos.sql
- spubreports_spubreports_edocta.sql
- spubreports_spubreports_list.sql
- spubreports_spubreports_sector_summary.sql
- sqrp_esta01_sqrp_esta01_report.sql
- sqrp_publicos_sqrp_publicos_report.sql
- srfrm_conci_banorte_sp_conciliados_by_fecha.sql
- srfrm_conci_banorte_sp_conciliados_by_folio.sql
- srfrm_conci_banorte_sp_histo_by_axo_folio.sql
- srfrm_conci_banorte_spd_chg_conci.sql
