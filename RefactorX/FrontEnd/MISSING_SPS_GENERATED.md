# 📊 REPORTE: SPs Faltantes Generados

**Fecha**: 11/11/2025, 8:04:21 a.m.
**Total de SPs creados**: 326

---

## 📋 RESUMEN POR MÓDULO


### aseo_contratado

- **Total SPs creados**: 100
- 🔴 Alta prioridad (≥5 usos): 5
- 🟡 Media prioridad (2-4 usos): 9
- ⚪ Baja prioridad (<2 usos): 86

**Ubicación**:
- Archivos SQL: `RefactorX/Base/aseo_contratado/database/generated/`
- Script deployment: `RefactorX/Base/aseo_contratado/database/deploy/`

**Top 5 más usados**:
1. `sp_aseo_zonas_list` - 15 usos en 15 componentes
2. `sp_aseo_contrato_consultar` - 11 usos en 10 componentes
3. `sp_aseo_unidades_list` - 10 usos en 10 componentes
4. `sp_aseo_tipos_list` - 6 usos en 6 componentes
5. `sp_aseo_adeudos_buscar_contrato` - 5 usos en 5 componentes

### cementerios

- **Total SPs creados**: 32
- 🔴 Alta prioridad (≥5 usos): 0
- 🟡 Media prioridad (2-4 usos): 19
- ⚪ Baja prioridad (<2 usos): 13

**Ubicación**:
- Archivos SQL: `RefactorX/Base/cementerios/database/generated/`
- Script deployment: `RefactorX/Base/cementerios/database/deploy/`

**Top 5 más usados**:
1. `sp_cem_abc_cementerios` - 4 usos en 1 componentes
2. `sp_cem_registrar_pago` - 4 usos en 1 componentes
3. `sp_cem_abc_pagos_por_folio` - 3 usos en 1 componentes
4. `sp_cem_modificar_folio` - 2 usos en 1 componentes
5. `sp_cem_baja_folio` - 2 usos en 1 componentes

### estacionamiento_exclusivo

- **Total SPs creados**: 1
- 🔴 Alta prioridad (≥5 usos): 0
- 🟡 Media prioridad (2-4 usos): 0
- ⚪ Baja prioridad (<2 usos): 1

**Ubicación**:
- Archivos SQL: `RefactorX/Base/estacionamiento_exclusivo/database/generated/`
- Script deployment: `RefactorX/Base/estacionamiento_exclusivo/database/deploy/`

**Top 5 más usados**:
1. `sp_chgpass_historial` - 1 usos en 1 componentes

### estacionamiento_publico

- **Total SPs creados**: 4
- 🔴 Alta prioridad (≥5 usos): 0
- 🟡 Media prioridad (2-4 usos): 1
- ⚪ Baja prioridad (<2 usos): 3

**Ubicación**:
- Archivos SQL: `RefactorX/Base/estacionamiento_publico/database/generated/`
- Script deployment: `RefactorX/Base/estacionamiento_publico/database/deploy/`

**Top 5 más usados**:
1. `spubreports` - 2 usos en 2 componentes
2. `sp_sfrm_baja_pub` - 1 usos en 1 componentes
3. `spget_lic_grales` - 1 usos en 1 componentes
4. `spget_lic_detalles` - 1 usos en 1 componentes

### multas_reglamentos

- **Total SPs creados**: 111
- 🔴 Alta prioridad (≥5 usos): 0
- 🟡 Media prioridad (2-4 usos): 59
- ⚪ Baja prioridad (<2 usos): 52

**Ubicación**:
- Archivos SQL: `RefactorX/Base/multas_reglamentos/database/generated/`
- Script deployment: `RefactorX/Base/multas_reglamentos/database/deploy/`

**Top 5 más usados**:
1. `recaudadora_get_ejecutores` - 2 usos en 1 componentes
2. `recaudadora_parse_file` - 2 usos en 1 componentes
3. `recaudadora_actualiza_fechas` - 2 usos en 1 componentes
4. `recaudadora_consulta_sdos_favor` - 2 usos en 1 componentes
5. `recaudadora_aplica_sdos_favor` - 2 usos en 1 componentes

### otras_obligaciones

- **Total SPs creados**: 29
- 🔴 Alta prioridad (≥5 usos): 0
- 🟡 Media prioridad (2-4 usos): 3
- ⚪ Baja prioridad (<2 usos): 26

**Ubicación**:
- Archivos SQL: `RefactorX/Base/otras_obligaciones/database/generated/`
- Script deployment: `RefactorX/Base/otras_obligaciones/database/deploy/`

**Top 5 más usados**:
1. `sp_gactualiza_multas_update` - 2 usos en 1 componentes
2. `sp_gactualiza_suspension_create` - 2 usos en 1 componentes
3. `sp_rubros_listar` - 2 usos en 1 componentes
4. `sp_gactualiza_dependencias_get` - 1 usos en 1 componentes
5. `sp_gactualiza_datos_get` - 1 usos en 1 componentes

### padron_licencias

- **Total SPs creados**: 49
- 🔴 Alta prioridad (≥5 usos): 0
- 🟡 Media prioridad (2-4 usos): 4
- ⚪ Baja prioridad (<2 usos): 45

**Ubicación**:
- Archivos SQL: `RefactorX/Base/padron_licencias/database/generated/`
- Script deployment: `RefactorX/Base/padron_licencias/database/deploy/`

**Top 5 más usados**:
1. `constancias_get_next_folio` - 2 usos en 1 componentes
2. `consulta_licencias_list` - 2 usos en 2 componentes
3. `sp_giros_dcon_adeudo` - 2 usos en 1 componentes
4. `sp_report_giros_dcon_adeudo` - 2 usos en 1 componentes
5. `sp_bloquearanuncio_get_anuncio` - 1 usos en 1 componentes

---

## 🚀 SIGUIENTE PASO

1. **Revisar archivos SQL generados** en cada módulo
2. **Implementar lógica específica** de cada SP (actualmente tienen placeholders)
3. **Ejecutar scripts de deployment** en cada base de datos PostgreSQL
4. **Verificar funcionamiento** en componentes Vue

---

**IMPORTANTE**: Los archivos SQL generados son PLANTILLAS que requieren implementación.
Cada SP tiene un placeholder que retorna JSON básico - debe ser reemplazado con la lógica real.

---

**Generado por**: RefactorX SP Generator v1.0
