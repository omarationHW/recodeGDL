# INFORME EXHAUSTIVO DE INSTALACIÓN DE STORED PROCEDURES - MÓDULO CEMENTERIOS

**Fecha de Generación:** 2025-11-09
**Base de Datos:** padron_licencias
**Host:** 192.168.6.146:5432
**Usuario:** refact
**Esquema:** public

---

## RESUMEN EJECUTIVO

| Métrica | Valor |
|---------|-------|
| **Total de archivos SQL** | 39 |
| **Total de Stored Procedures** | 93 |
| **Archivos CORE** | 3 (22 SPs) |
| **Archivos EXACTO** | 36 (71 SPs) |
| **Tamaño total** | ~4,269 líneas de código |
| **Complejidad** | Media-Alta |

---

## 1. ANÁLISIS DETALLADO DE ARCHIVOS SQL

### 1.1 GRUPO CORE - ARCHIVOS FUNDAMENTALES (3 archivos - 22 SPs)

#### 1.1.1 - 01_SP_CEMENTERIOS_CORE_all_procedures.sql

**Estadísticas:**
- Líneas: 559
- SPs: 9
- Tipo: Funciones (RETURNS TABLE)
- Categoría: CORE - Operaciones fundamentales

**Stored Procedures incluidos:**

1. **SP_CEMENTERIOS_DIFUNTOS_LIST**
   - Tipo: Consulta con paginación
   - Parámetros: p_page, p_limit, p_search, p_cementerio_id, p_fecha_desde, p_fecha_hasta
   - Retorna: Lista paginada de difuntos con información completa
   - Tablas: difuntos, cementerios
   - Características: Búsqueda por nombre/registro/solicitante, filtros por cementerio y fechas

2. **SP_CEMENTERIOS_DIFUNTO_GET**
   - Tipo: Consulta individual
   - Parámetros: p_difunto_id
   - Retorna: Información completa de un difunto específico
   - Tablas: difuntos, cementerios
   - Características: Join con cementerios para obtener nombre

3. **SP_CEMENTERIOS_DIFUNTO_CREATE**
   - Tipo: Transaccional (INSERT)
   - Parámetros: 19 parámetros (datos completos del difunto)
   - Retorna: success (BOOLEAN), message (TEXT), difunto_id (INTEGER)
   - Tablas: difuntos, cementerios, lotes
   - Validaciones:
     - Cementerio existe y está activo
     - Número de registro único
     - Lote/fosa disponible
   - Características: Calcula edad automáticamente, actualiza ocupación de lote

4. **SP_CEMENTERIOS_CEMENTERIOS_LIST**
   - Tipo: Consulta lista
   - Parámetros: Ninguno
   - Retorna: Lista completa de cementerios con estadísticas
   - Tablas: cementerios, difuntos
   - Características: Calcula ocupados, disponibles por cementerio

5. **SP_CEMENTERIOS_LOTES_LIST**
   - Tipo: Consulta con filtros
   - Parámetros: p_cementerio_id, p_seccion, p_estado
   - Retorna: Lista de lotes con información de ocupación
   - Tablas: lotes, difuntos
   - Características: LEFT JOIN para mostrar difunto si está ocupado

6. **SP_CEMENTERIOS_SERVICIOS_LIST**
   - Tipo: Consulta con paginación
   - Parámetros: p_page, p_limit, p_difunto_id, p_fecha_desde, p_fecha_hasta
   - Retorna: Lista paginada de servicios funerarios
   - Tablas: servicios, difuntos
   - Características: Filtros por difunto y rango de fechas

7. **SP_CEMENTERIOS_PAGOS_LIST**
   - Tipo: Consulta con paginación
   - Parámetros: p_page, p_limit, p_difunto_id, p_fecha_desde, p_fecha_hasta
   - Retorna: Lista paginada de pagos
   - Tablas: pagos, difuntos
   - Características: Filtros por difunto y rango de fechas

8. **SP_CEMENTERIOS_BUSCAR_DIFUNTO**
   - Tipo: Búsqueda avanzada
   - Parámetros: p_criterio, p_tipo_busqueda
   - Retorna: Resultados de búsqueda (máximo 100)
   - Tablas: difuntos, cementerios
   - Tipos de búsqueda: NOMBRE, REGISTRO, SOLICITANTE, UBICACION, GENERAL
   - Características: Búsqueda ILIKE case-insensitive

