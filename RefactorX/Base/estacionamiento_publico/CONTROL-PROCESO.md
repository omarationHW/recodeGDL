# CONTROL DE PROCESO - MODULO ESTACIONAMIENTO_PUBLICO

## Estado General
- **Fecha de Ultima Actualizacion:** 2025-11-09
- **Porcentaje Completado:** 71.11%
- **Estado:** EN PROCESO - FUNCIONAL CON LIMITACIONES

## Resumen de Componentes

| Categoria | Cantidad | Porcentaje |
|-----------|----------|------------|
| Componentes OK (Funcionales) | 32 | 71.11% |
| Componentes Pendientes (Bloqueados) | 13 | 28.89% |
| Componentes sin SPs (Solo UI) | 63 | - |
| **TOTAL COMPONENTES** | **108** | **100%** |

## Resumen de Stored Procedures

| Categoria | Cantidad | Porcentaje |
|-----------|----------|------------|
| SPs Funcionales | 162 | 89.5% |
| SPs con Errores | 20 | 11.05% |
| **TOTAL SPs** | **181** | **100%** |

---

## Componentes por Status

### OK - FUNCIONALES (32 componentes)

#### CRITICOS (4)
1. **AccesoPublicos.vue** - Acceso y registro de movimientos
   - SP: `sp_pub_movtos` - OK

2. **ConsGralPublicos.vue** - Consulta general de folios
   - SPs: `sp14_afolios`, `sp14_bfolios` - OK
   - NOTA: Tiene estilos inline complejos a migrar

3. **PublicosNew.vue** - Alta de nuevos estacionamientos publicos
   - SPs: `cons_predio`, `sppubalta` - OK

4. **SeguridadLoginPublicos.vue** - Login de seguridad
   - SP: `sp_login_seguridad` - OK

#### ALTO (11)
5. **ActualizacionPublicos.vue** - Actualizacion de pagos
   - SP: `actualiza_pub_pago` - OK

6. **BajaMultiplePublicos.vue** - Baja multiple de folios
   - SPs: `sp_insert_folios_baja_esta`, `sp_get_incidencias_baja_multiple` - OK

7. **CargaEdoExPublicos.vue** - Carga de estado de cuenta externo
   - SPs: `sp_insert_ta14_datos_edo`, `sp_afec_esta01`, `sp_insert_ta14_bitacora` - OK

8. **ConciBanortePublicos.vue** - Conciliacion bancaria con Banorte
   - SP: `sp_conciliados_by_folio` - OK

9. **FoliosAltaPublicos.vue** - Alta de folios de adeudo
   - SP: `sp_insert_folio_adeudo` - OK

10. **GenArcAltasPublicos.vue** - Generacion de archivos de altas
    - SPs: `get_periodo_altas`, `sp14_remesa` - OK

11. **GenArcDiarioPublicos.vue** - Generacion de archivo diario
    - SP: `sp14_remesa` - OK

12. **GenPgosBanortePublicos.vue** - Generacion de pagos Banorte
    - SP: `sp14_remesa` - OK

13. **ReportePagosPublicos.vue** - Reporte de pagos
    - SPs: `report_folios_pagados`, `report_folios_adeudo_por_inspector` - OK

#### MEDIO (15)
14. **AspectoPublicos.vue** - Gestion de aspectos visuales
    - SPs: `get_aspectos`, `get_current_aspecto` - OK

15. **ChgAutorizDesctoPublicos.vue** - Autorizacion y cambio de descuentos
    - SPs: `sp_buscar_folios_histo`, `sp_cambiar_a_tesorero` - OK

16. **ContrarecibosPublicos.vue** - Gestion de contrarecibos
    - SPs: `spd_crbo_abc`, `sum_contrarecibos_by_date` - OK

17. **EstadisticasPublicos.vue** - Reportes estadisticos
    - SP: `sqrp_esta01_report` - OK

18. **EstadoMpioPublicos.vue** - Remesas estado-municipio
    - SPs: `sp_get_remesas_estado_mpio`, `spd_delesta01` - OK

19. **GenerarPublicos.vue** - Generacion de publicos
    - SP: `sp_get_public_parking_list` - OK
    - NOTA: Componente basico, solo muestra JSON

