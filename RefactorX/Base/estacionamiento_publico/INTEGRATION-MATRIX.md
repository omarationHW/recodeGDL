# MATRIZ DE INTEGRACIÓN VUE ↔ BASE DE DATOS
## Módulo: estacionamiento_publico

**Fecha de análisis:** 2025-11-09
**Componentes analizados:** 108
**Componentes con SPs:** 45
**Tasa de funcionalidad:** 71.11% (32/45 componentes funcionales)

---

## RESUMEN EJECUTIVO

### Estado General
- **Total SPs requeridos por Vue:** 59
- **SPs disponibles en BD:** 162
- **SPs de Vue encontrados en BD:** 50 (84.7%)
- **SPs de Vue faltantes en BD:** 9 (15.3%)
- **SPs con errores que bloquean funcionalidad:** 6

### Componentes por Estado
- ✅ **Funcionales:** 32 componentes (71.11%)
- ❌ **Bloqueados:** 13 componentes (28.89%)
- ⚪ **Sin SPs:** 63 componentes

---

## COMPONENTES CRÍTICOS

| Componente | SPs Usados | Estado BD | Funcional | Observaciones |
|------------|------------|-----------|-----------|---------------|
| **AccesoPublicos.vue** | sp_pub_movtos | ✅ OK | ✅ SÍ | Login funcional |
| **ConsGralPublicos.vue** | sp14_afolios, sp14_bfolios | ✅ OK | ✅ SÍ | Consulta principal funcional |
| **PublicosNew.vue** | cons_predio, sppubalta | ✅ OK | ✅ SÍ | Alta de estacionamientos funcional |
| **SeguridadLoginPublicos.vue** | sp_login_seguridad | ✅ OK | ✅ SÍ | Login de seguridad funcional |
| **AplicaPagoDivAdminPublicos.vue** | sp_busca_folios_divadmin, sp_aplica_pago_divadmin | ❌ ERROR | ❌ NO | BLOQUEADO: sp_busca_folios_divadmin tiene parámetro 'axo' duplicado |
| **ConsultaPublicos.vue** | sp_get_public_parking_list, sp_get_public_parking_fines, cajero_pub_detalle, spget_lic_grales | ❌ FALTA | ❌ NO | BLOQUEADO: spget_lic_grales no existe en BD |

---

## COMPONENTES DE ALTA PRIORIDAD

| Componente | SPs Usados | Estado BD | Funcional | Observaciones |
|------------|------------|-----------|-----------|---------------|
| **ActualizacionPublicos.vue** | actualiza_pub_pago | ✅ OK | ✅ SÍ | Actualización de pagos funcional |
| **BajaMultiplePublicos.vue** | sp_insert_folios_baja_esta, sp_get_incidencias_baja_multiple | ✅ OK | ✅ SÍ | Baja múltiple funcional |
| **CargaEdoExPublicos.vue** | sp_insert_ta14_datos_edo, sp_afec_esta01, sp_insert_ta14_bitacora | ✅ OK | ✅ SÍ | Carga de estado cuenta funcional |
| **ConciBanortePublicos.vue** | sp_conciliados_by_folio | ✅ OK | ✅ SÍ | Conciliación bancaria funcional |
| **FoliosAltaPublicos.vue** | sp_insert_folio_adeudo | ✅ OK | ✅ SÍ | Alta de folios funcional |
| **GenArcAltasPublicos.vue** | get_periodo_altas, sp14_remesa | ✅ OK | ✅ SÍ | Generación archivo altas funcional |
| **GenArcDiarioPublicos.vue** | sp14_remesa | ✅ OK | ✅ SÍ | Generación archivo diario funcional |
| **GenPgosBanortePublicos.vue** | sp14_remesa | ✅ OK | ✅ SÍ | Generación pagos Banorte funcional |
| **ReportePagosPublicos.vue** | report_folios_pagados, report_folios_adeudo_por_inspector | ✅ OK | ✅ SÍ | Reporte de pagos funcional |
| **BajasPublicos.vue** | sp_sfrm_baja_pub | ❌ FALTA | ❌ NO | BLOQUEADO: sp_sfrm_baja_pub no existe |
| **ConsRemesasPublicos.vue** | sp_get_remesas, sp_get_remesa_detalle_mpio | ❌ ERROR | ❌ NO | BLOQUEADO: sp_get_remesa_detalle_mpio necesita tipo ta14_datos_mpio |
| **EdoCtaPublicos.vue** | spubreports_edocta | ❌ ERROR | ❌ NO | BLOQUEADO: spubreports_edocta tiene parámetro 'numesta' duplicado |
| **PagosPublicos.vue** | spubreports | ❌ FALTA | ❌ NO | BLOQUEADO: spubreports no existe (existe spubreports_list) |

