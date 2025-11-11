# 🔍 AUDITORÍA: Conexiones Vue → Base de Datos PostgreSQL

**Fecha**: 10/11/2025, 2:57:30 p.m.
**Sistema**: RefactorX Guadalajara

---

## 📊 RESUMEN EJECUTIVO

- **Total de archivos Vue analizados**: 593
- **Archivos con BASE_DB**: 168
- **Conexiones correctas**: 168 ✅
- **Conexiones incorrectas**: 0 ❌
- **Advertencias**: 0 ⚠️
- **Errores de análisis**: 0
- **Stored Procedures únicos detectados**: 129

---

## ✅ CONEXIONES CORRECTAS (168)


### Módulo: estacionamiento_exclusivo

| Archivo | Base de Datos | Línea |
|---------|---------------|-------|
| `src\views\modules\estacionamiento_exclusivo\ABCEjec.vue` | `estacionamiento_exclusivo` | 297 |
| `src\views\modules\estacionamiento_exclusivo\ApremiosSvnActuaciones.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\ApremiosSvnExpedientes.vue` | `estacionamiento_exclusivo` | 255 |
| `src\views\modules\estacionamiento_exclusivo\ApremiosSvnFases.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\ApremiosSvnNotificaciones.vue` | `estacionamiento_exclusivo` | 304 |
| `src\views\modules\estacionamiento_exclusivo\ApremiosSvnPagos.vue` | `estacionamiento_exclusivo` | 325 |
| `src\views\modules\estacionamiento_exclusivo\ApremiosSvnReportes.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\AutorizaDes.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\CartaInvitacion.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\CMultEmision.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\CMultFolio.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\ConsultaReg.vue` | `estacionamiento_exclusivo` | 180 |
| `src\views\modules\estacionamiento_exclusivo\Cons_his.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\Ejecutores.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\EstadxFolio.vue` | `estacionamiento_exclusivo` | 52 |
| `src\views\modules\estacionamiento_exclusivo\ExportarExcel.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Facturacion.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\FirmaElectronica.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Individual.vue` | `estacionamiento_exclusivo` | 18 |
| `src\views\modules\estacionamiento_exclusivo\Individual_Folio.vue` | `estacionamiento_exclusivo` | 18 |
| `src\views\modules\estacionamiento_exclusivo\Listados.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\ListadosAdeAseoForm.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\ListadosAdeExclusivosForm.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\ListadosAdeInfraccionesForm.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\ListadosAdeMercadosForm.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\ListadosAdePublicosForm.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\ListadosSinAdereq.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Listados_Ade.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Lista_Eje.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Lista_GastosCob.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\ListxFec.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\ListxReg.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\List_Eje.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Modifcar.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Modificar_bien.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Modif_Masiva.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Notificaciones.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\NotificacionesMes.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\Prenomina.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Reasignacion.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Recuperacion.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\ReportAutor.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\Requerimientos.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RprtCATAL_EJE.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RprtEstadxfolio.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RprtListados.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RprtListaxFec.vue` | `estacionamiento_exclusivo` | 14 |
| `src\views\modules\estacionamiento_exclusivo\RprtListaxRegAseo.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RprtListaxRegEstacionometro.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RprtListaxRegMer.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RprtList_Eje.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptFact_Merc.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptListado_Aseo.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptListaxRegPub.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptLista_mercados.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptPrenomina.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptRecup_Aseo.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptRecup_Merc.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptReq_Aseo.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptReq_Merc.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptReq_pba.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\RptReq_Pba_Aseo.vue` | `estacionamiento_exclusivo` | 13 |
| `src\views\modules\estacionamiento_exclusivo\sfrm_chgpass.vue` | `estacionamiento_exclusivo` | 14 |

### Módulo: multas_reglamentos

