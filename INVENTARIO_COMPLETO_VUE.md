# 📋 Inventario Completo de Archivos Vue.js - RefactorX Guadalajara

## Resumen Ejecutivo

| Sistema | Archivos Vue | Ubicación | Prioridad | Dev Asignado |
|---------|--------------|-----------|-----------|--------------|
| **Distribución** | 0 (crear) | N/A | 🟢 BAJA | Dev1 - Lunes AM |
| **Cementerios** | 36 | RefactorX/Base/cementerios/vue/ | 🟢 BAJA | Dev1 - Lunes PM |
| **Aseo Contratado** | 103 | RefactorX/Base/aseo_contratado/vue/ | 🟢 BAJA | Dev1 - Martes |
| **Mercados** | 107 | RefactorX/Base/mercados/vue/ | 🟡 MEDIA | Dev1 - Martes-Miércoles |
| **Otras Obligaciones** | 27 | RefactorX/Base/otras_obligaciones/vue/ | 🟡 MEDIA | Dev1 - Miércoles AM |
| **Padrón Licencias** | 97 | RefactorX/Base/padron_licencias/vue/ | 🔴 ALTA | Dev2 - Miércoles |
| **Multas y Reglamentos** | 106 | RefactorX/Base/multas_reglamentos/vue/ | 🔴 ALTA | Dev2 - Jueves |
| **Estacionamiento Exclusivo** | 61 | RefactorX/Base/estacionamiento_exclusivo/vue/ | 🟡 MEDIA | Dev2 - Jueves PM |
| **Estacionamiento Público** | 61 | RefactorX/Base/estacionamiento_publico/vue/ | 🟡 MEDIA | Dev1+Dev2 - Viernes |
| **TOTAL** | **598** | - | - | **5 días** |

---

## 1️⃣ Sistema: Distribución (0 archivos - CREAR DESDE CERO)

**📍 Ubicación destino:** `RefactorX/FrontEnd/src/modules/distribucion/`
**🎯 Prioridad:** 🟢 BAJA
**👤 Asignado:** Dev1 - Lunes 9:00-12:00 (3 horas)
**📦 Archivos a crear:** 15 archivos nuevos

### Estructura de carpetas:
```
RefactorX/FrontEnd/src/modules/distribucion/
├── views/
│   ├── DistribucionList.vue
│   ├── DistribucionForm.vue
│   └── DistribucionDetail.vue
├── components/
│   ├── DistribucionFilters.vue
│   ├── DistribucionTable.vue
│   └── DistribucionCard.vue
├── stores/
│   └── distribucion.store.js
├── router/
│   └── index.js
├── utils/
│   ├── distribucion.utils.js
│   └── validations.js
└── composables/
    ├── useDistribucion.js
    └── useDistribucionFilters.js
```

**IMPORTANTE:**
- ❌ NO crear servicios individuales (distribucion.service.js)
- ✅ Usar SOLO el servicio API genérico: `@/services/api.service.js`
- ✅ Todos los componentes Vue llaman directamente a `apiService.executeSystemSP('distribucion', 'sp_nombre', params)`

---

## 2️⃣ Sistema: Cementerios (36 archivos)

**📍 Ubicación:** `RefactorX/Base/cementerios/vue/`
**🎯 Prioridad:** 🟢 BAJA
**👤 Asignado:** Dev1 - Lunes 13:00-18:00 (5 horas)
**📦 Total archivos:** 36

### Lista completa de archivos:

1. ABCementer.vue
2. ABCFolio.vue
3. ABCPagos.vue
4. ABCPagosxfol.vue
5. ABCRecargos.vue
6. Acceso.vue
7. Bonificacion1.vue
8. Bonificaciones.vue
9. ConIndividual.vue
10. consulta400.vue
11. ConsultaFol.vue
12. ConsultaGuad.vue
13. ConsultaJardin.vue
14. ConsultaMezq.vue
15. ConsultaNombre.vue
16. ConsultaRCM.vue
17. ConsultaSAndres.vue
18. Descuentos.vue
19. Duplicados.vue
20. Estad_adeudo.vue
21. Liquidaciones.vue
22. List_Mov.vue
23. Menu.vue
24. Modulo.vue
25. Multiplefecha.vue
26. MultipleNombre.vue
27. MultipleRCM.vue
28. Rep_a_Cobrar.vue
29. Rep_Bon.vue
30. RptTitulos.vue
31. sfrm_chgpass.vue
32. Titulos.vue
33. TitulosSin.vue
34. TrasladoFol.vue
35. TrasladoFolSin.vue
36. Traslados.vue

### Categorización por tipo:

**ABCs / Mantenimiento (5):**
- ABCementer.vue
- ABCFolio.vue
- ABCPagos.vue
- ABCPagosxfol.vue
- ABCRecargos.vue

**Consultas (10):**
- ConIndividual.vue
- consulta400.vue
- ConsultaFol.vue
- ConsultaGuad.vue
- ConsultaJardin.vue
- ConsultaMezq.vue
- ConsultaNombre.vue
- ConsultaRCM.vue
- ConsultaSAndres.vue
- Estad_adeudo.vue

**Reportes (3):**
- Rep_a_Cobrar.vue
- Rep_Bon.vue
- RptTitulos.vue

**Procesos (10):**
- Bonificacion1.vue
- Bonificaciones.vue
- Descuentos.vue
- Duplicados.vue
- Liquidaciones.vue
- Multiplefecha.vue
- MultipleNombre.vue
- MultipleRCM.vue
- TrasladoFol.vue
- TrasladoFolSin.vue

**Otros (8):**
- Acceso.vue
- List_Mov.vue
- Menu.vue
- Modulo.vue
- sfrm_chgpass.vue
- Titulos.vue
- TitulosSin.vue
- Traslados.vue

---

## 3️⃣ Sistema: Aseo Contratado (103 archivos)

**📍 Ubicación:** `RefactorX/Base/aseo_contratado/vue/`
**🎯 Prioridad:** 🟢 BAJA
**👤 Asignado:** Dev1 - Martes completo (8 horas)
**📦 Total archivos:** 103

### Lista completa (ordenada alfabéticamente):