9. **SP_CEMENTERIOS_ESTADISTICAS**
   - Tipo: Dashboard/Métricas
   - Parámetros: Ninguno
   - Retorna: Estadísticas generales del sistema
   - Tablas: cementerios, difuntos, pagos, servicios, lotes
   - Métricas:
     - Total cementerios activos
     - Total difuntos
     - Registros del mes actual
     - Capacidad total
     - Porcentaje de ocupación
     - Ingresos del mes
     - Servicios del mes
     - Lotes disponibles

**Dependencias:**
- Tablas requeridas: difuntos, cementerios, lotes, servicios, pagos
- Sin dependencias de otros SPs

**Estado de instalación:**
- Prioridad: CRÍTICA (instalar primero)
- Riesgo: BAJO (sin dependencias circulares)

---

#### 1.1.2 - 02_SP_CEMENTERIOS_GESTION_all_procedures.sql

**Estadísticas:**
- Líneas: 462
- SPs: 8
- Tipo: Funciones transaccionales
- Categoría: GESTIÓN - Operaciones de negocio

**Stored Procedures incluidos:**

1. **SP_CEMENTERIOS_SERVICIO_CREATE**
   - Tipo: Transaccional (INSERT)
   - Parámetros: 9 parámetros (datos del servicio funerario)
   - Retorna: success, message, servicio_id
   - Tablas: servicios, difuntos
   - Validaciones: Difunto existe y está activo
   - Estado inicial: 'PROGRAMADO'

2. **SP_CEMENTERIOS_PAGO_CREATE**
   - Tipo: Transaccional (INSERT)
   - Parámetros: 7 parámetros (datos del pago)
   - Retorna: success, message, pago_id
   - Tablas: pagos, difuntos
   - Validaciones:
     - Difunto existe
     - Número de recibo único
   - Estado inicial: 'PAGADO'

3. **SP_CEMENTERIOS_LOTE_LIBERAR**
   - Tipo: Transaccional compleja (UPDATE + INSERT)
   - Parámetros: p_difunto_id, p_motivo_liberacion, p_autorizado_por, p_fecha_exhumacion
   - Retorna: success, message
   - Tablas: difuntos, lotes, historial_exhumaciones
   - Operaciones:
     - Actualiza difunto a 'EXHUMADO'
     - Libera lote (estado 'DISPONIBLE')
     - Registra en historial

4. **SP_CEMENTERIOS_RENOVACION_CREATE**
   - Tipo: Transaccional (INSERT)
   - Parámetros: 6 parámetros (datos de renovación)
   - Retorna: success, message, renovacion_id
   - Tablas: renovaciones, difuntos
   - Características: Calcula nueva fecha de vencimiento
   - Estado inicial: 'PENDIENTE_PAGO'

5. **SP_CEMENTERIOS_RENOVACION_CONFIRMAR**
   - Tipo: Transaccional (UPDATE)
   - Parámetros: p_renovacion_id, p_numero_recibo
   - Retorna: success, message
   - Tablas: renovaciones, difuntos
   - Validaciones: Renovación está pendiente de pago
   - Operaciones:
     - Confirma renovación
     - Actualiza fecha de vencimiento del difunto

6. **SP_CEMENTERIOS_REPORTES_OCUPACION**
   - Tipo: Reporte agregado
   - Parámetros: Ninguno
   - Retorna: Estadísticas por cementerio
   - Tablas: cementerios, difuntos, pagos
   - Métricas por cementerio:
     - Capacidad total
     - Lotes ocupados/disponibles
     - Porcentaje de ocupación
     - Ingresos del mes
     - Nuevos registros del mes

7. **SP_CEMENTERIOS_VENCIMIENTOS_PROXIMOS**
   - Tipo: Reporte filtrado
   - Parámetros: p_dias_anticipacion (default 90)
   - Retorna: Lista de concesiones próximas a vencer
   - Tablas: difuntos, cementerios, lotes
   - Características:
     - Calcula días restantes
     - Sugiere monto de renovación (50% del precio base)
     - Ordenado por fecha de vencimiento

8. **SP_CEMENTERIOS_DASHBOARD_RESUMEN**
   - Tipo: Dashboard completo
   - Parámetros: Ninguno
   - Retorna: Métricas completas del sistema
   - Tablas: cementerios, difuntos, pagos, servicios, renovaciones
   - Métricas:
     - Cementerios activos
     - Total difuntos
     - Registros del mes
     - Capacidad y ocupación
     - Ingresos del mes
     - Servicios del mes
     - Vencimientos próximos (90 días)
     - Renovaciones pendientes