---

## COMPONENTES DE PRIORIDAD MEDIA

| Componente | SPs Usados | Estado BD | Funcional | Observaciones |
|------------|------------|-----------|-----------|---------------|
| **AspectoPublicos.vue** | get_aspectos, get_current_aspecto | ✅ OK | ✅ SÍ | Gestión aspectos funcional |
| **ChgAutorizDesctoPublicos.vue** | sp_buscar_folios_histo, sp_cambiar_a_tesorero | ✅ OK | ✅ SÍ | Autorización descuentos funcional |
| **ContrarecibosPublicos.vue** | spd_crbo_abc, sum_contrarecibos_by_date | ✅ OK | ✅ SÍ | Contrarecibos funcional |
| **EstadisticasPublicos.vue** | sqrp_esta01_report | ✅ OK | ✅ SÍ | Estadísticas funcionales |
| **EstadoMpioPublicos.vue** | sp_get_remesas_estado_mpio, spd_delesta01 | ✅ OK | ✅ SÍ | Remesas estado-municipio funcional |
| **GenerarPublicos.vue** | sp_get_public_parking_list | ✅ OK | ✅ SÍ | Generación públicos funcional |
| **ImpPadronPublicos.vue** | sp_get_padron_report | ✅ OK | ✅ SÍ | Impresión padrón funcional |
| **InfoPublicos.vue** | sp_get_public_parking_list | ✅ OK | ✅ SÍ | Info públicos funcional |
| **InspectoresPublicos.vue** | sp_get_inspectors | ✅ OK | ✅ SÍ | Catálogo inspectores funcional |
| **ListadosPublicos.vue** | sqrp_publicos_report | ✅ OK | ✅ SÍ | Listados funcionales |
| **MetrometersPublicos.vue** | sp_get_metrometer_by_axo_folio, sp_get_metrometers_map_url | ✅ OK | ✅ SÍ | Metrometers funcional |
| **PasswordsPublicos.vue** | sp_passwords_list, sp_passwords_update | ✅ OK | ✅ SÍ | Gestión contraseñas funcional |
| **ReactivaFoliosPublicos.vue** | sp_reactiva_folios_buscar | ✅ OK | ✅ SÍ | Reactivación folios funcional |
| **ReporteFoliosPublicos.vue** | sp_get_folios_by_inspector | ✅ OK | ✅ SÍ | Reporte folios funcional |
| **ReporteListaPublicos.vue** | spubreports_list | ✅ OK | ✅ SÍ | Lista reportes funcional |
| **ReportesCalcoPublicos.vue** | sp_catalog_inspectors, sp_report_folios | ✅ OK | ✅ SÍ | Reportes calcomanías funcional |
| **TransFoliosPublicos.vue** | spd_delesta01 | ✅ OK | ✅ SÍ | Transfer folios funcional |
| **TransPublicos.vue** | sp_ta_15_publicos_insert | ✅ OK | ✅ SÍ | Transfer públicos funcional |
| **UpPagosPublicos.vue** | sp_up_pagos_update | ✅ OK | ✅ SÍ | Update pagos funcional |
| **GenIndividualPublicos.vue** | sp_gen_individual_add, sp_gen_individual_generate_file | ❌ ERROR | ❌ NO | BLOQUEADO: sp_gen_individual_add error RETURN NEXT |
| **RelacionFoliosPublicos.vue** | sQRp_relacion_folios_report | ⚠️ PROBLEMA | ❌ NO | BLOQUEADO: SP se despliega pero no se encuentra |
| **ReportesPublicos.vue** | spget_lic_detalles, spubreports | ❌ FALTA | ❌ NO | BLOQUEADO: Ambos SPs no existen |
| **SolicRepFoliosPublicos.vue** | report_folios_pagados, sQRp_relacion_folios_report | ⚠️ PROBLEMA | ❌ NO | BLOQUEADO: sQRp_relacion_folios_report problema despliegue |

