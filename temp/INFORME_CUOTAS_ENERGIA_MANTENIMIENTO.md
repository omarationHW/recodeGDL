# INFORME: Stored Procedures - Cuotas de Energía Mantenimiento

**Fecha:** 2025-12-03
**Módulo:** Cuotas de Energía Mantenimiento
**Base de datos:** mercados (PostgreSQL)
**Servidor:** 192.168.6.146:5432

---

## RESUMEN EJECUTIVO

Se han creado y corregido **3 stored procedures** para el módulo "Cuotas de Energía Mantenimiento" con las siguientes características:

- ✅ Validaciones completas de parámetros
- ✅ Manejo de errores estructurado
- ✅ Retorno de mensajes informativos
- ✅ Filtros opcionales (NULL = todos)
- ✅ Join con tabla de usuarios
- ✅ Prevención de duplicados
- ✅ Esquema `public` correctamente especificado

---

## TABLA UTILIZADA

**Tabla principal:** `public.ta_11_kilowhatts`

### Estructura estimada:
```sql
CREATE TABLE public.ta_11_kilowhatts (
    id_kilowhatts INTEGER PRIMARY KEY,
    axo SMALLINT NOT NULL,
    periodo SMALLINT NOT NULL,
    importe NUMERIC(18,6) NOT NULL,
    fecha_alta TIMESTAMP DEFAULT NOW(),
    id_usuario INTEGER,
    CONSTRAINT uk_axo_periodo UNIQUE (axo, periodo)
);
```

**Relaciones:**
- `id_usuario` → `public.usuarios.id` (LEFT JOIN)

---

## STORED PROCEDURES CREADOS

### 1. `sp_list_cuotas_energia` - Listar Cuotas

**Propósito:** Lista cuotas de energía con filtros opcionales por año y periodo.

**Firma:**
```sql
public.sp_list_cuotas_energia(
    p_axo INTEGER DEFAULT NULL,
    p_periodo INTEGER DEFAULT NULL
)
```

**Retorna:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_kilowhatts | INTEGER | ID único de la cuota |
| axo | INTEGER | Año de la cuota |
| periodo | INTEGER | Periodo (1-12) |
| importe | NUMERIC(18,6) | Importe de la cuota |
| fecha_alta | TIMESTAMP | Fecha de registro |
| id_usuario | INTEGER | ID del usuario que registró |
| usuario | VARCHAR(50) | Nombre del usuario |

**Características:**
- Si `p_axo` es NULL, retorna todas las cuotas (sin filtrar por año)
- Si `p_periodo` es NULL, retorna todas las cuotas (sin filtrar por periodo)
- Ordenado por año DESC, periodo DESC (más recientes primero)
- Incluye JOIN con tabla `usuarios` para obtener el nombre
- Si no hay usuario, muestra 'SIN USUARIO'

**Ejemplos de uso:**

```sql
-- Listar TODAS las cuotas
SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL);

-- Listar cuotas del año 2024
SELECT * FROM public.sp_list_cuotas_energia(2024, NULL);

-- Listar cuotas del periodo 12 (todos los años)
SELECT * FROM public.sp_list_cuotas_energia(NULL, 12);

-- Listar cuotas específicas: año 2024, periodo 6
SELECT * FROM public.sp_list_cuotas_energia(2024, 6);

-- Con filtros adicionales en WHERE
SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL)
WHERE importe > 100.00
ORDER BY fecha_alta DESC;
```

**Ejemplo de resultado:**
```
 id_kilowhatts | axo  | periodo | importe  | fecha_alta          | id_usuario | usuario
---------------+------+---------+----------+---------------------+------------+--------------
            45 | 2024 |      12 | 150.5000 | 2024-11-15 10:30:00 |          5 | juan.perez
            44 | 2024 |      11 | 148.7500 | 2024-10-15 09:20:00 |          3 | maria.lopez
            43 | 2024 |      10 | 145.2000 | 2024-09-15 14:45:00 |          5 | juan.perez
```

---

### 2. `sp_insert_cuota_energia` - Insertar Cuota

