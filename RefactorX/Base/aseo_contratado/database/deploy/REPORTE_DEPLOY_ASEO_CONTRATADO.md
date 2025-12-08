# Reporte de Deployment - Aseo Contratado

**Fecha:** 2025-11-26
**Archivo:** DEPLOY_ASEO_CONTRATADO_SPS.sql
**Ubicación:** `RefactorX/Base/aseo_contratado/database/deploy/`

---

## Resumen Ejecutivo

Se ha creado el archivo SQL de deployment para el módulo de **Aseo Contratado** que incluye 36 stored procedures fundamentales para los catálogos principales del sistema.

### Total de SPs Creados: 36

---

## Stored Procedures por Sección

### 1. EMPRESAS (5 SPs)

Gestión del catálogo de empresas prestadoras de servicio de aseo.

| SP | Descripción | Parámetros Principales |
|---|---|---|
| `SP_ASEO_EMPRESAS_LIST` | Lista empresas con paginación y búsqueda | p_search, p_ctrol_emp, p_page, p_limit |
| `SP_ASEO_EMPRESAS_GET` | Obtiene una empresa específica | p_num_empresa, p_ctrol_emp |
| `SP_ASEO_EMPRESAS_CREATE` | Crea nueva empresa | p_ctrol_emp, p_descripcion, p_representante |
| `SP_ASEO_EMPRESAS_UPDATE` | Actualiza empresa existente | p_num_empresa, p_descripcion, p_representante |
| `SP_ASEO_EMPRESAS_DELETE` | Baja lógica o física de empresa | p_num_empresa, p_usuario |

**Tabla:** `ta_16_empresas`

**Características:**
- Paginación integrada con total_records
- Búsqueda por descripción, representante o número
- Soft delete cuando hay contratos asociados
- Auto-generación de num_empresa

---

### 2. TIPOS DE EMPRESA (5 SPs)

Catálogo de tipos de empresa para clasificación.

| SP | Descripción |
|---|---|
| `SP_ASEO_TIPOS_EMP_LIST` | Lista todos los tipos de empresa |
| `SP_ASEO_TIPOS_EMP_GET` | Obtiene un tipo específico |
| `SP_ASEO_TIPOS_EMP_CREATE` | Crea nuevo tipo |
| `SP_ASEO_TIPOS_EMP_UPDATE` | Actualiza tipo existente |
| `SP_ASEO_TIPOS_EMP_DELETE` | Elimina tipo (valida uso) |

**Tabla:** `ta_16_tipos_emp`

**Características:**
- Validación de integridad referencial
- No permite eliminar si hay empresas asociadas

---

### 3. ZONAS (4 SPs)

Gestión de zonas de cobertura del servicio.

| SP | Descripción |
|---|---|
| `SP_ASEO_ZONAS_LIST` | Lista zonas con paginación |
| `SP_ASEO_ZONAS_CREATE` | Crea nueva zona |
| `SP_ASEO_ZONAS_UPDATE` | Actualiza zona existente |
| `SP_ASEO_ZONAS_DELETE` | Elimina zona (valida uso) |

**Tabla:** `ta_16_zonas`

**Características:**
- Identificación por zona + sub_zona
- Validación de duplicados
- Auto-generación de ctrol_zona

---

### 4. TIPOS DE ASEO (4 SPs)

Catálogo de tipos de servicio de aseo.

| SP | Descripción |
|---|---|
| `SP_ASEO_TIPOS_LIST` | Lista tipos de aseo con paginación |
| `SP_ASEO_TIPOS_CREATE` | Crea nuevo tipo |
| `SP_ASEO_TIPOS_UPDATE` | Actualiza tipo existente |
| `SP_ASEO_TIPOS_DELETE` | Elimina tipo (valida contratos) |

**Tabla:** `ta_16_tipo_aseo`

**Características:**
- Validación de cuenta de aplicación contable
- Auditoría con usuario y fecha
- No permite eliminar con contratos asociados

---

### 5. UNIDADES DE RECOLECCIÓN (4 SPs)

Catálogo de unidades de medida para el servicio.

