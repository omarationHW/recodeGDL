# Documentación Técnica - Migración Formulario Listados (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, componente de página independiente para Listados.
- **Base de Datos:** PostgreSQL 13+, toda la lógica SQL encapsulada en stored procedures.
- **Patrón de integración:** eRequest/eResponse (entrada/salida JSON).

## Flujo de Trabajo
1. **El usuario accede a la página Listados** (ruta `/listados`).
2. **Vue.js** carga catálogos (claves, vigencias, recaudadoras) usando `/api/execute` con acciones `getClaves`, `getVigencias`, `getRecaudadoras`.
3. El usuario selecciona filtros y ejecuta la búsqueda.
4. Vue.js envía un POST a `/api/execute` con acción `getListados` y los parámetros seleccionados.
5. **Laravel Controller** recibe la petición, valida parámetros, llama al stored procedure `sp_listados_get_listados`.
6. El resultado se regresa como JSON y se muestra en la tabla.
7. El usuario puede exportar a Excel (implementación futura).

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getListados",
      "params": {
        "id_rec": 1,
        "modulo": 11,
        "folio_desde": 100,
        "folio_hasta": 200,
        "clave": "P",
        "vigencia": "1",
        "fecha_prac_desde": "2024-01-01",
        "fecha_prac_hasta": "2024-06-30"
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## Stored Procedures
- Todos los catálogos y reportes se exponen como funciones PostgreSQL.
- El SP principal (`sp_listados_get_listados`) encapsula toda la lógica de filtros y joins.
- Los cálculos de campos (estado, imp_pagado, etc.) se realizan en el SP.

## Seguridad
- Validación de parámetros en el Controller.
- Solo se exponen los SP necesarios vía API.
- Se recomienda autenticación JWT para producción.

## Consideraciones de Migración
- Los combos y radios Delphi se migran a selects y radios Vue.js.
- El grid Delphi se migra a tabla HTML.
- La exportación a Excel se recomienda implementar vía backend (Laravel Excel) o frontend (xlsx.js).
- El endpoint es agnóstico de la UI, puede ser consumido por cualquier cliente.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón.
- Los SP pueden evolucionar sin afectar la API si mantienen la firma.