**Dependencias:**
- Tablas requeridas: servicios, pagos, difuntos, lotes, renovaciones, historial_exhumaciones
- Depende de tablas creadas por CORE

**Estado de instalación:**
- Prioridad: ALTA (instalar después de CORE)
- Riesgo: BAJO-MEDIO

---

#### 1.1.3 - 03_SP_CEMENTERIOS_ABC_all_procedures.sql

**Estadísticas:**
- Líneas: 202
- SPs: 5
- Tipo: Funciones de gestión de folios
- Categoría: ABC - Administración de folios

**Stored Procedures incluidos:**

1. **SP_CEMENTERIOS_FOLIO_GET**
   - Tipo: Consulta individual
   - Parámetros: p_folio (VARCHAR)
   - Retorna: Información completa del folio
   - Tablas: folios, difuntos

2. **SP_CEMENTERIOS_FOLIO_HISTORIA**
   - Tipo: Consulta de auditoría
   - Parámetros: p_folio_id
   - Retorna: Historial de movimientos
   - Tablas: historial_folios
   - Ordenado por fecha descendente

3. **SP_CEMENTERIOS_FOLIO_BAJA**
   - Tipo: Transaccional (UPDATE + INSERT)
   - Parámetros: p_folio_id, p_motivo_baja, p_usuario
   - Retorna: success, message
   - Tablas: folios, historial_folios
   - Validaciones: Folio no está ya cancelado
   - Operaciones:
     - Actualiza estado a 'CANCELADO'
     - Registra en historial

4. **SP_CEMENTERIOS_ADICIONALES_GET**
   - Tipo: Consulta lista
   - Parámetros: p_folio_id
   - Retorna: Servicios adicionales del folio
   - Tablas: servicios_adicionales

5. **SP_CEMENTERIOS_REPORTES_MENSUAL**
   - Tipo: Reporte agregado
   - Parámetros: p_año, p_mes, p_cementerio_id (opcional)
   - Retorna: Reporte mensual por cementerio
   - Tablas: cementerios, difuntos, servicios, renovaciones
   - Métricas:
     - Nuevos registros
     - Servicios realizados
     - Ingresos por servicios
     - Renovaciones
     - Ingresos por renovaciones
     - Total ingresos

**Dependencias:**
- Tablas requeridas: folios, difuntos, historial_folios, servicios_adicionales
- Prioridad: MEDIA

---

### 1.2 GRUPO EXACTO - ARCHIVOS DEL SISTEMA LEGACY (36 archivos - 71 SPs)

#### CATEGORÍA: ABCFolio (2 archivos - 4 SPs)

**01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql (2 SPs)**
- sp_13_historia: Guarda historial de modificaciones
- spd_abc_adercm: Recalcula adeudos (alta/baja/modificación)
- Líneas: 59
- Tablas: ta_13_datosrcm, ta_13_datosrcm_historico, ta_13_adeudosrcm

**13_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql (2 SPs)**
- Duplicado del anterior (verificar si son versiones diferentes)
- Líneas: 60

---

#### CATEGORÍA: Recargos (2 archivos - 10 SPs)

**02_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql (5 SPs)**
- sp_recargos_create: Crear recargo
- sp_recargos_update: Actualizar recargo
- sp_recargos_delete: Eliminar recargo
- sp_recargos_list: Listar recargos
- sp_recargos_calcular: Calcular recargos automáticamente
- Líneas: 183
- Tablas: ta_13_recargos

**14_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql (5 SPs)**
- Duplicado del anterior
- Líneas: 183

---

#### CATEGORÍA: Acceso (2 archivos - 2 SPs)

**03_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql (1 SP)**
- sp_acceso_login: Validación de acceso de usuarios
- Líneas: 40
- Tablas: ta_12_passwords

**15_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql (1 SP)**
- Duplicado del anterior
- Líneas: 40

---

#### CATEGORÍA: Bonificaciones (2 archivos - 5 SPs)

**04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql (3 SPs)**
- sp_bonificaciones_create: Crear bonificación
- sp_bonificaciones_update: Actualizar bonificación
- sp_bonificaciones_delete: Eliminar bonificación
- Líneas: 102
- Tablas: ta_13_bonifrcm

**16_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql (2 SPs)**
- Versión reducida (sin delete)
- Líneas: 81

---

#### CATEGORÍA: Consulta Individual (2 archivos - 17 SPs)

