# Documentación Técnica: sQRptUnd_Recolec

## Análisis

# Documentación Técnica: Migración de Formulario sQRptUnd_Recolec (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al catálogo de claves de recolección, originalmente implementado en Delphi como un reporte QuickReport. La migración implementa:
- Backend API en Laravel (endpoint único `/api/execute`)
- Lógica SQL encapsulada en stored procedures PostgreSQL
- Frontend como página Vue.js independiente

## 2. Backend (Laravel)
- **Controlador:** `App\Http\Controllers\Api\ExecuteController`
- **Endpoint:** `POST /api/execute`
- **Patrón:** Recibe un objeto `{ eRequest, params }` y responde `{ eResponse: { success, data, error } }`
- **eRequest soportados:**
  - `get_unidades_recolec`: Consulta el catálogo filtrado por ejercicio y ordenado por campo
  - `get_ejercicios`: Devuelve los ejercicios disponibles para selección
- **Seguridad:** Se recomienda proteger el endpoint con autenticación según la política de la aplicación.

## 3. Stored Procedures (PostgreSQL)
- **sp_get_unidades_recolec**: Devuelve los registros de `ta_16_unidades` filtrados por ejercicio y ordenados dinámicamente por el campo solicitado.
- **Parámetros:**
  - `p_ejercicio` (integer): Ejercicio fiscal
  - `p_order_by` (text): Campo de ordenamiento (`ctrol_recolec`, `cve_recolec`, `descripcion`, `costo_unidad`)
- **Retorno:** Tabla con los campos principales del catálogo.

## 4. Frontend (Vue.js)
- **Componente:** Página independiente, no usa tabs.
- **Funcionalidad:**
  - Selección de ejercicio y criterio de clasificación
  - Consulta y despliegue en tabla
  - Breadcrumb de navegación
  - Mensajes de carga, error y vacío
- **API:** Consume `/api/execute` con los eRequest mencionados

## 5. Flujo de Datos
1. El usuario selecciona ejercicio y clasificación y presiona "Consultar"
2. El frontend envía `{ eRequest: 'get_unidades_recolec', params: { ejercicio, order_by } }` a `/api/execute`
3. Laravel ejecuta el stored procedure y retorna los datos
4. El frontend muestra los resultados en tabla

## 6. Consideraciones
- El endpoint es unificado para facilitar integración y trazabilidad
- El ordenamiento es seguro, validado en backend
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js

## 7. Extensibilidad
- Se pueden agregar más eRequest en el controlador para futuras funcionalidades
- El stored procedure puede ampliarse para filtros adicionales

## 8. Seguridad
- Validar que los parámetros recibidos sean válidos y no permitan inyección
- Se recomienda agregar autenticación y autorización en producción


## Casos de Uso

# Casos de Uso - sQRptUnd_Recolec

**Categoría:** Form

## Caso de Uso 1: Consulta del catálogo por número de control

**Descripción:** El usuario desea ver el catálogo de claves de recolección del ejercicio 2024, ordenado por número de control.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros para el ejercicio 2024.

**Pasos a seguir:**
1. Ingresar a la página 'Catálogo de Claves de Recolección'.
2. Seleccionar '2024' en el campo Ejercicio.
3. Seleccionar 'Número de Control' en Clasificación por.
4. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los registros del ejercicio 2024, ordenados por el campo 'Control'.

**Datos de prueba:**
Ejercicio: 2024
Clasificación: ctrol

---

## Caso de Uso 2: Consulta del catálogo por descripción

**Descripción:** El usuario desea ver el catálogo de claves de recolección del ejercicio 2023, ordenado alfabéticamente por descripción.

**Precondiciones:**
El usuario tiene acceso y existen registros para el ejercicio 2023.

**Pasos a seguir:**
1. Ingresar a la página 'Catálogo de Claves de Recolección'.
2. Seleccionar '2023' en Ejercicio.
3. Seleccionar 'Descripción' en Clasificación por.
4. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra la tabla ordenada alfabéticamente por descripción.

**Datos de prueba:**
Ejercicio: 2023
Clasificación: descripcion

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario selecciona un ejercicio para el cual no existen registros.

**Precondiciones:**
El usuario tiene acceso. No existen registros para el ejercicio 2022.

**Pasos a seguir:**
1. Ingresar a la página.
2. Seleccionar '2022' en Ejercicio.
3. Seleccionar cualquier clasificación.
4. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron registros.

**Datos de prueba:**
Ejercicio: 2022
Clasificación: ctrol

---



## Casos de Prueba

# Casos de Prueba para Catálogo de Claves de Recolección

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta por número de control | ejercicio=2024, order_by=ctrol | Tabla con registros 2024 ordenados por ctrol_recolec |
| TC02 | Consulta por clave | ejercicio=2024, order_by=cve | Tabla con registros 2024 ordenados por cve_recolec |
| TC03 | Consulta por descripción | ejercicio=2023, order_by=descripcion | Tabla con registros 2023 ordenados por descripcion |
| TC04 | Consulta por costo de unidad | ejercicio=2023, order_by=costo | Tabla con registros 2023 ordenados por costo_unidad |
| TC05 | Consulta sin resultados | ejercicio=2022, order_by=ctrol | Mensaje de 'No se encontraron registros' |
| TC06 | Error de parámetro inválido | ejercicio=2024, order_by=INVALIDO | Se usa orden por ctrol_recolec por defecto |
| TC07 | Listado de ejercicios | - | Lista de ejercicios únicos disponibles |
| TC08 | Error de conexión a BD | - | Mensaje de error adecuado en frontend |