20. **ImpPadronPublicos.vue** - Impresion de padron
    - SP: `sp_get_padron_report` - OK

21. **InfoPublicos.vue** - Informacion general de publicos
    - SP: `sp_get_public_parking_list` - OK
    - NOTA: No implementa stats-grid

22. **InspectoresPublicos.vue** - Catalogo de inspectores
    - SP: `sp_get_inspectors` - OK

23. **ListadosPublicos.vue** - Listados de publicos
    - SP: `sqrp_publicos_report` - OK

24. **MetrometersPublicos.vue** - Gestion de parquimetros
    - SPs: `sp_get_metrometer_by_axo_folio`, `sp_get_metrometers_map_url` - OK

25. **PasswordsPublicos.vue** - Gestion de contrasenas
    - SPs: `sp_passwords_list`, `sp_passwords_update` - OK

26. **ReactivaFoliosPublicos.vue** - Reactivacion de folios
    - SP: `sp_reactiva_folios_buscar` - OK

27. **ReporteFoliosPublicos.vue** - Reporte de folios por inspector
    - SP: `sp_get_folios_by_inspector` - OK

28. **ReporteListaPublicos.vue** - Listado de reportes
    - SP: `spubreports_list` - OK

29. **ReportesCalcoPublicos.vue** - Reportes de calcomanias
    - SPs: `sp_catalog_inspectors`, `sp_report_folios` - OK

30. **TransFoliosPublicos.vue** - Transferencia de folios
    - SP: `spd_delesta01` - OK

31. **TransPublicos.vue** - Transferencia de publicos
    - SP: `sp_ta_15_publicos_insert` - OK
    - NOTA: Faltan validaciones HTML5

32. **UpPagosPublicos.vue** - Actualizacion de pagos
    - SP: `sp_up_pagos_update` - OK

#### BAJO (2)
33. **PredioCartoPublicos.vue** - Cartografia de predios
    - SP: `sp_get_predio_carto_url` - OK

---

### PENDIENTES - BLOQUEADOS (13 componentes)

#### CRITICOS (2)
1. **AplicaPagoDivAdminPublicos.vue**
   - **Motivo:** Error en `sp_busca_folios_divadmin` - parametro 'axo' duplicado
   - **Impacto:** Aplicacion de pagos diversos administrativos BLOQUEADA
   - **Tiempo estimado de correccion:** 15 minutos
   - **Archivo:** `AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql`

2. **ConsultaPublicos.vue**
   - **Motivo:** SP `spget_lic_grales` no existe en BD
   - **Impacto:** Consulta principal de estacionamientos publicos BLOQUEADA
   - **Tiempo estimado de correccion:** 2-3 horas
   - **Archivo:** Crear nuevo archivo SQL
   - **NOTA ADICIONAL:** Corregir badge-info a badge-purple (linea 48)

#### ALTO (4)
3. **BajasPublicos.vue**
   - **Motivo:** SP `sp_sfrm_baja_pub` no existe en BD
   - **Impacto:** Baja individual de estacionamientos BLOQUEADA
   - **Tiempo estimado de correccion:** 1-2 horas
   - **Archivo:** Crear nuevo archivo SQL
   - **NOTA ADICIONAL:** Falta confirmacion SweetAlert2 para operacion destructiva

4. **ConsRemesasPublicos.vue**
   - **Motivo:** Error en `sp_get_remesa_detalle_mpio` - tipo 'ta14_datos_mpio' no existe
   - **Impacto:** Consulta de remesas BLOQUEADA
   - **Tiempo estimado de correccion:** 30-45 minutos
   - **Archivo:** `ConsRemesas_sp_get_remesa_detalle_mpio.sql`

5. **EdoCtaPublicos.vue**
   - **Motivo:** Error en `spubreports_edocta` - parametro 'numesta' duplicado
   - **Impacto:** Estado de cuenta BLOQUEADO
   - **Tiempo estimado de correccion:** 15 minutos
   - **Archivo:** `spubreports_spubreports_edocta.sql`