1. ABC_Cves_Operacion.vue
2. ABC_Empresas.vue
3. ABC_Gastos.vue
4. ABC_Recargos.vue
5. ABC_Recaudadoras.vue
6. ABC_Tipos_Aseo.vue
7. ABC_Tipos_Emp.vue
8. ABC_Und_Recolec.vue
9. ABC_Zonas.vue
10. ActCont_CR.vue
11. Adeudos_Carga.vue
12. Adeudos_EdoCta.vue
13. Adeudos_Ins.vue
14. Adeudos_Nvo.vue
15. Adeudos_OpcMult.vue
16. Adeudos_Pag.vue
17. Adeudos_PagMult.vue
18. Adeudos_PagUpdPer.vue
19. Adeudos_UpdExed.vue
20. Adeudos_Venc.vue
21. AdeudosCN_Cond.vue
22. AdeudosEst.vue
23. AdeudosExe_Del.vue
24. AdeudosMult_Ins.vue
25. AplicaMultasNormal.vue
26. Cons_Cves_operacion.vue
27. Cons_Empresas.vue
28. Cons_Tipos_Aseo.vue
29. Cons_Tipos_Emp.vue
30. Cons_Und_Recolec.vue
31. Cons_Zonas.vue
32. Contratos.vue
33. Contratos_Adeudos.vue
34. Contratos_Cancela.vue
35. Contratos_Cons.vue
36. Contratos_Cons_Admin.vue
37. Contratos_Cons_Cont.vue
38. Contratos_Cons_ContAsc.vue
39. Contratos_Cons_Dom.vue
40. Contratos_Consulta.vue
41. Contratos_Del.vue
42. Contratos_EstGral.vue
43. Contratos_EstGral2.vue
44. Contratos_Ins.vue
45. Contratos_Ins_b.vue
46. Contratos_Upd.vue
47. Contratos_Upd_01.vue
48. Contratos_Upd_IniObl.vue
49. Contratos_Upd_Periodo.vue
50. Contratos_Upd_Und.vue
51. Contratos_Upd_UndC.vue
52. Contratos_UpdxCont.vue
53. ContratosEst.vue
54. Ctrol_Imp_Cat.vue
55. DatosConvenio.vue
56. Dscto_p_pago.vue
57. Ejercicios_Ins.vue
58. Empresas_Contratos.vue
59. frmRep_Und_Recolec.vue
60. Licencias_Relacionadas.vue
61. Mannto_Empresas.vue
62. Mannto_Gastos.vue
63. Mannto_Operaciones.vue
64. Mannto_Recargos.vue
65. Mannto_Recaudadoras.vue
66. Mannto_Tipos_Aseo.vue
67. Mannto_Tipos_Emp.vue
68. Mannto_Und_Recolec.vue
69. Mannto_Zonas.vue
70. Menu.vue
71. Pagos_Con_FPgo.vue
72. Pagos_Cons_Cont.vue
73. Pagos_Cons_ContAsc.vue
74. Prueba.vue
75. Rep_AdeudCond.vue
76. Rep_Adeudos.vue
77. Rep_Contratos.vue
78. Rep_Empresas.vue
79. Rep_PadronContratos.vue
80. Rep_Recaudadoras.vue
81. Rep_Tipos_Aseo.vue
82. Rep_Tipos_Emp.vue
83. Rep_Zonas.vue
84. ReqsCons.vue
85. sDM_Procesos.vue
86. sQRptAdeudos.vue
87. sQRptAdeudosCond.vue
88. sQRptAdeudosVenc.vue
89. sQRptContratos.vue
90. sQRptContratos_Det.vue
91. sQRptContratos_Est.vue
92. sQRptContratos_EstGral.vue
93. sQRptCves_Operacion.vue
94. sQRptEmpresas.vue
95. sQRptPagosXContrato.vue
96. sQRptRecaudadoras.vue
97. sQRptTipos_Aseo.vue
98. sQRptTipos_Empresas.vue
99. sQRptUnd_Recolec.vue
100. sQRptZonas.vue
101. uDM_Procesos.vue
102. unAcceso.vue
103. Unit1.vue

### Categorización por funcionalidad:

**ABCs / Catálogos (9):**
- ABC_Cves_Operacion.vue
- ABC_Empresas.vue
- ABC_Gastos.vue
- ABC_Recargos.vue
- ABC_Recaudadoras.vue
- ABC_Tipos_Aseo.vue
- ABC_Tipos_Emp.vue
- ABC_Und_Recolec.vue
- ABC_Zonas.vue

**Adeudos (14):**
- Adeudos_Carga.vue
- Adeudos_EdoCta.vue
- Adeudos_Ins.vue
- Adeudos_Nvo.vue
- Adeudos_OpcMult.vue
- Adeudos_Pag.vue
- Adeudos_PagMult.vue
- Adeudos_PagUpdPer.vue
- Adeudos_UpdExed.vue
- Adeudos_Venc.vue
- AdeudosCN_Cond.vue
- AdeudosEst.vue
- AdeudosExe_Del.vue
- AdeudosMult_Ins.vue

**Contratos (23):**
- Contratos.vue
- Contratos_Adeudos.vue
- Contratos_Cancela.vue
- Contratos_Cons.vue
- Contratos_Cons_Admin.vue
- Contratos_Cons_Cont.vue
- Contratos_Cons_ContAsc.vue
- Contratos_Cons_Dom.vue
- Contratos_Consulta.vue
- Contratos_Del.vue
- Contratos_EstGral.vue
- Contratos_EstGral2.vue
- Contratos_Ins.vue
- Contratos_Ins_b.vue
- Contratos_Upd.vue
- Contratos_Upd_01.vue
- Contratos_Upd_IniObl.vue
- Contratos_Upd_Periodo.vue
- Contratos_Upd_Und.vue
- Contratos_Upd_UndC.vue
- Contratos_UpdxCont.vue
- ContratosEst.vue
- Empresas_Contratos.vue

**Consultas (6):**
- Cons_Cves_operacion.vue
- Cons_Empresas.vue
- Cons_Tipos_Aseo.vue
- Cons_Tipos_Emp.vue
- Cons_Und_Recolec.vue
- Cons_Zonas.vue

**Mantenimiento (9):**
- Mannto_Empresas.vue
- Mannto_Gastos.vue
- Mannto_Operaciones.vue
- Mannto_Recargos.vue
- Mannto_Recaudadoras.vue
- Mannto_Tipos_Aseo.vue
- Mannto_Tipos_Emp.vue
- Mannto_Und_Recolec.vue
- Mannto_Zonas.vue

