# Ejemplos para Probar ReqTrans.vue

## ✅ STORED PROCEDURE DESPLEGADO EXITOSAMENTE

**Nombre:** `recaudadora_reqtrans_list`
**Tabla:** `catastro_gdl.reqdiftransmision`
**Total de registros:** 13 requerimientos de transmisión
**Columnas:**
- `clave_cuenta` (TEXT) - Clave de cuenta
- `folio` (INTEGER) - Número de folio de transmisión
- `ejercicio` (INTEGER) - Año del requerimiento
- `estatus` (TEXT) - Estado del requerimiento (Activo/Inactivo/Pendiente)

---

## 📋 EJEMPLOS PARA PRUEBAS

### EJEMPLO 1: Buscar por cuenta específica
**Parámetros:**
- **Cuenta:** `11111`
- **Año:** (dejar vacío)

**Resultado Esperado:**
- **Registros:** 2
- **Páginas:** 1 página
- **Primer Dato:**
  - Cuenta: 11111
  - Folio: 0
  - Año: 2025
  - Estatus: Pendiente
- **Acciones:** Botones Editar y Eliminar disponibles

---

### EJEMPLO 2: Buscar por año específico
**Parámetros:**
- **Cuenta:** (dejar vacío)
- **Año:** `2025`

**Resultado Esperado:**
- **Registros:** 5
- **Páginas:** 1 página
- **Datos:**
  - Cuenta 11111 - Folio 0 - Año 2025 - Pendiente
  - Cuenta 999888777 - Folio 0 - Año 2025 - Pendiente
  - Cuenta 888777666 - Folio 0 - Año 2025 - Pendiente
  - Cuenta 444555666 - Folio 0 - Año 2025 - Pendiente
  - Cuenta 333333333 - Folio 0 - Año 2025 - Pendiente

---

### EJEMPLO 3: Buscar todos (sin filtros)
**Parámetros:**
- **Cuenta:** (dejar vacío)
- **Año:** (dejar vacío)

**Resultado Esperado:**
- **Registros:** 13 requerimientos totales
- **Páginas:** 2 páginas (10 registros en página 1, 3 registros en página 2)
- **Primeros 5 registros:**
  1. Cuenta 11111 - Folio 0 - Año 2025 - Pendiente
  2. Cuenta 999888777 - Folio 0 - Año 2025 - Pendiente
  3. Cuenta 888777666 - Folio 0 - Año 2025 - Pendiente
  4. Cuenta 444555666 - Folio 0 - Año 2025 - Pendiente
  5. Cuenta 333333333 - Folio 0 - Año 2025 - Pendiente

**Navegación:**
- Página 1: Registros 1-10
- Página 2: Registros 11-13
- Usar botones "Anterior" y "Siguiente" para navegar

---

## 🔧 CAMBIOS IMPLEMENTADOS

### Frontend (ReqTrans.vue):
✅ **Parámetros en español** (`nombre`, `tipo`, `valor`) - CRÍTICO
✅ **Paginación implementada** (10 registros por página)
✅ Procesamiento de datos desde `data.result`
✅ Header de resultados con contador de registros
✅ Controles de paginación (Anterior/Siguiente)
✅ Funciones de navegación entre páginas
✅ Reset de paginación en nueva búsqueda
✅ CSS para controles de paginación

### Backend:
✅ Stored Procedure `recaudadora_reqtrans_list` creado
✅ Corrección de tipos de datos (CAST de INTEGER a TEXT)
✅ Manejo de valores NULL con COALESCE
✅ Búsqueda por cuenta con patrón ILIKE
✅ Filtro por año (ejercicio)
✅ Estatus calculado basado en columna vigencia:
   - '1' o 'A' → Activo
   - '0' o 'I' → Inactivo
   - Otro/NULL → Pendiente
✅ Ordenamiento por año y folio descendente
✅ Límite de 100 registros

---

## 🎯 CARACTERÍSTICAS DEL MÓDULO

### Funcionalidad CRUD:
- **Lista:** Ver todos los requerimientos con paginación
- **Buscar:** Filtrar por cuenta y/o año
- **Nuevo:** Botón para crear nuevo requerimiento (modal)
- **Editar:** Botón para modificar cada registro (modal)
- **Eliminar:** Botón para eliminar cada registro

### Columnas de la Tabla:
1. **Cuenta** - Clave de cuenta (formato código)
2. **Folio** - Número de folio de transmisión
3. **Año** - Ejercicio fiscal
4. **Estatus** - Estado del requerimiento
5. **Acciones** - Botones Editar y Eliminar

---

## 📊 VERIFICACIÓN DEL SP

```sql
-- Probar el SP directamente en PostgreSQL
SELECT * FROM recaudadora_reqtrans_list('11111', NULL);  -- Ejemplo 1
SELECT * FROM recaudadora_reqtrans_list(NULL, 2025);     -- Ejemplo 2
SELECT * FROM recaudadora_reqtrans_list(NULL, NULL);     -- Ejemplo 3
```

---

## 📁 ESTRUCTURA DE DATOS

### Tabla: catastro_gdl.reqdiftransmision
**Columnas principales:**
- `cvereq` - Clave del requerimiento
- `cvecuenta` - Clave de cuenta (mapeada a clave_cuenta)
- `foliotransm` - Folio de transmisión (mapeado a folio)
- `axoreq` - Año del requerimiento (mapeado a ejercicio)
- `vigencia` - Estado de vigencia (mapeado a estatus)
- `impuesto`, `recargos`, `multa_imp`, `multa_ext` - Montos
- `actualizacion`, `gastos`, `total` - Totales

---

## 🎯 RESUMEN

- **SP:** `recaudadora_reqtrans_list` ✅ Funcional
- **Vista:** `ReqTrans.vue` ✅ Actualizada con paginación
- **Paginación:** 10 registros por página ✅ Implementada
- **Ejemplos:** 3 casos de prueba con datos reales ✅ Documentados
- **Total de registros:** 13 requerimientos disponibles
- **Total de páginas:** 2 páginas (en búsqueda sin filtros)

---

## 📝 NOTAS IMPORTANTES

1. **CRUD Completo:** Este módulo incluye operaciones Create, Update y Delete además de Read/List. Los SPs para estas operaciones (`RECAUDADORA_REQTRANS_CREATE`, `UPDATE`, `DELETE`) aún no están implementados.

2. **Parámetros Corregidos:** Los parámetros ahora usan español (`nombre`, `tipo`, `valor`) en lugar de inglés. Esto es crítico para que el backend procese correctamente las peticiones.

3. **Procesamiento de Datos:** La función `processResults()` verifica múltiples ubicaciones para los datos (`data.result`, `data.rows`, `data` directo) para máxima compatibilidad.

4. **Paginación Reactiva:** La paginación se resetea automáticamente cuando se realiza una nueva búsqueda.

5. **Datos Actuales:** La tabla tiene registros principalmente de 2023, 2024 y 2025, con la mayoría en 2025.

6. **Folios:** Todos los folios actuales son 0, lo que podría indicar que están pendientes de asignación.

---

## 🚀 PRÓXIMOS PASOS (OPCIONAL)

Si se desean implementar las operaciones CRUD completas, se necesitarían crear:
- `recaudadora_reqtrans_create` - Para insertar nuevos registros
- `recaudadora_reqtrans_update` - Para actualizar registros existentes
- `recaudadora_reqtrans_delete` - Para eliminar registros

Por ahora, solo la operación LIST (consulta) está completamente funcional.