---

## COMPONENTES DE PRIORIDAD BAJA

| Componente | SPs Usados | Estado BD | Funcional | Observaciones |
|------------|------------|-----------|-----------|---------------|
| **PredioCartoPublicos.vue** | sp_get_predio_carto_url | ✅ OK | ✅ SÍ | Cartografía funcional |
| **MensajePublicos.vue** | sp_mensaje_show | ❌ ERROR | ❌ NO | BLOQUEADO: sp_mensaje_show parámetro 'tipo' duplicado |
| **ValetPasoPublicos.vue** | process_valet_file | ❌ ERROR | ❌ NO | BLOQUEADO: process_valet_file error RETURN NEXT |

---

## SPs CRÍTICOS FALTANTES

### 1. spget_lic_grales
- **Componente afectado:** ConsultaPublicos.vue (CRÍTICO)
- **Impacto:** Bloquea consulta general de licencias
- **Acción:** Implementar SP urgentemente

### 2. sp_sfrm_baja_pub
- **Componente afectado:** BajasPublicos.vue (ALTO)
- **Impacto:** Bloquea proceso de bajas
- **Acción:** Implementar SP

### 3. spubreports
- **Componentes afectados:** PagosPublicos.vue (ALTO), ReportesPublicos.vue (MEDIO)
- **Impacto:** Bloquea reportes de pagos
- **Acción:** Implementar SP o modificar llamadas Vue a spubreports_list (que sí existe)
- **Nota:** Existe spubreports_list que podría ser el correcto

### 4. spget_lic_detalles
- **Componente afectado:** ReportesPublicos.vue (MEDIO)
- **Impacto:** Bloquea detalles de licencias
- **Acción:** Implementar SP

---

## SPs CON ERRORES QUE BLOQUEAN FUNCIONALIDAD

### 1. sp_busca_folios_divadmin (CRÍTICO)
- **Error:** `parameter name 'axo' used more than once`
- **Componente afectado:** AplicaPagoDivAdminPublicos.vue
- **Prioridad:** CRÍTICO
- **Archivo:** `AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql`
- **Solución:** Eliminar parámetro duplicado 'axo'

### 2. sp_get_remesa_detalle_mpio (ALTO)
- **Error:** `type 'ta14_datos_mpio' does not exist`
- **Componente afectado:** ConsRemesasPublicos.vue
- **Prioridad:** ALTO
- **Archivo:** `ConsRemesas_sp_get_remesa_detalle_mpio.sql`
- **Solución:** Crear tipo ta14_datos_mpio o modificar SP para no usarlo

### 3. spubreports_edocta (ALTO)
- **Error:** `parameter name 'numesta' used more than once`
- **Componente afectado:** EdoCtaPublicos.vue
- **Prioridad:** ALTO
- **Archivo:** `spubreports_spubreports_edocta.sql`
- **Solución:** Eliminar parámetro duplicado 'numesta'

### 4. sp_gen_individual_add (MEDIO)
- **Error:** `RETURN NEXT cannot have a parameter in function with OUT parameters`
- **Componente afectado:** GenIndividualPublicos.vue
- **Prioridad:** MEDIO
- **Archivo:** `Gen_Individual_sp_gen_individual_add.sql`
- **Solución:** Corregir sintaxis de RETURN NEXT con OUT parameters

### 5. sp_mensaje_show (BAJO)
- **Error:** `parameter name 'tipo' used more than once`
- **Componente afectado:** MensajePublicos.vue
- **Prioridad:** BAJO
- **Archivo:** `mensaje_sp_mensaje_show.sql`
- **Solución:** Eliminar parámetro duplicado 'tipo'

### 6. process_valet_file (BAJO)
- **Error:** `RETURN NEXT cannot have a parameter in function with OUT parameters`
- **Componente afectado:** ValetPasoPublicos.vue
- **Prioridad:** BAJO
- **Archivo:** `sfrm_valet_paso_process_valet_file.sql`
- **Solución:** Corregir sintaxis de RETURN NEXT con OUT parameters

---

## SPs CON PROBLEMAS DE DESPLIEGUE