**Pagos (3):**
- Pagos_Con_FPgo.vue
- Pagos_Cons_Cont.vue
- Pagos_Cons_ContAsc.vue

**Reportes (19):**
- Rep_AdeudCond.vue
- Rep_Adeudos.vue
- Rep_Contratos.vue
- Rep_Empresas.vue
- Rep_PadronContratos.vue
- Rep_Recaudadoras.vue
- Rep_Tipos_Aseo.vue
- Rep_Tipos_Emp.vue
- Rep_Zonas.vue
- sQRptAdeudos.vue
- sQRptAdeudosCond.vue
- sQRptAdeudosVenc.vue
- sQRptContratos.vue
- sQRptContratos_Det.vue
- sQRptContratos_Est.vue
- sQRptContratos_EstGral.vue
- sQRptCves_Operacion.vue
- sQRptEmpresas.vue
- sQRptPagosXContrato.vue

**Otros (20):**
- ActCont_CR.vue
- AplicaMultasNormal.vue
- Ctrol_Imp_Cat.vue
- DatosConvenio.vue
- Dscto_p_pago.vue
- Ejercicios_Ins.vue
- frmRep_Und_Recolec.vue
- Licencias_Relacionadas.vue
- Menu.vue
- Prueba.vue
- ReqsCons.vue
- sDM_Procesos.vue
- sQRptRecaudadoras.vue
- sQRptTipos_Aseo.vue
- sQRptTipos_Empresas.vue
- sQRptUnd_Recolec.vue
- sQRptZonas.vue
- uDM_Procesos.vue
- unAcceso.vue
- Unit1.vue

---

## 4️⃣ Sistema: Mercados (107 archivos)

**📍 Ubicación:** `RefactorX/Base/mercados/vue/`
**🎯 Prioridad:** 🟡 MEDIA
**👤 Asignado:** Dev1 - Martes PM + Miércoles AM (12 horas)
**📦 Total archivos:** 107

### Lista completa (ordenada alfabéticamente):

1. Acceso.vue
2. AdeEnergiaGrl.vue
3. AdeGlobalLocales.vue
4. AdeudosEnergia.vue
5. AdeudosLocales.vue
6. AdeudosLocGrl.vue
7. AltaPagos.vue
8. AltaPagosEnergia.vue
9. AutCargaPagos.vue
10. AutCargaPagosMtto.vue
11. CargaDiversosEsp.vue
12. CargaPagEnergia.vue
13. CargaPagEnergiaElec.vue
14. CargaPagEspecial.vue
15. CargaPagLocales.vue
16. CargaPagMercado.vue
17. CargaPagosTexto.vue
18. CargaReqPagados.vue
19. CargaTCultural.vue
20. CatalogoMercados.vue
21. CatalogoMntto.vue
22. Categoria.vue
23. CategoriaMntto.vue
24. Condonacion.vue
25. ConsCapturaEnergia.vue
26. ConsCapturaFecha.vue
27. ConsCapturaFechaEnergia.vue
28. ConsCapturaMerc.vue
29. ConsCondonacion.vue
30. ConsCondonacionEnergia.vue
31. ConsPagos.vue
32. ConsPagosEnergia.vue
33. ConsPagosLocales.vue
34. ConsRequerimientos.vue
35. ConsultaDatosEnergia.vue
36. ConsultaDatosLocales.vue
37. ConsultaGeneral.vue
38. CuentaPublica.vue
39. CuotasEnergia.vue
40. CuotasEnergiaMntto.vue
41. CuotasMdo.vue
42. CuotasMdoMntto.vue
43. CveCuota.vue
44. CveCuotaMntto.vue
45. CveDiferencias.vue
46. CveDiferMntto.vue
47. DatosConvenio.vue
48. DatosIndividuales.vue
49. DatosMovimientos.vue
50. DatosRequerimientos.vue
51. EmisionEnergia.vue
52. EmisionLibertad.vue
53. EmisionLocales.vue
54. EnergiaModif.vue
55. EnergiaMtto.vue
56. Estadisticas.vue
57. EstadPagosyAdeudos.vue
58. FechaDescuento.vue
59. FechasDescuentoMntto.vue
60. IngresoCaptura.vue
61. IngresoLib.vue
62. ListadosLocales.vue
63. LocalesModif.vue
64. LocalesMtto.vue
65. Menu.vue
66. ModuloBD.vue
67. PadronEnergia.vue
68. PadronGlobal.vue
69. PadronLocales.vue
70. PagosDifIngresos.vue
71. PagosEneCons.vue
72. PagosIndividual.vue
73. PagosLocGrl.vue
74. PasoAdeudos.vue
75. PasoEne.vue
76. PasoMdos.vue
77. Prescripcion.vue
78. Recargos.vue
79. RecargosMntto.vue
80. RprtSalvadas.vue
81. RptAdeEnergiaGrl.vue
82. RptAdeudosAbastos1998.vue
83. RptAdeudosAnteriores.vue
84. RptAdeudosEnergia.vue
85. RptAdeudosLocales.vue
86. RptCaratulaDatos.vue
87. RptCaratulaEnergia.vue
88. RptCatalogoMerc.vue
89. RptCuentaPublica.vue
90. RptDesgloceAdeporImporte.vue
91. RptEmisionEnergia.vue
92. RptEmisionLaser.vue
93. RptEmisionLocales.vue
94. RptEmisionRbosAbastos.vue
95. RptEstadisticaAdeudos.vue
96. RptEstadPagosyAdeudos.vue
97. RptFacturaEmision.vue
98. RptFacturaEnergia.vue
99. RptIngresoZonificado.vue
100. RptMovimientos.vue
101. RptPadronEnergia.vue
102. RptPadronGlobal.vue
103. RptPadronLocales.vue
104. RptPagosLocales.vue
105. Secciones.vue
106. SeccionesMntto.vue
107. TrDocumentos.vue

### Categorización por funcionalidad:

**Adeudos (6):**
- AdeEnergiaGrl.vue
- AdeGlobalLocales.vue
- AdeudosEnergia.vue
- AdeudosLocales.vue
- AdeudosLocGrl.vue
- EstadPagosyAdeudos.vue

