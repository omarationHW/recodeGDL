# Documentación Técnica: Módulo de Descuentos Cementerios

## Arquitectura General
- **Backend**: Laravel Controller único (`DescuentosController`) con endpoint `/api/execute`.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación y formularios independientes.
- **Base de Datos**: PostgreSQL, lógica de negocio crítica en stored procedure `spd_13_abcdesctos`.
- **API**: Patrón eRequest/eResponse, todas las operaciones por `/api/execute`.

## Flujo de Operación
1. **El usuario ingresa un folio** y consulta los datos de la fosa y sus adeudos vigentes.
2. **Puede aplicar un descuento** seleccionando un adeudo y un tipo de descuento.
3. **Puede ver, borrar o reactivar descuentos** ya registrados.

## API: /api/execute
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "listar|consultar|alta|modifica|baja|reactivar|tipos|adeudos|registro", ...params } }`
- **Salida**: `{ "eResponse": { "ok": true|false, "message": "...", "data": ... } }`

### Acciones soportadas
- `listar`: Lista todos los descuentos activos.
- `consultar`: Consulta datos de una fosa por control_rcm.
- `alta`: Alta de descuento (llama SP).
- `modifica`: Modifica descuento (llama SP).
- `baja`: Baja de descuento (llama SP).
- `reactivar`: Reactiva descuento (llama SP).
- `tipos`: Lista tipos de descuento para un año.
- `adeudos`: Lista adeudos vigentes de una fosa.
- `registro`: Lista descuentos registrados de una fosa.

## Stored Procedure: spd_13_abcdesctos
- **Parámetros**:
  - v_control: integer (folio)
  - v_axo: integer (año)
  - v_porc: integer (porcentaje)
  - v_usu: integer (usuario)
  - v_reac: varchar(1) ('S'/'N')
  - v_tipo_descto: varchar(1)
  - v_opc: integer (1=alta, 2=baja, 3=modifica, 4=reactivar)
- **Retorna**: par_ok (0=ok, 1=error), par_observ (mensaje)

## Frontend Vue.js
- Página única, sin tabs.
- Permite buscar folio, ver adeudos, aplicar/borrar/reactivar descuentos.
- Navegación breadcrumb.
- Mensajes de error y éxito claros.

## Seguridad
- El usuario debe estar autenticado (simulado en el ejemplo con usuario=1).
- Validación de parámetros en backend y frontend.

## Consideraciones
- Todas las operaciones críticas (alta, baja, modifica, reactivar) pasan por el stored procedure para mantener la lógica centralizada y consistente.
- El frontend es reactivo y muestra mensajes claros según el resultado de la operación.

## Ejemplo de llamada API
```json
POST /api/execute
{
  "eRequest": {
    "action": "alta",
    "control_rcm": 1234,
    "axo": 2024,
    "porcentaje": 10,
    "usuario": 1,
    "reactivar": "N",
    "tipo_descto": "A"
  }
}
```

## Ejemplo de respuesta
```json
{
  "eResponse": {
    "ok": true,
    "message": "Descuento dado de alta correctamente",
    "data": null
  }
}
```