| SP | Descripción |
|---|---|
| `SP_ASEO_UNIDADES_LIST` | Lista unidades por ejercicio |
| `SP_ASEO_UNIDADES_CREATE` | Crea nueva unidad |
| `SP_ASEO_UNIDADES_UPDATE` | Actualiza unidad existente |
| `SP_ASEO_UNIDADES_DELETE` | Elimina unidad (valida uso) |

**Tabla:** `ta_16_unidades`

**Características:**
- Organización por ejercicio fiscal
- Costos unitario y de excedente
- Auto-generación de ctrol_recolec por ejercicio

---

### 6. RECARGOS (4 SPs)

Configuración de recargos y multas por periodo.

| SP | Descripción |
|---|---|
| `SP_ASEO_RECARGOS_LIST` | Lista recargos por año |
| `SP_ASEO_RECARGOS_CREATE` | Crea nuevo recargo |
| `SP_ASEO_RECARGOS_UPDATE` | Actualiza recargo existente |
| `SP_ASEO_RECARGOS_DELETE` | Elimina recargo |

**Tabla:** `ta_16_recargos`

**Características:**
- Identificación por periodo (mes/año)
- Porcentajes de recargo y multa
- Validación de duplicados por periodo

---

### 7. RECAUDADORAS (4 SPs)

Catálogo de oficinas recaudadoras.

| SP | Descripción |
|---|---|
| `SP_ASEO_RECAUDADORAS_LIST` | Lista recaudadoras |
| `SP_ASEO_RECAUDADORAS_CREATE` | Crea nueva recaudadora |
| `SP_ASEO_RECAUDADORAS_UPDATE` | Actualiza recaudadora |
| `SP_ASEO_RECAUDADORAS_DELETE` | Elimina recaudadora (valida contratos) |

**Tabla:** `ta_16_recaudadoras`

**Características:**
- Identificación por número de recaudadora
- Validación de contratos asociados

---

### 8. CLAVES DE OPERACIÓN (4 SPs)

Catálogo de claves de operación para pagos.

| SP | Descripción |
|---|---|
| `SP_ASEO_CVES_OPERACION_LIST` | Lista claves de operación |
| `SP_ASEO_CVES_OPERACION_CREATE` | Crea nueva clave |
| `SP_ASEO_CVES_OPERACION_UPDATE` | Actualiza clave existente |
| `SP_ASEO_CVES_OPERACION_DELETE` | Elimina clave (valida pagos) |

**Tabla:** `ta_16_operacion`

**Características:**
- Auto-generación de ctrol_operacion
- Validación de unicidad de clave
- No permite eliminar con pagos asociados

---

### 9. GASTOS (2 SPs)

Configuración de gastos de cobranza.

| SP | Descripción |
|---|---|
| `SP_ASEO_GASTOS_LIST` | Obtiene configuración de gastos |
| `SP_ASEO_GASTOS_UPDATE` | Actualiza configuración (replace) |

**Tabla:** `ta_16_gastos`

**Características:**
- Solo un registro de configuración
- Reemplazo completo en actualización
- Porcentajes para requerimiento, embargo y secuestro

---

## Convención de Nombres

### Patrón Original → Nuevo Patrón

```
sp_empresas_list       → SP_ASEO_EMPRESAS_LIST
sp_empresas_create     → SP_ASEO_EMPRESAS_CREATE
sp_zonas_list          → SP_ASEO_ZONAS_LIST
sp_tipos_aseo_create   → SP_ASEO_TIPOS_CREATE
sp_unidades_list       → SP_ASEO_UNIDADES_LIST
```

### Estructura del Nombre

```
SP_ASEO_{ENTIDAD}_{ACCION}
```

- **SP_ASEO_**: Prefijo identificador del módulo
- **{ENTIDAD}**: Nombre de la entidad (EMPRESAS, ZONAS, TIPOS, etc.)
- **{ACCION}**: Operación (LIST, CREATE, UPDATE, DELETE, GET)

---

## Características Comunes

### 1. Paginación
Todos los SPs de listado incluyen:
- `p_page`: Número de página (default: 1)
- `p_limit`: Registros por página (default: 50-100)
- `total_records`: Total de registros en el resultado