**Pagos y Carga (15):**
- AltaPagos.vue
- AltaPagosEnergia.vue
- AutCargaPagos.vue
- AutCargaPagosMtto.vue
- CargaDiversosEsp.vue
- CargaPagEnergia.vue
- CargaPagEnergiaElec.vue
- CargaPagEspecial.vue
- CargaPagLocales.vue
- CargaPagMercado.vue
- CargaPagosTexto.vue
- CargaReqPagados.vue
- CargaTCultural.vue
- PagosDifIngresos.vue
- PagosEneCons.vue

**Catálogos y Mantenimiento (12):**
- CatalogoMercados.vue
- CatalogoMntto.vue
- Categoria.vue
- CategoriaMntto.vue
- CuotasEnergia.vue
- CuotasEnergiaMntto.vue
- CuotasMdo.vue
- CuotasMdoMntto.vue
- CveCuota.vue
- CveCuotaMntto.vue
- CveDiferencias.vue
- CveDiferMntto.vue

**Consultas (13):**
- ConsCapturaEnergia.vue
- ConsCapturaFecha.vue
- ConsCapturaFechaEnergia.vue
- ConsCapturaMerc.vue
- ConsCondonacion.vue
- ConsCondonacionEnergia.vue
- ConsPagos.vue
- ConsPagosEnergia.vue
- ConsPagosLocales.vue
- ConsRequerimientos.vue
- ConsultaDatosEnergia.vue
- ConsultaDatosLocales.vue
- ConsultaGeneral.vue

**Emisión (3):**
- EmisionEnergia.vue
- EmisionLibertad.vue
- EmisionLocales.vue

**Padrón (3):**
- PadronEnergia.vue
- PadronGlobal.vue
- PadronLocales.vue

**Reportes (29):**
- RprtSalvadas.vue
- RptAdeEnergiaGrl.vue
- RptAdeudosAbastos1998.vue
- RptAdeudosAnteriores.vue
- RptAdeudosEnergia.vue
- RptAdeudosLocales.vue
- RptCaratulaDatos.vue
- RptCaratulaEnergia.vue
- RptCatalogoMerc.vue
- RptCuentaPublica.vue
- RptDesgloceAdeporImporte.vue
- RptEmisionEnergia.vue
- RptEmisionLaser.vue
- RptEmisionLocales.vue
- RptEmisionRbosAbastos.vue
- RptEstadisticaAdeudos.vue
- RptEstadPagosyAdeudos.vue
- RptFacturaEmision.vue
- RptFacturaEnergia.vue
- RptIngresoZonificado.vue
- RptMovimientos.vue
- RptPadronEnergia.vue
- RptPadronGlobal.vue
- RptPadronLocales.vue
- RptPagosLocales.vue

**Otros (26):**
- Acceso.vue
- Condonacion.vue
- CuentaPublica.vue
- DatosConvenio.vue
- DatosIndividuales.vue
- DatosMovimientos.vue
- DatosRequerimientos.vue
- EnergiaModif.vue
- EnergiaMtto.vue
- Estadisticas.vue
- FechaDescuento.vue
- FechasDescuentoMntto.vue
- IngresoCaptura.vue
- IngresoLib.vue
- ListadosLocales.vue
- LocalesModif.vue
- LocalesMtto.vue
- Menu.vue
- ModuloBD.vue
- PagosIndividual.vue
- PagosLocGrl.vue
- PasoAdeudos.vue
- PasoEne.vue
- PasoMdos.vue
- Prescripcion.vue
- Recargos.vue
- RecargosMntto.vue
- Secciones.vue
- SeccionesMntto.vue
- TrDocumentos.vue

---

## 5️⃣ Sistema: Otras Obligaciones (27 archivos)

**📍 Ubicación:** `RefactorX/Base/otras_obligaciones/vue/`
**🎯 Prioridad:** 🟡 MEDIA
**👤 Asignado:** Dev1 - Miércoles PM (4 horas)
**📦 Total archivos:** 27

### Lista completa (ordenada alfabéticamente):

1. Apremios.vue
2. AuxRep.vue
3. CargaCartera.vue
4. CargaValores.vue
5. Etiquetas.vue
6. GActualiza.vue
7. GAdeudos.vue
8. GAdeudos_OpcMult.vue
9. GAdeudos_OpcMult_RA.vue
10. GAdeudosGral.vue
11. GBaja.vue
12. GConsulta.vue
13. GConsulta2.vue
14. GFacturacion.vue
15. GNuevos.vue
16. GRep_Padron.vue
17. Menu.vue
18. RActualiza.vue
19. RAdeudos.vue
20. RAdeudos_OpcMult.vue
21. RBaja.vue
22. RConsulta.vue
23. RFacturacion.vue
24. RNuevos.vue
25. RPagados.vue
26. RRep_Padron.vue
27. Rubros.vue

### Categorización por funcionalidad:

**Grupo G - Generales (10):**
- GActualiza.vue
- GAdeudos.vue
- GAdeudos_OpcMult.vue
- GAdeudos_OpcMult_RA.vue
- GAdeudosGral.vue
- GBaja.vue
- GConsulta.vue
- GConsulta2.vue
- GFacturacion.vue
- GNuevos.vue
- GRep_Padron.vue

**Grupo R - Rubros específicos (7):**
- RActualiza.vue
- RAdeudos.vue
- RAdeudos_OpcMult.vue
- RBaja.vue
- RConsulta.vue
- RFacturacion.vue
- RNuevos.vue
- RPagados.vue
- RRep_Padron.vue

**Otros (9):**
- Apremios.vue
- AuxRep.vue
- CargaCartera.vue
- CargaValores.vue
- Etiquetas.vue
- Menu.vue
- Rubros.vue

---

## 6️⃣ Sistema: Padrón Licencias (97 archivos)

**📍 Ubicación:** `RefactorX/Base/padron_licencias/vue/`
**🎯 Prioridad:** 🔴 ALTA
**👤 Asignado:** Dev2 - Miércoles completo (8 horas)
**📦 Total archivos:** 97

### Lista completa (ordenada alfabéticamente):

