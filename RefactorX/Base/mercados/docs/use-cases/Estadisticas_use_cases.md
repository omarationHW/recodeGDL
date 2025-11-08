# Casos de Uso - Estadisticas

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadística Global de Adeudos

**Descripción:** El usuario desea obtener la estadística global de adeudos vencidos al periodo junio 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudos en la base.

**Pasos a seguir:**
1. Acceder a la página de Estadísticas.
2. Seleccionar 'Todos los Adeudos'.
3. Ingresar año 2024 y mes 6.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con la estadística global de adeudos por oficina y mercado.

**Datos de prueba:**
{ "action": "getEstadisticasGlobal", "params": { "year": 2024, "month": 6 } }

---

## Caso de Uso 2: Consulta de Adeudos con Importe Mínimo

**Descripción:** El usuario desea ver solo los mercados con adeudos mayores o iguales a $3000 al periodo junio 2024.

**Precondiciones:**
El usuario tiene acceso y existen adeudos mayores a $3000.

**Pasos a seguir:**
1. Acceder a la página de Estadísticas.
2. Seleccionar 'Adeudos ≥ Importe'.
3. Ingresar año 2024, mes 6, importe 3000.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla solo con mercados que cumplen el filtro de importe.

**Datos de prueba:**
{ "action": "getEstadisticasImporte", "params": { "year": 2024, "month": 6, "importe": 3000 } }

---

## Caso de Uso 3: Desglose de Adeudos por Importe

**Descripción:** El usuario requiere el desglose por año de los locales con adeudos mayores o iguales a $5000 al periodo mayo 2024.

**Precondiciones:**
El usuario tiene acceso y existen locales con adeudos mayores a $5000.

**Pasos a seguir:**
1. Acceder a la página de Estadísticas.
2. Seleccionar 'Desglose Adeudos ≥ Importe'.
3. Ingresar año 2024, mes 5, importe 5000.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con el desglose por año de adeudos para cada local filtrado.

**Datos de prueba:**
{ "action": "getDesgloceAdeudosPorImporte", "params": { "year": 2024, "month": 5, "importe": 5000 } }

---