| Archivo | Base de Datos | Línea |
|---------|---------------|-------|
| `src\views\modules\multas_reglamentos\ActualizaFechaEmpresas.vue` | `multas_reglamentos` | 150 |
| `src\views\modules\multas_reglamentos\AplicaSdosFavor.vue` | `multas_reglamentos` | 86 |
| `src\views\modules\multas_reglamentos\autdescto.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\bloqctasreqfrm.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\BloqueoMulta.vue` | `multas_reglamentos` | 92 |
| `src\views\modules\multas_reglamentos\busque.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\canc.vue` | `multas_reglamentos` | 16 |
| `src\views\modules\multas_reglamentos\CapturaDif.vue` | `multas_reglamentos` | 18 |
| `src\views\modules\multas_reglamentos\CartaInvitacion.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\CatastroDM.vue` | `multas_reglamentos` | 105 |
| `src\views\modules\multas_reglamentos\centrosfrm.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\codificafrm.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\conscentrosfrm.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\consdesc.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\consescrit400.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\consmulpagos.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\consobsmulfrm.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\ConsReq400.vue` | `multas_reglamentos` | 108 |
| `src\views\modules\multas_reglamentos\consultapredial.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\dderechosLic.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\DescDerechosMerc.vue` | `multas_reglamentos` | 69 |
| `src\views\modules\multas_reglamentos\descmultampalfrm.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\descpredfrm.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\desctorec.vue` | `multas_reglamentos` | 11 |
| `src\views\modules\multas_reglamentos\DrecgoFosa.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\drecgoLic.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\drecgoOtrasObligaciones.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\DrecgoTrans.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\Ejecutores.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\Empresas.vue` | `multas_reglamentos` | 86 |
| `src\views\modules\multas_reglamentos\entregafrm.vue` | `multas_reglamentos` | 11 |
| `src\views\modules\multas_reglamentos\estadreq.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\Exclusivos_Upd.vue` | `multas_reglamentos` | 16 |
| `src\views\modules\multas_reglamentos\ExtractosRpt.vue` | `multas_reglamentos` | 16 |
| `src\views\modules\multas_reglamentos\FirmaElectronica.vue` | `multas_reglamentos` | 16 |
| `src\views\modules\multas_reglamentos\FolMulta.vue` | `multas_reglamentos` | 17 |
| `src\views\modules\multas_reglamentos\FrmEje.vue` | `multas_reglamentos` | 17 |
| `src\views\modules\multas_reglamentos\frmpol.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\GastosTransmision.vue` | `multas_reglamentos` | 67 |
| `src\views\modules\multas_reglamentos\Hastafrm.vue` | `multas_reglamentos` | 37 |
| `src\views\modules\multas_reglamentos\impreqCvecat.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\ImpresionNva.vue` | `multas_reglamentos` | 12 |
| `src\views\modules\multas_reglamentos\ImprimeDesctos.vue` | `multas_reglamentos` | 36 |
| `src\views\modules\multas_reglamentos\ipor.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\leyesfrm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\LicenciaMicrogenerador.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\LicenciaMicrogeneradorEcologia.vue` | `multas_reglamentos` | 13 |
| `src\views\modules\multas_reglamentos\ligapago.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\ligapagoTra.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\ListaDiferencias.vue` | `multas_reglamentos` | 53 |
| `src\views\modules\multas_reglamentos\ListadoMultiple.vue` | `multas_reglamentos` | 53 |
| `src\views\modules\multas_reglamentos\ListAna.vue` | `multas_reglamentos` | 66 |
| `src\views\modules\multas_reglamentos\listanotificacionesfrm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\listareq.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\listchq.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\listdesctomultafrm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\ModifMasiva.vue` | `multas_reglamentos` | 33 |
| `src\views\modules\multas_reglamentos\multas400frm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\MultasDM.vue` | `multas_reglamentos` | 79 |
| `src\views\modules\multas_reglamentos\multasfrm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\multasfrmcalif.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\newsfrm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\Otorgadescto.vue` | `multas_reglamentos` | 45 |
| `src\views\modules\multas_reglamentos\pagalicfrm.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\pagosdivfrm.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\PagosEspe.vue` | `multas_reglamentos` | 29 |
| `src\views\modules\multas_reglamentos\pagosmultfrm.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\PeriodoInicial.vue` | `multas_reglamentos` | 23 |
| `src\views\modules\multas_reglamentos\polcon.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\prepagofrm.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\pres.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\Propuestatab.vue` | `multas_reglamentos` | 23 |
| `src\views\modules\multas_reglamentos\proyecfrm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\pruebacalcas.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\Publicos_Upd.vue` | `multas_reglamentos` | 16 |
| `src\views\modules\multas_reglamentos\reg.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\regHfrm.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\RegSecyMas.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\reimpfrm.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\relmes.vue` | `multas_reglamentos` | 44 |
| `src\views\modules\multas_reglamentos\repavance.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\RepDescImpto.vue` | `multas_reglamentos` | 16 |
| `src\views\modules\multas_reglamentos\repmultampalfrm.vue` | `multas_reglamentos` | 40 |
| `src\views\modules\multas_reglamentos\RepOper.vue` | `multas_reglamentos` | 22 |
| `src\views\modules\multas_reglamentos\Req.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\reqctascanfrm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\ReqFrm.vue` | `multas_reglamentos` | 22 |
| `src\views\modules\multas_reglamentos\reqmultas400frm.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\ReqPromocion.vue` | `multas_reglamentos` | 22 |
| `src\views\modules\multas_reglamentos\ReqTrans.vue` | `multas_reglamentos` | 101 |
| `src\views\modules\multas_reglamentos\RequerimientosDM.vue` | `multas_reglamentos` | 22 |
| `src\views\modules\multas_reglamentos\RequerxCvecat.vue` | `multas_reglamentos` | 21 |
| `src\views\modules\multas_reglamentos\ResolucionJuez.vue` | `multas_reglamentos` | 22 |
| `src\views\modules\multas_reglamentos\SdosFavorDM.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\SdosFavor_CtrlExp.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\SdosFavor_Pagos.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\sfrm_calificacionQR.vue` | `multas_reglamentos` | 3 |
| `src\views\modules\multas_reglamentos\sfrm_chgpass.vue` | `multas_reglamentos` | 34 |
| `src\views\modules\multas_reglamentos\sfrm_prescrip_sec01.vue` | `multas_reglamentos` | 40 |
| `src\views\modules\multas_reglamentos\sgcv2.vue` | `multas_reglamentos` | 5 |
| `src\views\modules\multas_reglamentos\SinLigarFrm.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\SolSdosFavor.vue` | `multas_reglamentos` | 19 |
| `src\views\modules\multas_reglamentos\TDMConection.vue` | `multas_reglamentos` | 18 |
| `src\views\modules\multas_reglamentos\trasladosfrm.vue` | `multas_reglamentos` | 30 |
| `src\views\modules\multas_reglamentos\Ubicodifica.vue` | `multas_reglamentos` | 19 |

