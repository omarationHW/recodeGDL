# Documentación Técnica: Migración de Formulario Rep_AdeudCond (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite consultar y generar reportes de adeudos condonados por contrato y tipo de aseo. El flujo original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. Flujo de la Aplicación
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El usuario elige el criterio de ordenamiento (periodo de adeudo u operación).
3. Al hacer clic en "Vista Previa":
   - Se valida el número de contrato.
   - Se consulta el contrato y tipo de aseo.
   - Se verifica si existen adeudos condonados para ese contrato.
   - Si existen, se genera y muestra el reporte.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: Identificador de la operación (string)
  - `params`: Parámetros específicos de la operación (object)
- **Salida:**
  - `eResponse`: Objeto con `success`, `data`, `message`

### Ejemplo de Request
```json
{
  "eRequest": "get_reporte_adeudos_condonados",
  "params": {
    "control_contrato": 12345,
    "opcion": 1
  }
}
```

### Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
}
```

## 5. Stored Procedures
Toda la lógica SQL reside en funciones de PostgreSQL:
- `get_tipo_aseo_catalog()`: Catálogo de tipos de aseo.
- `get_contrato_by_numero_tipoaseo(num_contrato, ctrol_aseo)`: Consulta contrato.
- `get_adeudos_condonados_by_contrato(control_contrato)`: Adeudos condonados.
- `get_reporte_adeudos_condonados(control_contrato, opcion)`: Reporte principal.

## 6. Validaciones
- El número de contrato debe ser numérico y no vacío.
- Debe existir el contrato y el tipo de aseo seleccionado.
- Deben existir adeudos condonados para mostrar el reporte.

## 7. Seguridad
- Todas las operaciones usan parámetros preparados para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación según la política de la aplicación.

## 8. Extensibilidad
- Se pueden agregar nuevos eRequest fácilmente en el controlador Laravel y como nuevos stored procedures.
- El frontend está desacoplado y puede consumir cualquier operación definida en la API.

## 9. Manejo de Errores
- Los errores se devuelven en el campo `message` de `eResponse`.
- El frontend muestra mensajes claros al usuario.

## 10. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.
