# Documentación: frmpol

## Análisis Técnico

# Documentación Técnica: Migración de Formulario frmpol (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de reporte de póliza por recaudadora (frmpol) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y catálogo se implementa mediante stored procedures en PostgreSQL y se expone a través de un endpoint API unificado siguiendo el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, página independiente `/frmpol`.
- **Backend**: Laravel Controller único (`ExecuteController`) con endpoint `/api/execute`.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint**: `POST /api/execute`
- **Request**:
  - `eRequest`: Nombre de la operación (ej: `getPolizaReporte`, `getRecaudadoras`)
  - `params`: Parámetros específicos de la operación
- **Response**:
  - `eResponse.success`: true/false
  - `eResponse.data`: Datos de respuesta (array/objeto)
  - `eResponse.message`: Mensaje de error o información

## 4. Stored Procedures
- **reporte_poliza_por_recaudadora(fecha, recaud)**: Devuelve el reporte agrupado por cuenta de aplicación, con totales y sumas.
- **catalogo_recaudadoras()**: Devuelve el catálogo de recaudadoras disponibles.

## 5. Flujo de la Aplicación
1. El usuario accede a la página `/frmpol`.
2. El frontend solicita el catálogo de recaudadoras (`getRecaudadoras`).
3. El usuario selecciona fecha y recaudadora, y presiona "Imprimir".
4. El frontend envía la solicitud `getPolizaReporte` con los parámetros.
5. El backend ejecuta el stored procedure y devuelve los resultados.
6. El frontend muestra la tabla de resultados y totales.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse mediante autenticación (ej: middleware `auth:api`), según la política de la aplicación.
- Validación de parámetros en el backend.

## 7. Consideraciones de Migración
- El reporte visual se implementa como tabla HTML con totales, no como PDF/impreso (puede exportarse si se requiere).
- Los nombres de campos y lógica se mantienen fieles al original Delphi.
- El catálogo de recaudadoras se obtiene de la tabla `c_ctasapl`.

## 8. Extensibilidad
- Nuevos formularios pueden integrarse fácilmente usando el mismo patrón eRequest/eResponse y agregando nuevos stored procedures y casos en el controlador.

## 9. Dependencias
- Laravel 9+
- Vue.js 3+
- PostgreSQL 12+

## 10. Ejemplo de Solicitud API
```json
{
  "eRequest": "getPolizaReporte",
  "params": {
    "fecha": "2024-06-01",
    "recaud": "003"
  }
}
```

## 11. Ejemplo de Respuesta API
```json
{
  "eResponse": {
    "success": true,
    "data": [
      { "cvectaapl": "003", "ctaaplicacion": "Recaudadora Centro", "totpar": 12, "suma": 15000.00 },
      ...
    ],
    "message": ""
  }
}
```

## Casos de Uso

# Casos de Uso - frmpol

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de póliza para una recaudadora y fecha específica

**Descripción:** El usuario desea obtener el reporte de póliza para la recaudadora '003' correspondiente al día 2024-06-01.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos para la recaudadora '003' en la fecha indicada.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de póliza.
2. Selecciona la fecha '2024-06-01'.
3. Selecciona la recaudadora '003'.
4. Presiona el botón 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con las cuentas de aplicación, descripción, total parcial y suma para la recaudadora '003' en la fecha seleccionada, junto con los totales generales.

**Datos de prueba:**
fecha: 2024-06-01, recaud: '003'

---

## Caso de Uso 2: Intento de consulta sin seleccionar recaudadora

**Descripción:** El usuario intenta generar el reporte sin seleccionar una recaudadora.

**Precondiciones:**
El usuario accede a la página y no selecciona recaudadora.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de póliza.
2. Selecciona la fecha '2024-06-01'.
3. No selecciona ninguna recaudadora.
4. Presiona el botón 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la recaudadora es obligatoria.

**Datos de prueba:**
fecha: 2024-06-01, recaud: ''

---

## Caso de Uso 3: Consulta de reporte para fecha sin datos

**Descripción:** El usuario consulta el reporte para una fecha en la que no existen registros.

**Precondiciones:**
No existen pagos registrados para la recaudadora '001' en la fecha '2024-01-01'.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de póliza.
2. Selecciona la fecha '2024-01-01'.
3. Selecciona la recaudadora '001'.
4. Presiona el botón 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron resultados para los criterios seleccionados.

**Datos de prueba:**
fecha: 2024-01-01, recaud: '001'

---

## Casos de Prueba

# Casos de Prueba para frmpol (Reporte de Póliza por Recaudadora)

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Consulta exitosa de reporte | fecha: 2024-06-01, recaud: '003' | Tabla con resultados y totales mostrados correctamente |
| TC02 | Consulta sin recaudadora | fecha: 2024-06-01, recaud: '' | Mensaje de error: 'Parámetros requeridos: fecha, recaud' |
| TC03 | Consulta sin resultados | fecha: 2024-01-01, recaud: '001' | Mensaje: 'No se encontraron resultados para los criterios seleccionados.' |
| TC04 | Consulta con recaudadora inexistente | fecha: 2024-06-01, recaud: '999' | Mensaje: 'No se encontraron resultados para los criterios seleccionados.' |
| TC05 | Consulta con fecha inválida | fecha: 'invalid-date', recaud: '003' | Mensaje de error de validación |
| TC06 | Carga de catálogo de recaudadoras | - | Lista de recaudadoras mostrada en el select |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