---

## ❌ CONEXIONES INCORRECTAS (0)

✅ **¡Excelente!** No se encontraron conexiones incorrectas.

---

## ⚠️  ADVERTENCIAS (0)

No hay advertencias.

---

## 📋 STORED PROCEDURES DETECTADOS (129)

| # | Stored Procedure | Usado en (archivos) |
|---|------------------|---------------------|
| 1 | `APREMIOSSVN_APREMIOS_ESTADISTICAS` | 1 archivo (1 uso) |
| 2 | `APREMIOSSVN_EXPEDIENTES_ESTADISTICAS` | 1 archivo (1 uso) |
| 3 | `APREMIOSSVN_EXPEDIENTES_LIST` | 1 archivo (1 uso) |
| 4 | `APREMIOSSVN_LISTADOS_ADE` | 1 archivo (1 uso) |
| 5 | `APREMIOSSVN_NOTIFICACIONES_ESTADISTICAS` | 1 archivo (1 uso) |
| 6 | `APREMIOSSVN_NOTIFICACIONES_LIST` | 1 archivo (1 uso) |
| 7 | `APREMIOSSVN_PAGOS_ESTADISTICAS` | 1 archivo (1 uso) |
| 8 | `APREMIOSSVN_PAGOS_LIST` | 1 archivo (1 uso) |
| 9 | `RECAUDADORA_ACTUALIZA_FECHAS` | 1 archivo (1 uso) |
| 10 | `RECAUDADORA_APLICA_SDOS_FAVOR` | 1 archivo (1 uso) |
| 11 | `RECAUDADORA_AUTDESCTO` | 1 archivo (1 uso) |
| 12 | `RECAUDADORA_BLOQCTASREQFRM` | 1 archivo (1 uso) |
| 13 | `RECAUDADORA_BLOQUEO_MULTA` | 1 archivo (1 uso) |
| 14 | `RECAUDADORA_BUSQUE` | 1 archivo (1 uso) |
| 15 | `RECAUDADORA_CANC` | 1 archivo (1 uso) |
| 16 | `RECAUDADORA_CAPTURA_DIF` | 1 archivo (1 uso) |
| 17 | `RECAUDADORA_CARTA_INVITACION` | 1 archivo (1 uso) |
| 18 | `RECAUDADORA_CATASTRO_DM` | 1 archivo (1 uso) |
| 19 | `RECAUDADORA_CENTROSFRM` | 1 archivo (1 uso) |
| 20 | `RECAUDADORA_CODIFICAFRM` | 1 archivo (1 uso) |
| 21 | `RECAUDADORA_CONSCENTROSFRM` | 1 archivo (1 uso) |
| 22 | `RECAUDADORA_CONSDESC` | 1 archivo (1 uso) |
| 23 | `RECAUDADORA_CONSULTA_SDOS_FAVOR` | 1 archivo (1 uso) |
| 24 | `RECAUDADORA_DESCDERECHOS_MERC` | 1 archivo (1 uso) |
| 25 | `RECAUDADORA_DRECGO_FOSA` | 1 archivo (1 uso) |
| 26 | `RECAUDADORA_DRECGO_TRANS` | 1 archivo (1 uso) |
| 27 | `RECAUDADORA_EJECUTORES` | 1 archivo (1 uso) |
| 28 | `RECAUDADORA_EMPRESAS` | 1 archivo (1 uso) |
| 29 | `RECAUDADORA_EXCLUSIVOS_UPD` | 1 archivo (1 uso) |
| 30 | `RECAUDADORA_EXTRACTOS_RPT` | 1 archivo (1 uso) |
| 31 | `RECAUDADORA_FIRMA_ELECTRONICA` | 1 archivo (1 uso) |
| 32 | `RECAUDADORA_FOL_MULTA` | 1 archivo (1 uso) |
| 33 | `RECAUDADORA_GASTOS_TRANSMISION` | 1 archivo (1 uso) |
| 34 | `RECAUDADORA_GET_EJECUTORES` | 1 archivo (1 uso) |
| 35 | `RECAUDADORA_HASTAFRM` | 1 archivo (1 uso) |
| 36 | `RECAUDADORA_IMPRIME_DESCTOS` | 1 archivo (1 uso) |
| 37 | `RECAUDADORA_LISTADO_MULTIPLE` | 1 archivo (1 uso) |
| 38 | `RECAUDADORA_LISTANA` | 1 archivo (1 uso) |
| 39 | `RECAUDADORA_LISTA_DIFERENCIAS` | 1 archivo (1 uso) |
| 40 | `RECAUDADORA_MODIF_MASIVA` | 1 archivo (1 uso) |
| 41 | `RECAUDADORA_MULTAS_DM` | 1 archivo (1 uso) |
| 42 | `RECAUDADORA_OTORGA_DESCTO` | 1 archivo (1 uso) |
| 43 | `RECAUDADORA_PAGOS_ESPE` | 1 archivo (1 uso) |
| 44 | `RECAUDADORA_PARSE_FILE` | 1 archivo (1 uso) |
| 45 | `RECAUDADORA_PERIODO_INICIAL` | 1 archivo (1 uso) |
| 46 | `RECAUDADORA_PROPUESTATAB` | 1 archivo (1 uso) |
| 47 | `RECAUDADORA_PUBLICOS_UPD` | 1 archivo (1 uso) |
| 48 | `RECAUDADORA_REGSECYMAS` | 1 archivo (1 uso) |
| 49 | `RECAUDADORA_REP_DESC_IMPTO` | 1 archivo (1 uso) |
| 50 | `RECAUDADORA_REP_OPER` | 1 archivo (1 uso) |
| 51 | `RECAUDADORA_REQ` | 1 archivo (1 uso) |
| 52 | `RECAUDADORA_REQTRANS_CREATE` | 1 archivo (1 uso) |
| 53 | `RECAUDADORA_REQTRANS_DELETE` | 1 archivo (1 uso) |
| 54 | `RECAUDADORA_REQTRANS_LIST` | 1 archivo (1 uso) |
| 55 | `RECAUDADORA_REQTRANS_UPDATE` | 1 archivo (1 uso) |
| 56 | `RECAUDADORA_REQUERIMIENTOS_DM` | 1 archivo (1 uso) |
| 57 | `RECAUDADORA_REQUERXCVECAT` | 1 archivo (1 uso) |
| 58 | `RECAUDADORA_REQ_FRM_SAVE` | 1 archivo (1 uso) |
| 59 | `RECAUDADORA_REQ_PROMOCION` | 1 archivo (1 uso) |
| 60 | `RECAUDADORA_RESOLUCION_JUEZ` | 1 archivo (1 uso) |
| 61 | `RECAUDADORA_SDOSFAVOR_CTRLEXP` | 1 archivo (1 uso) |
| 62 | `RECAUDADORA_SDOSFAVOR_DM` | 1 archivo (1 uso) |
| 63 | `RECAUDADORA_SDOSFAVOR_PAGOS` | 1 archivo (1 uso) |
| 64 | `RECAUDADORA_SINLIGARFRM` | 1 archivo (1 uso) |
| 65 | `RECAUDADORA_SOL_SDOS_FAVOR` | 1 archivo (1 uso) |
| 66 | `RECAUDADORA_TDM_CONECTION` | 1 archivo (1 uso) |
| 67 | `RECAUDADORA_UBICODIFICA` | 1 archivo (1 uso) |
| 68 | `apremiossvn_apremios_estadisticas` | 58 archivos (59 usos) |
| 69 | `apremiossvn_ejecutores_estadisticas` | 1 archivo (2 usos) |
| 70 | `estadxfolio_stats` | 1 archivo (1 uso) |
| 71 | `get_individual_folio` | 1 archivo (1 uso) |
| 72 | `rprt_listados` | 1 archivo (1 uso) |
| 73 | `rprt_listaxfec` | 1 archivo (1 uso) |
| 74 | `rprtlist_eje_report` | 1 archivo (1 uso) |
| 75 | `rpt_catal_eje` | 1 archivo (1 uso) |
| 76 | `rpt_estadxfolio` | 1 archivo (1 uso) |
| 77 | `rpt_lista_mercados` | 1 archivo (1 uso) |
| 78 | `rpt_listado_aseo` | 1 archivo (1 uso) |
| 79 | `rpt_listax_reg_mer` | 1 archivo (1 uso) |
| 80 | `rpt_listaxreg_estacionometro` | 1 archivo (1 uso) |
| 81 | `rpt_listaxregpub_get_report` | 1 archivo (1 uso) |
| 82 | `rpt_prenomina` | 1 archivo (1 uso) |
| 83 | `rptfact_merc_get_report` | 1 archivo (1 uso) |
| 84 | `rptrecup_aseo_report` | 1 archivo (1 uso) |
| 85 | `rptrecup_merc_report` | 1 archivo (1 uso) |
| 86 | `rptreq_aseo_report` | 1 archivo (1 uso) |
| 87 | `rptreq_merc_reporte` | 1 archivo (1 uso) |
| 88 | `rptreq_pba_aseo_get_report` | 1 archivo (1 uso) |
| 89 | `rptreq_pba_get_report_data` | 1 archivo (1 uso) |
| 90 | `sp_actuaciones_list` | 1 archivo (1 uso) |
| 91 | `sp_autorizades_search` | 1 archivo (1 uso) |
| 92 | `sp_buscar_folios` | 1 archivo (1 uso) |
| 93 | `sp_buscar_mercados_adeudos` | 1 archivo (1 uso) |
| 94 | `sp_cambiar_fase` | 1 archivo (1 uso) |
| 95 | `sp_carta_invitacion` | 1 archivo (1 uso) |
| 96 | `sp_change_password` | 1 archivo (1 uso) |
| 97 | `sp_chgpass_historial` | 1 archivo (1 uso) |
| 98 | `sp_cmultemision_search` | 1 archivo (1 uso) |
| 99 | `sp_cmultfolio_search` | 1 archivo (1 uso) |
| 100 | `sp_consultareg_mercados` | 1 archivo (2 usos) |
| 101 | `sp_ejecutores_list` | 1 archivo (2 usos) |
| 102 | `sp_ejecutores_listar` | 1 archivo (1 uso) |
| 103 | `sp_estadisticas_generales` | 1 archivo (1 uso) |
| 104 | `sp_facturacion_list` | 1 archivo (1 uso) |
| 105 | `sp_fases_list` | 1 archivo (1 uso) |
| 106 | `sp_firmaelectronica_listar_folios` | 1 archivo (1 uso) |
| 107 | `sp_get_apremio` | 1 archivo (1 uso) |
| 108 | `sp_get_cons_his` | 1 archivo (1 uso) |
| 109 | `sp_individual_folio_search` | 1 archivo (1 uso) |
| 110 | `sp_lista_eje_get` | 2 archivos (2 usos) |
| 111 | `sp_listados_ade_aseo` | 1 archivo (1 uso) |
| 112 | `sp_listados_ade_exclusivos` | 1 archivo (1 uso) |
| 113 | `sp_listados_ade_infracciones` | 1 archivo (1 uso) |
| 114 | `sp_listados_ade_mercados` | 1 archivo (1 uso) |
| 115 | `sp_listados_ade_publicos` | 1 archivo (1 uso) |
| 116 | `sp_listados_get_listados` | 1 archivo (1 uso) |
| 117 | `sp_listados_sin_adereq` | 1 archivo (1 uso) |
| 118 | `sp_listxfec_report` | 1 archivo (1 uso) |
| 119 | `sp_listxreg_report` | 1 archivo (1 uso) |
| 120 | `sp_modif_masiva_aplicar` | 1 archivo (1 uso) |
| 121 | `sp_modificar_bien` | 1 archivo (1 uso) |
| 122 | `sp_notificaciones_list` | 1 archivo (1 uso) |
| 123 | `sp_prenomina_report` | 1 archivo (1 uso) |
| 124 | `sp_recuperacion_report` | 1 archivo (1 uso) |
| 125 | `sp_report_autorizados` | 1 archivo (1 uso) |
| 126 | `sp_rprt_listax_reg_aseo` | 1 archivo (1 uso) |
| 127 | `spd_12_gastoscob` | 1 archivo (1 uso) |
| 128 | `spd_15_foliospag` | 1 archivo (1 uso) |
| 129 | `spd_15_notif_mes` | 1 archivo (1 uso) |

