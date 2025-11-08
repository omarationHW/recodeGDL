# Documentación Técnica: Migración Formulario Titulos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 14+ (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (payload JSON con acción y datos)

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "search|update|print|view|validate|extra",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

## Controlador Laravel
- Un solo controlador (`TitulosController`) maneja todas las acciones.
- Cada acción llama a un stored procedure PostgreSQL.
- Validación de datos con Laravel Validator.
- Manejo de errores y respuestas unificadas.

## Stored Procedures PostgreSQL
- Toda la lógica de negocio y consultas SQL se encapsula en funciones/stored procedures.
- Cada SP corresponde a una acción de negocio: búsqueda, actualización, impresión, validación, vista previa, datos extendidos.
- Los SP devuelven tablas (TABLE) o registros (JSONB) según el caso.

## Componente Vue.js
- Página independiente para el formulario de Títulos.
- Formulario reactivo para búsqueda, edición y actualización de beneficiario.
- Botones para buscar, actualizar, imprimir y limpiar.
- Vista previa de impresión (muestra datos JSON, puede integrarse con PDF/plantilla en el futuro).
- Mensajes de error y éxito.

## Seguridad
- Validación de datos en backend y frontend.
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel, no incluido aquí).

## Consideraciones de Migración
- Los nombres de campos y lógica se adaptan a la estructura PostgreSQL.
- Los reportes Delphi se migran como datos JSON para impresión; la generación de PDF/plantilla queda como extensión futura.
- El flujo de actualización y validación sigue la lógica del formulario original.

## Extensibilidad
- Se pueden agregar nuevas acciones en el controlador y SPs sin romper la API.
- El frontend puede consumir cualquier acción definida en el backend.

## Ejemplo de Flujo
1. El usuario ingresa fecha, folio y operación y presiona "Buscar".
2. El frontend llama a `/api/execute` con acción `search`.
3. El backend ejecuta `sp_titulos_search` y devuelve los datos.
4. El usuario edita los datos de beneficiario y presiona "Actualizar".
5. El frontend llama a `/api/execute` con acción `update`.
6. El backend ejecuta `sp_titulos_update` y responde con el estado.
7. El usuario puede presionar "Imprimir" para obtener los datos de impresión.

# Estructura de Base de Datos (Resumen)
- **ta_13_titulos**: Tabla principal de títulos.
- **v_titulos_cem**: Vista extendida para impresión avanzada.

# Notas
- Los nombres de campos pueden variar según la migración real; ajustar los SPs según el modelo final.
- Para impresión real, se recomienda integrar una librería de generación de PDF en backend o frontend.