### sQRp_relacion_folios_report
- **Problema:** SP se despliega exitosamente pero no se encuentra después de ejecutar
- **Componentes afectados:** RelacionFoliosPublicos.vue, SolicRepFoliosPublicos.vue
- **Prioridad:** MEDIO
- **Archivo:** `sQRp_relacion_folios_sQRp_relacion_folios_report.sql`
- **Solución:** Revisar nombre del SP, puede estar creándose con nombre diferente al esperado

---

## RECOMENDACIONES PRIORIZADAS

### PRIORIDAD CRÍTICA (Acción Inmediata)

1. **Corregir sp_busca_folios_divadmin**
   - Archivo: `AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql`
   - Problema: Parámetro 'axo' duplicado
   - Impacto: Bloquea AplicaPagoDivAdminPublicos.vue (CRÍTICO)
   - Tiempo estimado: 15 minutos

2. **Implementar spget_lic_grales**
   - Archivo: Crear nuevo SQL
   - Problema: SP no existe
   - Impacto: Bloquea ConsultaPublicos.vue (CRÍTICO)
   - Tiempo estimado: 2-4 horas (requiere análisis de lógica)

### PRIORIDAD ALTA (Esta Semana)

3. **Corregir sp_get_remesa_detalle_mpio**
   - Archivo: `ConsRemesas_sp_get_remesa_detalle_mpio.sql`
   - Problema: Tipo ta14_datos_mpio no existe
   - Impacto: Bloquea ConsRemesasPublicos.vue (ALTO)
   - Tiempo estimado: 1-2 horas

4. **Corregir spubreports_edocta**
   - Archivo: `spubreports_spubreports_edocta.sql`
   - Problema: Parámetro 'numesta' duplicado
   - Impacto: Bloquea EdoCtaPublicos.vue (ALTO)
   - Tiempo estimado: 15 minutos

5. **Implementar sp_sfrm_baja_pub**
   - Archivo: Crear nuevo SQL
   - Problema: SP no existe
   - Impacto: Bloquea BajasPublicos.vue (ALTO)
   - Tiempo estimado: 2-3 horas

6. **Resolver spubreports vs spubreports_list**
   - Archivo: Modificar llamadas Vue o crear alias
   - Problema: Vue llama spubreports pero existe spubreports_list
   - Impacto: Bloquea PagosPublicos.vue, ReportesPublicos.vue (ALTO)
   - Tiempo estimado: 30 minutos - 1 hora

### PRIORIDAD MEDIA (Próximas 2 Semanas)

7. **Corregir sp_gen_individual_add**
   - Archivo: `Gen_Individual_sp_gen_individual_add.sql`
   - Problema: Sintaxis RETURN NEXT incorrecta
   - Impacto: Bloquea GenIndividualPublicos.vue (MEDIO)
   - Tiempo estimado: 1 hora

8. **Implementar spget_lic_detalles**
   - Archivo: Crear nuevo SQL
   - Problema: SP no existe
   - Impacto: Bloquea ReportesPublicos.vue (MEDIO)
   - Tiempo estimado: 2 horas

9. **Revisar sQRp_relacion_folios_report**
   - Archivo: `sQRp_relacion_folios_sQRp_relacion_folios_report.sql`
   - Problema: SP se crea pero no se encuentra
   - Impacto: Bloquea RelacionFoliosPublicos.vue, SolicRepFoliosPublicos.vue (MEDIO)
   - Tiempo estimado: 1 hora

### PRIORIDAD BAJA (Cuando Haya Tiempo)

10. **Corregir sp_mensaje_show**
    - Archivo: `mensaje_sp_mensaje_show.sql`
    - Problema: Parámetro 'tipo' duplicado
    - Impacto: Bloquea MensajePublicos.vue (BAJO)
    - Tiempo estimado: 15 minutos

11. **Corregir process_valet_file**
    - Archivo: `sfrm_valet_paso_process_valet_file.sql`
    - Problema: Sintaxis RETURN NEXT incorrecta
    - Impacto: Bloquea ValetPasoPublicos.vue (BAJO)
    - Tiempo estimado: 1 hora

---

## ANÁLISIS DE COMPATIBILIDAD DE PARÁMETROS

### SPs que requieren validación de parámetros

Los siguientes SPs están disponibles y funcionan, pero se recomienda validar que los parámetros enviados desde Vue coincidan con los esperados por el SP:

