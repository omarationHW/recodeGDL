# Documentación Técnica: Módulo MultipleRCM (Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite la consulta múltiple de registros de R.C.M. (Registro de Cementerio Municipal) a partir de criterios de búsqueda jerárquicos (cementerio, clase, sección, línea, fosa, etc). La migración Delphi → Laravel + Vue.js + PostgreSQL se realizó manteniendo la lógica de paginación y búsqueda progresiva.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js de página completa, sin tabs.
- **Base de Datos:** PostgreSQL, lógica de búsqueda encapsulada en stored procedure.

## 3. API (Laravel Controller)
- **Ruta:** `/api/execute` (POST)
- **Parámetros:**
  - `action`: (string) Acción a ejecutar. Ej: `searchRCM`, `getCementerios`, `getRCMById`.
  - `params`: (object) Parámetros específicos de la acción.
- **Respuesta:**
  - `success`: boolean
  - `data`: array/objeto con los resultados
  - `message`: string de error si aplica

### Acciones soportadas
- `getCementerios`: Lista todos los cementerios.
- `searchRCM`: Busca registros de RCM según los parámetros de búsqueda.
- `getRCMById`: Devuelve el detalle de un registro por su folio/control_rcm.

## 4. Stored Procedure (PostgreSQL)
- **sp_multiple_rcm_search**: Implementa la lógica de búsqueda jerárquica y paginada (máximo 100 resultados por llamada).
- **Ventajas:**
  - Permite paginación eficiente (usando `control_rcm > :cuenta`)
  - Encapsula la lógica de comparación de campos alfabéticos y numéricos

## 5. Frontend (Vue.js)
- **Página independiente**: No usa tabs, es una ruta propia.
- **Formulario de búsqueda**: Permite ingresar todos los criterios.
- **Tabla de resultados**: Muestra hasta 100 resultados. Si hay más, permite continuar la búsqueda desde el último folio.
- **Detalle**: Modal para ver detalles de un registro.
- **Navegación**: Breadcrumb para contexto.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación JWT o session según la política del sistema.
- Validar y sanear todos los parámetros recibidos.

## 7. Consideraciones de Migración
- El stored procedure reemplaza la lógica Delphi de construcción dinámica de SQL.
- El frontend replica la experiencia de "continuar búsqueda" usando el campo `cuenta` (último folio).
- El endpoint es unificado para facilitar integración y pruebas.

## 8. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón `switch($action)`.
- El stored procedure puede extenderse para incluir más filtros si es necesario.

## 9. Pruebas
- Ver sección de casos de uso y casos de prueba para ejemplos prácticos.
