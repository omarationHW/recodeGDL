# Documentación Técnica: Migración Formulario loctp (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario de localización de datos registrales de avisos presentados para su trámite (loctp). Permite buscar escrituras por notaría, municipio y número de escrituras, mostrando los actos asociados y permitiendo la edición de observaciones.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros. Todas las operaciones se canalizan a stored procedures en PostgreSQL.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y edición inline.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "search|municipios|detalle|update_observacion|clear",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

## 4. Stored Procedures
- `sp_loctp_search`: Busca escrituras por notaría, municipio y número de escrituras.
- `sp_loctp_municipios`: Devuelve el catálogo de municipios.
- `sp_loctp_detalle`: Devuelve detalle de la cuenta cvecuenta.
- `sp_loctp_update_observacion`: Actualiza el campo de observaciones de un acto.

## 5. Controlador Laravel
- Recibe la acción y parámetros.
- Llama al stored procedure correspondiente usando DB::select o DB::update.
- Devuelve la respuesta en formato `eResponse`.
- Valida parámetros obligatorios y errores.

## 6. Componente Vue.js
- Página completa, sin tabs.
- Formulario de búsqueda con validación.
- Tabla de resultados editable (observaciones).
- Mensajes de error y éxito.
- Navegación y limpieza de campos.

## 7. Seguridad
- Validación de parámetros obligatorios en backend y frontend.
- No expone SQL directo, todo va por stored procedures.
- No permite acciones no soportadas.

## 8. Extensibilidad
- Se pueden agregar nuevas acciones en el endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden ampliarse para lógica adicional.

## 9. Pruebas
- Casos de uso y pruebas detalladas en las secciones siguientes.

---