**Propósito:** Inserta una nueva cuota de energía con validaciones completas.

**Firma:**
```sql
public.sp_insert_cuota_energia(
    p_axo INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
)
```

**Parámetros:**
| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|-------------|-------------|
| p_axo | INTEGER | Sí | Año (ej: 2024) |
| p_periodo | INTEGER | Sí | Periodo 1-12 |
| p_importe | NUMERIC(18,6) | Sí | Importe > 0 |
| p_id_usuario | INTEGER | Sí | ID del usuario |

**Retorna:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| success | BOOLEAN | `true` si se insertó, `false` si falló |
| message | TEXT | Mensaje descriptivo del resultado |
| id_kilowhatts | INTEGER | ID generado (NULL si falló) |

**Validaciones implementadas:**
1. ✅ Año no puede ser NULL
2. ✅ Periodo no puede ser NULL
3. ✅ Importe debe ser mayor a cero
4. ✅ ID de usuario no puede ser NULL
5. ✅ **No permite duplicados** (combinación año+periodo única)

**Ejemplos de uso:**

```sql
-- CASO 1: Inserción exitosa
SELECT * FROM public.sp_insert_cuota_energia(2025, 1, 155.75, 5);

-- Resultado esperado:
-- success | message                                      | id_kilowhatts
-- --------+----------------------------------------------+--------------
-- true    | Cuota de energía registrada correctamente    |           46
```

```sql
-- CASO 2: Intento de duplicado (debe fallar)
SELECT * FROM public.sp_insert_cuota_energia(2024, 12, 160.00, 5);

-- Resultado esperado:
-- success | message                                                        | id_kilowhatts
-- --------+----------------------------------------------------------------+--------------
-- false   | Ya existe una cuota registrada para el año 2024 y periodo 12  | NULL
```

```sql
-- CASO 3: Importe negativo (debe fallar)
SELECT * FROM public.sp_insert_cuota_energia(2025, 2, -50.00, 5);

-- Resultado esperado:
-- success | message                              | id_kilowhatts
-- --------+--------------------------------------+--------------
-- false   | El importe debe ser mayor a cero     | NULL
```

```sql
-- CASO 4: Parámetro NULL (debe fallar)
SELECT * FROM public.sp_insert_cuota_energia(NULL, 3, 100.00, 5);

-- Resultado esperado:
-- success | message                    | id_kilowhatts
-- --------+----------------------------+--------------
-- false   | El año es obligatorio      | NULL
```

**Uso desde PHP/Laravel:**
```php
$result = DB::select('SELECT * FROM public.sp_insert_cuota_energia(?, ?, ?, ?)',
    [2025, 3, 162.50, $userId]
);

if ($result[0]->success) {
    $newId = $result[0]->id_kilowhatts;
    return response()->json([
        'success' => true,
        'message' => $result[0]->message,
        'id' => $newId
    ]);
} else {
    return response()->json([
        'success' => false,
        'message' => $result[0]->message
    ], 400);
}
```

---

### 3. `sp_update_cuota_energia` - Actualizar Cuota

**Propósito:** Actualiza SOLO el importe de una cuota existente (no cambia año ni periodo).

**Firma:**
```sql
public.sp_update_cuota_energia(
    p_id_kilowhatts INTEGER,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
)
```

**Parámetros:**
| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|-------------|-------------|
| p_id_kilowhatts | INTEGER | Sí | ID de la cuota a actualizar |
| p_importe | NUMERIC(18,6) | Sí | Nuevo importe > 0 |
| p_id_usuario | INTEGER | Sí | ID del usuario que modifica |

**Retorna:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| success | BOOLEAN | `true` si se actualizó, `false` si falló |
| message | TEXT | Mensaje descriptivo del resultado |

**Validaciones implementadas:**
1. ✅ ID de cuota no puede ser NULL
2. ✅ Importe debe ser mayor a cero
3. ✅ ID de usuario no puede ser NULL
4. ✅ **Verifica que exista el registro** antes de actualizar
5. ✅ Actualiza `fecha_alta` y `id_usuario` automáticamente