6. **PagosPublicos.vue**
   - **Motivo:** SP `spubreports` no existe en BD (existe `spubreports_list`)
   - **Impacto:** Gestion de pagos BLOQUEADA
   - **Tiempo estimado de correccion:** 1-2 horas
   - **Archivo:** Crear nuevo archivo SQL o renombrar llamadas en Vue

#### MEDIO (5)
7. **GenIndividualPublicos.vue**
   - **Motivo:** Error en `sp_gen_individual_add` - RETURN NEXT con OUT parameters
   - **Impacto:** Generacion individual de archivos BLOQUEADA
   - **Tiempo estimado de correccion:** 30 minutos
   - **Archivo:** `Gen_Individual_sp_gen_individual_add.sql`

8. **RelacionFoliosPublicos.vue**
   - **Motivo:** `sQRp_relacion_folios_report` no se encuentra despues de ejecutar
   - **Impacto:** Relacion de folios BLOQUEADA
   - **Tiempo estimado de correccion:** 1 hora
   - **Archivo:** `sQRp_relacion_folios_sQRp_relacion_folios_report.sql`

9. **ReportesPublicos.vue**
   - **Motivo:** SPs `spget_lic_detalles` y `spubreports` no existen en BD
   - **Impacto:** Reportes generales BLOQUEADOS
   - **Tiempo estimado de correccion:** 3-4 horas
   - **Archivo:** Crear nuevos archivos SQL

10. **SolicRepFoliosPublicos.vue**
    - **Motivo:** `sQRp_relacion_folios_report` no se encuentra despues de ejecutar
    - **Impacto:** Solicitud de reposicion de folios BLOQUEADA
    - **Tiempo estimado de correccion:** 1 hora
    - **Archivo:** `sQRp_relacion_folios_sQRp_relacion_folios_report.sql`

#### BAJO (2)
11. **MensajePublicos.vue**
    - **Motivo:** Error en `sp_mensaje_show` - parametro 'tipo' duplicado
    - **Impacto:** Sistema de mensajes BLOQUEADO
    - **Tiempo estimado de correccion:** 10 minutos
    - **Archivo:** `mensaje_sp_mensaje_show.sql`

12. **ValetPasoPublicos.vue**
    - **Motivo:** Error en `process_valet_file` - RETURN NEXT con OUT parameters
    - **Impacto:** Procesamiento de archivos valet BLOQUEADO
    - **Tiempo estimado de correccion:** 30 minutos
    - **Archivo:** `sfrm_valet_paso_process_valet_file.sql`

---

## SPs por Status

### FUNCIONALES (162 SPs)

**SPs mas utilizados:**
- `sp14_remesa` - Usado por 3 componentes (GenArcAltasPublicos, GenArcDiarioPublicos, GenPgosBanortePublicos)
- `sp_get_public_parking_list` - Usado por 3 componentes (ConsultaPublicos, GenerarPublicos, InfoPublicos)
- `spd_delesta01` - Usado por 2 componentes (EstadoMpioPublicos, TransFoliosPublicos)
- `report_folios_pagados` - Usado por 2 componentes (ReportePagosPublicos, SolicRepFoliosPublicos)

**Lista completa de SPs funcionales:**
`sp_pub_movtos`, `actualiza_pub_pago`, `sp_aplica_pago_divadmin`, `get_aspectos`, `get_current_aspecto`, `sp_insert_folios_baja_esta`, `sp_get_incidencias_baja_multiple`, `sp_insert_ta14_datos_edo`, `sp_afec_esta01`, `sp_insert_ta14_bitacora`, `sp_buscar_folios_histo`, `sp_cambiar_a_tesorero`, `sp_conciliados_by_folio`, `sp14_afolios`, `sp14_bfolios`, `sp_get_remesas`, `sp_get_public_parking_list`, `sp_get_public_parking_fines`, `cajero_pub_detalle`, `spd_crbo_abc`, `sum_contrarecibos_by_date`, `sqrp_esta01_report`, `sp_get_remesas_estado_mpio`, `spd_delesta01`, `sp_insert_folio_adeudo`, `get_periodo_altas`, `sp14_remesa`, `sp_gen_individual_generate_file`, `sp_get_padron_report`, `sp_get_inspectors`, `sqrp_publicos_report`, `sp_get_metrometer_by_axo_folio`, `sp_get_metrometers_map_url`, `sp_passwords_list`, `sp_passwords_update`, `sp_get_predio_carto_url`, `cons_predio`, `sppubalta`, `sp_reactiva_folios_buscar`, `sp_get_folios_by_inspector`, `spubreports_list`, `report_folios_pagados`, `report_folios_adeudo_por_inspector`, `sp_catalog_inspectors`, `sp_report_folios`, `sp_login_seguridad`, `sp_ta_15_publicos_insert`, `sp_up_pagos_update`, y 114 SPs adicionales.

