# REPORTE DE IMPLEMENTACIÓN - CERTIFICACIONESFRM

## Información General

- **Componente:** certificacionesfrm
- **Descripción:** Gestión completa de certificaciones
- **Fecha:** 2025-11-20
- **Estado:** IMPLEMENTADO CON LOGICA REAL
- **Schema:** public
- **Tabla principal:** public.certificaciones

## Stored Procedures Implementados

### Total: 7 SPs

| # | Nombre SP | Tipo | Descripción | Estado |
|---|-----------|------|-------------|--------|
| 1 | `sp_certificaciones_list` | Report | Listar certificaciones por tipo | ✅ IMPLEMENTADO |
| 2 | `sp_certificaciones_get` | Catalog | Obtener certificación por ID | ✅ IMPLEMENTADO |
| 3 | `sp_certificaciones_create` | CRUD | Crear certificación con folio automático | ✅ IMPLEMENTADO |
| 4 | `sp_certificaciones_update` | CRUD | Actualizar certificación vigente | ✅ IMPLEMENTADO |
| 5 | `sp_certificaciones_cancel` | CRUD | Cancelar certificación (soft delete) | ✅ IMPLEMENTADO |
| 6 | `sp_certificaciones_search` | Report | Búsqueda avanzada con filtros | ✅ IMPLEMENTADO |
| 7 | `sp_certificaciones_print` | Report | Datos para impresión en JSON | ✅ IMPLEMENTADO |

## Detalle de Implementación

### 1. sp_certificaciones_list

**Firma:**
```sql
sp_certificaciones_list(p_tipo TEXT)
```

**Funcionalidad:**
- Lista todas las certificaciones de un tipo específico
- Ordena por año y folio descendente
- Validación obligatoria del parámetro tipo

**Retorna:**
- id, axo, folio, id_licencia, partidapago, observacion, vigente, feccap, capturista, tipo

---

### 2. sp_certificaciones_get

**Firma:**
```sql
sp_certificaciones_get(p_id INT)
```

**Funcionalidad:**
- Obtiene el detalle completo de una certificación por ID
- Incluye campos licencia y anuncio
- Valida existencia del registro
- Excepción si no existe

**Retorna:**
- Registro completo con todos los campos de la tabla

---

### 3. sp_certificaciones_create

**Firma:**
```sql
sp_certificaciones_create(
    p_tipo TEXT,
    p_id_licencia INT,
    p_observacion TEXT,
    p_partidapago TEXT,
    p_capturista TEXT
)
```

**Funcionalidad:**
- Crea nueva certificación
- Genera folio automático desde `parametros_lic.certificacion`
- Incrementa el contador global
- Asigna año actual automáticamente
- Estado inicial 'V' (Vigente)
- Obtiene número de licencia y anuncio de la tabla licencias
- Validaciones exhaustivas:
  - Tipo requerido
  - ID licencia válido y existente
  - Capturista requerido

**Retorna:**
- ID de la nueva certificación creada

**Algoritmo de folio:**
1. Obtiene folio actual de `parametros_lic`
2. Incrementa en 1
3. Actualiza parámetro
4. Asigna a nueva certificación
5. Si no existe parámetro, inicializa en 1

---

### 4. sp_certificaciones_update

**Firma:**
```sql
sp_certificaciones_update(
    p_id INT,
    p_observacion TEXT,
    p_partidapago TEXT,
    p_capturista TEXT
)
```

**Funcionalidad:**
- Actualiza certificación existente
- Solo permite modificar certificaciones VIGENTES
- Actualiza observacion, partidapago y capturista
- Valida estado antes de modificar
- Excepción si está cancelada

**Retorna:**
- TRUE si actualiza exitosamente
- FALSE si no encuentra registro

---

### 5. sp_certificaciones_cancel

**Firma:**
```sql
sp_certificaciones_cancel(
    p_id INT,
    p_motivo TEXT,
    p_capturista TEXT
)
```

**Funcionalidad:**
- Cancelación lógica (soft delete)
- Cambia estado a 'C' (Cancelada)
- Preserva observación anterior
- Formato: "CANCELADA - [motivo] | Obs.Anterior: [obs]"
- Actualiza fecha de captura
- Valida que no esté ya cancelada
- Motivo obligatorio

**Retorna:**
- TRUE si cancela exitosamente
- Excepción si ya está cancelada

---

### 6. sp_certificaciones_search