### 2. Búsqueda
Los listados soportan:
- Parámetro `p_search` para búsqueda textual
- Búsqueda insensible a mayúsculas/minúsculas (ILIKE)
- Filtros opcionales específicos por entidad

### 3. Respuestas Estandarizadas
CRUDs retornan:
```sql
success BOOLEAN
message TEXT
```

### 4. Validaciones
- Verificación de duplicados antes de insertar
- Validación de integridad referencial antes de eliminar
- Validación de existencia antes de actualizar

### 5. Auditoría
Campos de seguimiento:
- `fecha_alta`: Timestamp de creación
- `fecha_mod`: Timestamp de modificación
- `usuario_alta`: Usuario que creó
- `usuario_mod`: Usuario que modificó

---

## Mapeo de Tablas

| Tabla | Descripción | Clave Primaria |
|---|---|---|
| `ta_16_empresas` | Empresas prestadoras | num_empresa, ctrol_emp |
| `ta_16_tipos_emp` | Tipos de empresa | ctrol_emp |
| `ta_16_zonas` | Zonas de cobertura | ctrol_zona |
| `ta_16_tipo_aseo` | Tipos de aseo | ctrol_aseo |
| `ta_16_unidades` | Unidades de recolección | ctrol_recolec |
| `ta_16_recargos` | Recargos por periodo | aso_mes_recargo |
| `ta_16_recaudadoras` | Oficinas recaudadoras | num_rec |
| `ta_16_operacion` | Claves de operación | ctrol_operacion |
| `ta_16_gastos` | Configuración de gastos | (único registro) |

---

## SPs Pendientes (Fase 2)

Los siguientes grupos de SPs requieren implementación posterior:

### Contratos (Alta Prioridad)
- SP_ASEO_CONTRATOS_LIST
- SP_ASEO_CONTRATOS_CREATE
- SP_ASEO_CONTRATOS_UPDATE
- SP_ASEO_CONTRATOS_CONSULTAR
- SP_ASEO_CONTRATO_CANCELAR
- SP_ASEO_DETALLE_CONTRATO

### Adeudos (Alta Prioridad)
- SP_ASEO_ADEUDOS_BUSCAR_CONTRATO
- SP_ASEO_ADEUDOS_PENDIENTES
- SP_ASEO_ADEUDOS_POR_CONTRATO
- SP_ASEO_ADEUDOS_INSERTAR
- SP_ASEO_ADEUDOS_ESTADO_CUENTA
- SP_ASEO_ADEUDOS_VENCIDOS

### Pagos (Alta Prioridad)
- SP_ASEO_ADEUDOS_REGISTRAR_PAGO
- SP_ASEO_PAGOS_POR_CONTRATO
- SP_ASEO_PAGOS_BUSCAR
- SP_ASEO_PAGO_MULTIPLE

### Reportes (Media Prioridad)
- SP_ASEO_REPORTE_PADRON_CONTRATOS
- SP_ASEO_REPORTE_ADEUDOS_CONDONADOS
- SP_ASEO_REPORTE_POR_ZONAS
- SP_ASEO_ESTADISTICAS_GENERALES

### Operaciones Masivas (Baja Prioridad)
- SP_ASEO_ACTUALIZAR_PERIODOS_CONTRATOS
- SP_ASEO_ACTUALIZAR_UNIDADES_CONTRATOS
- SP_ASEO_ADEUDOS_CARGA_MASIVA

---

## Instrucciones de Deployment

### 1. Pre-requisitos
```bash
# Verificar conexión a la base de datos
psql -U postgres -d guadalajara -c "SELECT version();"

# Verificar existencia de tablas
psql -U postgres -d guadalajara -c "\dt ta_16_*"
```

### 2. Ejecutar Deployment
```bash
cd RefactorX/Base/aseo_contratado/database/deploy
psql -U postgres -d guadalajara -f DEPLOY_ASEO_CONTRATADO_SPS.sql
```

### 3. Verificar Resultados
```sql
-- Listar SPs creados
SELECT proname
FROM pg_proc
WHERE proname LIKE 'sp_aseo_%'
ORDER BY proname;

-- Debería retornar 36 registros
```