### CON ERRORES (20 SPs)

#### Errores de Parametros Duplicados (4 SPs)
1. **sp_busca_folios_divadmin**
   - Error: `parameter name 'axo' used more than once`
   - Afecta: AplicaPagoDivAdminPublicos.vue
   - Prioridad: CRITICO

2. **spubreports_edocta**
   - Error: `parameter name 'numesta' used more than once`
   - Afecta: EdoCtaPublicos.vue
   - Prioridad: ALTO

3. **sp_mensaje_show**
   - Error: `parameter name 'tipo' used more than once`
   - Afecta: MensajePublicos.vue
   - Prioridad: BAJO

4. **sp_get_estado_cuenta**
   - Error: `parameter name 'no_exclusivo' used more than once`
   - Afecta: Componentes de reportes ejecutivos
   - Prioridad: MEDIO

#### Errores de Tipos Inexistentes (2 SPs)
5. **sp_get_remesa_detalle_mpio**
   - Error: `type 'ta14_datos_mpio' does not exist`
   - Afecta: ConsRemesasPublicos.vue
   - Prioridad: ALTO

6. **sp_get_remesa_detalle_edo**
   - Error: `type 'ta14_datos_edo' does not exist`
   - Afecta: Componentes de remesas
   - Prioridad: MEDIO

#### Errores de Sintaxis RETURN NEXT (2 SPs)
7. **sp_gen_individual_add**
   - Error: `RETURN NEXT cannot have a parameter in function with OUT parameters`
   - Afecta: GenIndividualPublicos.vue
   - Prioridad: MEDIO

8. **process_valet_file**
   - Error: `RETURN NEXT cannot have a parameter in function with OUT parameters`
   - Afecta: ValetPasoPublicos.vue
   - Prioridad: BAJO

#### SPs Faltantes en BD (4 SPs)
9. **spget_lic_grales**
   - Afecta: ConsultaPublicos.vue
   - Prioridad: CRITICO

10. **sp_sfrm_baja_pub**
    - Afecta: BajasPublicos.vue
    - Prioridad: ALTO

11. **spubreports**
    - Afecta: PagosPublicos.vue, ReportesPublicos.vue
    - Prioridad: ALTO
    - NOTA: Existe `spubreports_list` pero no `spubreports`

12. **spget_lic_detalles**
    - Afecta: ReportesPublicos.vue
    - Prioridad: MEDIO

#### Problemas de Despliegue (1 SP)
13. **sQRp_relacion_folios_report**
    - Error: `SP no encontrado despues de ejecutar`
    - Afecta: RelacionFoliosPublicos.vue, SolicRepFoliosPublicos.vue
    - Prioridad: MEDIO

#### Errores de Sintaxis (3 SPs)
14. **check_rfc_exists**
    - Error: `syntax error at or near "exists"`
    - Prioridad: MEDIO

15. **insert_persona**
    - Error: `input parameters after one with a default value must also have defaults`
    - Prioridad: MEDIO

16. **sp_adeudos_detalle**
    - Error: `parameter name "axo" used more than once`
    - Prioridad: MEDIO

---

## Plan de Accion

### FASE 1 - CRITICO (2.25-3.25 horas)
**Componentes afectados:** 2 (AplicaPagoDivAdminPublicos, ConsultaPublicos)

#### Tarea 1.1: Corregir sp_busca_folios_divadmin (15 min)
- Archivo: `AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql`
- Accion: Eliminar parametro duplicado 'axo'
- Componente desbloqueado: AplicaPagoDivAdminPublicos.vue