**05_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql (11 SPs)**
- sp_conindividual_get
- sp_conindividual_list
- sp_conindividual_adeudos
- sp_conindividual_pagos
- sp_conindividual_bonificaciones
- sp_conindividual_historial
- sp_conindividual_resumen
- sp_conindividual_calculo_total
- sp_conindividual_generar_recibo
- sp_conindividual_aplicar_pago
- sp_conindividual_revertir_pago
- Líneas: 191
- Tablas: ta_13_datosrcm, ta_13_adeudosrcm, ta_13_bonifrcm, ta_13_pagos

**17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql (6 SPs)**
- Versión reducida
- Líneas: 141

---

#### CATEGORÍA: Consultas por Cementerio (6 archivos - 12 SPs)

**06_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql (3 SPs)**
- sp_consultaguad_list: Lista de fosas en Cementerio Guadalajara
- sp_consultaguad_resumen: Resumen estadístico
- sp_consultaguad_detalle: Detalle completo
- Líneas: 149

**18_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql (2 SPs)**
- Versión reducida
- Líneas: 113

**07_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql (3 SPs)**
- sp_consultajardin_list
- sp_consultajardin_resumen
- sp_consultajardin_detalle
- Líneas: 103

**19_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql (2 SPs)**
- Versión reducida
- Líneas: 81

**08_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql (3 SPs)**
- sp_consultasandres_list
- sp_consultasandres_resumen
- sp_consultasandres_detalle
- Líneas: 91

**20_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql (2 SPs)**
- Versión reducida
- Líneas: 66

---

#### CATEGORÍA: Descuentos (2 archivos - 2 SPs)

**09_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql (1 SP)**
- sp_descuentos_aplicar
- Líneas: 72

**21_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql (1 SP)**
- Duplicado
- Líneas: 74

---

#### CATEGORÍA: Estadísticas de Adeudos (2 archivos - 3 SPs)

**10_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql (2 SPs)**
- sp_estad_adeudo_resumen: Resumen por cementerio y año
- sp_estad_adeudo_listado: Listado detallado de adeudos
- Líneas: 78
- Tablas: ta_13_datosrcm, tc_13_cementerios, ta_12_passwords

**22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql (1 SP)**
- Versión reducida
- Líneas: 43

---

#### CATEGORÍA: Liquidaciones (2 archivos - 2 SPs)

**11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql (1 SP)**
- sp_liquidaciones_generar
- Líneas: 75

**23_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql (1 SP)**
- Duplicado
- Líneas: 77

---

#### CATEGORÍA: Lista de Movimientos (2 archivos - 2 SPs)

**12_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql (1 SP)**
- sp_list_mov_cementerios
- Líneas: 84

**24_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql (1 SP)**
- Duplicado
- Líneas: 86

---

#### CATEGORÍA: Módulo (1 archivo - 2 SPs)

**25_SP_CEMENTERIOS_MODULO_EXACTO_all_procedures.sql (2 SPs)**
- sp_modulo_config_get
- sp_modulo_config_update
- Líneas: 97

---

#### CATEGORÍA: Búsquedas Múltiples (3 archivos - 3 SPs)

**26_SP_CEMENTERIOS_MULTIPLENOMBRE_EXACTO_all_procedures.sql (1 SP)**
- sp_multiplenombre_buscar: Búsqueda por nombre
- Líneas: 69

**27_SP_CEMENTERIOS_MULTIPLERCM_EXACTO_all_procedures.sql (1 SP)**
- sp_multiplercm_buscar: Búsqueda por RCM
- Líneas: 78

**28_SP_CEMENTERIOS_MULTIPLEFECHA_EXACTO_all_procedures.sql (1 SP)**
- sp_multiplefecha_buscar: Búsqueda por fecha
- Líneas: 75

---

#### CATEGORÍA: Reportes (2 archivos - 3 SPs)

**29_SP_CEMENTERIOS_REP_BON_EXACTO_all_procedures.sql (1 SP)**
- sp_rep_bon_generar: Reporte de bonificaciones
- Líneas: 85

**30_SP_CEMENTERIOS_REP_A_COBRAR_EXACTO_all_procedures.sql (1 SP)**
- sp_rep_a_cobrar_generar: Reporte de adeudos por cobrar
- Líneas: 52

**31_SP_CEMENTERIOS_RPTTITULOS_EXACTO_all_procedures.sql (2 SPs)**
- sp_rpttitulos_generar
- sp_rpttitulos_detalle
- Líneas: 95

---

