# Documentación Técnica: Descuentos en Recargos Aseo Contratado (drecgoAseo)

## Descripción General
Este módulo permite la gestión de descuentos en recargos para contratos de aseo contratado. Incluye:
- Consulta de contratos de aseo
- Alta y cancelación de descuentos por periodo y porcentaje
- Consulta de descuentos vigentes
- Validación de permisos de usuario y topes de autorización

## Arquitectura
- **Backend**: Laravel Controller (DrecgoAseoController) con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Componente Vue.js de página completa, sin tabs
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures
- **API**: Todas las operaciones se realizan vía POST a `/api/execute` con parámetros `action` y `params`

## Flujo de Operación
1. El usuario selecciona el tipo de aseo y número de contrato.
2. El sistema consulta el contrato y muestra los datos.
3. Se listan los descuentos vigentes para ese contrato.
4. El usuario puede dar de alta un nuevo descuento, indicando periodo, porcentaje y funcionario autorizante.
5. El sistema valida el tope de porcentaje según el funcionario.
6. El usuario puede cancelar descuentos vigentes.

## Seguridad y Permisos
- Solo usuarios con permisos (num_tag=1319) pueden ver todos los funcionarios autorizantes.
- El tope de porcentaje permitido depende del funcionario seleccionado.
- Todas las acciones quedan registradas con usuario y fecha.

## API: eRequest/eResponse
- Endpoint: `/api/execute`
- Método: POST
- Body:
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- Acciones soportadas:
  - `searchContrato`: Busca contrato de aseo
  - `getDescuentos`: Lista descuentos vigentes para contrato
  - `altaDescuento`: Alta de descuento
  - `cancelarDescuento`: Cancela descuento
  - `getTiposAseo`: Lista tipos de aseo
  - `getFuncionarios`: Lista funcionarios autorizantes

## Validaciones
- El porcentaje no puede exceder el tope del funcionario.
- No se pueden duplicar descuentos para el mismo periodo y contrato.
- Solo se pueden cancelar descuentos vigentes.

## Estructura de la Base de Datos
- `v_contrato`: Vista de contratos de aseo
- `v_descrecaseo`: Vista de descuentos de recargos de aseo
- `t34_descrecaseo`: Tabla de descuentos de recargos de aseo
- `c_autdescrec`: Catálogo de funcionarios autorizantes
- `v_tipo_aseo`: Catálogo de tipos de aseo

## Stored Procedure Principal
- `ins_recaraseo`: Inserta o cancela descuentos de recargos de aseo

## Frontend
- Página Vue.js independiente
- Navegación por rutas, sin tabs
- Formulario de alta y listado de descuentos
- Validación de campos y mensajes de error

## Backend
- Controlador Laravel con endpoint único
- Métodos para cada acción de negocio
- Uso de stored procedures para lógica de negocio

## Ejemplo de Request
```json
{
  "action": "altaDescuento",
  "params": {
    "id_contrato": 123,
    "axo_ini": 2024,
    "mes_ini": 1,
    "axo_fin": 2024,
    "mes_fin": 6,
    "porc": 25,
    "funcionario_id": 5
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "control": 456
}
```
