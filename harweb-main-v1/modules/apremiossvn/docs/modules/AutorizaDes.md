# Documentación Técnica - Migración Formulario AutorizaDes (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend:** Vue.js SPA, cada formulario es una página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica de negocio SQL se implementa en stored procedures (SPs).

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "search|alta|modificar|baja|catalogo_quien|catalogo_aplicacion|catalogo_oficina",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "result": [ ... ],
      "error": "mensaje de error o null"
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica de inserción, actualización, baja y consulta de descuentos autorizados se implementa en SPs.
- Los SPs devuelven tablas o mensajes de éxito/error.
- Los catálogos (quién autoriza, oficinas, aplicaciones) también se exponen como SPs.

## 4. Controlador Laravel
- Un solo método `execute` que despacha según el campo `action`.
- Cada acción llama al SP correspondiente usando DB::select.
- Maneja errores y los retorna en el campo `error`.

## 5. Componente Vue.js
- Página independiente para descuentos autorizados.
- Permite buscar folio, visualizar datos, alta, modificación y baja de descuentos.
- Usa selectores para catálogos (oficina, aplicación, quién autoriza).
- Valida el porcentaje máximo permitido según el autorizador.
- Muestra mensajes de éxito/error.

## 6. Seguridad
- El usuario autenticado debe ser validado en el backend (no incluido aquí, pero debe integrarse con Auth de Laravel).
- Los SPs validan los permisos para mostrar el catálogo de quién autoriza.

## 7. Consideraciones de Migración
- Los nombres de tablas y campos se adaptan a PostgreSQL.
- Los SPs encapsulan la lógica de transacciones y validaciones.
- El frontend no usa tabs ni componentes tabulares, cada formulario es una página.
- El endpoint es único y flexible para futuras extensiones.

## 8. Extensibilidad
- Se pueden agregar nuevas acciones en el controlador y SPs sin modificar la estructura general.
- El frontend puede consumir nuevos catálogos o reportes usando el mismo patrón.

## 9. Pruebas
- Los casos de uso y pruebas cubren búsqueda, alta, modificación, baja y validaciones de reglas de negocio.

## 10. Despliegue
- Los SPs deben crearse en la base de datos PostgreSQL destino.
- El controlador debe estar registrado en las rutas de Laravel.
- El componente Vue debe estar registrado en el router de la SPA.

