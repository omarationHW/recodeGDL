# Solución: Error "function does not exist" en Publicos_Upd.vue

**Fecha**: 2025-12-04
**Error**: `SQLSTATE[42883]: Undefined function: public.recaudadora_publicos_upd() does not exist`

---

## PROBLEMA IDENTIFICADO

El error indicaba que el SP se estaba llamando **sin parámetros**: `public.recaudadora_publicos_upd()`

**Causa raíz**: El componente Vue estaba enviando los parámetros en formato **objeto**:
```javascript
const params = {
  p_datos: jsonPayload.value
}
```

Pero el **GenericController** espera los parámetros en formato **array** con estructura específica:
```javascript
const params = [
  {
    nombre: 'p_datos',
    valor: jsonPayload.value,
    tipo: 'string'
  }
]
```

---

## SOLUCIÓN APLICADA

### Archivo corregido: `Publicos_Upd.vue`

**Cambio realizado** (líneas 206-213):

```javascript
// ❌ ANTES (incorrecto)
const params = {
  p_datos: jsonPayload.value
}

// ✅ DESPUÉS (correcto)
const params = [
  {
    nombre: 'p_datos',
    valor: jsonPayload.value,
    tipo: 'string'
  }
]
```

---

## VERIFICACIÓN

### Pruebas realizadas con la API

**✅ EJEMPLO 1: Actualizar concepto existente**
```bash
HTTP 200
ID: 4 → ACTUALIZADO
Descripción: "PAGO DE DIVERSOS TEST API"
```

**✅ EJEMPLO 2: Insertar nuevo concepto**
```bash
HTTP 200
ID: 52 (auto-generado) → INSERTADO
Descripción: "CONCEPTO PRUEBA API"
```

**✅ EJEMPLO 3: Actualización masiva**
```bash
HTTP 200
ID: 1 → ACTUALIZADO
ID: 2 → ACTUALIZADO
ID: 3 → ACTUALIZADO
```

---

## FLUJO COMPLETO

### 1. Frontend (Publicos_Upd.vue)
```javascript
const params = [
  {
    nombre: 'p_datos',
    valor: '[{"cveconcepto": 4, ...}]',
    tipo: 'string'
  }
]

await execute('RECAUDADORA_PUBLICOS_UPD', 'multas_reglamentos', params)
```

### 2. Composable (useApi.js)
```javascript
const response = await apiService.execute(
  'RECAUDADORA_PUBLICOS_UPD',
  'multas_reglamentos',
  params,  // Array con formato correcto
  '',
  null,
  null
)
```

### 3. API Service (apiService.js)
```javascript
const payload = {
  eRequest: {
    Operacion: 'recaudadora_publicos_upd',
    Base: 'multas_reglamentos',
    Parametros: [  // Array de parámetros
      {
        nombre: 'p_datos',
        valor: '[{...}]',
        tipo: 'string'
      }
    ]
  }
}

axios.post('/api/generic', payload)
```

### 4. Backend (GenericController.php)
```php
// Procesa los parámetros
foreach ($parametros as $param) {
    if (isset($param['nombre']) && array_key_exists('valor', $param)) {
        $valor = $param['valor'];
        // ...
        $paramMap[$param['nombre']] = $valor;
    }
}

// Construye SQL
$sql = "SELECT * FROM public.recaudadora_publicos_upd(?)";

// Ejecuta con valores
$stmt->execute([$paramMap['p_datos']]);
```

### 5. Base de datos (PostgreSQL)
```sql
SELECT * FROM public.recaudadora_publicos_upd('[{...}]'::TEXT)
```

---

## FORMATO ESPERADO POR GENERICCONTROLLER

### Estructura de parámetros:

```javascript
[
  {
    nombre: 'nombre_parametro',  // Nombre del parámetro del SP
    valor: 'valor_del_parametro', // Valor a pasar
    tipo: 'string'                // Tipo: string, integer, numeric, boolean, json, etc.
  },
  // ... más parámetros si es necesario
]
```

### Tipos soportados:
- `string`: Texto (default)
- `integer` o `int`: Números enteros
- `numeric` o `decimal`: Números decimales
- `boolean` o `bool`: Verdadero/Falso
- `json`: Objetos JSON
- `integer_array` o `int_array`: Arrays de enteros