#### CATEGORÍA: Títulos (3 archivos - 7 SPs)

**32_SP_CEMENTERIOS_TITULOSSIN_EXACTO_all_procedures.sql (2 SPs)**
- sp_titulossin_list
- sp_titulossin_generar
- Líneas: 127

**33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql (3 SPs)**
- sp_titulos_list
- sp_titulos_generar
- sp_titulos_imprimir
- Líneas: 109

**34_SP_CEMENTERIOS_TRASLADOFOLSIN_EXACTO_all_procedures.sql (1 SP)**
- sp_trasladofolsin_ejecutar
- Líneas: 96

**35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql (2 SPs)**
- sp_traslados_crear
- sp_traslados_confirmar
- Líneas: 134

---

#### CATEGORÍA: Cambio de Contraseña (1 archivo - 1 SP)

**36_SP_CEMENTERIOS_SFRM_CHGPASS_EXACTO_all_procedures.sql (1 SP)**
- sp_sfrm_chgpass: Cambiar contraseña de usuario
- Líneas: 38

---

## 2. RESUMEN DE TABLAS UTILIZADAS

### 2.1 Tablas del Módulo 13 (Cementerios Legacy)

| Tabla | Descripción | Usada por |
|-------|-------------|-----------|
| **ta_13_datosrcm** | Datos principales de fosas RCM | CORE, ABCFolio, Consultas |
| **ta_13_datosrcm_historico** | Historial de cambios | ABCFolio |
| **ta_13_adeudosrcm** | Adeudos por fosa | ABCFolio, ConIndividual, Estadísticas |
| **ta_13_bonifrcm** | Bonificaciones aplicadas | Bonificaciones, ConIndividual |
| **ta_13_recargos** | Recargos por mora | Recargos |
| **ta_13_pagos** | Pagos realizados | ConIndividual, Liquidaciones |
| **tc_13_cementerios** | Catálogo de cementerios | Consultas, Estadísticas |

### 2.2 Tablas CORE (Nuevo Sistema)

| Tabla | Descripción | Usada por |
|-------|-------------|-----------|
| **difuntos** | Registro de difuntos | CORE, GESTIÓN, ABC |
| **cementerios** | Catálogo de cementerios | CORE, GESTIÓN |
| **lotes** | Espacios disponibles | CORE, GESTIÓN |
| **servicios** | Servicios funerarios | CORE, GESTIÓN |
| **pagos** | Pagos registrados | CORE, GESTIÓN, ABC |
| **renovaciones** | Renovaciones de concesión | GESTIÓN |
| **historial_exhumaciones** | Auditoría de exhumaciones | GESTIÓN |
| **folios** | Gestión de folios | ABC |
| **historial_folios** | Auditoría de folios | ABC |
| **servicios_adicionales** | Servicios extra | ABC |

### 2.3 Tablas de Sistema

| Tabla | Descripción | Usada por |
|-------|-------------|-----------|
| **ta_12_passwords** | Usuarios del sistema | Acceso, Estadísticas |

---

## 3. ORDEN DE INSTALACIÓN RECOMENDADO

### FASE 1: CORE (CRÍTICA)
1. ✓ 01_SP_CEMENTERIOS_CORE_all_procedures.sql (9 SPs)
2. ✓ 02_SP_CEMENTERIOS_GESTION_all_procedures.sql (8 SPs)
3. ✓ 03_SP_CEMENTERIOS_ABC_all_procedures.sql (5 SPs)

**Total Fase 1:** 22 SPs

### FASE 2: EXACTO PARTE 1 (OPERACIONES BÁSICAS)
4. 01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql (2 SPs)
5. 02_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql (5 SPs)
6. 03_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql (1 SP)
7. 04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql (3 SPs)

**Total Fase 2:** 11 SPs

### FASE 3: EXACTO PARTE 2 (CONSULTAS Y REPORTES)
8. 05_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql (11 SPs)
9. 06_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql (3 SPs)
10. 07_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql (3 SPs)
11. 08_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql (3 SPs)
12. 09_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql (1 SP)
13. 10_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql (2 SPs)

**Total Fase 3:** 23 SPs