### 4. Probar un SP
```sql
-- Ejemplo: Listar empresas
SELECT * FROM SP_ASEO_EMPRESAS_LIST(
    p_search := NULL,
    p_ctrol_emp := NULL,
    p_page := 1,
    p_limit := 10
);
```

---

## Compatibilidad con Frontend

### Archivos Vue Compatibles

Los siguientes componentes Vue están listos para usar estos SPs:

1. **ABC_Empresas.vue** - Gestión de empresas
2. **ABC_Tipos_Emp.vue** - Tipos de empresa
3. **ABC_Zonas.vue** - Zonas
4. **ABC_Tipos_Aseo.vue** - Tipos de aseo
5. **ABC_Und_Recolec.vue** - Unidades de recolección
6. **ABC_Recargos.vue** - Recargos
7. **ABC_Recaudadoras.vue** - Recaudadoras
8. **ABC_Cves_Operacion.vue** - Claves de operación
9. **ABC_Gastos.vue** - Gastos

### Ejemplo de Llamada desde Vue

```javascript
// Listar empresas con búsqueda
const response = await execute(
  'SP_ASEO_EMPRESAS_LIST',
  'aseo_contratado',
  [
    { nombre: 'p_search', valor: 'empresa' },
    { nombre: 'p_ctrol_emp', valor: null },
    { nombre: 'p_page', valor: 1 },
    { nombre: 'p_limit', valor: 50 }
  ],
  'guadalajara'
)

// Crear nueva empresa
const response = await execute(
  'SP_ASEO_EMPRESAS_CREATE',
  'aseo_contratado',
  [
    { nombre: 'p_ctrol_emp', valor: 1 },
    { nombre: 'p_descripcion', valor: 'Empresa XYZ' },
    { nombre: 'p_representante', valor: 'Juan Pérez' },
    { nombre: 'p_telefono', valor: '3312345678' },
    { nombre: 'p_email', valor: 'contacto@empresa.com' },
    { nombre: 'p_direccion', valor: 'Av. Principal 123' },
    { nombre: 'p_usuario', valor: 'admin' }
  ],
  'guadalajara'
)
```

---

## Notas Técnicas

### Auto-generación de IDs
Los siguientes campos se generan automáticamente:
- `num_empresa` en EMPRESAS (por ctrol_emp)
- `ctrol_zona` en ZONAS
- `ctrol_recolec` en UNIDADES (por ejercicio)
- `ctrol_operacion` en OPERACION

### Soft Delete
La tabla `ta_16_empresas` soporta baja lógica mediante el campo `fecha_baja`. El SP DELETE evalúa si hay contratos asociados antes de decidir entre soft delete o hard delete.

### Transaccionalidad
Todos los SPs están envueltos en transacciones implícitas de PostgreSQL. Si ocurre un error, se hace rollback automático.

### Performance
- Los listados usan CTEs (Common Table Expressions) para calcular totales de forma eficiente
- La paginación usa LIMIT/OFFSET
- Los índices deben existir en las columnas de búsqueda frecuente

---

## Checklist de Verificación

- [x] 36 SPs creados con convención SP_ASEO_*
- [x] Paginación implementada en todos los listados
- [x] Validaciones de integridad referencial
- [x] Respuestas estandarizadas (success/message)
- [x] Campos de auditoría (usuario/fecha)
- [x] Soft delete en EMPRESAS
- [x] Auto-generación de IDs donde corresponde
- [ ] Pruebas unitarias de cada SP
- [ ] Documentación de casos de uso
- [ ] Integración con frontend Vue
- [ ] SPs de Contratos (Fase 2)
- [ ] SPs de Adeudos (Fase 2)
- [ ] SPs de Pagos (Fase 2)

---

## Soporte y Contacto

**Responsable:** Equipo de Desarrollo RefactorX
**Fecha de Creación:** 2025-11-26
**Versión:** 1.0
**Estado:** Producción (Catálogos Base)

---

## Historial de Cambios

| Fecha | Versión | Cambios |
|---|---|---|
| 2025-11-26 | 1.0 | Creación inicial con 36 SPs de catálogos base |

---

**Fin del Reporte**