1. Agendavisitasfrm.vue
2. bajaAnunciofrm.vue
3. bajaLicenciafrm.vue
4. BloquearAnunciorm.vue
5. BloquearLicenciafrm.vue
6. BloquearTramitefrm.vue
7. bloqueoDomiciliosfrm.vue
8. bloqueoRFCfrm.vue
9. buscagirofrm.vue
10. busque.vue
11. BusquedaActividadFrm.vue
12. BusquedaScianFrm.vue
13. cancelaTramitefrm.vue
14. carga.vue
15. carga_imagen.vue
16. cargadatosfrm.vue
17. cartonva.vue
18. CatalogoActividadesFrm.vue
19. catalogogirosfrm.vue
20. CatastroDM.vue
21. CatRequisitos.vue
22. certificacionesfrm.vue
23. consAnun400frm.vue
24. consLic400frm.vue
25. constanciafrm.vue
26. constanciaNoOficialfrm.vue
27. consultaAnunciofrm.vue
28. consultaLicenciafrm.vue
29. consultapredial.vue
30. ConsultaTramitefrm.vue
31. consultausuariosfrm.vue
32. Cruces.vue
33. dependenciasFrm.vue
34. dictamenfrm.vue
35. dictamenusodesuelo.vue
36. doctosfrm.vue
37. empresasfrm.vue
38. estatusfrm.vue
39. fechasegfrm.vue
40. firma.vue
41. firmausuario.vue
42. formabuscalle.vue
43. formabuscolonia.vue
44. formatosEcologiafrm.vue
45. frmImpLicenciaReglamentada.vue
46. frmselcalle.vue
47. gestionHologramasfrm.vue
48. GirosDconAdeudofrm.vue
49. girosVigentesCteXgirofrm.vue
50. grs_dlg.vue
51. GruposAnunciosAbcfrm.vue
52. gruposAnunciosfrm.vue
53. GruposLicenciasAbcfrm.vue
54. gruposLicenciasfrm.vue
55. h_bloqueoDomiciliosfrm.vue
56. Hastafrm.vue
57. ImpLicenciaReglamentadaFrm.vue
58. ImpOficiofrm.vue
59. ImpRecibofrm.vue
60. impsolinspeccionfrm.vue
61. LicenciasVigentesfrm.vue
62. ligaAnunciofrm.vue
63. LigaRequisitos.vue
64. modlicAdeudofrm.vue
65. modlicfrm.vue
66. modtramitefrm.vue
67. observacionfrm.vue
68. prepagofrm.vue
69. privilegios.vue
70. prophologramasfrm.vue
71. Propuestatab.vue
72. psplash.vue
73. ReactivaTramite.vue
74. regHfrm.vue
75. RegistroSolicitudForm.vue
76. regsolicfrm.vue
77. regsolicfrm_manual.vue
78. repdoc.vue
79. repEstadisticosLicfrm.vue
80. repestado.vue
81. ReporteAnunExcelfrm.vue
82. repsuspendidasfrm.vue
83. Responsivafrm.vue
84. revisionesfrm.vue
85. Semaforo.vue
86. sfrm_chgfirma.vue
87. sfrm_chgpass.vue
88. SGCv2.vue
89. splash.vue
90. TDMConection.vue
91. tipobloqueofrm.vue
92. TramiteBajaAnun.vue
93. TramiteBajaLic.vue
94. UnidadImg.vue
95. webBrowser.vue
96. ZonaAnuncio.vue
97. ZonaLicencia.vue

### Categorización por funcionalidad:

**Bajas y Bloqueos (8):**
- bajaAnunciofrm.vue
- bajaLicenciafrm.vue
- BloquearAnunciorm.vue
- BloquearLicenciafrm.vue
- BloquearTramitefrm.vue
- bloqueoDomiciliosfrm.vue
- bloqueoRFCfrm.vue
- h_bloqueoDomiciliosfrm.vue

**Búsquedas (5):**
- buscagirofrm.vue
- busque.vue
- BusquedaActividadFrm.vue
- BusquedaScianFrm.vue
- formabuscalle.vue
- formabuscolonia.vue
- frmselcalle.vue

**Catálogos (7):**
- CatalogoActividadesFrm.vue
- catalogogirosfrm.vue
- CatastroDM.vue
- CatRequisitos.vue
- dependenciasFrm.vue
- doctosfrm.vue
- empresasfrm.vue

**Consultas (10):**
- consAnun400frm.vue
- consLic400frm.vue
- consultaAnunciofrm.vue
- consultaLicenciafrm.vue
- consultapredial.vue
- ConsultaTramitefrm.vue
- consultausuariosfrm.vue
- GirosDconAdeudofrm.vue
- girosVigentesCteXgirofrm.vue
- LicenciasVigentesfrm.vue

**Trámites y Solicitudes (8):**
- cancelaTramitefrm.vue
- modtramitefrm.vue
- ReactivaTramite.vue
- RegistroSolicitudForm.vue
- regsolicfrm.vue
- regsolicfrm_manual.vue
- TramiteBajaAnun.vue
- TramiteBajaLic.vue

**Grupos (4):**
- GruposAnunciosAbcfrm.vue
- gruposAnunciosfrm.vue
- GruposLicenciasAbcfrm.vue
- gruposLicenciasfrm.vue

**Impresión (5):**
- frmImpLicenciaReglamentada.vue
- ImpLicenciaReglamentadaFrm.vue
- ImpOficiofrm.vue
- ImpRecibofrm.vue
- impsolinspeccionfrm.vue

**Reportes (5):**
- repdoc.vue
- repEstadisticosLicfrm.vue
- repestado.vue
- ReporteAnunExcelfrm.vue
- repsuspendidasfrm.vue

**Licencias y Anuncios (6):**
- ligaAnunciofrm.vue
- LigaRequisitos.vue
- modlicAdeudofrm.vue
- modlicfrm.vue
- ZonaAnuncio.vue
- ZonaLicencia.vue

**Hologramas (2):**
- gestionHologramasfrm.vue
- prophologramasfrm.vue

**Otros (37):**
- Agendavisitasfrm.vue
- carga.vue
- carga_imagen.vue
- cargadatosfrm.vue
- cartonva.vue
- certificacionesfrm.vue
- constanciafrm.vue
- constanciaNoOficialfrm.vue
- Cruces.vue
- dictamenfrm.vue
- dictamenusodesuelo.vue
- estatusfrm.vue
- fechasegfrm.vue
- firma.vue
- firmausuario.vue
- formatosEcologiafrm.vue
- grs_dlg.vue
- Hastafrm.vue
- observacionfrm.vue
- prepagofrm.vue
- privilegios.vue
- Propuestatab.vue
- psplash.vue
- regHfrm.vue
- Responsivafrm.vue
- revisionesfrm.vue
- Semaforo.vue
- sfrm_chgfirma.vue
- sfrm_chgpass.vue
- SGCv2.vue
- splash.vue
- TDMConection.vue
- tipobloqueofrm.vue
- UnidadImg.vue
- webBrowser.vue