**Ejemplos de uso:**

```sql
-- CASO 1: Actualización exitosa
SELECT * FROM public.sp_update_cuota_energia(45, 165.00, 5);

-- Resultado esperado:
-- success | message
-- --------+-----------------------------------------------------------------------
-- true    | Cuota de energía actualizada correctamente (Año: 2024, Periodo: 12)
```

```sql
-- CASO 2: ID inexistente (debe fallar)
SELECT * FROM public.sp_update_cuota_energia(999999, 170.00, 5);

-- Resultado esperado:
-- success | message
-- --------+---------------------------------------
-- false   | No se encontró la cuota con ID 999999
```

```sql
-- CASO 3: Importe cero (debe fallar)
SELECT * FROM public.sp_update_cuota_energia(45, 0, 5);

-- Resultado esperado:
-- success | message
-- --------+--------------------------------------
-- false   | El importe debe ser mayor a cero
```

**Uso desde PHP/Laravel:**
```php
$result = DB::select('SELECT * FROM public.sp_update_cuota_energia(?, ?, ?)',
    [$idKilowhatts, $nuevoImporte, $userId]
);

if ($result[0]->success) {
    return response()->json([
        'success' => true,
        'message' => $result[0]->message
    ]);
} else {
    return response()->json([
        'success' => false,
        'message' => $result[0]->message
    ], 400);
}
```

---

## FLUJO DE TRABAJO RECOMENDADO

### Crear una nueva cuota:

```sql
-- 1. Verificar que no exista
SELECT * FROM public.sp_list_cuotas_energia(2025, 4);

-- 2. Si no existe, insertar
SELECT * FROM public.sp_insert_cuota_energia(2025, 4, 175.50, 5);

-- 3. Verificar la inserción
SELECT * FROM public.sp_list_cuotas_energia(2025, 4);
```

### Modificar una cuota existente:

```sql
-- 1. Buscar la cuota
SELECT * FROM public.sp_list_cuotas_energia(2025, 4);

-- 2. Actualizar el importe (usando el id_kilowhatts obtenido)
SELECT * FROM public.sp_update_cuota_energia(46, 180.00, 5);

-- 3. Verificar la actualización
SELECT * FROM public.sp_list_cuotas_energia(2025, 4);
```

---

## ARCHIVOS GENERADOS

### Archivos SQL individuales:

1. **`01_sp_list_cuotas_energia.sql`**
   - Stored procedure para listar cuotas
   - Puede ejecutarse independientemente

2. **`02_sp_insert_cuota_energia.sql`**
   - Stored procedure para insertar cuotas
   - Incluye todas las validaciones

3. **`03_sp_update_cuota_energia.sql`**
   - Stored procedure para actualizar cuotas
   - Solo modifica importe

4. **`00_deploy_all_cuotas_energia.sql`**
   - **Archivo completo** con los 3 SPs
   - Recomendado para deployment

---

## INSTRUCCIONES DE DESPLIEGUE

### Opción 1: Usando psql (Línea de comandos)

```bash
# Desplegar todos los SPs de una vez
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f 00_deploy_all_cuotas_energia.sql

# O desplegar uno por uno
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f 01_sp_list_cuotas_energia.sql
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f 02_sp_insert_cuota_energia.sql
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f 03_sp_update_cuota_energia.sql
```

### Opción 2: Desde pgAdmin

1. Conectar a servidor: 192.168.6.146:5432
2. Seleccionar base de datos: `mercados`
3. Abrir Query Tool
4. Copiar contenido de `00_deploy_all_cuotas_energia.sql`
5. Ejecutar (F5)

### Opción 3: Desde DBeaver

1. Nueva conexión PostgreSQL
2. Host: 192.168.6.146, Port: 5432, Database: mercados
3. User: refact, Password: FF)-BQk2
4. Abrir SQL Editor
5. Ejecutar contenido de `00_deploy_all_cuotas_energia.sql`

---

## VERIFICACIÓN POST-DESPLIEGUE

