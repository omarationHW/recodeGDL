# Reporte: Publicos_Upd.vue - Actualización Masiva de Conceptos

**Fecha**: 2025-12-04
**Módulo**: multas_reglamentos
**Componente**: Publicos_Upd.vue
**SP**: recaudadora_publicos_upd

---

## RESUMEN EJECUTIVO

✅ **ESTADO**: COMPLETADO Y FUNCIONAL

Se corrigió el componente Publicos_Upd.vue, se creó el Stored Procedure `recaudadora_publicos_upd`, se probó con 3 ejemplos reales y se implementó la visualización de resultados en tabla HTML.

---

## ARCHIVOS INVOLUCRADOS

### 1. Componente Vue
**Ubicación**: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/Publicos_Upd.vue`

**Características**:
- Área de texto para ingresar JSON con array de actualizaciones
- 3 botones de ejemplo para cargar datos de prueba
- Validación de JSON antes de enviar
- Tabla HTML con resultados detallados
- Badges de colores según acción:
  - 🟢 Verde (INSERTADO)
  - 🟡 Amarillo (ACTUALIZADO)
  - 🔴 Rojo (ERROR)
- Header con gradiente naranja corporativo
- Resumen con total de registros procesados

### 2. Stored Procedure
**Ubicación**: `temp/recaudadora_publicos_upd_fixed.sql`

**Función**: `public.recaudadora_publicos_upd(p_datos TEXT)`

**Parámetros**:
- `p_datos`: JSON array con registros a actualizar/insertar
  ```json
  [{
    "cveconcepto": 1,
    "descripcion": "DESCRIPCION",
    "ncorto": "CORTO",
    "cvegrupo": 1
  }]
  ```

**Retorna**: Tabla con columnas:
- `cveconcepto`: ID del concepto
- `descripcion`: Descripción del concepto
- `ncorto`: Nombre corto
- `cvegrupo`: Grupo del concepto
- `accion`: ACTUALIZADO | INSERTADO | ERROR
- `resultado`: Mensaje descriptivo

**Tabla afectada**: `public.c_conceptos`

---

## LÓGICA DEL SP

### Validaciones
1. ✅ Valida que p_datos sea JSON válido
2. ✅ Valida que sea un array de objetos
3. ✅ Valida que cada registro tenga descripción

### Procesamiento
1. **Si cveconcepto existe**: ACTUALIZA el registro
   - Actualiza descripcion, ncorto, cvegrupo
   - Actualiza feccap a fecha actual
   - Registra capturista como 'SISTEMA'

2. **Si cveconcepto NO existe**: INSERTA nuevo registro
   - Si cveconcepto = 0, genera ID automático (MAX + 1)
   - Si ncorto está vacío, toma primeros 15 caracteres de descripcion
   - Inserta con fecha y capturista actual

### Manejo de Errores
- JSON inválido → retorna mensaje de error
- Descripción vacía → retorna error para ese registro
- Sin registros procesados → retorna mensaje informativo

---

## PRUEBAS REALIZADAS

### ✅ EJEMPLO 1: Actualizar concepto existente

**Input**:
```json
[{
  "cveconcepto": 4,
  "descripcion": "PAGO DE DIVERSOS ACTUALIZADO",
  "ncorto": "DIV-ACT",
  "cvegrupo": 1
}]
```

**Resultado**:
- ID: 4
- Acción: ACTUALIZADO
- Resultado: Registro actualizado correctamente

---

### ✅ EJEMPLO 2: Insertar nuevo concepto

**Input**:
```json
[{
  "cveconcepto": 0,
  "descripcion": "PAGO DE PRUEBA SISTEMA",
  "ncorto": "PRUEBA",
  "cvegrupo": 2
}]
```

**Resultado**:
- ID: 51 (generado automáticamente)
- Acción: INSERTADO
- Resultado: Registro creado correctamente

---

### ✅ EJEMPLO 3: Actualización masiva (3 registros)

**Input**:
```json
[
  {"cveconcepto": 1, "descripcion": "IMPUESTO PREDIAL", "ncorto": "PREDIAL", "cvegrupo": 1},
  {"cveconcepto": 2, "descripcion": "TRANSMISION PATRIMONIAL", "ncorto": "TRANSM-PAT", "cvegrupo": 1},
  {"cveconcepto": 51, "descripcion": "PRUEBA MODIFICADO", "ncorto": "PRUEBA-MOD", "cvegrupo": 2}
]
```

**Resultado**:
- ID: 1 → ACTUALIZADO
- ID: 2 → ACTUALIZADO
- ID: 51 → ACTUALIZADO
- Total: 3 registros procesados

---

## PROBLEMAS ENCONTRADOS Y SOLUCIONADOS

### ❌ Problema 1: Sintaxis SQL
**Error**: `SQLSTATE[42601]: Syntax error at or near ";"`
**Causa**: Uso de `!=` en lugar de `<>` en PL/pgSQL
**Solución**: Cambiar `!=` por `<>` en línea 51

### ❌ Problema 2: Columnas ambiguas
**Error**: `SQLSTATE[42702]: column reference "cveconcepto" is ambiguous`
**Causa**: Nombres de columnas conflictúan con variables
**Solución**: Agregar alias a todas las referencias de tabla:
```sql
-- Antes
SELECT 1 FROM public.c_conceptos WHERE cveconcepto = v_cveconcepto

