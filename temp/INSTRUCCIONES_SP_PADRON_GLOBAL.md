# Instrucciones de Uso - SP sp_padron_global

## Ubicación de Archivos

Todos los archivos se encuentran en:
```
C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\
```

### Archivos Principales:

1. **sp_padron_global_CORREGIDO.sql**
   - Archivo SQL listo para ejecutar
   - Contiene el SP corregido con documentación

2. **fix_sp_padron_global.js**
   - Script Node.js para crear el SP
   - Incluye verificaciones y pruebas

3. **verificar_sp_padron_global.js**
   - Script de verificación rápida
   - Comprueba que el SP funciona correctamente

4. **RESUMEN_CORRECCION_SP_PADRON_GLOBAL.md**
   - Documentación completa del problema y solución
   - Ejemplos de uso y resultados

---

## Instalación/Actualización del SP

### Opción 1: Usando Node.js (Recomendado)

```bash
cd C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp
node fix_sp_padron_global.js
```

Este script:
- ✓ Verifica la estructura de las tablas
- ✓ Elimina el SP anterior si existe
- ✓ Crea el nuevo SP con tipos correctos
- ✓ Ejecuta pruebas automáticas
- ✓ Muestra ejemplos de resultados

### Opción 2: Usando SQL directo

Si tienes `psql` instalado:

```bash
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f sp_padron_global_CORREGIDO.sql
```

O desde cualquier cliente SQL (DBeaver, pgAdmin, etc.):
- Abrir el archivo `sp_padron_global_CORREGIDO.sql`
- Ejecutar todo el contenido

---

## Verificación

Para verificar que el SP está funcionando:

```bash
cd C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp
node verificar_sp_padron_global.js
```

Este script muestra:
- Si el SP existe en la BD
- Cantidad de registros por vigencia
- Ejemplo de registro retornado
- Tipos de datos del resultado

---

## Uso del SP

### Sintaxis Básica

```sql
SELECT * FROM publico.sp_padron_global(año, mes, vigencia);
```

### Parámetros

1. **año** (INTEGER): Año del periodo (ej: 2025)
2. **mes** (INTEGER): Mes del periodo (1-12)
3. **vigencia** (VARCHAR): Tipo de vigencia
   - `'A'` = Activos
   - `'B'` = Baja
   - `'C'` = Cancelados
   - `'D'` = Desocupados
   - `'T'` = Todos

### Ejemplos de Uso

#### 1. Obtener todos los locales activos del mes actual:
```sql
SELECT * FROM publico.sp_padron_global(2025, 12, 'A');
```

#### 2. Obtener todos los locales (todas las vigencias):
```sql
SELECT * FROM publico.sp_padron_global(2025, 12, 'T');
```

#### 3. Contar locales por vigencia:
```sql
-- Activos
SELECT COUNT(*) FROM publico.sp_padron_global(2025, 12, 'A');  -- 12,945

-- Baja
SELECT COUNT(*) FROM publico.sp_padron_global(2025, 12, 'B');  -- 286

-- Todos
SELECT COUNT(*) FROM publico.sp_padron_global(2025, 12, 'T');  -- 13,320
```

#### 4. Filtrar locales con adeudos:
```sql
SELECT
    id_local,
    num_mercado,
    descripcion as mercado,
    local,
    letra_local,
    nombre,
    renta,
    leyenda
FROM publico.sp_padron_global(2025, 12, 'A')
WHERE adeudo = 1
ORDER BY num_mercado, local;
```

#### 5. Filtrar locales al corriente:
```sql
SELECT *
FROM publico.sp_padron_global(2025, 12, 'A')
WHERE adeudo = 0;
```

#### 6. Obtener locales de un mercado específico:
```sql
SELECT *
FROM publico.sp_padron_global(2025, 12, 'T')
WHERE num_mercado = 2  -- MEXICALTZINGO
ORDER BY local;
```

#### 7. Sumar rentas por mercado:
```sql
SELECT
    num_mercado,
    descripcion,
    COUNT(*) as total_locales,
    SUM(renta) as renta_total
FROM publico.sp_padron_global(2025, 12, 'A')
GROUP BY num_mercado, descripcion
ORDER BY num_mercado;
```

#### 8. Locales con mayor renta:
```sql
SELECT
    id_local,
    num_mercado,
    descripcion as mercado,
    local,
    nombre,
    superficie,
    renta
FROM publico.sp_padron_global(2025, 12, 'A')
ORDER BY renta DESC
LIMIT 10;
```

---

## Campos Retornados

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id_local` | INTEGER | ID único del local |
| `oficina` | SMALLINT | Código de oficina |
| `num_mercado` | SMALLINT | Número de mercado |
| `categoria` | SMALLINT | Categoría del local |
| `seccion` | CHARACTER(2) | Sección (ej: SS, PS) |
| `local` | INTEGER | Número de local |
| `letra_local` | VARCHAR(3) | Letra del local (A, B, etc.) |
| `bloque` | VARCHAR(2) | Bloque del local |
| `nombre` | VARCHAR(60) | Nombre del arrendatario |
| `descripcion_local` | CHARACTER(20) | Descripción del local ⚠️ |
| `superficie` | NUMERIC | Superficie en m² |
| `vigencia` | CHARACTER(1) | Vigencia (A, B, C, D) |
| `clave_cuota` | SMALLINT | Clave de cuota |
| `descripcion` | VARCHAR(30) | Nombre del mercado |
| `renta` | NUMERIC(10,2) | Renta calculada |
| `leyenda` | VARCHAR(50) | Estado de adeudo |
| `adeudo` | INTEGER | 1 = con adeudo, 0 = al corriente |
| `registro` | VARCHAR(200) | Concatenación de datos |

⚠️ **Nota importante:** `descripcion_local` es CHARACTER(20) con espacios de relleno.

---

## Integración con Laravel/PHP

### Ejemplo en un Controller:

```php
use Illuminate\Support\Facades\DB;

