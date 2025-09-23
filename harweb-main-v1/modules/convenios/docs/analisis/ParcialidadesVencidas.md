# Parcialidades Vencidas - Migración Delphi a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite consultar y exportar la lista de convenios con parcialidades vencidas, mostrando información relevante como nombre, domicilio, subtipo, fechas, adeudo, intereses, recargos y total. La migración incluye:
- Backend en Laravel (API RESTful, endpoint unificado)
- Frontend en Vue.js (componente de página independiente)
- Lógica de negocio en stored procedure PostgreSQL
- API unificada con patrón eRequest/eResponse

## Arquitectura
- **Backend:** Laravel Controller (`ParcialidadesVencidasController`) con endpoint `/api/execute`.
- **Frontend:** Componente Vue.js (`ParcialidadesVencidasPage.vue`) que consume la API y muestra la tabla de resultados.
- **Base de Datos:** Stored Procedure `spd_17_parcvencida` en PostgreSQL.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getVencidas",
      "params": {}
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success",
      "data": [ ... ],
      "message": "Datos obtenidos correctamente"
    }
  }
  ```

## Stored Procedure
- **Nombre:** `spd_17_parcvencida`
- **Tipo:** REPORT
- **Descripción:** Devuelve la lista de convenios con parcialidades vencidas, incluyendo adeudo, intereses, recargos y total.
- **Parámetros:** Ninguno
- **Retorno:** Tabla con los campos requeridos para la vista.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Botón Buscar para recargar datos.
- Botón Exportar Excel (descarga CSV).
- Tabla con todos los campos relevantes.
- Mensajes de carga y error.

## Backend (Laravel)
- Controlador con método `execute` que recibe eRequest y retorna eResponse.
- Llama al stored procedure y retorna los datos.
- Manejo de errores y logging.

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar permisos de usuario antes de exponer datos sensibles.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas.
- El stored procedure puede ser modificado para incluir más filtros si es necesario.

## Pruebas
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad.