#### Tarea 1.2: Implementar spget_lic_grales (2-3 horas)
- Archivo: Crear nuevo SQL
- Accion: Implementar SP completo para consulta de licencias generales
- Componente desbloqueado: ConsultaPublicos.vue

#### Tarea 1.3: Corregir badge-info en ConsultaPublicos (5 min)
- Archivo: `ConsultaPublicos.vue` linea 48
- Accion: Cambiar badge-info a badge-purple

**Total Fase 1:** 2.25-3.25 horas

---

### FASE 2 - ALTO (3-4.5 horas)
**Componentes afectados:** 4 (BajasPublicos, ConsRemesasPublicos, EdoCtaPublicos, PagosPublicos)

#### Tarea 2.1: Implementar sp_sfrm_baja_pub (1-2 horas)
- Archivo: Crear nuevo SQL
- Accion: Implementar SP para baja de estacionamientos
- Componente desbloqueado: BajasPublicos.vue

#### Tarea 2.2: Corregir sp_get_remesa_detalle_mpio (30-45 min)
- Archivo: `ConsRemesas_sp_get_remesa_detalle_mpio.sql`
- Accion: Crear tipo 'ta14_datos_mpio' o modificar SP
- Componente desbloqueado: ConsRemesasPublicos.vue

#### Tarea 2.3: Corregir spubreports_edocta (15 min)
- Archivo: `spubreports_spubreports_edocta.sql`
- Accion: Eliminar parametro duplicado 'numesta'
- Componente desbloqueado: EdoCtaPublicos.vue

#### Tarea 2.4: Implementar spubreports o renombrar llamadas (1-2 horas)
- Archivo: Crear nuevo SQL o modificar Vue
- Accion: Implementar SP o cambiar llamadas a spubreports_list
- Componente desbloqueado: PagosPublicos.vue

**Total Fase 2:** 3-4.5 horas

---

### FASE 3 - MEDIO (5-6.5 horas)
**Componentes afectados:** 4 (GenIndividualPublicos, RelacionFoliosPublicos, ReportesPublicos, SolicRepFoliosPublicos)

#### Tarea 3.1: Corregir sp_gen_individual_add (30 min)
- Archivo: `Gen_Individual_sp_gen_individual_add.sql`
- Accion: Corregir sintaxis RETURN NEXT
- Componente desbloqueado: GenIndividualPublicos.vue

#### Tarea 3.2: Revisar sQRp_relacion_folios_report (1 hora)
- Archivo: `sQRp_relacion_folios_sQRp_relacion_folios_report.sql`
- Accion: Investigar y corregir problema de despliegue
- Componentes desbloqueados: RelacionFoliosPublicos.vue, SolicRepFoliosPublicos.vue

#### Tarea 3.3: Implementar spget_lic_detalles (2-3 horas)
- Archivo: Crear nuevo SQL
- Accion: Implementar SP para detalles de licencias
- Componente desbloqueado: ReportesPublicos.vue (parcial)

#### Tarea 3.4: Implementar spubreports para ReportesPublicos (1-2 horas)
- Archivo: Crear nuevo SQL o modificar Vue
- Accion: Implementar SP o cambiar llamadas
- Componente desbloqueado: ReportesPublicos.vue (completo)

**Total Fase 3:** 5-6.5 horas

---

### FASE 4 - BAJO (40 minutos)
**Componentes afectados:** 2 (MensajePublicos, ValetPasoPublicos)

#### Tarea 4.1: Corregir sp_mensaje_show (10 min)
- Archivo: `mensaje_sp_mensaje_show.sql`
- Accion: Eliminar parametro duplicado 'tipo'
- Componente desbloqueado: MensajePublicos.vue

#### Tarea 4.2: Corregir process_valet_file (30 min)
- Archivo: `sfrm_valet_paso_process_valet_file.sql`
- Accion: Corregir sintaxis RETURN NEXT
- Componente desbloqueado: ValetPasoPublicos.vue

**Total Fase 4:** 40 minutos

---

## Mejoras Pendientes de Estandares

### Composables (ALTA PRIORIDAD)
- **Componentes afectados:** 45 de 45
- **Impacto:** ALTO - Consistencia de codigo
- **Accion:** Migrar todos los componentes a usar composables estandar:
  - `useApi` - Llamadas a la API
  - `useLicenciasErrorHandler` - Manejo de errores
  - `useGlobalLoading` - Estados de carga
