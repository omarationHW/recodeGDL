# Documentación Técnica: Migración Formulario AdeudosExe_Del (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario "AdeudosExe_Del" permite realizar la baja física (eliminación) o baja lógica (marcar como baja) de registros de pagos de contratos para un periodo y tipo de operación específico. La migración implementa:
- Un endpoint API unificado `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros.
- Un controlador Laravel que enruta la acción y ejecuta la lógica correspondiente, usando transacciones.
- Stored Procedures en PostgreSQL para las operaciones críticas (baja física, baja lógica, consulta de contrato).
- Un componente Vue.js como página independiente, con formulario y resultado.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|delete|logic_delete",
      "contrato": int,
      "ctrol_aseo": int,
      "aso": int,
      "mes": int,
      "ctrol_operacion": int,
      "oficio": string, // solo para baja lógica
      "usuario_id": int
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 3. Controlador Laravel
- **AdeudosExeDelController**
  - Método `execute(Request $request)`
  - Rutea según `action` a:
    - `listContrato`: Consulta datos del contrato.
    - `deleteFisica`: Baja física (DELETE).
    - `deleteLogica`: Baja lógica (UPDATE status_vigencia = 'B').
  - Usa transacciones para operaciones críticas.
  - Valida parámetros obligatorios.

## 4. Stored Procedures PostgreSQL
- **sp_adeudos_exe_del_fisica**: Elimina físicamente el registro de pago.
- **sp_adeudos_exe_del_logica**: Realiza baja lógica (status_vigencia = 'B').
- **sp_adeudos_exe_del_list_contrato**: Consulta datos básicos del contrato.

## 5. Componente Vue.js
- Página independiente, sin tabs.
- Formulario con campos:
  - Contrato, Tipo de Aseo, Año, Mes, Tipo de Movimiento, Oficio, Opción de Movimiento (radio: física/lógica).
- Botón Ejecutar y Cancelar.
- Muestra resultado de la operación.
- Carga catálogos de tipos de aseo y operación vía API.

## 6. Seguridad y Validaciones
- Validación de campos obligatorios en frontend y backend.
- Uso de transacciones en operaciones críticas.
- El usuario debe estar autenticado y su ID debe enviarse en la petición.

## 7. Integración
- El endpoint `/api/execute` puede ser compartido por otros formularios, usando el campo `action` para distinguir la operación.
- Los catálogos (`tipos-aseo`, `tipos-operacion`) deben exponerse como endpoints REST o estar cacheados en frontend.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con la estructura de PostgreSQL.
- Los stored procedures deben ser idempotentes y seguros ante errores.
- El frontend debe manejar correctamente los mensajes de error y éxito.

## 9. Ejemplo de Petición para Baja Física
```json
{
  "eRequest": {
    "action": "delete",
    "contrato": 12345,
    "ctrol_aseo": 9,
    "aso": 2024,
    "mes": 6,
    "ctrol_operacion": 3,
    "usuario_id": 1
  }
}
```

## 10. Ejemplo de Petición para Baja Lógica
```json
{
  "eRequest": {
    "action": "logic_delete",
    "contrato": 12345,
    "ctrol_aseo": 9,
    "aso": 2024,
    "mes": 6,
    "ctrol_operacion": 3,
    "oficio": "OF123456",
    "usuario_id": 1
  }
}
```