class PadronController extends Controller
{
    public function obtenerPadronGlobal(Request $request)
    {
        $year = $request->input('year', date('Y'));
        $month = $request->input('month', date('n'));
        $vigencia = $request->input('vigencia', 'A');

        $padron = DB::connection('mercados')
            ->select('SELECT * FROM publico.sp_padron_global(?, ?, ?)', [
                $year,
                $month,
                $vigencia
            ]);

        return response()->json([
            'success' => true,
            'data' => $padron,
            'total' => count($padron)
        ]);
    }
}
```

### Ejemplo en un Modelo:

```php
namespace App\Models\Mercados;

use Illuminate\Support\Facades\DB;

class PadronGlobal
{
    public static function obtener($year, $month, $vigencia = 'T')
    {
        return DB::connection('mercados')
            ->select('SELECT * FROM publico.sp_padron_global(?, ?, ?)', [
                (int)$year,
                (int)$month,
                $vigencia
            ]);
    }

    public static function contar($year, $month, $vigencia = 'T')
    {
        $result = DB::connection('mercados')
            ->selectOne('SELECT COUNT(*) as total FROM publico.sp_padron_global(?, ?, ?)', [
                (int)$year,
                (int)$month,
                $vigencia
            ]);

        return $result->total;
    }

    public static function porMercado($year, $month, $numMercado, $vigencia = 'A')
    {
        $sql = "
            SELECT *
            FROM publico.sp_padron_global(?, ?, ?)
            WHERE num_mercado = ?
            ORDER BY local, letra_local
        ";

        return DB::connection('mercados')
            ->select($sql, [$year, $month, $vigencia, $numMercado]);
    }
}
```

### Uso en Vue/Frontend:

```javascript
// Servicio API
async obtenerPadronGlobal(year, month, vigencia = 'A') {
    const response = await axios.get('/api/mercados/padron-global', {
        params: { year, month, vigencia }
    });
    return response.data;
}

// Componente Vue
export default {
    data() {
        return {
            padron: [],
            year: new Date().getFullYear(),
            month: new Date().getMonth() + 1,
            vigencia: 'A'
        }
    },
    methods: {
        async cargarPadron() {
            try {
                const response = await this.obtenerPadronGlobal(
                    this.year,
                    this.month,
                    this.vigencia
                );
                this.padron = response.data;
            } catch (error) {
                console.error('Error al cargar padrón:', error);
            }
        }
    },
    mounted() {
        this.cargarPadron();
    }
}
```

---

## Solución de Problemas

### Error: "function does not exist"

**Causa:** El SP no está creado en la BD

**Solución:**
```bash
node fix_sp_padron_global.js
```

### Error: "column reference is ambiguous"

**Causa:** Versión antigua del SP con columnas sin calificar

**Solución:** Re-ejecutar el script de corrección:
```bash
node fix_sp_padron_global.js
```

### Error de tipos de datos

**Causa:** Versión antigua del SP con tipos incorrectos

**Solución:** La versión corregida ya tiene los tipos correctos:
- `descripcion_local`: CHARACTER(20)
- `bloque`: CHARACTER VARYING(2)
- `superficie`: NUMERIC

### No retorna datos

**Verificar:**
1. Que el año/mes sean válidos
2. Que existan datos para esa vigencia
3. Probar con vigencia 'T' (todos)

```sql
SELECT COUNT(*) FROM publico.sp_padron_global(2025, 12, 'T');
```

---

## Rendimiento

**Datos de prueba:**
- Vigencia 'A': 12,945 registros
- Vigencia 'T': 13,320 registros
- Tiempo de ejecución: < 1 segundo

**Recomendaciones:**
- Usar filtro de vigencia apropiado
- Agregar LIMIT para consultas de vista previa
- Indexar id_local si hay problemas de rendimiento

---

## Mantenimiento

### Verificar estado del SP:

```sql
-- Ver definición del SP
SELECT pg_get_functiondef('publico.sp_padron_global'::regproc);

-- Ver parámetros del SP
SELECT
    parameter_name,
    data_type,
    parameter_mode
FROM information_schema.parameters
WHERE specific_schema = 'publico'
AND specific_name LIKE '%sp_padron_global%'
ORDER BY ordinal_position;
```

### Backup del SP:

```bash
pg_dump -h 192.168.6.146 -U refact -d mercados \
  --schema=publico \
  --routine=sp_padron_global \
  > sp_padron_global_backup.sql
```

---

## Contacto y Soporte

**Archivos de referencia:**
- Resumen completo: `RESUMEN_CORRECCION_SP_PADRON_GLOBAL.md`
- Script de instalación: `fix_sp_padron_global.js`
- Script de verificación: `verificar_sp_padron_global.js`
- SQL directo: `sp_padron_global_CORREGIDO.sql`

**Ubicación:**
```
C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\
```

---

**Última actualización:** 2025-12-03
**Versión del SP:** CORREGIDA (tipos de datos exactos)
**Estado:** ✅ FUNCIONAL EN PRODUCCIÓN