### Detalle por Stored Procedure:


#### `APREMIOSSVN_APREMIOS_ESTADISTICAS`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Listados_Ade.vue`

#### `APREMIOSSVN_EXPEDIENTES_ESTADISTICAS`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnExpedientes.vue`

#### `APREMIOSSVN_EXPEDIENTES_LIST`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnExpedientes.vue`

#### `APREMIOSSVN_LISTADOS_ADE`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Listados_Ade.vue`

#### `APREMIOSSVN_NOTIFICACIONES_ESTADISTICAS`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnNotificaciones.vue`

#### `APREMIOSSVN_NOTIFICACIONES_LIST`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnNotificaciones.vue`

#### `APREMIOSSVN_PAGOS_ESTADISTICAS`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnPagos.vue`

#### `APREMIOSSVN_PAGOS_LIST`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnPagos.vue`

#### `RECAUDADORA_ACTUALIZA_FECHAS`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ActualizaFechaEmpresas.vue`

#### `RECAUDADORA_APLICA_SDOS_FAVOR`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\AplicaSdosFavor.vue`

#### `RECAUDADORA_AUTDESCTO`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\autdescto.vue`

#### `RECAUDADORA_BLOQCTASREQFRM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\bloqctasreqfrm.vue`

#### `RECAUDADORA_BLOQUEO_MULTA`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\BloqueoMulta.vue`