### FASE 4: EXACTO PARTE 3 (GESTIÓN AVANZADA)
14. 11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql (1 SP)
15. 12_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql (1 SP)
16. 25_SP_CEMENTERIOS_MODULO_EXACTO_all_procedures.sql (2 SPs)
17. 26_SP_CEMENTERIOS_MULTIPLENOMBRE_EXACTO_all_procedures.sql (1 SP)
18. 27_SP_CEMENTERIOS_MULTIPLERCM_EXACTO_all_procedures.sql (1 SP)
19. 28_SP_CEMENTERIOS_MULTIPLEFECHA_EXACTO_all_procedures.sql (1 SP)

**Total Fase 4:** 7 SPs

### FASE 5: EXACTO PARTE 4 (REPORTES Y TÍTULOS)
20. 29_SP_CEMENTERIOS_REP_BON_EXACTO_all_procedures.sql (1 SP)
21. 30_SP_CEMENTERIOS_REP_A_COBRAR_EXACTO_all_procedures.sql (1 SP)
22. 31_SP_CEMENTERIOS_RPTTITULOS_EXACTO_all_procedures.sql (2 SPs)
23. 32_SP_CEMENTERIOS_TITULOSSIN_EXACTO_all_procedures.sql (2 SPs)
24. 33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql (3 SPs)
25. 34_SP_CEMENTERIOS_TRASLADOFOLSIN_EXACTO_all_procedures.sql (1 SP)
26. 35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql (2 SPs)

**Total Fase 5:** 12 SPs

### FASE 6: EXACTO DUPLICADOS (VERIFICAR SI SON NECESARIOS)
27. 13_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql (2 SPs)
28. 14_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql (5 SPs)
29. 15_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql (1 SP)
30. 16_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql (2 SPs)
31. 17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql (6 SPs)
32. 18_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql (2 SPs)
33. 19_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql (2 SPs)
34. 20_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql (2 SPs)
35. 21_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql (1 SP)
36. 22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql (1 SP)
37. 23_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql (1 SP)
38. 24_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql (1 SP)

**Total Fase 6:** 26 SPs (posiblemente duplicados)

### FASE 7: UTILIDADES
39. 36_SP_CEMENTERIOS_SFRM_CHGPASS_EXACTO_all_procedures.sql (1 SP)

**Total Fase 7:** 1 SP

---

## 4. POSIBLES ERRORES Y SOLUCIONES

### 4.1 Errores Comunes Esperados

#### Error: Tabla no existe

**Tablas CORE que podrían faltar:**
- difuntos
- cementerios
- lotes
- servicios
- pagos
- renovaciones
- historial_exhumaciones
- folios
- historial_folios
- servicios_adicionales

**Solución:** Crear scripts de creación de tablas antes de instalar SPs

**Tablas LEGACY que podrían faltar:**
- ta_13_datosrcm
- ta_13_datosrcm_historico
- ta_13_adeudosrcm
- ta_13_bonifrcm
- ta_13_recargos
- ta_13_pagos
- tc_13_cementerios

**Solución:** Migrar esquema desde sistema legacy

---

#### Error: SP ya existe

**Causa:** Archivo duplicado (13-24 vs 01-12)
**Solución:** Usar CREATE OR REPLACE (ya implementado) o instalar solo una versión

---

#### Error: Tipo de dato no compatible

**Causa:** Diferencias entre SQL Server y PostgreSQL
**Solución:** Los archivos ya están adaptados a PostgreSQL

---

#### Error: Permiso denegado

**Causa:** Usuario refact no tiene permisos
**Solución:**
```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO refact;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO refact;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO refact;
```

---

### 4.2 Validaciones Pre-Instalación

**Ejecutar antes de instalar:**

```sql
-- 1. Verificar permisos
SELECT has_schema_privilege('refact', 'public', 'CREATE');

-- 2. Verificar tablas CORE
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'difuntos', 'cementerios', 'lotes', 'servicios',
    'pagos', 'renovaciones', 'historial_exhumaciones',
    'folios', 'historial_folios', 'servicios_adicionales'
  );

-- 3. Verificar tablas LEGACY
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (table_name LIKE 'ta_13_%' OR table_name LIKE 'tc_13_%');

-- 4. Verificar tabla de usuarios
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'ta_12_passwords';
```

---

## 5. PRUEBAS POST-INSTALACIÓN

### 5.1 Pruebas de SPs CORE

```sql
-- Test 1: Estadísticas generales
SELECT * FROM SP_CEMENTERIOS_ESTADISTICAS();

-- Test 2: Lista de cementerios
SELECT * FROM SP_CEMENTERIOS_CEMENTERIOS_LIST();

-- Test 3: Búsqueda de difuntos (vacío si no hay datos)
SELECT * FROM SP_CEMENTERIOS_BUSCAR_DIFUNTO('test', 'GENERAL');

-- Test 4: Dashboard resumen
SELECT * FROM SP_CEMENTERIOS_DASHBOARD_RESUMEN();
```