---

## 7️⃣ Sistema: Multas y Reglamentos (106 archivos)

**📍 Ubicación:** `RefactorX/Base/multas_reglamentos/vue/`
**🎯 Prioridad:** 🔴 ALTA
**👤 Asignado:** Dev2 - Jueves AM (8 horas)
**📦 Total archivos:** 106

### Lista completa (ordenada alfabéticamente):

1. ActualizaFechaEmpresas.vue
2. AplicaSdosFavor.vue
3. autdescto.vue
4. bloqctasreqfrm.vue
5. BloqueoMulta.vue
6. busque.vue
7. canc.vue
8. CapturaDif.vue
9. CartaInvitacion.vue
10. CatastroDM.vue
11. centrosfrm.vue
12. codificafrm.vue
13. conscentrosfrm.vue
14. consdesc.vue
15. consescrit400.vue
16. consmulpagos.vue
17. consobsmulfrm.vue
18. ConsReq400.vue
19. consultapredial.vue
20. dderechosLic.vue
21. DescDerechosMerc.vue
22. descmultampalfrm.vue
23. descpredfrm.vue
24. desctorec.vue
25. DrecgoFosa.vue
26. drecgoLic.vue
27. drecgoOtrasObligaciones.vue
28. DrecgoTrans.vue
29. Ejecutores.vue
30. Empresas.vue
31. entregafrm.vue
32. estadreq.vue
33. Exclusivos_Upd.vue
34. ExtractosRpt.vue
35. FirmaElectronica.vue
36. FolMulta.vue
37. FrmEje.vue
38. frmpol.vue
39. GastosTransmision.vue
40. Hastafrm.vue
41. impreqCvecat.vue
42. ImpresionNva.vue
43. ImprimeDesctos.vue
44. ipor.vue
45. leyesfrm.vue
46. LicenciaMicrogenerador.vue
47. LicenciaMicrogeneradorEcologia.vue
48. ligapago.vue
49. ligapagoTra.vue
50. ListaDiferencias.vue
51. ListadoMultiple.vue
52. ListAna.vue
53. listanotificacionesfrm.vue
54. listareq.vue
55. listchq.vue
56. listdesctomultafrm.vue
57. ModifMasiva.vue
58. multas400frm.vue
59. MultasDM.vue
60. multasfrm.vue
61. multasfrmcalif.vue
62. newsfrm.vue
63. Otorgadescto.vue
64. pagalicfrm.vue
65. pagosdivfrm.vue
66. PagosEspe.vue
67. pagosmultfrm.vue
68. PeriodoInicial.vue
69. polcon.vue
70. prepagofrm.vue
71. pres.vue
72. Propuestatab.vue
73. proyecfrm.vue
74. pruebacalcas.vue
75. psplash.vue
76. Publicos_Upd.vue
77. reg.vue
78. regHfrm.vue
79. RegSecyMas.vue
80. reimpfrm.vue
81. relmes.vue
82. repavance.vue
83. RepDescImpto.vue
84. repmultampalfrm.vue
85. RepOper.vue
86. Req.vue
87. reqctascanfrm.vue
88. ReqFrm.vue
89. reqmultas400frm.vue
90. ReqPromocion.vue
91. ReqTrans.vue
92. RequerimientosDM.vue
93. RequerxCvecat.vue
94. ResolucionJuez.vue
95. SdosFavor_CtrlExp.vue
96. SdosFavor_Pagos.vue
97. SdosFavorDM.vue
98. sfrm_calificacionQR.vue
99. sfrm_chgpass.vue
100. sfrm_prescrip_sec01.vue
101. sgcv2.vue
102. SinLigarFrm.vue
103. SolSdosFavor.vue
104. TDMConection.vue
105. trasladosfrm.vue
106. Ubicodifica.vue

### Categorización por funcionalidad:

**Multas (9):**
- BloqueoMulta.vue
- descmultampalfrm.vue
- FolMulta.vue
- multas400frm.vue
- MultasDM.vue
- multasfrm.vue
- multasfrmcalif.vue
- repmultampalfrm.vue
- reqmultas400frm.vue

**Requerimientos (11):**
- bloqctasreqfrm.vue
- ConsReq400.vue
- estadreq.vue
- impreqCvecat.vue
- listareq.vue
- Req.vue
- reqctascanfrm.vue
- ReqFrm.vue
- ReqPromocion.vue
- ReqTrans.vue
- RequerimientosDM.vue
- RequerxCvecat.vue

**Descuentos (5):**
- autdescto.vue
- consdesc.vue
- DescDerechosMerc.vue
- descpredfrm.vue
- desctorec.vue
- ImprimeDesctos.vue
- listdesctomultafrm.vue
- Otorgadescto.vue
- RepDescImpto.vue

**Derechos (5):**
- dderechosLic.vue
- DrecgoFosa.vue
- drecgoLic.vue
- drecgoOtrasObligaciones.vue
- DrecgoTrans.vue
- GastosTransmision.vue

**Pagos (7):**
- consmulpagos.vue
- ligapago.vue
- ligapagoTra.vue
- pagalicfrm.vue
- pagosdivfrm.vue
- PagosEspe.vue
- pagosmultfrm.vue
- prepagofrm.vue

**Saldos a Favor (4):**
- AplicaSdosFavor.vue
- SdosFavor_CtrlExp.vue
- SdosFavor_Pagos.vue
- SdosFavorDM.vue
- SolSdosFavor.vue

**Listas (6):**
- ListaDiferencias.vue
- ListadoMultiple.vue
- ListAna.vue
- listanotificacionesfrm.vue
- listchq.vue

**Consultas (7):**
- conscentrosfrm.vue
- consescrit400.vue
- consobsmulfrm.vue
- consultapredial.vue

**Reportes (5):**
- ExtractosRpt.vue
- relmes.vue
- repavance.vue
- RepOper.vue