#### `RECAUDADORA_BUSQUE`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\busque.vue`

#### `RECAUDADORA_CANC`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\canc.vue`

#### `RECAUDADORA_CAPTURA_DIF`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\CapturaDif.vue`

#### `RECAUDADORA_CARTA_INVITACION`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\CartaInvitacion.vue`

#### `RECAUDADORA_CATASTRO_DM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\CatastroDM.vue`

#### `RECAUDADORA_CENTROSFRM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\centrosfrm.vue`

#### `RECAUDADORA_CODIFICAFRM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\codificafrm.vue`

#### `RECAUDADORA_CONSCENTROSFRM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\conscentrosfrm.vue`

#### `RECAUDADORA_CONSDESC`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\consdesc.vue`

#### `RECAUDADORA_CONSULTA_SDOS_FAVOR`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\AplicaSdosFavor.vue`

#### `RECAUDADORA_DESCDERECHOS_MERC`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\DescDerechosMerc.vue`

#### `RECAUDADORA_DRECGO_FOSA`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\DrecgoFosa.vue`

#### `RECAUDADORA_DRECGO_TRANS`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\DrecgoTrans.vue`

#### `RECAUDADORA_EJECUTORES`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Ejecutores.vue`

#### `RECAUDADORA_EMPRESAS`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Empresas.vue`

