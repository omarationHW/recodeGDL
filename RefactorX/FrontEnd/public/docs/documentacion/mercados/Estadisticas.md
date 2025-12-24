# Estadisticas

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Estadísticas de Adeudos

## Descripción General
Este módulo permite consultar estadísticas de adeudos de locales comerciales, con tres modalidades:

1. **Todos los Adeudos**: Estadística global de adeudos vencidos al periodo seleccionado.
2. **Adeudos ≥ Importe**: Estadística global de adeudos vencidos al periodo, filtrando por importe mínimo.
3. **Desglose Adeudos ≥ Importe**: Desglose de adeudos por año para locales con importe mayor o igual al parámetro.

La solución está compuesta por:
- **Backend Laravel**: Un controlador con endpoint unificado `/api/execute` que recibe eRequest/eResponse.
- **Frontend Vue.js**: Página independiente para consulta y exportación de estadísticas.
- **Stored Procedures PostgreSQL**: Toda la lógica SQL reside en SPs para eficiencia y seguridad.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato**:
  ```json
  {
    "action": "getEstadisticasGlobal|getEstadisticasImporte|getDesgloceAdeudosPorImporte",
    "params": {
      "year": 2024,
      "month": 6,
      "importe": 3000
    }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## Stored Procedures
- **sp_estadisticas_global**: Devuelve estadística global de adeudos.
- **sp_estadisticas_importe**: Igual que anterior, pero filtrando por importe.
- **sp_desgloce_adeudos_por_importe**: Devuelve desglose por año de adeudos para locales con importe mayor o igual al parámetro.

## Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## Exportación a Excel
- El frontend exporta los resultados a CSV (puede integrarse con librerías como SheetJS para Excel nativo).

## Navegación
- Cada formulario es una página independiente.
- Breadcrumbs para navegación contextual.

## Integración
- El frontend se comunica con el backend usando Axios y el endpoint unificado.
- El backend ejecuta el SP correspondiente según el tipo de estadística.

## Consideraciones
- Los SPs pueden ser adaptados para optimización según el volumen de datos.
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js.

# Parámetros de Entrada
- **year**: Año de corte de la estadística.
- **month**: Mes de corte.
- **importe**: Importe mínimo (solo para los modos 2 y 3).

# Parámetros de Salida
- Listado de registros con columnas dinámicas según el SP invocado.

# Errores Comunes
- Si no se selecciona tipo de estadística, el backend responde con error.
- Si los parámetros son inválidos, el backend retorna mensaje de error.

# Pruebas y Validación
- Ver sección de Casos de Uso y Casos de Prueba.


## Casos de Uso

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



## Casos de Prueba

# Casos de Prueba: Estadísticas de Adeudos

## Caso 1: Consulta Global
- **Entrada:**
  - action: getEstadisticasGlobal
  - params: { year: 2024, month: 6 }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array con columnas [oficina, num_mercado, local_count, adeudo, descripcion]

## Caso 2: Consulta por Importe
- **Entrada:**
  - action: getEstadisticasImporte
  - params: { year: 2024, month: 6, importe: 3000 }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array solo con mercados con adeudo >= 3000

## Caso 3: Desglose por Importe
- **Entrada:**
  - action: getDesgloceAdeudosPorImporte
  - params: { year: 2024, month: 5, importe: 5000 }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array con columnas [id_local, oficina, mercado, categoria, seccion, local, letra, bloque, nombre, descripcion, ade_ant, ade_2004, ade_2005, ade_2006, ade_2007, ade_2008, tot_ade]

## Caso 4: Parámetros Inválidos
- **Entrada:**
  - action: getEstadisticasImporte
  - params: { year: 2024, month: 6 }
- **Esperado:**
  - HTTP 200
  - success: false
  - message: error de parámetros

## Caso 5: Acción No Soportada
- **Entrada:**
  - action: getFooBar
  - params: {}
- **Esperado:**
  - HTTP 200
  - success: false
  - message: 'Acción no soportada'



