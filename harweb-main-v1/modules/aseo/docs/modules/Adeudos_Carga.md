# Documentación Técnica: Carga de Adeudos (Adeudos_Carga)

## Descripción General
El proceso "Carga de Adeudos" permite generar automáticamente los registros de adeudos (pagos) para todos los contratos vigentes y no vigentes de un ejercicio fiscal determinado. Se utiliza para inicializar o regenerar los adeudos de un año completo, insertando un registro mensual por contrato en la tabla `ta_16_pagos`.

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL (Stored Procedure)
- **Patrón API:** eRequest/eResponse

## Flujo de Proceso
1. El usuario accede a la página de "Carga de Adeudos".
2. Ingresa el ejercicio fiscal y su ID de usuario.
3. Al enviar el formulario, el frontend realiza una petición POST a `/api/execute` con el payload eRequest.
4. El backend valida los datos y ejecuta el stored procedure `sp_carga_adeudos_contratos_vigentes` en PostgreSQL.
5. El stored procedure recorre todos los contratos vigentes/no vigentes y genera los pagos mensuales para el ejercicio.
6. El backend retorna el resultado en eResponse.

## Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "carga_adeudos",
      "ejercicio": 2024,
      "usuario_id": 23
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "Carga de adeudos ejecutada correctamente",
      "result": []
    }
  }
  ```

## Validaciones
- El ejercicio debe ser un año válido (>= 2000).
- El usuario debe estar autenticado y tener permisos para ejecutar el proceso.
- El stored procedure ignora pagos ya existentes para evitar duplicados.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- El usuario_id debe corresponder al usuario autenticado.

## Manejo de Errores
- Si falta algún parámetro, retorna 422 con detalles.
- Si ocurre un error en la base de datos, retorna 500 con el mensaje de error.
- Si la acción no es reconocida, retorna 400.

## Detalles del Stored Procedure
- Recorre todos los contratos con status 'V' (vigente) o 'N' (no vigente).
- Para cada contrato, obtiene la unidad de recolección y el costo correspondiente al ejercicio.
- Inserta 12 registros (uno por mes) en `ta_16_pagos` para cada contrato.
- Si ya existe un pago para ese periodo y contrato, lo ignora (manejo de unique_violation).

## Consideraciones
- El proceso puede ser pesado si hay muchos contratos; se recomienda ejecutarlo fuera de horario laboral o en modo batch.
- Se recomienda auditar los resultados y revisar los logs de errores.

## Extensibilidad
- El endpoint y el stored procedure pueden ser reutilizados para otros procesos de carga masiva.
- El frontend puede ser adaptado para otros procesos similares cambiando el action.
