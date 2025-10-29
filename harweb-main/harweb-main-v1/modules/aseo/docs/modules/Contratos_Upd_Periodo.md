# Documentación Técnica: Actualización de Periodo de Inicio de Obligación (Contratos)

## Descripción General
Este módulo permite consultar y actualizar el periodo de inicio de obligación de un contrato de recolección de residuos. Incluye:
- Consulta de contrato por número y tipo de aseo
- Visualización de datos relevantes del contrato
- Actualización del periodo de inicio de obligación (año y mes)
- Registro de documento y descripción justificativa en el histórico

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio
- **API:** Todas las operaciones se realizan vía POST a `/api/execute` con parámetros `action` y `params`

## Flujo de Trabajo
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El sistema consulta el contrato y muestra los datos.
3. El usuario ingresa el nuevo año, mes, documento y descripción.
4. El sistema valida y ejecuta la actualización vía stored procedure.
5. El resultado (éxito o error) se muestra al usuario.

## Seguridad
- El endpoint requiere autenticación (Laravel middleware `auth` recomendado).
- El usuario autenticado se utiliza para registrar el movimiento.
- Validaciones de parámetros en backend y frontend.

## Validaciones
- El documento es obligatorio y debe tener longitud mínima.
- El año y mes deben ser válidos.
- No se permite actualizar al mismo periodo actual.
- El contrato debe existir.

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Ejemplo para buscar contrato:**
  ```json
  {
    "action": "buscarContrato",
    "params": {
      "num_contrato": 1234,
      "ctrol_aseo": 8
    }
  }
  ```
- **Ejemplo para actualizar periodo:**
  ```json
  {
    "action": "actualizarPeriodoObligacion",
    "params": {
      "control_contrato": 5678,
      "anio": 2024,
      "mes": "03",
      "documento": "DR/14/2024",
      "descripcion": "Cambio por resolución administrativa"
    }
  }
  ```

## Stored Procedures
- **sp_contratos_buscar:** Devuelve todos los datos relevantes del contrato.
- **sp_contratos_actualizar_periodo_obligacion:** Realiza la actualización y registra en histórico.

## Manejo de Errores
- Todos los errores se devuelven en el campo `message` del JSON de respuesta.
- El campo `status` indica el código de resultado (0 = éxito, >0 = error).

## Consideraciones de Integración
- El frontend debe mostrar mensajes claros según el resultado de la operación.
- El backend debe registrar todos los movimientos en el histórico.
- El endpoint es extensible para otras acciones del sistema.
