# Documentación Técnica: RptAdeudosConvDiversosSaldoAnt

## Descripción General
Este módulo permite generar un reporte de convenios diversos mostrando el saldo anterior y los pagos realizados en un rango de fechas, agrupando por zona y estado del convenio. La migración Delphi → Laravel + Vue.js + PostgreSQL se realiza usando un endpoint API unificado y stored procedures para la lógica de negocio.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures
- **Comunicación:** JSON (REST), validación de parámetros en backend

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getReport",
      "params": {
        "tipo": 3,
        "subtipo": 1,
        "letras": "ZO3",
        "estado": "A",
        "fechadsd": "2024-01-01",
        "fechahst": "2024-06-30"
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success",
      "data": [ ... ],
      "message": "Reporte generado correctamente"
    }
  }
  ```

## Stored Procedures
- Toda la lógica SQL se encapsula en stored procedures PostgreSQL:
  - `sp_rpt_adeudos_conv_diversos_saldo_ant`: Obtiene el reporte principal
  - `sp_rpt_adeudos_conv_diversos_saldo_ant_saldo_anterior`: Obtiene el saldo anterior de un convenio

## Validaciones
- Todos los parámetros son validados en el backend antes de ejecutar el SP
- Errores de validación o ejecución se devuelven en el campo `message` de la respuesta

## Frontend
- Página Vue.js independiente
- Formulario de filtros (tipo, subtipo, letras, estado, fechas)
- Tabla de resultados con exportación a CSV
- Mensajes de carga y error

## Seguridad
- El endpoint debe estar protegido por autenticación (ej. JWT, Laravel Sanctum)
- Validar que el usuario tenga permisos para consultar el reporte

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar la ruta
- Los stored procedures pueden evolucionar sin afectar la API

## Ejemplo de Uso
1. El usuario ingresa los filtros y presiona "Generar Reporte"
2. El frontend envía la petición a `/api/execute` con la acción `getReport`
3. El backend valida, ejecuta el SP y retorna los datos
4. El frontend muestra la tabla y permite exportar a CSV

# Parámetros de Entrada
- `tipo`: integer (obligatorio)
- `subtipo`: integer (obligatorio)
- `letras`: string (obligatorio, zona)
- `estado`: string (A/B/P)
- `fechadsd`: date (obligatorio)
- `fechahst`: date (obligatorio)

# Parámetros de Salida
- Listado de convenios con campos: convenio, nombre, domicilio, ext., saldo anterior, pagos, saldo actual

# Errores Comunes
- Parámetros inválidos: status error, message descriptivo
- Error de ejecución SQL: status error, message descriptivo

# Pruebas y Casos de Uso
Ver secciones correspondientes.