**Otros (42):**
- ActualizaFechaEmpresas.vue
- busque.vue
- canc.vue
- CapturaDif.vue
- CartaInvitacion.vue
- CatastroDM.vue
- centrosfrm.vue
- codificafrm.vue
- Ejecutores.vue
- Empresas.vue
- entregafrm.vue
- Exclusivos_Upd.vue
- FirmaElectronica.vue
- FrmEje.vue
- frmpol.vue
- Hastafrm.vue
- ImpresionNva.vue
- ipor.vue
- leyesfrm.vue
- LicenciaMicrogenerador.vue
- LicenciaMicrogeneradorEcologia.vue
- ModifMasiva.vue
- newsfrm.vue
- PeriodoInicial.vue
- polcon.vue
- pres.vue
- Propuestatab.vue
- proyecfrm.vue
- pruebacalcas.vue
- psplash.vue
- Publicos_Upd.vue
- reg.vue
- regHfrm.vue
- RegSecyMas.vue
- reimpfrm.vue
- ResolucionJuez.vue
- sfrm_calificacionQR.vue
- sfrm_chgpass.vue
- sfrm_prescrip_sec01.vue
- sgcv2.vue
- SinLigarFrm.vue
- TDMConection.vue
- trasladosfrm.vue
- Ubicodifica.vue

---

## 8️⃣ Sistema: Estacionamiento Exclusivo (61 archivos)

**📍 Ubicación:** `RefactorX/Base/estacionamiento_exclusivo/vue/`
**🎯 Prioridad:** 🟡 MEDIA
**👤 Asignado:** Dev2 - Jueves PM (4 horas)
**📦 Total archivos:** 61

### Lista completa (ordenada alfabéticamente):

1. ABCEjec.vue
2. acceso.vue
3. AutorizaDes.vue
4. CartaInvitacion.vue
5. CMultEmision.vue
6. CMultFolio.vue
7. Cons_his.vue
8. ConsultaReg.vue
9. Ejecutores.vue
10. EstadxFolio.vue
11. ExportarExcel.vue
12. Facturacion.vue
13. FirmaElectronica.vue
14. Individual.vue
15. Individual_Folio.vue
16. List_Eje.vue
17. Lista_Eje.vue
18. Lista_GastosCob.vue
19. Listados.vue
20. Listados_Ade.vue
21. ListadosAdeAseoForm.vue
22. ListadosAdeExclusivosForm.vue
23. ListadosAdeInfraccionesForm.vue
24. ListadosAdeMercadosForm.vue
25. ListadosAdePublicosForm.vue
26. ListadosSinAdereq.vue
27. ListxFec.vue
28. ListxReg.vue
29. Menu.vue
30. Modif_Masiva.vue
31. Modifcar.vue
32. Modificar_bien.vue
33. ModuloDb.vue
34. Notificaciones.vue
35. NotificacionesMes.vue
36. Prenomina.vue
37. Reasignacion.vue
38. Recuperacion.vue
39. ReportAutor.vue
40. Requerimientos.vue
41. RprtCATAL_EJE.vue
42. RprtEstadxfolio.vue
43. RprtList_Eje.vue
44. RprtListados.vue
45. RprtListaxFec.vue
46. RprtListaxRegAseo.vue
47. RprtListaxRegEstacionometro.vue
48. RprtListaxRegMer.vue
49. RptFact_Merc.vue
50. RptLista_mercados.vue
51. RptListado_Aseo.vue
52. RptListaxRegPub.vue
53. RptPrenomina.vue
54. RptRecup_Aseo.vue
55. RptRecup_Merc.vue
56. RptReq_Aseo.vue
57. RptReq_Merc.vue
58. RptReq_pba.vue
59. RptReq_Pba_Aseo.vue
60. sfrm_chgpass.vue
61. UNIT9.vue

### Categorización por funcionalidad:

**ABCs y Ejecutores (3):**
- ABCEjec.vue
- Ejecutores.vue
- List_Eje.vue
- Lista_Eje.vue

**Consultas (3):**
- Cons_his.vue
- ConsultaReg.vue
- EstadxFolio.vue

**Emisión y Folios (3):**
- CMultEmision.vue
- CMultFolio.vue
- Individual_Folio.vue

**Listados y Adeudos (11):**
- Listados.vue
- Listados_Ade.vue
- ListadosAdeAseoForm.vue
- ListadosAdeExclusivosForm.vue
- ListadosAdeInfraccionesForm.vue
- ListadosAdeMercadosForm.vue
- ListadosAdePublicosForm.vue
- ListadosSinAdereq.vue
- ListxFec.vue
- ListxReg.vue
- Lista_GastosCob.vue

**Modificación (3):**
- Modif_Masiva.vue
- Modifcar.vue
- Modificar_bien.vue

**Reportes (19):**
- RprtCATAL_EJE.vue
- RprtEstadxfolio.vue
- RprtList_Eje.vue
- RprtListados.vue
- RprtListaxFec.vue
- RprtListaxRegAseo.vue
- RprtListaxRegEstacionometro.vue
- RprtListaxRegMer.vue
- RptFact_Merc.vue
- RptLista_mercados.vue
- RptListado_Aseo.vue
- RptListaxRegPub.vue
- RptPrenomina.vue
- RptRecup_Aseo.vue
- RptRecup_Merc.vue
- RptReq_Aseo.vue
- RptReq_Merc.vue
- RptReq_pba.vue
- RptReq_Pba_Aseo.vue

**Otros (22):**
- acceso.vue
- AutorizaDes.vue
- CartaInvitacion.vue
- ExportarExcel.vue
- Facturacion.vue
- FirmaElectronica.vue
- Individual.vue
- Menu.vue
- ModuloDb.vue
- Notificaciones.vue
- NotificacionesMes.vue
- Prenomina.vue
- Reasignacion.vue
- Recuperacion.vue
- ReportAutor.vue
- Requerimientos.vue
- sfrm_chgpass.vue
- UNIT9.vue

---

## 9️⃣ Sistema: Estacionamiento Público (61 archivos)

**📍 Ubicación:** `RefactorX/Base/estacionamiento_publico/vue/`
**🎯 Prioridad:** 🟡 MEDIA
**👤 Asignado:** Dev1 + Dev2 - Viernes (8 horas en paralelo)
**📦 Total archivos:** 61

### Lista completa (ordenada alfabéticamente):

