# Documentación Técnica: sQRptTipos_Aseo

## Análisis

# Documentación Técnica: Migración de Formulario sQRptTipos_Aseo

## 1. Descripción General
Este módulo implementa la migración del formulario Delphi `sQRptTipos_Aseo` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). El objetivo es ofrecer una página de reporte/catalogación de los tipos de aseo, permitiendo la clasificación dinámica por diferentes campos.

## 2. Arquitectura
- **Backend:** Laravel 10+, PostgreSQL
- **Frontend:** Vue.js 3+
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** Procedimientos almacenados para lógica de negocio

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "get_tipos_aseo_report",
    "params": { "opcion": 1 }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```
- **Parámetro `opcion`:**
  - 1: Clasificar por Número de Control (`ctrol_aseo`)
  - 2: Clasificar por Tipo (`tipo_aseo`)
  - 3: Clasificar por Descripción (`descripcion`)

## 4. Stored Procedure
- **Nombre:** `sp_ta_16_tipo_aseo_report`
- **Parámetro:** `opcion integer`
- **Retorna:** Tabla con columnas `ctrol_aseo`, `tipo_aseo`, `descripcion` ordenada según la opción.

## 5. Frontend
- **Ruta:** `/tipos-aseo` (ejemplo)
- **Funcionalidad:**
  - Selector de clasificación
  - Tabla de resultados
  - Breadcrumb de navegación
  - Fecha/hora de impresión

## 6. Seguridad
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## 7. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas operaciones fácilmente usando el patrón eRequest.

## 8. Consideraciones
- El procedimiento almacenado está optimizado para ordenamiento dinámico.
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js.

## 9. Dependencias
- Laravel 10+, PHP 8+
- PostgreSQL 12+
- Vue.js 3+
- Axios (para llamadas HTTP)

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba.


## Casos de Uso

# Casos de Uso - sQRptTipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de tipos de aseo ordenado por Número de Control

**Descripción:** El usuario accede a la página de Tipos de Aseo y visualiza el catálogo ordenado por el campo 'Número de Control'.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla ta_16_tipo_aseo.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Tipos de Aseo'.
2. Elige 'Número de Control' en el selector de clasificación.
3. El sistema consulta el API con opcion=1.
4. El sistema muestra la tabla ordenada por 'ctrol_aseo'.

**Resultado esperado:**
La tabla muestra todos los registros de tipos de aseo ordenados ascendentemente por el campo 'ctrol_aseo'.

**Datos de prueba:**
ta_16_tipo_aseo: [{ctrol_aseo: '001', tipo_aseo: 'A', descripcion: 'Barrido'}, {ctrol_aseo: '002', tipo_aseo: 'B', descripcion: 'Recolección'}]

---

## Caso de Uso 2: Visualizar catálogo de tipos de aseo ordenado por Tipo

**Descripción:** El usuario selecciona la opción de clasificación por 'Tipo' y visualiza el catálogo ordenado por ese campo.

**Precondiciones:**
El usuario está en la página de Tipos de Aseo.

**Pasos a seguir:**
1. El usuario selecciona 'Tipo' en el selector de clasificación.
2. El sistema consulta el API con opcion=2.
3. El sistema muestra la tabla ordenada por 'tipo_aseo'.

**Resultado esperado:**
La tabla muestra los registros ordenados ascendentemente por el campo 'tipo_aseo'.

**Datos de prueba:**
ta_16_tipo_aseo: [{ctrol_aseo: '002', tipo_aseo: 'B', descripcion: 'Recolección'}, {ctrol_aseo: '001', tipo_aseo: 'A', descripcion: 'Barrido'}]

---

## Caso de Uso 3: Visualizar catálogo de tipos de aseo ordenado por Descripción

**Descripción:** El usuario selecciona la opción de clasificación por 'Descripción' y visualiza el catálogo ordenado por ese campo.

**Precondiciones:**
El usuario está en la página de Tipos de Aseo.

**Pasos a seguir:**
1. El usuario selecciona 'Descripción' en el selector de clasificación.
2. El sistema consulta el API con opcion=3.
3. El sistema muestra la tabla ordenada por 'descripcion'.

**Resultado esperado:**
La tabla muestra los registros ordenados ascendentemente por el campo 'descripcion'.

**Datos de prueba:**
ta_16_tipo_aseo: [{ctrol_aseo: '001', tipo_aseo: 'A', descripcion: 'Barrido'}, {ctrol_aseo: '002', tipo_aseo: 'B', descripcion: 'Recolección'}]

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Tipos de Aseo

## Caso 1: Consulta por Número de Control
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 1 }
- **Acción:** POST a /api/execute
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data ordenado por ctrol_aseo ascendente

## Caso 2: Consulta por Tipo
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 2 }
- **Acción:** POST a /api/execute
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data ordenado por tipo_aseo ascendente

## Caso 3: Consulta por Descripción
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 3 }
- **Acción:** POST a /api/execute
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data ordenado por descripcion ascendente

## Caso 4: Sin registros en la tabla
- **Precondición:** ta_16_tipo_aseo está vacía
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 1 }
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data = []

## Caso 5: Parámetro inválido
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 99 }
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data = [] (o sin error, pero sin resultados)

## Caso 6: eRequest no soportado
- **Entrada:**
  - eRequest: "no_existente"
- **Resultado esperado:**
  - eResponse.success = false
  - eResponse.message = "eRequest not supported."