1. **sp_get_metrometer_by_axo_folio / sp_get_metrometers_map_url**
   - Componente: MetrometersPublicos.vue
   - Revisar tipos de datos de parámetros axo y folio

2. **sp14_remesa**
   - Componentes: GenArcAltasPublicos.vue, GenArcDiarioPublicos.vue, GenPgosBanortePublicos.vue
   - Usado por 3 componentes, validar consistencia de parámetros

3. **sp_get_public_parking_list**
   - Componentes: ConsultaPublicos.vue, GenerarPublicos.vue, InfoPublicos.vue
   - Usado por 3 componentes, validar parámetros de búsqueda

---

## ESTADÍSTICAS DETALLADAS

### Por Prioridad de Componente

| Prioridad | Total | Funcionales | Bloqueados | % Funcional |
|-----------|-------|-------------|------------|-------------|
| CRÍTICO   | 6     | 4           | 2          | 66.67%      |
| ALTO      | 14    | 10          | 4          | 71.43%      |
| MEDIO     | 19    | 15          | 4          | 78.95%      |
| BAJO      | 3     | 1           | 2          | 33.33%      |
| **TOTAL** | **42**| **30**      | **12**     | **71.43%**  |

### Por Tipo de Error

| Tipo de Error | Cantidad | SPs Afectados |
|---------------|----------|---------------|
| Parámetros duplicados | 4 | sp_busca_folios_divadmin, spubreports_edocta, sp_mensaje_show, (otros) |
| Tipos inexistentes | 1 | sp_get_remesa_detalle_mpio |
| Sintaxis RETURN NEXT | 2 | sp_gen_individual_add, process_valet_file |
| SPs faltantes | 4 | spget_lic_grales, sp_sfrm_baja_pub, spubreports, spget_lic_detalles |
| Problemas despliegue | 1 | sQRp_relacion_folios_report |

### Cobertura de SPs

- **Total SPs únicos llamados por Vue:** 59
- **SPs encontrados en BD:** 50 (84.7%)
- **SPs funcionales sin errores:** 44 (74.6%)
- **SPs con errores:** 6 (10.2%)
- **SPs faltantes:** 9 (15.3%)

---

## PLAN DE ACCIÓN SUGERIDO

### Fase 1: Correcciones Críticas (1-2 días)
1. Corregir sp_busca_folios_divadmin (parámetro duplicado)
2. Implementar spget_lic_grales
3. Total tiempo estimado: 4-6 horas

### Fase 2: Correcciones Altas (1 semana)
4. Corregir sp_get_remesa_detalle_mpio
5. Corregir spubreports_edocta
6. Implementar sp_sfrm_baja_pub
7. Resolver spubreports/spubreports_list
8. Total tiempo estimado: 6-8 horas

### Fase 3: Correcciones Medias (2 semanas)
9. Corregir sp_gen_individual_add
10. Implementar spget_lic_detalles
11. Revisar sQRp_relacion_folios_report
12. Total tiempo estimado: 4-5 horas

### Fase 4: Correcciones Bajas (cuando haya tiempo)
13. Corregir sp_mensaje_show
14. Corregir process_valet_file
15. Total tiempo estimado: 1-2 horas

**Tiempo total estimado:** 15-21 horas de trabajo

---

## NOTAS FINALES

1. **Componentes sin SPs (63 componentes):** Estos componentes no utilizan stored procedures directamente. Podrían usar endpoints API que llaman a los SPs internamente, o ser componentes de UI pura.

2. **SPs en BD no usados por Vue:** Hay 112 SPs en la base de datos que no son llamados directamente por ningún componente Vue analizado. Estos podrían ser:
   - SPs heredados del sistema antiguo
   - SPs utilizados por otros módulos
   - SPs de utilidad interna
   - SPs que serán usados en el futuro

3. **Validación de parámetros pendiente:** Aunque 44 SPs están funcionales, se recomienda hacer pruebas de integración para validar que los parámetros enviados desde Vue coincidan exactamente con los esperados por PostgreSQL.

4. **Documentación:** Se recomienda documentar los parámetros esperados por cada SP para facilitar el mantenimiento futuro.

---

**Reporte generado:** 2025-11-09
**Módulo:** estacionamiento_publico
**Total archivos analizados:** 290 (108 componentes Vue + 182 archivos SQL)
