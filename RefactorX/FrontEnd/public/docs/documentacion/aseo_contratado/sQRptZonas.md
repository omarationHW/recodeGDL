# Documentación Técnica: sQRptZonas

## Análisis

# Documentación Técnica: Migración de Formulario sQRptZonas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de reporte de zonas (`sQRptZonas`) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo consultar y visualizar el catálogo de zonas con diferentes criterios de clasificación.

## 2. Arquitectura
- **Backend**: Laravel expone un endpoint único `/api/execute` que recibe peticiones estructuradas (eRequest/eResponse) y ejecuta la lógica correspondiente, incluyendo la invocación de stored procedures en PostgreSQL.
- **Frontend**: Vue.js implementa una página independiente para el reporte de zonas, permitiendo seleccionar el criterio de clasificación y mostrando los resultados en una tabla.
- **Base de Datos**: Toda la lógica de consulta y ordenamiento se encapsula en un stored procedure (`rpt_ta_16_zonas_report`) en PostgreSQL.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "getZonasReport",
    "params": { "opcion": 1 }
  }
  ```
  - `opcion`: 1=Control, 2=Zona, 3=Sub-Zona, 4=Descripción
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": "Reporte de zonas obtenido correctamente."
    }
  }
  ```

## 4. Stored Procedure
- **Nombre**: `rpt_ta_16_zonas_report`
- **Parámetro**: `opcion` (integer)
- **Retorna**: Tabla con columnas `ctrol_zona`, `zona`, `sub_zona`, `descripcion` ordenada según la opción.
- **Uso**:
  ```sql
  SELECT * FROM rpt_ta_16_zonas_report(1);
  ```

## 5. Frontend (Vue.js)
- Página independiente `/zonas-report`.
- Permite seleccionar el criterio de clasificación.
- Muestra los resultados en tabla.
- Incluye breadcrumb y fecha/hora de impresión.

## 6. Backend (Laravel)
- Controlador: `Api\ExecuteController`
- Método: `handle(Request $request)`
- Invoca el stored procedure vía DB::select.
- Devuelve respuesta estructurada eResponse.

## 7. Seguridad
- Validación básica de parámetros.
- Se recomienda proteger el endpoint con autenticación según las políticas del sistema.

## 8. Pruebas
- Casos de uso y pruebas detalladas en secciones siguientes.

## 9. Consideraciones
- El endpoint es extensible para otros formularios y operaciones.
- El stored procedure puede ser optimizado según índices y volumen de datos.


## Casos de Uso

# Casos de Uso - sQRptZonas

**Categoría:** Form

## Caso de Uso 1: Consulta de zonas clasificadas por Número de Control

**Descripción:** El usuario desea obtener el catálogo de zonas ordenado por el número de control.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la tabla ta_16_zonas.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Zonas.
2. Selecciona 'Número de Control' como criterio de clasificación.
3. Hace clic en 'Consultar'.
4. El sistema envía la petición al endpoint /api/execute con eRequest 'getZonasReport' y opcion=1.
5. El backend ejecuta el stored procedure y retorna los datos ordenados por ctrol_zona.
6. El frontend muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra la lista de zonas ordenada por el campo ctrol_zona.

**Datos de prueba:**
ta_16_zonas:
| ctrol_zona | zona | sub_zona | descripcion |
|------------|------|----------|-------------|
| 001        | A    | 1        | Centro      |
| 002        | B    | 2        | Norte       |

---

## Caso de Uso 2: Consulta de zonas clasificadas por Zona y Sub-Zona

**Descripción:** El usuario desea ver el catálogo de zonas ordenado primero por zona y luego por sub-zona.

**Precondiciones:**
El usuario tiene acceso y existen zonas con diferentes valores en zona y sub_zona.

**Pasos a seguir:**
1. Accede a la página de reporte de zonas.
2. Selecciona 'Zona' como criterio de clasificación.
3. Hace clic en 'Consultar'.
4. El sistema envía la petición con opcion=2.
5. El backend retorna los datos ordenados por zona y sub_zona.

**Resultado esperado:**
La tabla muestra las zonas agrupadas por zona y ordenadas por sub_zona dentro de cada zona.

**Datos de prueba:**
ta_16_zonas:
| ctrol_zona | zona | sub_zona | descripcion |
|------------|------|----------|-------------|
| 003        | A    | 2        | Este        |
| 004        | A    | 1        | Oeste       |
| 005        | B    | 1        | Sur         |

---

## Caso de Uso 3: Consulta de zonas clasificadas por Descripción

**Descripción:** El usuario requiere ver el catálogo de zonas ordenado alfabéticamente por la descripción.

**Precondiciones:**
El usuario tiene acceso y existen descripciones variadas en la tabla.

**Pasos a seguir:**
1. Accede a la página de reporte de zonas.
2. Selecciona 'Descripción' como criterio de clasificación.
3. Hace clic en 'Consultar'.
4. El sistema envía la petición con opcion=4.
5. El backend retorna los datos ordenados por descripcion y ctrol_zona.

**Resultado esperado:**
La tabla muestra las zonas ordenadas alfabéticamente por el campo descripcion.

**Datos de prueba:**
ta_16_zonas:
| ctrol_zona | zona | sub_zona | descripcion |
|------------|------|----------|-------------|
| 006        | C    | 3        | Zafiro      |
| 007        | D    | 4        | Amatista    |
| 008        | E    | 5        | Rubí        |

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Zonas

## Caso 1: Consulta por Número de Control
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 1 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true
  - Datos ordenados por ctrol_zona ascendente

## Caso 2: Consulta por Zona y Sub-Zona
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 2 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true
  - Datos ordenados por zona, sub_zona ascendente

## Caso 3: Consulta por Sub-Zona y Zona
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 3 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true
  - Datos ordenados por sub_zona, zona ascendente

## Caso 4: Consulta por Descripción
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 4 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true
  - Datos ordenados por descripcion, ctrol_zona ascendente

## Caso 5: Parámetro inválido
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 99 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true (devuelve todos los datos, sin orden específico)

## Caso 6: eRequest no soportado
- **Entrada:**
  - eRequest: getZonasUnknown
  - params: {}
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = false
  - Mensaje de error indicando eRequest no soportado