1. Acceso.vue
2. AplicaPgo_DivAdmin.vue
3. Bja_Multiple.vue
4. Bja_Multiple_Ind.vue
5. Cga_ArcEdoEx.vue
6. ConsGral.vue
7. ConsRemesas.vue
8. DM_Crbos.vue
9. DsDBGasto.vue
10. Dspasswords.vue
11. frmMetrometers.vue
12. Gen_ArcAltas.vue
13. Gen_ArcDiario.vue
14. Gen_Individual.vue
15. Gen_Individual_b.vue
16. Gen_PgosBanorte.vue
17. mensaje.vue
18. Reactiva_Folios.vue
19. Reportes_Folios.vue
20. sdmWebService.vue
21. sfolios_alta.vue
22. sfrm_abc_propietario.vue
23. sfrm_alta_ubicaciones.vue
24. sfrm_aspecto.vue
25. sfrm_chg_autorizadescto.vue
26. sFrm_consulta_folios.vue
27. sfrm_consultapublicos.vue
28. sFrm_datos_oficio.vue
29. sfrm_EXC_alta.vue
30. sfrm_exc_mod_contrato.vue
31. sfrm_excConsulta.vue
32. sFrm_menu.vue
33. sfrm_modif_folios.vue
34. sfrm_nva_calco.vue
35. sfrm_pagosestadorel.vue
36. sFrm_pasar_padron.vue
37. sfrm_pdfviewer.vue
38. sfrm_prop_exclusivo.vue
39. sfrm_rep_folio.vue
40. sfrm_report_pagos.vue
41. SFRM_REPORTES_EXEC.vue
42. sfrm_reportescalco.vue
43. sfrm_tr_estado_mpio.vue
44. sFrm_trans_exclu.vue
45. sfrm_trans_pub.vue
46. sfrm_transfolios.vue
47. sfrm_up_pagos.vue
48. sFrm_UpExclus.vue
49. sfrm_valet_paso.vue
50. sfrmMetrometers.vue
51. sfrmprediocarto.vue
52. spubActualizacionfrm.vue
53. spublicosnewfrm.vue
54. spubreports.vue
55. sqrp_esta01.vue
56. sqrp_publicos.vue
57. sQRp_relacion_folios.vue
58. sQRt_imp_padron.vue
59. srfrm_conci_banorte.vue
60. Unit1.vue
61. UNIT9.vue

### Categorización por funcionalidad:

**Generación de archivos (5):**
- Gen_ArcAltas.vue
- Gen_ArcDiario.vue
- Gen_Individual.vue
- Gen_Individual_b.vue
- Gen_PgosBanorte.vue

**Consultas (5):**
- ConsGral.vue
- ConsRemesas.vue
- sFrm_consulta_folios.vue
- sfrm_consultapublicos.vue
- sfrm_excConsulta.vue

**Folios (4):**
- Reactiva_Folios.vue
- Reportes_Folios.vue
- sfolios_alta.vue
- sfrm_modif_folios.vue
- sfrm_transfolios.vue

**Pagos (4):**
- AplicaPgo_DivAdmin.vue
- sfrm_pagosestadorel.vue
- sfrm_report_pagos.vue
- sfrm_up_pagos.vue

**Bajas (2):**
- Bja_Multiple.vue
- Bja_Multiple_Ind.vue

**Estacionómetros/Medidores (2):**
- frmMetrometers.vue
- sfrmMetrometers.vue

**Exclusivos (4):**
- sfrm_EXC_alta.vue
- sfrm_exc_mod_contrato.vue
- sfrm_prop_exclusivo.vue
- sFrm_trans_exclu.vue
- sFrm_UpExclus.vue

**Reportes (9):**
- sfrm_rep_folio.vue
- SFRM_REPORTES_EXEC.vue
- sfrm_reportescalco.vue
- spubreports.vue
- sqrp_esta01.vue
- sqrp_publicos.vue
- sQRp_relacion_folios.vue
- sQRt_imp_padron.vue

**Padrón (2):**
- sFrm_pasar_padron.vue
- sQRt_imp_padron.vue

**Otros (24):**
- Acceso.vue
- Cga_ArcEdoEx.vue
- DM_Crbos.vue
- DsDBGasto.vue
- Dspasswords.vue
- mensaje.vue
- sdmWebService.vue
- sfrm_abc_propietario.vue
- sfrm_alta_ubicaciones.vue
- sfrm_aspecto.vue
- sfrm_chg_autorizadescto.vue
- sFrm_datos_oficio.vue
- sFrm_menu.vue
- sfrm_nva_calco.vue
- sfrm_pdfviewer.vue
- sfrm_trans_pub.vue
- sfrm_tr_estado_mpio.vue
- sfrm_valet_paso.vue
- sfrmprediocarto.vue
- spubActualizacionfrm.vue
- spublicosnewfrm.vue
- srfrm_conci_banorte.vue
- Unit1.vue
- UNIT9.vue

---

## 📊 Resumen por Desarrollador

### Dev1 - 135 archivos (Sistemas simples y medios)

| Sistema | Archivos | Tiempo |
|---------|----------|--------|
| Distribución | 0 (crear 15) | Lunes AM (3h) |
| Cementerios | 36 | Lunes PM (5h) |
| Aseo Contratado | 103 | Martes (8h) |
| Mercados | 107 | Martes PM + Miércoles AM (12h) |
| Otras Obligaciones | 27 | Miércoles PM (4h) |
| Est. Público (50%) | 30 | Viernes (4h) |
| **TOTAL** | **308** | **36 horas** |

### Dev2 - 335 archivos (Sistemas complejos)

| Sistema | Archivos | Tiempo |
|---------|----------|--------|
| Padrón Licencias | 97 | Miércoles (8h) |
| Multas y Reglamentos | 106 | Jueves AM (8h) |
| Est. Exclusivo | 61 | Jueves PM (4h) |
| Est. Público (50%) | 31 | Viernes (4h) |
| **TOTAL** | **295** | **24 horas** |

---

## 🎯 Próximos Pasos

1. **Revisión de archivos Vue existentes:** Analizar estructura y patrones
2. **Definir estándares de conversión:** Establecer guía de migración Delphi → Vue
3. **Crear templates base:** Plantillas para ABCs, consultas, reportes, etc.
4. **Setup proyecto Vue:** Configurar estructura de carpetas y dependencias
5. **Iniciar conversión:** Comenzar con Distribución (desde cero)

---

**Fecha de creación:** 2025-11-03
**Versión:** 1.0
**Total de archivos Vue:** 598 archivos
**Tiempo estimado de conversión:** 5 días (2 desarrolladores)