-- Después
SELECT 1 FROM public.c_conceptos c WHERE c.cveconcepto = v_cveconcepto
```

### ❌ Problema 3: Ambigüedad en MAX()
**Error**: Similar al anterior en función MAX
**Causa**: Falta de alias en subconsulta
**Solución**:
```sql
-- Antes
SELECT COALESCE(MAX(cveconcepto), 0) + 1 FROM public.c_conceptos

-- Después
SELECT COALESCE(MAX(c.cveconcepto), 0) + 1 FROM public.c_conceptos c
```

---

## ESTRUCTURA DE LA TABLA c_conceptos

```sql
CREATE TABLE public.c_conceptos (
    cveconcepto INTEGER PRIMARY KEY,
    descripcion VARCHAR(35) NOT NULL,
    ncorto VARCHAR(15),
    cvegrupo SMALLINT,
    feccap DATE,
    capturista VARCHAR(20)
);
```

---

## CASOS DE USO

### Caso 1: Actualizar descripción de concepto existente
**Escenario**: El nombre de un concepto cambió por actualización de reglamento
**Acción**: Enviar JSON con cveconcepto existente y nueva descripción
**Resultado**: Se actualiza el registro preservando el ID

### Caso 2: Crear nuevos conceptos de pago
**Escenario**: Se agregan nuevos tipos de pago al sistema
**Acción**: Enviar JSON con cveconcepto = 0
**Resultado**: Sistema genera ID automático e inserta el registro

### Caso 3: Migración masiva de conceptos
**Escenario**: Actualizar múltiples conceptos de un solo golpe
**Acción**: Enviar JSON array con todos los registros
**Resultado**: Procesa todos en una sola transacción

---

## INTEGRACIÓN CON EL SISTEMA

### Backend (Laravel)
**Controlador**: `GenericController.php`
**Ruta API**: `/api/execute-sp`
**Método**: POST
**Body**:
```json
{
  "operation": "RECAUDADORA_PUBLICOS_UPD",
  "database": "multas_reglamentos",
  "params": {
    "p_datos": "[{...}]"
  }
}
```

### Frontend (Vue 3)
**Composable**: `useApi()`
**Llamada**:
```javascript
const { execute } = useApi()
const data = await execute('RECAUDADORA_PUBLICOS_UPD', 'multas_reglamentos', {
  p_datos: jsonPayload.value
})
```

---

## VISUALIZACIÓN DE RESULTADOS

La tabla HTML muestra:

| Columna | Descripción |
|---------|-------------|
| ID | Clave del concepto |
| Descripción | Nombre completo del concepto |
| Nombre Corto | Abreviatura (máx. 15 caracteres) |
| Grupo | Grupo al que pertenece |
| Acción | Badge de color (INSERTADO/ACTUALIZADO/ERROR) |
| Resultado | Mensaje descriptivo del resultado |

**Estilos aplicados**:
- Header: Gradiente naranja `linear-gradient(135deg, #ea8215 0%, #d67512 100%)`
- Filas success: Fondo verde claro `#d4edda`
- Filas error: Fondo rojo claro `#f8d7da`
- Hover: Fondo gris `#f9f9f9`

---

## EJEMPLOS LISTOS PARA EL FORMULARIO

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

## VERIFICACIÓN FINAL

✅ SP desplegado en base de datos: `public.recaudadora_publicos_upd`
✅ Componente Vue actualizado con tabla de resultados
✅ 3 ejemplos probados exitosamente
✅ Validación de JSON implementada
✅ Manejo de errores robusto
✅ Badges de colores funcionando
✅ Resumen de registros procesados
✅ Integración con API genérica validada

---

## COMANDOS PARA PRUEBAS

### Probar SP directamente:
```bash
php temp/test_publicos_upd.php
```

### Redesplegar SP si es necesario:
```bash
php -r "\$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2'); \$pdo->exec(file_get_contents('temp/recaudadora_publicos_upd_fixed.sql')); echo 'SP desplegado';"
```

### Consultar conceptos actuales:
```sql
SELECT * FROM public.c_conceptos ORDER BY cveconcepto LIMIT 10;
```

---

## CONCLUSIÓN

El componente **Publicos_Upd.vue** está completamente funcional y listo para uso en producción. Permite actualización masiva de conceptos de pago con interfaz intuitiva, validación robusta y visualización clara de resultados.

**Próximos módulos**: Listos para trabajar en el siguiente componente del módulo multas_reglamentos.
