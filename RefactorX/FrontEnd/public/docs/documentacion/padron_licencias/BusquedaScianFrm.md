# Documentación Técnica: BusquedaScianFrm

## Análisis Técnico

# Documentación Técnica: Migración de BusquedaScianFrm a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de búsqueda de giros SCIAN, migrando el formulario Delphi `BusquedaScianFrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). Toda la lógica de consulta reside en un stored procedure, y la comunicación entre frontend y backend se realiza mediante un endpoint API unificado (`/api/execute`) usando el patrón `eRequest`/`eResponse`.

## 2. Arquitectura
- **Frontend**: Componente Vue.js de página completa, sin tabs, con tabla de resultados y campo de búsqueda.
- **Backend**: Controlador Laravel que recibe peticiones unificadas y ejecuta el stored procedure correspondiente.
- **Base de Datos**: Stored procedure en PostgreSQL que realiza la búsqueda filtrada.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request Body**:
  ```json
  {
    "eRequest": "catalog.scian.search",
    "params": {
      "descripcion": "texto a buscar"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "error": null
  }
  ```

## 4. Stored Procedure
- **Nombre**: `catalogo_scian_busqueda(p_descripcion TEXT)`
- **Funcionalidad**: Devuelve todos los registros vigentes de `c_scian` filtrando por descripción o código_scian (parcial, insensible a mayúsculas/minúsculas). Si el parámetro es vacío, devuelve todos los vigentes.

## 5. Controlador Laravel
- **Archivo**: `app/Http/Controllers/Api/ExecuteController.php`
- **Método principal**: `handle(Request $request)`
- **Lógica**:
  - Lee `eRequest` y `params`.
  - Ejecuta el stored procedure adecuado según el valor de `eRequest`.
  - Devuelve la respuesta en formato estándar.

## 6. Componente Vue.js
- **Archivo**: `BusquedaScianPage.vue`
- **Características**:
  - Página completa con breadcrumb.
  - Campo de búsqueda reactivo.
  - Tabla de resultados con selección.
  - Botón "Aceptar" habilitado solo si hay selección.
  - Manejo de errores y estados vacíos.

## 7. Seguridad y Validaciones
- El backend valida el valor de `eRequest`.
- El stored procedure previene SQL Injection usando parámetros.
- El frontend limita la longitud del campo de búsqueda.

## 8. Extensibilidad
- Se pueden agregar nuevos `eRequest` en el controlador para otras operaciones.
- El stored procedure puede ampliarse para más filtros si es necesario.

## 9. Consideraciones de Migración
- El campo `vigente` se filtra por 'V' (vigente).
- La búsqueda es insensible a mayúsculas/minúsculas y permite buscar por descripción o código.
- El formulario Delphi usaba un grid y un campo de texto; esto se replica en la UI Vue.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 10

---

## Casos de Prueba

# Casos de Prueba: BusquedaScianFrm Migrado

## Caso 1: Búsqueda por descripción parcial
- **Entrada**: descripcion = 'FARMACIA'
- **Acción**: Buscar
- **Resultado esperado**: Se muestran todos los registros vigentes donde la descripción contiene 'FARMACIA'.

## Caso 2: Búsqueda por código SCIAN
- **Entrada**: descripcion = '561110'
- **Acción**: Buscar
- **Resultado esperado**: Se muestra el registro con código_scian 561110 si está vigente.

## Caso 3: Búsqueda sin filtro
- **Entrada**: descripcion = ''
- **Acción**: Buscar
- **Resultado esperado**: Se muestran todos los registros vigentes de c_scian.

## Caso 4: Búsqueda sin resultados
- **Entrada**: descripcion = 'ZZZZZZZ'
- **Acción**: Buscar
- **Resultado esperado**: Se muestra mensaje 'No se encontraron resultados.'

## Caso 5: Selección y aceptación
- **Entrada**: Buscar 'RESTAURANTE', seleccionar un registro, presionar 'Aceptar'
- **Acción**: Seleccionar y aceptar
- **Resultado esperado**: Se emite evento o alerta con los datos del registro seleccionado.

## Caso 6: Error de backend
- **Simulación**: API responde con error
- **Resultado esperado**: Se muestra mensaje de error en la interfaz.

## Casos de Uso

# Casos de Uso - BusquedaScianFrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de giros por descripción parcial

**Descripción:** El usuario desea buscar todos los giros cuyo nombre contenga la palabra 'RESTAURANTE'.

**Precondiciones:**
La tabla c_scian contiene registros vigentes con descripciones variadas.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de giros.
2. Escribe 'RESTAURANTE' en el campo de descripción.
3. El sistema muestra todos los registros cuyo campo descripción contiene 'RESTAURANTE'.

**Resultado esperado:**
Se listan todos los giros vigentes que contienen 'RESTAURANTE' en la descripción.

**Datos de prueba:**
descripcion = 'RESTAURANTE'

---

## Caso de Uso 2: Búsqueda de giros por código SCIAN

**Descripción:** El usuario conoce el código SCIAN y desea buscarlo directamente.

**Precondiciones:**
La tabla c_scian contiene el código 722511.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de giros.
2. Escribe '722511' en el campo de descripción.
3. El sistema muestra el registro con código_scian 722511.

**Resultado esperado:**
Se muestra el giro con código_scian 722511.

**Datos de prueba:**
descripcion = '722511'

---

## Caso de Uso 3: Búsqueda sin filtro (todos los vigentes)

**Descripción:** El usuario desea ver todos los giros vigentes sin aplicar ningún filtro.

**Precondiciones:**
Existen registros vigentes en la tabla c_scian.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de giros.
2. Deja el campo de descripción vacío.
3. El sistema muestra todos los registros vigentes.

**Resultado esperado:**
Se listan todos los giros vigentes.

**Datos de prueba:**
descripcion = ''

---

