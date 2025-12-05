# Ejemplos para Probar ReqPromocion.vue

## ✅ STORED PROCEDURE DESPLEGADO EXITOSAMENTE

**Nombre:** `recaudadora_req_promocion`
**Tabla:** `catastro_gdl.descuentos2008`
**Total de registros:** 76 descuentos
**Columnas:**
- `cvedescuento` (INTEGER) - ID del descuento
- `descripcion` (TEXT) - Descripción del descuento
- `importe` (NUMERIC) - Importe total del descuento

---

## 📋 EJEMPLOS PARA PRUEBAS

### EJEMPLO 1: Buscar por ID específico 175
**Parámetros:**
- **Cuenta / ID Descuento:** `175`
- **Año:** (dejar vacío)

**Resultado Esperado:**
- **Registros:** 1
- **Páginas:** 1 página
- **Datos:**
  - ID: 175
  - Descripción: 3A EDAD 80 AÑOS 2007
  - Importe: $40,223.53

---

### EJEMPLO 2: Buscar por ID que coincida parcialmente (98)
**Parámetros:**
- **Cuenta / ID Descuento:** `98`
- **Año:** (dejar vacío)

**Resultado Esperado:**
- **Registros:** 2 (encuentra 98 y 198 por coincidencia parcial)
- **Páginas:** 1 página
- **Datos:**
  - ID 198: MAYORES 60 AÑOS 2008 - $12,439,079.39
  - ID 98: VIUDAS 2003 - $824.85

**Nota:** El SP busca con `ILIKE '%98%'`, por lo que encuentra tanto 98 como 198.

---

### EJEMPLO 3: Buscar todos (sin filtros)
**Parámetros:**
- **Cuenta / ID Descuento:** (dejar vacío)
- **Año:** (dejar vacío)

**Resultado Esperado:**
- **Registros:** 76 descuentos
- **Páginas:** 8 páginas (10 registros por página)
- **Primeros registros mostrados:**
  1. ID 999999: DESCUENTO POR PRONTO PAGO 2008 - $52,550,792.21
  2. ID 202: INCENTIVOS FISCALES 2008 0.81 - $44,035.56
  3. ID 200: VIUDAS (O) 2008 - $1,260,796.11
  4. ID 199: PENSIONADOS 2008 - $11,848,261.20
  5. ID 198: MAYORES 60 AÑOS 2008 - $12,439,079.39
  6. ID 197: MENORES 14 AÑOS 2008 - $2,008,969.68
  7. ID 196: 70 AÑOS O MAS 2008 - $22,039,033.02
  8. ID 195: MAYORES 60 AÑOS 2007 - $3,001,032.63
  9. ID 194: 3A EDAD 80 AÑOS 2007 - $280.00
  10. ID 193: 3A EDAD 75 AÑOS 2007 - $110.00

**Navegación:**
- Usar botones "Anterior" y "Siguiente" para navegar entre las 8 páginas
- Cada página muestra 10 registros
- La última página (página 8) mostrará 6 registros

---

## 🔧 CAMBIOS IMPLEMENTADOS

### Frontend (ReqPromocion.vue):
✅ HTML correctamente formateado (sin errores de parsing)
✅ Título actualizado a "Requerimiento Promoción"
✅ Ícono cambiado a "badge-percent"
✅ Parámetros en español (`nombre`, `tipo`, `valor`) - **CRÍTICO**
✅ Paginación implementada (10 registros por página)
✅ Procesamiento de datos desde `data.result`
✅ Formato de columnas personalizado
✅ Formato de moneda para importe ($MXN)
✅ Campo de búsqueda por ID Descuento
✅ Campo de año (opcional, no utilizado por el SP actual)

### Backend:
✅ Stored Procedure `recaudadora_req_promocion` creado
✅ Corrección de tipos de datos (TEXT en lugar de VARCHAR)
✅ Búsqueda por ID con patrón ILIKE
✅ Ordenamiento por ID descendente
✅ Límite de 100 registros

---

## 📊 VERIFICACIÓN DEL SP

```sql
-- Probar el SP directamente en PostgreSQL
SELECT * FROM recaudadora_req_promocion('175', NULL);  -- Ejemplo 1
SELECT * FROM recaudadora_req_promocion('98', NULL);   -- Ejemplo 2
SELECT * FROM recaudadora_req_promocion(NULL, NULL);   -- Ejemplo 3
```

---

## 🎯 RESUMEN

- **SP:** `recaudadora_req_promocion` ✅ Funcional
- **Vista:** `ReqPromocion.vue` ✅ Actualizada
- **Paginación:** 10 registros por página ✅ Implementada
- **Ejemplos:** 3 casos de prueba con datos reales ✅ Documentados
- **Total de registros:** 76 descuentos disponibles
- **Total de páginas:** 8 páginas (en búsqueda sin filtros)

---

## 📝 NOTAS

1. El campo "Año" está presente en el formulario pero el SP actual no lo utiliza (parámetro `p_ejercicio` no aplicado en el WHERE).
2. La búsqueda es por coincidencia parcial (ILIKE '%valor%'), por lo que '98' encontrará tanto 98 como 198.
3. Los importes se formatean automáticamente en pesos mexicanos (MXN).
4. El SP está limitado a 100 registros, pero la tabla solo tiene 76.