**Firma:**
```sql
sp_certificaciones_search(
    p_axo INT DEFAULT NULL,
    p_folio INT DEFAULT NULL,
    p_id_licencia INT DEFAULT NULL,
    p_feccap_ini DATE DEFAULT NULL,
    p_feccap_fin DATE DEFAULT NULL,
    p_tipo TEXT DEFAULT NULL,
    p_vigente TEXT DEFAULT NULL
)
```

**Funcionalidad:**
- Búsqueda avanzada con 7 filtros opcionales
- Todos los parámetros son opcionales
- Combina filtros con AND lógico
- Valida rango de fechas (inicio <= fin)
- Valida estado vigente (V/C)
- Ordena por año y folio descendente

**Parámetros:**
- `p_axo`: Año de emisión
- `p_folio`: Número de folio
- `p_id_licencia`: ID de licencia
- `p_feccap_ini`: Fecha captura desde
- `p_feccap_fin`: Fecha captura hasta
- `p_tipo`: Tipo de certificación
- `p_vigente`: Estado (V=Vigente, C=Cancelada, NULL=Todas)

**Retorna:**
- Listado de certificaciones que cumplen los filtros

---

### 7. sp_certificaciones_print

**Firma:**
```sql
sp_certificaciones_print(p_id INT)
```

**Funcionalidad:**
- Obtiene datos completos para impresión
- Retorna 3 objetos JSON:
  1. **certificacion**: Datos completos + folio_completo (formato: año-folio)
  2. **licencia**: Datos completos + nombre_completo concatenado
  3. **pagos**: Array de pagos (concepto 8 = certificaciones)
- Formatea fechas y horas
- Ordena pagos por fecha/hora descendente

**Retorna:**
- 3 columnas tipo JSON con toda la información

**Estructura JSON certificación:**
```json
{
  "id": 1,
  "axo": 2024,
  "folio": 1234,
  "folio_completo": "2024-001234",
  "id_licencia": 123,
  "partidapago": "001.001.001",
  "observacion": "...",
  "vigente": "V",
  "feccap": "2024-11-20",
  "capturista": "admin",
  "tipo": "ANUAL",
  "licencia": 123,
  "anuncio": 0
}
```

## Características Implementadas

### ✅ Validaciones Completas
- Parámetros obligatorios verificados
- Tipos de datos validados
- Rangos lógicos validados
- Existencia de registros relacionados

### ✅ Manejo de Errores
- Excepciones con mensajes descriptivos
- RAISE EXCEPTION para errores
- Bloques EXCEPTION WHEN OTHERS
- Mensajes informativos al usuario

### ✅ Soft Delete
- No eliminación física
- Campo `vigente` (V/C)
- Preservación de histórico
- Cancelación con motivo

### ✅ Generación Automática
- Folios consecutivos desde `parametros_lic`
- Año automático (EXTRACT YEAR)
- Manejo de contador global
- Thread-safe con UPDATE

### ✅ Datos Enriquecidos
- Folio completo formateado
- Nombre completo concatenado
- Fechas formateadas para impresión
- Relaciones con licencias y pagos

### ✅ Búsqueda Flexible
- Filtros opcionales múltiples
- Combinación dinámica
- Sin filtros = todos los registros
- Ordenamiento consistente

### ✅ Formato JSON
- Impresión con datos relacionados
- Estructura clara y completa
- Arrays para colecciones
- Objetos vacíos cuando no hay datos

## Estructura de Tabla

```sql
public.certificaciones
├── id (PK)                 - ID único
├── axo                     - Año de emisión
├── folio                   - Número de folio
├── id_licencia (FK)        - Licencia certificada
├── partidapago             - Partida presupuestal
├── observacion             - Observaciones/motivo
├── vigente                 - V=Vigente, C=Cancelada
├── feccap                  - Fecha de captura
├── capturista              - Usuario responsable
├── tipo                    - Tipo de certificación
├── licencia                - Número licencia (redundante)
└── anuncio                 - Número anuncio asociado
```

## Dependencias

### Tablas Relacionadas:
- `public.certificaciones` - Tabla principal
- `public.parametros_lic` - Contador de folios
- `public.licencias` - Datos de licencias
- `public.pagos` - Pagos asociados

### Campos en parametros_lic:
- `certificacion` - Contador de folios

## Ejemplos de Uso

### Listar por tipo
```sql
SELECT * FROM public.sp_certificaciones_list('ANUAL');
```

### Obtener detalle
```sql
SELECT * FROM public.sp_certificaciones_get(1);
```