#### `RECAUDADORA_EXCLUSIVOS_UPD`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Exclusivos_Upd.vue`

#### `RECAUDADORA_EXTRACTOS_RPT`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ExtractosRpt.vue`

#### `RECAUDADORA_FIRMA_ELECTRONICA`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\FirmaElectronica.vue`

#### `RECAUDADORA_FOL_MULTA`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\FolMulta.vue`

#### `RECAUDADORA_GASTOS_TRANSMISION`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\GastosTransmision.vue`

#### `RECAUDADORA_GET_EJECUTORES`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ActualizaFechaEmpresas.vue`

#### `RECAUDADORA_HASTAFRM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Hastafrm.vue`

#### `RECAUDADORA_IMPRIME_DESCTOS`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ImprimeDesctos.vue`

#### `RECAUDADORA_LISTADO_MULTIPLE`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ListadoMultiple.vue`

#### `RECAUDADORA_LISTANA`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ListAna.vue`

#### `RECAUDADORA_LISTA_DIFERENCIAS`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ListaDiferencias.vue`

#### `RECAUDADORA_MODIF_MASIVA`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ModifMasiva.vue`

#### `RECAUDADORA_MULTAS_DM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\MultasDM.vue`

#### `RECAUDADORA_OTORGA_DESCTO`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Otorgadescto.vue`

#### `RECAUDADORA_PAGOS_ESPE`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\PagosEspe.vue`

#### `RECAUDADORA_PARSE_FILE`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ActualizaFechaEmpresas.vue`

#### `RECAUDADORA_PERIODO_INICIAL`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\PeriodoInicial.vue`

#### `RECAUDADORA_PROPUESTATAB`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Propuestatab.vue`

#### `RECAUDADORA_PUBLICOS_UPD`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Publicos_Upd.vue`

#### `RECAUDADORA_REGSECYMAS`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\RegSecyMas.vue`

#### `RECAUDADORA_REP_DESC_IMPTO`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\RepDescImpto.vue`

