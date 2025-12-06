# RESUMEN: Correcciones Pendientes

**Fecha:** 2025-12-05
**Tests Ejecutados:** 11 componentes
**Resultado Actual:** 4 funcionando, 7 con errores

---

## COMPONENTES FUNCIONANDO ✅

1. **ReporteGeneralMercados** - 13 registros (OK)
2. **RptLocalesGiro** - 5,548 registros (OK)
3. **RptPagosAno** - CORREGIDO (public → publico, num_mercado → num_mercado_nvo)
4. **RptFacturaGLunes** - CORREGIDO (id_rec → oficina, mercado → num_mercado, estado eliminado)

---

## COMPONENTES CON ERRORES ❌

### 1. Estadisticas
- **Error:** SP no existe
- **Acción:** Necesita crearse o encontrar el SP correcto

### 2. Prescripcion (sp_listar_adeudos_energia)
- **Error:** Structure of query does not match function result type
- **Problema:** RETURNS TABLE no coincide con los tipos reales
- **Acción:** Ajustar tipos en RETURNS TABLE

### 3. RptIngresos
- **Error:** invalid input syntax for type integer: "2010-01-01"
- **Problema:** Los parámetros de prueba eran fechas pero el SP espera integers
- **Acción:** Verificar firma del SP y ajustar pruebas

### 4. RptIngresosEnergia
- **Error:** invalid input syntax for type integer: "2010-01-01"
- **Problema:** Los parámetros de prueba eran fechas pero el SP espera integers
- **Acción:** Verificar firma del SP y ajustar pruebas

### 5. RptPagosCaja
- **Error:** invalid input syntax for type date: "2010"
- **Problema:** Los parámetros de prueba no coinciden con la firma del SP
- **Acción:** Verificar firma del SP y ajustar pruebas

### 6. RptPagosDetalle
- **Error:** SP no existe
- **Acción:** Verificar si el SP existe con otro nombre o necesita crearse

### 7. RptPagosGrl
- **Error:** invalid input syntax for type integer: "2010-01-01"
- **Problema:** Los parámetros de prueba eran fechas pero el SP espera integers
- **Acción:** Verificar firma del SP y ajustar pruebas

---

## PRÓXIMOS PASOS

1. ✅ RptPagosAno y RptFacturaGLunes YA CORREGIDOS
2. Verificar firmas reales de todos los SPs
3. Corregir tipos de parámetros en Prescripcion
4. Encontrar o crear SPs faltantes (Estadisticas, RptPagosDetalle)
5. Ajustar parámetros de prueba para coincidir con firmas reales