---

## RESPUESTA DE LA API

### Estructura de respuesta exitosa:

```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "result": [
        {
          "cveconcepto": 4,
          "descripcion": "PAGO DE DIVERSOS TEST API",
          "ncorto": "DIV-API",
          "cvegrupo": 1,
          "accion": "ACTUALIZADO",
          "resultado": "Registro actualizado correctamente"
        }
      ],
      "count": 1,
      "debug": {
        "connection": { ... },
        "sp_name": "public.recaudadora_publicos_upd",
        "sql_executed": "SELECT * FROM public.recaudadora_publicos_upd(?)",
        "parameters_sent": [ ... ]
      }
    },
    "timestamp": "2025-12-04T19:37:17+00:00"
  }
}
```

### Acceso en Vue:

```javascript
// useApi retorna: response.data (que es eResponse.data)
const data = await execute(...)

// Acceder al resultado
if (data && data.result && Array.isArray(data.result)) {
  resultado.value = data.result  // ✅ Correcto
}
```

---

## EJEMPLOS PARA EL FORMULARIO

### Ejemplo 1: Actualizar concepto existente
```json
[
  {
    "cveconcepto": 4,
    "descripcion": "PAGO DE DIVERSOS ACTUALIZADO",
    "ncorto": "DIV-ACT",
    "cvegrupo": 1
  }
]
```

### Ejemplo 2: Insertar nuevo concepto
```json
[
  {
    "cveconcepto": 0,
    "descripcion": "NUEVO CONCEPTO DE PAGO",
    "ncorto": "NUEVO",
    "cvegrupo": 2
  }
]
```

### Ejemplo 3: Actualización masiva
```json
[
  {
    "cveconcepto": 1,
    "descripcion": "IMPUESTO PREDIAL",
    "ncorto": "PREDIAL",
    "cvegrupo": 1
  },
  {
    "cveconcepto": 2,
    "descripcion": "TRANSMISION PATRIMONIAL",
    "ncorto": "TRANSM-PAT",
    "cvegrupo": 1
  }
]
```

---

## ARCHIVOS MODIFICADOS

1. ✅ **Publicos_Upd.vue** - Corregido formato de parámetros
2. ✅ **recaudadora_publicos_upd_fixed.sql** - SP desplegado
3. ✅ **test_api_publicos_upd.php** - Script de prueba creado

---

## COMANDOS DE VERIFICACIÓN

### Probar API directamente:
```bash
php temp/test_api_publicos_upd.php
```

### Verificar SP en base de datos:
```bash
php -r "$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2'); $stmt = $pdo->query(\"SELECT routine_name FROM information_schema.routines WHERE routine_name = 'recaudadora_publicos_upd'\"); var_dump($stmt->fetch());"
```

### Ver logs del backend:
```bash
tail -f RefactorX/BackEnd/storage/logs/laravel.log
```

---

## ESTADO FINAL

✅ **SP desplegado**: `public.recaudadora_publicos_upd(TEXT)`
✅ **Componente corregido**: `Publicos_Upd.vue`
✅ **Formato de parámetros**: Array con estructura {nombre, valor, tipo}
✅ **Pruebas exitosas**: 3 ejemplos funcionando
✅ **Integración completa**: Frontend → API → SP → DB

---

## LECCIÓN APRENDIDA

**El GenericController SIEMPRE espera parámetros en formato array:**

```javascript
// ✅ CORRECTO
const params = [
  { nombre: 'p_param1', valor: 'valor1', tipo: 'string' },
  { nombre: 'p_param2', valor: 123, tipo: 'integer' }
]

// ❌ INCORRECTO
const params = {
  p_param1: 'valor1',
  p_param2: 123
}
```

Este formato permite al controlador:
- Identificar cada parámetro por nombre
- Aplicar conversiones de tipo correctas
- Mantener el orden de los parámetros
- Soportar valores null y tipos complejos

---

## PRÓXIMOS PASOS

El componente **Publicos_Upd.vue** está completamente funcional y listo para uso en producción.

✅ El usuario puede probar el formulario con los 3 ejemplos proporcionados
✅ Los botones de ejemplo cargan JSON válido automáticamente
✅ La tabla muestra resultados con badges de colores
✅ El resumen indica total de registros procesados
