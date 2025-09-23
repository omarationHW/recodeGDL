# Documentación Técnica: ActualizaPlazo (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite importar, previsualizar y actualizar masivamente los contratos con ampliación de plazo (tabla `ta_17_amp_plazo`). El proceso consiste en cargar un archivo plano/tabulado, mostrar los datos en una grilla, y ejecutar la actualización en base de datos usando stored procedures PostgreSQL. Toda la lógica de negocio se expone vía un endpoint API unificado `/api/execute` bajo el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel Controller (`ActualizaPlazoController`) con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con carga de archivo, previsualización y ejecución.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **Comunicación:** JSON (eRequest/eResponse).

## Flujo de Trabajo
1. **Carga de Archivo:** El usuario selecciona un archivo plano (txt/csv) con los datos tabulados por `|`.
2. **Previsualización:** El frontend parsea el archivo y muestra los datos en una tabla.
3. **Ejecución:** Al confirmar, el frontend envía los datos al backend, que procesa cada fila:
   - Llama al SP `spd_17_calc_fechav` para calcular la fecha de vencimiento.
   - Inserta el registro en `ta_17_amp_plazo` usando el SP `sp_actualiza_plazo`.
4. **Respuesta:** El backend retorna el resultado global y los errores por fila (si los hay).

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "actualizarPlazo",
    "payload": {
      "user_id": 1,
      "rows": [[...], [...], ...]
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "message": "Actualización completada",
    "data": { "errores": [] }
  }
  ```

## Stored Procedures
- **spd_17_calc_fechav:** Calcula la fecha de vencimiento según tipo de pago y parcialidades.
- **sp_actualiza_plazo:** Inserta el registro de ampliación de plazo.

## Validaciones
- El archivo debe tener al menos 19 columnas por fila.
- Se valida la existencia del convenio antes de insertar.
- Se reportan errores por fila en la respuesta.

## Seguridad
- El endpoint requiere autenticación (simulado en ejemplo, debe integrarse con Auth real).
- El usuario que ejecuta la acción se registra en cada inserción.

## Extensibilidad
- El endpoint `/api/execute` puede recibir otras acciones (importFile, previewGrid, etc).
- El frontend puede ser extendido para otros formularios siguiendo el mismo patrón.

## Pruebas
- Incluye casos de uso y escenarios de prueba para validar la funcionalidad.