### 5.2 Pruebas de SPs EXACTO

```sql
-- Test 5: Estadísticas de adeudos
SELECT * FROM sp_estad_adeudo_resumen();

-- Test 6: Listado de adeudos
SELECT * FROM sp_estad_adeudo_listado(2020);
```

### 5.3 Pruebas de SPs Transaccionales (con datos de prueba)

**IMPORTANTE:** Solo si existen datos de prueba en las tablas

```sql
-- Test 7: Crear bonificación (ajustar parámetros según datos reales)
-- SELECT sp_bonificaciones_create(...);

-- Test 8: Generar reporte de bonificaciones
-- SELECT * FROM sp_rep_bon_generar(2025, 1);
```

---

## 6. ARCHIVOS GENERADOS

### 6.1 Script de Instalación Automática
**Archivo:** `INSTALL_CEMENTERIOS_SPS.sh`
**Uso:**
```bash
chmod +x INSTALL_CEMENTERIOS_SPS.sh
./INSTALL_CEMENTERIOS_SPS.sh
```

### 6.2 Checklist Manual
**Archivo:** `CHECKLIST_INSTALACION_CEMENTERIOS.md`
**Uso:** Seguir paso a paso para instalación manual

### 6.3 Script de Verificación
**Archivo:** `VERIFICACION_POST_INSTALACION.sql`
**Uso:**
```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f VERIFICACION_POST_INSTALACION.sql
```

### 6.4 Este Informe
**Archivo:** `INFORME_DETALLADO_CEMENTERIOS_SPS.md`
**Uso:** Documentación técnica completa

---

## 7. RECOMENDACIONES

### 7.1 Antes de Instalar

1. ✓ **Hacer backup completo de la base de datos**
   ```bash
   pg_dump -h 192.168.6.146 -U refact padron_licencias > backup_pre_cementerios.sql
   ```

2. ✓ **Verificar que existen todas las tablas necesarias**
   - Ejecutar queries de validación (Sección 4.2)

3. ✓ **Verificar permisos del usuario refact**

4. ✓ **Tener acceso a logs de PostgreSQL**

### 7.2 Durante la Instalación

1. ✓ **Instalar en orden recomendado** (Sección 3)

2. ✓ **Documentar cada error encontrado**

3. ✓ **No continuar si hay errores críticos en FASE 1**

4. ✓ **Revisar archivos duplicados (13-24)**
   - Determinar si son necesarios
   - Verificar diferencias con versiones 01-12

### 7.3 Después de Instalar

1. ✓ **Ejecutar script de verificación**
   ```bash
   psql -h 192.168.6.146 -U refact -d padron_licencias -f VERIFICACION_POST_INSTALACION.sql
   ```

2. ✓ **Ejecutar pruebas de SPs críticos** (Sección 5)

3. ✓ **Verificar que el total de SPs instalados sea 93**
   - Si hay menos, revisar errores
   - Si hay más, revisar duplicados

4. ✓ **Probar integración con backend**
   - GenericController debe poder llamar a los SPs
   - Verificar conexión desde PHP

5. ✓ **Probar integración con frontend**
   - apiService.js debe poder consumir endpoints
   - Verificar respuestas en componentes Vue

### 7.4 Siguiente Fase

1. ✓ **Crear datos de prueba** (si no existen)
   - Cementerios de ejemplo
   - Difuntos de ejemplo
   - Lotes de ejemplo

2. ✓ **Documentar SPs para desarrolladores**
   - Parámetros de entrada
   - Estructura de salida
   - Ejemplos de uso

3. ✓ **Crear pruebas unitarias**
   - Para cada SP crítico
   - Casos de éxito y error

4. ✓ **Optimizar SPs lentos**
   - Agregar índices si es necesario
   - Revisar EXPLAIN ANALYZE

---

## 8. MÉTRICAS ESPERADAS POST-INSTALACIÓN

| Métrica | Valor Esperado |
|---------|----------------|
| **Total SPs instalados** | 93 |
| **SPs CORE** | 22 |
| **SPs EXACTO únicos** | 45 |
| **SPs EXACTO duplicados** | 26 |
| **Tiempo de instalación** | 5-10 minutos |
| **Errores esperados** | 0-5 (tablas faltantes) |
| **Pruebas exitosas** | 5/5 |

