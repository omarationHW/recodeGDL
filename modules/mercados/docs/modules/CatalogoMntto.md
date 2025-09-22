# Documentación Técnica: Migración Formulario CatalogoMntto (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (JSON)

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

## Controlador Laravel
- Un solo controlador (`CatalogoMnttoController`) maneja todas las acciones relacionadas con el catálogo de mercados.
- Cada acción del frontend se traduce en un `action` y se ejecuta el stored procedure correspondiente.
- Validación de parámetros con `Validator`.
- Manejo de errores y mensajes amigables.

## Stored Procedures PostgreSQL
- Toda la lógica de inserción, actualización y consulta está en stored procedures.
- Los procedimientos devuelven siempre un resultado estructurado (éxito, mensaje, datos).
- Se usan transacciones y manejo de errores SQL.

## Componente Vue.js
- Página independiente (`CatalogoMnttoPage.vue`):
  - Formulario de alta/edición de mercados.
  - Listado de mercados con opción de editar.
  - Navegación breadcrumb.
  - Validación de campos en frontend y backend.
  - Mensajes de éxito/error.
- El formulario es reactivo y cambia entre modo alta/edición.
- El listado se actualiza automáticamente tras cada operación.

## Seguridad
- Todas las operaciones pasan por validación de datos.
- El backend valida que no existan claves duplicadas.
- Los stored procedures previenen SQL injection y errores de lógica.

## Flujo de Datos
1. El usuario accede a la página de Catálogo de Mercados.
2. El frontend carga listas de recaudadoras, categorías, zonas y cuentas vía API.
3. El usuario llena el formulario y envía (alta o edición).
4. El frontend envía la petición a `/api/execute` con la acción y los parámetros.
5. El backend ejecuta el stored procedure correspondiente y devuelve el resultado.
6. El frontend muestra el mensaje y actualiza la lista.

## Integración
- El endpoint `/api/execute` puede ser usado por cualquier frontend compatible.
- Los stored procedures pueden ser reutilizados por otros sistemas.

## Extensibilidad
- Para agregar nuevos formularios, basta con crear nuevos stored procedures y acciones en el controlador y frontend.

# Esquema de Base de Datos (relevante)
- **ta_11_mercados**: Catálogo de mercados
- **ta_12_recaudadoras**: Catálogo de recaudadoras
- **ta_11_categoria**: Catálogo de categorías
- **ta_12_zonas**: Catálogo de zonas
- **ta_12_cuentas**: Catálogo de cuentas de ingreso

# Validaciones
- No se permite insertar mercados duplicados (clave compuesta oficina + num_mercado_nvo).
- Todos los campos requeridos deben estar presentes.
- Si el mercado no cobra energía, la cuenta de energía debe ser NULL.

# Errores Comunes
- Si se intenta insertar un mercado existente, se devuelve un mensaje de error.
- Si falta algún campo requerido, el backend lo reporta.

# Pruebas
- Se recomienda probar inserción, edición, y validación de duplicados y campos requeridos.

# Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar en producción.