#### `RECAUDADORA_REP_OPER`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\RepOper.vue`

#### `RECAUDADORA_REQ`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Req.vue`

#### `RECAUDADORA_REQTRANS_CREATE`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ReqTrans.vue`

#### `RECAUDADORA_REQTRANS_DELETE`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ReqTrans.vue`

#### `RECAUDADORA_REQTRANS_LIST`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ReqTrans.vue`

#### `RECAUDADORA_REQTRANS_UPDATE`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ReqTrans.vue`

#### `RECAUDADORA_REQUERIMIENTOS_DM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\RequerimientosDM.vue`

#### `RECAUDADORA_REQUERXCVECAT`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\RequerxCvecat.vue`

#### `RECAUDADORA_REQ_FRM_SAVE`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ReqFrm.vue`

#### `RECAUDADORA_REQ_PROMOCION`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ReqPromocion.vue`

#### `RECAUDADORA_RESOLUCION_JUEZ`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\ResolucionJuez.vue`

#### `RECAUDADORA_SDOSFAVOR_CTRLEXP`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\SdosFavor_CtrlExp.vue`

#### `RECAUDADORA_SDOSFAVOR_DM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\SdosFavorDM.vue`

#### `RECAUDADORA_SDOSFAVOR_PAGOS`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\SdosFavor_Pagos.vue`

#### `RECAUDADORA_SINLIGARFRM`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\SinLigarFrm.vue`

#### `RECAUDADORA_SOL_SDOS_FAVOR`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\SolSdosFavor.vue`

#### `RECAUDADORA_TDM_CONECTION`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\TDMConection.vue`

#### `RECAUDADORA_UBICODIFICA`

- **multas_reglamentos**: `src\views\modules\multas_reglamentos\Ubicodifica.vue`

#### `apremiossvn_apremios_estadisticas`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnActuaciones.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnFases.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnReportes.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\AutorizaDes.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\CartaInvitacion.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\CMultEmision.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\CMultFolio.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ConsultaReg.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Cons_his.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Ejecutores.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\EstadxFolio.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ExportarExcel.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Facturacion.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\FirmaElectronica.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Individual.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Individual_Folio.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Listados.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdeAseoForm.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdeExclusivosForm.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdeInfraccionesForm.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdeMercadosForm.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdePublicosForm.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosSinAdereq.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Lista_Eje.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Lista_GastosCob.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListxFec.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListxReg.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\List_Eje.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Modifcar.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Modificar_bien.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Modif_Masiva.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Notificaciones.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\NotificacionesMes.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Prenomina.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Reasignacion.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Recuperacion.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ReportAutor.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Requerimientos.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtCATAL_EJE.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtEstadxfolio.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListados.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListaxFec.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListaxRegAseo.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListaxRegEstacionometro.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListaxRegMer.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtList_Eje.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptFact_Merc.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptListado_Aseo.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptListaxRegPub.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptLista_mercados.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptPrenomina.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptRecup_Aseo.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptRecup_Merc.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptReq_Aseo.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptReq_Merc.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptReq_pba.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptReq_Pba_Aseo.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\sfrm_chgpass.vue`

#### `apremiossvn_ejecutores_estadisticas`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ABCEjec.vue`

#### `estadxfolio_stats`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\EstadxFolio.vue`

#### `get_individual_folio`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Individual.vue`

#### `rprt_listados`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListados.vue`

#### `rprt_listaxfec`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListaxFec.vue`

#### `rprtlist_eje_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtList_Eje.vue`

#### `rpt_catal_eje`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtCATAL_EJE.vue`

#### `rpt_estadxfolio`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtEstadxfolio.vue`

#### `rpt_lista_mercados`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptLista_mercados.vue`

#### `rpt_listado_aseo`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptListado_Aseo.vue`

#### `rpt_listax_reg_mer`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListaxRegMer.vue`

#### `rpt_listaxreg_estacionometro`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListaxRegEstacionometro.vue`

#### `rpt_listaxregpub_get_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptListaxRegPub.vue`

#### `rpt_prenomina`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptPrenomina.vue`

#### `rptfact_merc_get_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptFact_Merc.vue`

#### `rptrecup_aseo_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptRecup_Aseo.vue`

#### `rptrecup_merc_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptRecup_Merc.vue`

#### `rptreq_aseo_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptReq_Aseo.vue`

#### `rptreq_merc_reporte`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptReq_Merc.vue`

#### `rptreq_pba_aseo_get_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptReq_Pba_Aseo.vue`

#### `rptreq_pba_get_report_data`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RptReq_pba.vue`

#### `sp_actuaciones_list`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnActuaciones.vue`