---

## 9. CONTACTO Y SOPORTE

**Si encuentras errores durante la instalación:**

1. Revisar el log de instalación
2. Consultar sección 4 (Errores y Soluciones)
3. Ejecutar script de verificación
4. Documentar el error en el checklist
5. Consultar con el equipo de desarrollo

---

## ANEXO A: LISTA COMPLETA DE 93 STORED PROCEDURES

### CORE (22 SPs)

#### 01_SP_CEMENTERIOS_CORE_all_procedures.sql (9)
1. SP_CEMENTERIOS_DIFUNTOS_LIST
2. SP_CEMENTERIOS_DIFUNTO_GET
3. SP_CEMENTERIOS_DIFUNTO_CREATE
4. SP_CEMENTERIOS_CEMENTERIOS_LIST
5. SP_CEMENTERIOS_LOTES_LIST
6. SP_CEMENTERIOS_SERVICIOS_LIST
7. SP_CEMENTERIOS_PAGOS_LIST
8. SP_CEMENTERIOS_BUSCAR_DIFUNTO
9. SP_CEMENTERIOS_ESTADISTICAS

#### 02_SP_CEMENTERIOS_GESTION_all_procedures.sql (8)
10. SP_CEMENTERIOS_SERVICIO_CREATE
11. SP_CEMENTERIOS_PAGO_CREATE
12. SP_CEMENTERIOS_LOTE_LIBERAR
13. SP_CEMENTERIOS_RENOVACION_CREATE
14. SP_CEMENTERIOS_RENOVACION_CONFIRMAR
15. SP_CEMENTERIOS_REPORTES_OCUPACION
16. SP_CEMENTERIOS_VENCIMIENTOS_PROXIMOS
17. SP_CEMENTERIOS_DASHBOARD_RESUMEN

#### 03_SP_CEMENTERIOS_ABC_all_procedures.sql (5)
18. SP_CEMENTERIOS_FOLIO_GET
19. SP_CEMENTERIOS_FOLIO_HISTORIA
20. SP_CEMENTERIOS_FOLIO_BAJA
21. SP_CEMENTERIOS_ADICIONALES_GET
22. SP_CEMENTERIOS_REPORTES_MENSUAL

### EXACTO - Primera Versión (45 SPs)

23-24. sp_13_historia, spd_abc_adercm (ABCFolio)
25-29. sp_recargos_* (5 SPs de Recargos)
30. sp_acceso_login (Acceso)
31-33. sp_bonificaciones_* (3 SPs de Bonificaciones)
34-44. sp_conindividual_* (11 SPs de Consulta Individual)
45-47. sp_consultaguad_* (3 SPs Cementerio Guadalajara)
48-50. sp_consultajardin_* (3 SPs Cementerio Jardín)
51-53. sp_consultasandres_* (3 SPs Cementerio San Andrés)
54. sp_descuentos_aplicar (Descuentos)
55-56. sp_estad_adeudo_* (2 SPs Estadísticas)
57. sp_liquidaciones_generar (Liquidaciones)
58. sp_list_mov_cementerios (Lista de Movimientos)
59-60. sp_modulo_config_* (2 SPs Módulo)
61-63. sp_multiple*_buscar (3 SPs Búsquedas Múltiples)
64-65. sp_rep_bon_generar, sp_rep_a_cobrar_generar (2 SPs Reportes)
66-67. sp_rpttitulos_* (2 SPs)
68-69. sp_titulossin_* (2 SPs)
70-72. sp_titulos_* (3 SPs)
73. sp_trasladofolsin_ejecutar
74-75. sp_traslados_* (2 SPs)

### EXACTO - Segunda Versión (26 SPs - posiblemente duplicados)

76-77. sp_13_historia, spd_abc_adercm (duplicados)
78-82. sp_recargos_* (5 SPs duplicados)
83. sp_acceso_login (duplicado)
84-85. sp_bonificaciones_* (2 SPs - versión reducida)
86-91. sp_conindividual_* (6 SPs - versión reducida)
92-93. sp_consultaguad_* (2 SPs - versión reducida)
... (continúa con versiones reducidas)

### UTILIDADES (1 SP)

93. sp_sfrm_chgpass (Cambio de contraseña)

---

**FIN DEL INFORME**

---

**Generado por:** Claude Code (Anthropic)
**Fecha:** 2025-11-09
**Versión:** 1.0
**Estado:** LISTO PARA INSTALACIÓN