### Crear certificación
```sql
SELECT public.sp_certificaciones_create(
    'ANUAL',
    123,
    'Certificación de licencia vigente',
    '001.001.001',
    'admin'
);
-- Retorna: 1 (nuevo ID)
```

### Actualizar
```sql
SELECT public.sp_certificaciones_update(
    1,
    'Observación actualizada',
    '001.001.002',
    'admin'
);
-- Retorna: true
```

### Cancelar
```sql
SELECT public.sp_certificaciones_cancel(
    1,
    'Certificación duplicada por error',
    'admin'
);
-- Retorna: true
```

### Buscar con filtros
```sql
-- Todas las certificaciones vigentes de 2024
SELECT * FROM public.sp_certificaciones_search(
    2024,        -- año
    NULL,        -- folio
    NULL,        -- id_licencia
    NULL,        -- fecha inicio
    NULL,        -- fecha fin
    NULL,        -- tipo
    'V'          -- solo vigentes
);

-- Por rango de fechas
SELECT * FROM public.sp_certificaciones_search(
    NULL,
    NULL,
    NULL,
    '2024-01-01',
    '2024-12-31',
    'ANUAL',
    NULL
);
```

### Datos para impresión
```sql
SELECT * FROM public.sp_certificaciones_print(1);
-- Retorna: 3 columnas JSON (certificacion, licencia, pagos)
```

## Testing Recomendado

### Test 1: Crear certificación
```sql
-- Crear
SELECT public.sp_certificaciones_create('ANUAL', 1, 'Test', '001', 'admin');

-- Verificar folio incrementado
SELECT certificacion FROM public.parametros_lic;
```

### Test 2: Actualizar
```sql
-- Actualizar vigente (debe funcionar)
SELECT public.sp_certificaciones_update(1, 'Nueva obs', '002', 'admin');

-- Cancelar
SELECT public.sp_certificaciones_cancel(1, 'Test', 'admin');

-- Intentar actualizar cancelada (debe fallar)
SELECT public.sp_certificaciones_update(1, 'Otra obs', '003', 'admin');
```

### Test 3: Búsqueda
```sql
-- Buscar todas
SELECT * FROM public.sp_certificaciones_search(NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Buscar vigentes
SELECT * FROM public.sp_certificaciones_search(NULL, NULL, NULL, NULL, NULL, NULL, 'V');

-- Buscar canceladas
SELECT * FROM public.sp_certificaciones_search(NULL, NULL, NULL, NULL, NULL, NULL, 'C');
```

## Compatibilidad API Genérica

Todos los SPs son compatibles con la API genérica del sistema:

### Endpoints esperados:
- `GET /certificaciones?tipo=ANUAL` → `sp_certificaciones_list`
- `GET /certificaciones/{id}` → `sp_certificaciones_get`
- `POST /certificaciones` → `sp_certificaciones_create`
- `PUT /certificaciones/{id}` → `sp_certificaciones_update`
- `DELETE /certificaciones/{id}` → `sp_certificaciones_cancel`
- `GET /certificaciones/search` → `sp_certificaciones_search`
- `GET /certificaciones/{id}/print` → `sp_certificaciones_print`

## Archivos Generados

1. **CERTIFICACIONESFRM_all_procedures_IMPLEMENTED.sql**
   - Archivo principal con todos los SPs
   - Ubicación: `C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\ok\`
   - Listo para deploy

2. **CERTIFICACIONESFRM_REPORTE_IMPLEMENTACION.md**
   - Este reporte
   - Documentación completa
   - Ejemplos de uso

## Checklist de Implementación

- ✅ 7 SPs implementados
- ✅ Lógica real y funcional
- ✅ Validaciones completas
- ✅ Manejo de errores
- ✅ Soft delete implementado
- ✅ Generación automática de folios
- ✅ Búsqueda avanzada
- ✅ Formato JSON para impresión
- ✅ Comentarios y documentación
- ✅ Ejemplos de uso
- ✅ Compatible con API genérica
- ✅ Schema correcto (public)
- ✅ Nombrado consistente

## Conclusión

Se han implementado exitosamente los **7 stored procedures** del componente **certificacionesfrm** con lógica real, robusta y lista para producción.

Características principales:
- CRUD completo
- Soft delete con histórico
- Folios automáticos
- Búsqueda flexible
- Datos para impresión en JSON
- Validaciones exhaustivas
- Manejo de errores completo

**Estado: LISTO PARA DEPLOY**