- **Tiempo estimado:** 10-15 horas para todos los componentes

### Confirmaciones SweetAlert2 (ALTA PRIORIDAD)
- **Componentes afectados:** 15
- **Impacto:** ALTO - Seguridad en operaciones destructivas
- **Componentes criticos:**
  - BajasPublicos.vue (operacion destructiva sin confirmacion)
  - TransPublicos.vue
  - AplicaPagoDivAdminPublicos.vue
- **Tiempo estimado:** 2-3 horas para todos los componentes

### Validaciones HTML5 (ALTA PRIORIDAD)
- **Componentes afectados:** 25
- **Impacto:** ALTO - Calidad de datos
- **Componentes criticos:**
  - TransPublicos.vue
  - BajasPublicos.vue
- **Tiempo estimado:** 3-4 horas para todos los componentes

### Stats Cards (MEDIA PRIORIDAD)
- **Componentes afectados:** 20
- **Impacto:** MEDIO - Experiencia de usuario
- **Componentes a mejorar:**
  - InfoPublicos.vue
  - ConsultaPublicos.vue
- **Tiempo estimado:** 4-6 horas para componentes principales

### Badges (BAJA PRIORIDAD)
- **Componentes afectados:** 1
- **Impacto:** BAJO - Consistencia visual
- **Componente:** ConsultaPublicos.vue (linea 48)
- **Tiempo estimado:** 5 minutos

### Estilos Inline (MEDIA PRIORIDAD)
- **Componentes afectados:** 18
- **Impacto:** MEDIO - Mantenibilidad
- **Componentes principales:**
  - ConsGralPublicos.vue
  - ConsultaPublicos.vue
- **Tiempo estimado:** 2-3 horas para migrar a clases

---

## Resumen de Tiempos de Correccion

| Fase | Prioridad | Componentes | Tiempo Estimado |
|------|-----------|-------------|-----------------|
| Fase 1 | CRITICO | 2 | 2.25-3.25 horas |
| Fase 2 | ALTO | 4 | 3-4.5 horas |
| Fase 3 | MEDIO | 4 | 5-6.5 horas |
| Fase 4 | BAJO | 2 | 40 minutos |
| **TOTAL** | **-** | **12** | **11-15 horas** |

**Mejoras de estandares (opcional):**
- Composables: 10-15 horas
- Confirmaciones: 2-3 horas
- Validaciones: 3-4 horas
- Stats Cards: 4-6 horas
- Estilos: 2-3 horas
- **TOTAL MEJORAS:** 21-31 horas

**GRAN TOTAL (correcciones + mejoras):** 32-46 horas

---

## Componentes sin SPs (Solo UI) - 63 componentes

Estos componentes no hacen llamadas a stored procedures, solo renderizan UI o usan datos locales:
- AdminPublicos.vue (placeholder)
- Y 62 componentes adicionales de la carpeta Base

---

## Notas Finales

### Estado Actual
El modulo **estacionamiento_publico** tiene un **71.11% de funcionalidad operativa**. De los 45 componentes que usan stored procedures, **32 estan completamente funcionales** y **13 estan bloqueados** por errores en SPs.

### Prioridades
1. **CRITICO:** Desbloquear AplicaPagoDivAdminPublicos y ConsultaPublicos (2.25-3.25 horas)
2. **ALTO:** Desbloquear componentes de gestion de bajas, remesas, estado de cuenta y pagos (3-4.5 horas)
3. **MEDIO:** Desbloquear reportes y generacion de archivos (5-6.5 horas)
4. **BAJO:** Desbloquear mensajes y valet (40 minutos)

### Arquitectura de Codigo
Todos los componentes requieren migracion a composables estandar y mejoras de validacion/confirmacion para cumplir con los estandares del proyecto.

---

**Fecha de generacion:** 2025-11-09
**Version:** 1.0
**Generado automaticamente desde:**
- `integration-report.json`
- `vue-standards-check.json`
- `vue-styles-audit.json`
- `sp-deployment-report.json`