#### `sp_autorizades_search`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\AutorizaDes.vue`

#### `sp_buscar_folios`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Reasignacion.vue`

#### `sp_buscar_mercados_adeudos`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Requerimientos.vue`

#### `sp_cambiar_fase`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnFases.vue`

#### `sp_carta_invitacion`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\CartaInvitacion.vue`

#### `sp_change_password`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\sfrm_chgpass.vue`

#### `sp_chgpass_historial`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\sfrm_chgpass.vue`

#### `sp_cmultemision_search`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\CMultEmision.vue`

#### `sp_cmultfolio_search`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\CMultFolio.vue`

#### `sp_consultareg_mercados`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ConsultaReg.vue`

#### `sp_ejecutores_list`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ABCEjec.vue`

#### `sp_ejecutores_listar`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Ejecutores.vue`

#### `sp_estadisticas_generales`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnReportes.vue`

#### `sp_facturacion_list`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Facturacion.vue`

#### `sp_fases_list`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ApremiosSvnFases.vue`

#### `sp_firmaelectronica_listar_folios`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\FirmaElectronica.vue`

#### `sp_get_apremio`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Modifcar.vue`

#### `sp_get_cons_his`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Cons_his.vue`

#### `sp_individual_folio_search`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Individual_Folio.vue`

#### `sp_lista_eje_get`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Lista_Eje.vue`
- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\List_Eje.vue`

#### `sp_listados_ade_aseo`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdeAseoForm.vue`

#### `sp_listados_ade_exclusivos`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdeExclusivosForm.vue`

#### `sp_listados_ade_infracciones`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdeInfraccionesForm.vue`

#### `sp_listados_ade_mercados`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdeMercadosForm.vue`

#### `sp_listados_ade_publicos`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosAdePublicosForm.vue`

#### `sp_listados_get_listados`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Listados.vue`

#### `sp_listados_sin_adereq`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListadosSinAdereq.vue`

#### `sp_listxfec_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListxFec.vue`

#### `sp_listxreg_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ListxReg.vue`

#### `sp_modif_masiva_aplicar`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Modif_Masiva.vue`

#### `sp_modificar_bien`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Modificar_bien.vue`

#### `sp_notificaciones_list`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Notificaciones.vue`

#### `sp_prenomina_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Prenomina.vue`

#### `sp_recuperacion_report`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Recuperacion.vue`

#### `sp_report_autorizados`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ReportAutor.vue`

#### `sp_rprt_listax_reg_aseo`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\RprtListaxRegAseo.vue`

#### `spd_12_gastoscob`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\Lista_GastosCob.vue`

#### `spd_15_foliospag`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\ExportarExcel.vue`

#### `spd_15_notif_mes`

- **estacionamiento_exclusivo**: `src\views\modules\estacionamiento_exclusivo\NotificacionesMes.vue`

---

## 🎯 VERIFICACIÓN POR MÓDULO


### ✅ estacionamiento_exclusivo

- Base de datos esperada: `estacionamiento_exclusivo`
- Esquema: `public`
- Conexiones correctas: 63
- Conexiones incorrectas: 0
- Advertencias: 0

### ✅ padron_licencias

- Base de datos esperada: `padron_licencias`
- Esquema: `public`
- Conexiones correctas: 0
- Conexiones incorrectas: 0
- Advertencias: 0

### ✅ cementerios

- Base de datos esperada: `cementerios`
- Esquema: `public`
- Conexiones correctas: 0
- Conexiones incorrectas: 0
- Advertencias: 0

### ✅ otras_obligaciones

- Base de datos esperada: `otras_obligaciones`
- Esquema: `public`
- Conexiones correctas: 0
- Conexiones incorrectas: 0
- Advertencias: 0

### ✅ multas_reglamentos

- Base de datos esperada: `multas_reglamentos`
- Esquema: `public`
- Conexiones correctas: 105
- Conexiones incorrectas: 0
- Advertencias: 0

---

## 🔧 RECOMENDACIONES


✅ **¡Sistema Verificado!**

- Todas las conexiones apuntan a PostgreSQL
- No hay referencias a INFORMIX
- Los módulos usan las bases de datos correctas
- El sistema está listo para producción

### Próximo paso:

Ejecutar el script de verificación de Stored Procedures para confirmar que todos los SPs existen en la base de datos.

```bash
node scripts/verify-stored-procedures.cjs
```

---

## 📈 ESTADÍSTICAS ADICIONALES

- **Promedio de SPs por archivo**: 0.77
- **Módulos analizados**: 5
- **Cobertura de análisis**: 28.3%

---

**Generado por**: RefactorX Audit System
**Versión**: 1.0.0
