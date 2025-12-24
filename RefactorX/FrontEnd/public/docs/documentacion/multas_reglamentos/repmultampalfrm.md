# Documentación: repmultampalfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario repmultampalfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este documento describe la migración del formulario Delphi `repmultampalfrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio). El objetivo es mantener la funcionalidad original, permitiendo la consulta y reporte de multas municipales con filtros avanzados.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de reportes en stored procedures.

## 3. Endpoints API
- **POST /api/execute**
  - **eRequest: get_dependencias**
    - Retorna catálogo de dependencias.
  - **eRequest: get_infracciones_by_dependencia**
    - Parámetro: `id_dependencia`
    - Retorna catálogo de infracciones para la dependencia seleccionada.
  - **eRequest: get_multas_report**
    - Parámetros: filtros de reporte (ver stored procedure)
    - Retorna listado de multas según filtros.

## 4. Stored Procedure Principal
- **report_multas**: Recibe todos los filtros posibles y retorna el reporte de multas, incluyendo datos de dependencia (abreviatura).
- Los filtros incluyen:
  - Dependencia
  - Infracción
  - Nombre de contribuyente
  - Domicilio
  - Fecha (única, rango, año)
  - Estatus (vigente, cancelado, pagado)

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Filtros dinámicos (habilitados/deshabilitados según checkbox).
- Carga dinámica de infracciones según dependencia seleccionada.
- Validaciones de campos requeridos según tipo de filtro.
- Resultados en tabla, con total de registros.

## 6. Backend (Laravel)
- Controlador único `ExecuteController`.
- Manejo de eRequest/eResponse.
- Llamadas a stored procedures vía DB::select.
- Validación de parámetros y manejo de errores.

## 7. Seguridad
- Validación de parámetros en backend.
- Uso de parámetros en consultas para evitar SQL Injection.
- El endpoint `/api/execute` debe protegerse según políticas de autenticación/autorización del sistema.

## 8. Consideraciones
- El estatus "Pagado" no está implementado en la lógica original Delphi, se deja como placeholder.
- El frontend puede ser extendido para exportar a PDF/Excel si se requiere.

## 9. Requerimientos Previos
- Tablas: `multas`, `c_dependencias`, `c_infracciones` deben existir y tener los campos esperados.
- El stored procedure debe ser creado en la base de datos PostgreSQL destino.

## 10. Ejemplo de Llamada API
```json
{
  "eRequest": "get_multas_report",
  "params": {
    "id_dependencia": 1,
    "id_infraccion": null,
    "contribuyente": "JUAN",
    "domicilio": null,
    "fecha_tipo": 2,
    "fecha1": "2024-01-01",
    "fecha2": "2024-06-30",
    "anio": null,
    "estatus": 1
  }
}
```

## 11. Errores Comunes
- Si faltan parámetros requeridos, el API retorna `success: false` y un mensaje de error.
- Si no hay resultados, el frontend muestra mensaje de "No se encontraron resultados".

## Casos de Uso

# Casos de Uso - repmultampalfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de multas por dependencia y rango de fechas

**Descripción:** El usuario desea obtener un reporte de todas las multas de una dependencia específica en un rango de fechas.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros de multas para la dependencia seleccionada.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Multas Municipales.
2. Activar el filtro 'Dependencia' y seleccionar la dependencia deseada.
3. Seleccionar 'Rango de fechas' como tipo de fecha.
4. Ingresar la fecha de inicio y fin.
5. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se muestra una tabla con todas las multas de la dependencia seleccionada dentro del rango de fechas especificado.

**Datos de prueba:**
Dependencia: 'Tránsito'
Fecha inicio: 2024-01-01
Fecha fin: 2024-06-30

---

## Caso de Uso 2: Búsqueda de multas por nombre de contribuyente y año

**Descripción:** El usuario busca todas las multas de un contribuyente específico en un año determinado.

**Precondiciones:**
El usuario tiene acceso y existen multas registradas para el contribuyente y año indicados.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Multas Municipales.
2. Activar el filtro 'Nombre' e ingresar el nombre del contribuyente.
3. Seleccionar 'Año' como tipo de fecha e ingresar el año.
4. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se muestra una tabla con todas las multas del contribuyente en el año especificado.

**Datos de prueba:**
Nombre: 'MARIA LOPEZ'
Año: 2023

---

## Caso de Uso 3: Consulta de multas vigentes por infracción y domicilio

**Descripción:** El usuario desea ver todas las multas vigentes de una infracción específica y domicilio que comiencen con un texto dado.

**Precondiciones:**
El usuario tiene acceso y existen multas vigentes para la infracción y domicilio indicados.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Multas Municipales.
2. Activar el filtro 'Infracción' y seleccionar la infracción.
3. Activar el filtro 'Domicilio' e ingresar el texto inicial del domicilio.
4. Seleccionar 'Vigente' como estado.
5. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se muestra una tabla con todas las multas vigentes que cumplen con los filtros de infracción y domicilio.

**Datos de prueba:**
Infracción: 'ESTACIONARSE EN LUGAR PROHIBIDO'
Domicilio: 'AVENIDA PRINCIPAL'

---

## Casos de Prueba

# Casos de Prueba para Reporte de Multas Municipales

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Consulta sin filtros (Todos) | Sin filtros (todos por default) | Se muestran todas las multas existentes |
| TC02 | Consulta por dependencia y rango de fechas | Dependencia: 2, Fecha inicio: 2024-01-01, Fecha fin: 2024-03-31, Tipo fecha: Rango | Solo multas de la dependencia 2 en ese rango |
| TC03 | Consulta por nombre de contribuyente | Nombre: 'PEDRO', Tipo fecha: Todos | Solo multas cuyo contribuyente inicia con 'PEDRO' |
| TC04 | Consulta por año y estado vigente | Año: 2023, Estado: Vigente | Solo multas del año 2023 y con fecha_cancelacion NULL |
| TC05 | Consulta por infracción y domicilio | Infracción: 5, Domicilio: 'CALLE 10', Estado: Todos | Solo multas con esa infracción y domicilio que inicia con 'CALLE 10' |
| TC06 | Consulta sin resultados | Dependencia: 99 (no existe) | Mensaje de 'No se encontraron resultados' |
| TC07 | Validación de campos requeridos | Tipo fecha: Rango, solo fecha inicio | Mensaje de error: 'Debe seleccionar fecha de inicio y fin.' |
| TC08 | Validación de año | Tipo fecha: Año, año vacío | Mensaje de error: 'Debe especificar el año.' |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

