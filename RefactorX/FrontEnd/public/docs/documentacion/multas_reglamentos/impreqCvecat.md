# Documentación: impreqCvecat

## Análisis Técnico

# Documentación Técnica: Migración Formulario impreqCvecat (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde a la migración del formulario de impresión y asignación de requerimientos de predial (impreqCvecat) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos). Toda la lógica de negocio y SQL se encapsula en stored procedures y funciones PostgreSQL. La comunicación entre frontend y backend se realiza mediante un endpoint único `/api/execute` usando el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel 10+, controlador `ImpreqCvecatController`.
- **Frontend:** Vue.js 3+, componente de página independiente `ImpreqCvecatPage.vue`.
- **Base de Datos:** PostgreSQL 13+, con stored procedures y funciones para lógica de negocio.
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros, y responde con `eResponse`.

## Flujo de Trabajo
1. El usuario ingresa los parámetros de búsqueda (recaudadora, rango de folios, fecha) y ejecuta la búsqueda.
2. El frontend envía la petición a `/api/execute` con `action: 'listar'` y los parámetros.
3. El backend ejecuta la función correspondiente y retorna los requerimientos encontrados.
4. El usuario puede seleccionar folios y ejecutar acciones de asignación, impresión o generación de reporte PDF.
5. Cada acción se traduce en una llamada a `/api/execute` con el `action` adecuado.

## Seguridad
- Todas las acciones requieren autenticación JWT (Laravel Sanctum/Passport recomendado).
- El usuario autenticado se pasa como parámetro en cada acción que lo requiera.
- Validaciones de entrada y permisos se realizan en el backend.

## Stored Procedures
Toda la lógica de asignación, impresión, cálculo de máximos y listados de ejecutores se implementa en funciones y procedimientos almacenados en PostgreSQL. Esto permite mantener la lógica cerca de los datos y facilita la migración de reglas de negocio.

## API eRequest/eResponse
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar",
      "params": { "recaud": 1, "folioini": 100, "foliofin": 200, "fecha": "2024-06-01" }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "data": [ ... ]
    }
  }
  ```

## Frontend
- Cada formulario es una página Vue.js independiente, sin tabs.
- El usuario puede navegar entre páginas usando rutas y breadcrumbs.
- El componente maneja loading, errores y muestra los resultados en tablas.
- Acciones como asignar, imprimir y generar reporte PDF se ejecutan sobre los folios seleccionados.

## Consideraciones de Migración
- Los procedimientos almacenados encapsulan toda la lógica de negocio que antes estaba en Delphi.
- El frontend es reactivo y desacoplado, solo consume la API.
- El endpoint único permite fácil integración y mantenimiento.

# Endpoints y Acciones
- `/api/execute` con `action: listar` → Listar requerimientos
- `/api/execute` con `action: filtrar` → Filtrar control de requerimientos
- `/api/execute` con `action: asignar` → Asignar requerimientos a ejecutor
- `/api/execute` con `action: imprimir` → Marcar requerimientos como impresos
- `/api/execute` con `action: ejecutores` → Listar ejecutores disponibles
- `/api/execute` con `action: max_impresiones` → Calcular máximo de impresiones
- `/api/execute` con `action: reporte` → Generar reporte PDF (dummy)

# Validaciones y Errores
- Todos los parámetros son validados en backend.
- Errores se retornan en `eResponse.error`.
- El frontend muestra los errores al usuario.

# Pruebas y Casos de Uso
Ver sección de casos de uso y casos de prueba.

## Casos de Uso

# Casos de Uso - impreqCvecat

**Categoría:** Form

## Caso de Uso 1: Asignar requerimientos a ejecutor

**Descripción:** El usuario busca requerimientos por rango de folios y asigna los seleccionados a un ejecutor.

**Precondiciones:**
El usuario está autenticado y tiene permisos de asignación.

**Pasos a seguir:**
1. El usuario ingresa recaudadora, folio inicial, folio final y fecha.
2. Presiona 'Buscar' y visualiza los requerimientos.
3. Selecciona varios folios.
4. Presiona 'Asignar', ingresa el número de ejecutor.
5. El sistema llama a /api/execute con action: 'asignar'.

**Resultado esperado:**
Los requerimientos seleccionados quedan asignados al ejecutor indicado y la tabla se actualiza.

**Datos de prueba:**
{ "recaud": 1, "folioini": 100, "foliofin": 110, "fecha": "2024-06-01", "ejecutor": 5, "usuario": "admin" }

---

## Caso de Uso 2: Imprimir requerimientos seleccionados

**Descripción:** El usuario marca varios folios y los marca como impresos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de impresión.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de requerimientos.
2. Selecciona varios folios.
3. Presiona 'Imprimir'.
4. El sistema llama a /api/execute con action: 'imprimir'.

**Resultado esperado:**
Los folios seleccionados quedan marcados como impresos.

**Datos de prueba:**
{ "recaud": 1, "folioini": 100, "foliofin": 105, "usuario": "admin" }

---

## Caso de Uso 3: Listar ejecutores disponibles

**Descripción:** El usuario consulta los ejecutores disponibles para una recaudadora y fecha.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario selecciona una recaudadora y fecha.
2. Presiona 'Listar ejecutores'.
3. El sistema llama a /api/execute con action: 'ejecutores'.

**Resultado esperado:**
Se muestra la lista de ejecutores disponibles.

**Datos de prueba:**
{ "recaud": 1, "fecha": "2024-06-01" }

---

## Casos de Prueba

# Casos de Prueba: impreqCvecat

## Caso 1: Búsqueda y asignación exitosa
- **Entrada:** recaud=1, folioini=100, foliofin=110, fecha=2024-06-01, ejecutor=5, usuario=admin
- **Acción:** listar → asignar
- **Esperado:** Los folios 100-110 quedan asignados al ejecutor 5

## Caso 2: Asignación con folios inexistentes
- **Entrada:** recaud=1, folioini=9999, foliofin=10010, fecha=2024-06-01, ejecutor=5, usuario=admin
- **Acción:** listar → asignar
- **Esperado:** Error: No existen folios en ese rango

## Caso 3: Impresión de folios
- **Entrada:** recaud=1, folioini=100, foliofin=105, usuario=admin
- **Acción:** imprimir
- **Esperado:** Los folios 100-105 quedan marcados como impresos

## Caso 4: Listar ejecutores
- **Entrada:** recaud=1, fecha=2024-06-01
- **Acción:** ejecutores
- **Esperado:** Lista de ejecutores disponibles

## Caso 5: Calcular máximo de impresiones
- **Entrada:** recaud=1
- **Acción:** max_impresiones
- **Esperado:** Devuelve el número máximo de impresiones posibles

## Caso 6: Generar reporte PDF
- **Entrada:** recaud=1, folioini=100, foliofin=110
- **Acción:** reporte
- **Esperado:** Devuelve URL de PDF generado

## Integración con Backend

> ⚠️ Pendiente de documentar