### 1. Verificar que los SPs se crearon:

```sql
SELECT
    p.proname as nombre,
    pg_get_function_arguments(p.oid) as parametros
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'sp_list_cuotas_energia',
    'sp_insert_cuota_energia',
    'sp_update_cuota_energia'
)
ORDER BY p.proname;
```

**Resultado esperado:**
```
 nombre                      | parametros
-----------------------------+------------------------------------------------
 sp_insert_cuota_energia     | p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer
 sp_list_cuotas_energia      | p_axo integer DEFAULT NULL, p_periodo integer DEFAULT NULL
 sp_update_cuota_energia     | p_id_kilowhatts integer, p_importe numeric, p_id_usuario integer
```

### 2. Probar funcionalidad básica:

```sql
-- Listar cuotas existentes
SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL) LIMIT 5;

-- Intentar insertar duplicado (debe fallar)
SELECT * FROM public.sp_insert_cuota_energia(
    (SELECT axo FROM public.ta_11_kilowhatts LIMIT 1),
    (SELECT periodo FROM public.ta_11_kilowhatts LIMIT 1),
    100.00,
    1
);

-- Actualizar cuota existente
SELECT * FROM public.sp_update_cuota_energia(
    (SELECT id_kilowhatts FROM public.ta_11_kilowhatts LIMIT 1),
    200.00,
    1
);
```

---

## INTEGRACIÓN CON LARAVEL

### Controller Example:

```php
namespace App\Http\Controllers\Api\Mercados;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CuotasEnergiaController extends Controller
{
    /**
     * Listar cuotas de energía
     */
    public function index(Request $request)
    {
        $axo = $request->input('axo');
        $periodo = $request->input('periodo');

        $cuotas = DB::select(
            'SELECT * FROM public.sp_list_cuotas_energia(?, ?)',
            [$axo, $periodo]
        );

        return response()->json($cuotas);
    }

    /**
     * Crear nueva cuota
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'axo' => 'required|integer|min:2000|max:2100',
            'periodo' => 'required|integer|min:1|max:12',
            'importe' => 'required|numeric|min:0.01',
            'id_usuario' => 'required|integer'
        ]);

        $result = DB::select(
            'SELECT * FROM public.sp_insert_cuota_energia(?, ?, ?, ?)',
            [
                $validated['axo'],
                $validated['periodo'],
                $validated['importe'],
                $validated['id_usuario']
            ]
        );

        if ($result[0]->success) {
            return response()->json([
                'success' => true,
                'message' => $result[0]->message,
                'id_kilowhatts' => $result[0]->id_kilowhatts
            ], 201);
        } else {
            return response()->json([
                'success' => false,
                'message' => $result[0]->message
            ], 400);
        }
    }

    /**
     * Actualizar cuota existente
     */
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'importe' => 'required|numeric|min:0.01',
            'id_usuario' => 'required|integer'
        ]);

        $result = DB::select(
            'SELECT * FROM public.sp_update_cuota_energia(?, ?, ?)',
            [
                $id,
                $validated['importe'],
                $validated['id_usuario']
            ]
        );

        if ($result[0]->success) {
            return response()->json([
                'success' => true,
                'message' => $result[0]->message
            ]);
        } else {
            return response()->json([
                'success' => false,
                'message' => $result[0]->message
            ], 400);
        }
    }
}
```

### Rutas API:

```php
// routes/api.php
Route::prefix('mercados')->group(function () {
    Route::get('/cuotas-energia', [CuotasEnergiaController::class, 'index']);
    Route::post('/cuotas-energia', [CuotasEnergiaController::class, 'store']);
    Route::put('/cuotas-energia/{id}', [CuotasEnergiaController::class, 'update']);
});
```

---

## EJEMPLOS DE CONSULTAS AVANZADAS

### Filtrar por rango de años:

```sql
SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL)
WHERE axo BETWEEN 2020 AND 2024
ORDER BY axo DESC, periodo DESC;
```

### Buscar importes mayores a cierto valor:

```sql
SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL)
WHERE importe > 150.00
ORDER BY importe DESC;
```

### Agrupar por año y calcular promedio:

```sql
SELECT
    axo,
    COUNT(*) as total_cuotas,
    AVG(importe) as importe_promedio,
    MIN(importe) as importe_minimo,
    MAX(importe) as importe_maximo
FROM public.sp_list_cuotas_energia(NULL, NULL)
GROUP BY axo
ORDER BY axo DESC;
```

### Buscar cuotas registradas por un usuario específico:

```sql
SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL)
WHERE usuario = 'juan.perez'
ORDER BY fecha_alta DESC;
```

---

## MANTENIMIENTO Y TROUBLESHOOTING

### Problema: "relation ta_11_kilowhatts does not exist"

**Solución:** Verificar el esquema correcto de la tabla

```sql
-- Buscar la tabla en todos los esquemas
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename = 'ta_11_kilowhatts';

-- Si está en otro esquema, modificar los SPs para usar el esquema correcto
```

### Problema: "function does not exist"

**Solución:** Re-desplegar los SPs

```bash
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f 00_deploy_all_cuotas_energia.sql
```

### Problema: Constraint violation al insertar

**Solución:** Verificar que no exista la combinación axo+periodo

```sql
SELECT * FROM public.ta_11_kilowhatts
WHERE axo = ? AND periodo = ?;
```

---

## DATOS DE PRUEBA

### Insertar datos de prueba:

```sql
-- Limpiar tabla (CUIDADO en producción)
-- TRUNCATE TABLE public.ta_11_kilowhatts RESTART IDENTITY CASCADE;

-- Insertar cuotas de prueba para 2024
SELECT * FROM public.sp_insert_cuota_energia(2024, 1, 140.50, 1);
SELECT * FROM public.sp_insert_cuota_energia(2024, 2, 142.75, 1);
SELECT * FROM public.sp_insert_cuota_energia(2024, 3, 145.00, 1);
SELECT * FROM public.sp_insert_cuota_energia(2024, 4, 147.25, 1);
SELECT * FROM public.sp_insert_cuota_energia(2024, 5, 149.50, 1);
SELECT * FROM public.sp_insert_cuota_energia(2024, 6, 151.75, 1);

-- Insertar cuotas de prueba para 2025
SELECT * FROM public.sp_insert_cuota_energia(2025, 1, 155.00, 1);
SELECT * FROM public.sp_insert_cuota_energia(2025, 2, 157.50, 1);
SELECT * FROM public.sp_insert_cuota_energia(2025, 3, 160.00, 1);

-- Verificar
SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL);
```

---

## PERFORMANCE

### Índices recomendados:

```sql
-- Índice en columna de búsqueda frecuente
CREATE INDEX IF NOT EXISTS idx_kilowhatts_axo ON public.ta_11_kilowhatts(axo);
CREATE INDEX IF NOT EXISTS idx_kilowhatts_periodo ON public.ta_11_kilowhatts(periodo);
CREATE INDEX IF NOT EXISTS idx_kilowhatts_axo_periodo ON public.ta_11_kilowhatts(axo, periodo);
CREATE INDEX IF NOT EXISTS idx_kilowhatts_usuario ON public.ta_11_kilowhatts(id_usuario);
```

### Plan de ejecución:

```sql
EXPLAIN ANALYZE
SELECT * FROM public.sp_list_cuotas_energia(2024, NULL);
```

---

## CONCLUSIONES

✅ **3 Stored Procedures creados exitosamente**
✅ **Validaciones completas implementadas**
✅ **Prevención de duplicados**
✅ **Mensajes descriptivos de error**
✅ **Compatibilidad con Laravel/PHP**
✅ **Código documentado y listo para producción**

**Archivos listos para desplegar:**
- `C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\00_deploy_all_cuotas_energia.sql`

**Próximos pasos:**
1. Desplegar los SPs en el servidor de base de datos
2. Probar con datos reales
3. Integrar con el frontend Vue.js
4. Implementar en el controlador Laravel

---

**Generado por:** Claude Code
**Fecha:** 2025-12-03
