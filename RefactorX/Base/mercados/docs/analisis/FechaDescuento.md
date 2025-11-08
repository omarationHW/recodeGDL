# Documentación Técnica: Módulo FechaDescuento

## Descripción General
El módulo FechaDescuento permite la consulta y modificación de las fechas de vencimiento para descuentos y recargos mensuales en el sistema de mercados municipales. Está compuesto por:

- **Backend**: Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: Stored Procedures en PostgreSQL para listar, consultar y actualizar fechas de descuento.

## Arquitectura

### API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: JSON con estructura `{ eRequest: { action: 'list|get|update', params: {...} } }`
- **Salida**: JSON `{ eResponse: { success, data, message } }`

### Stored Procedures
- `sp_fechadescuento_list()`: Devuelve todas las fechas de descuento.
- `sp_fechadescuento_get(p_mes)`: Devuelve la fecha de descuento de un mes específico.
- `sp_fechadescuento_update(p_mes, p_fecha_descuento, p_fecha_recargos, p_id_usuario)`: Actualiza las fechas para un mes.

### Seguridad
- El endpoint requiere autenticación (no implementada aquí, pero debe integrarse con middleware de Laravel).
- El usuario que realiza la actualización debe ser registrado en la tabla.

### Validaciones
- El mes debe estar entre 1 y 12.
- Las fechas deben ser válidas y coherentes.
- Solo se permite modificar meses existentes.

## Flujo de Datos
1. **Consulta**: El frontend solicita la lista de fechas (`action: 'list'`).
2. **Selección**: El usuario selecciona un mes y abre el modal de edición.
3. **Edición**: El usuario modifica las fechas y confirma.
4. **Actualización**: El frontend envía `action: 'update'` con los datos. El backend llama el stored procedure y retorna el resultado.
5. **Refresco**: El frontend recarga la lista.

## Integración Vue.js
- El componente consume el endpoint `/api/execute` para todas las operaciones.
- El usuario actual se obtiene de la variable global `window.AppUser` (debe integrarse con el sistema de autenticación real).
- El modal de edición permite modificar solo las fechas y muestra el usuario actual.

## Integración Laravel
- El controlador mapea las acciones a los stored procedures.
- Todas las respuestas siguen el patrón eResponse.
- Validaciones de entrada se realizan antes de llamar a los SP.

## Integración PostgreSQL
- Los stored procedures encapsulan la lógica de negocio y validación a nivel de base de datos.
- Todas las operaciones de modificación actualizan la columna `fecha_alta` y el usuario.

## Consideraciones
- El sistema es multiusuario y audita el usuario que realiza los cambios.
- El frontend es reactivo y muestra mensajes de error en caso de problemas.

# Esquema de Base de Datos (relevante)

```sql
CREATE TABLE ta_11_fecha_desc (
    mes smallint PRIMARY KEY,
    fecha_descuento date NOT NULL,
    fecha_alta timestamp NOT NULL DEFAULT now(),
    id_usuario integer NOT NULL,
    fecha_recargos date NOT NULL
);

CREATE TABLE ta_12_passwords (
    id_usuario integer PRIMARY KEY,
    usuario varchar(50) NOT NULL
);
```

# Ejemplo de eRequest/eResponse

**Request**:
```json
{
  "eRequest": {
    "action": "update",
    "params": {
      "mes": 5,
      "fecha_descuento": "2024-05-15",
      "fecha_recargos": "2024-05-25",
      "id_usuario": 3
    }
  }
}
```

**Response**:
```json
{
  "eResponse": {
    "success": true,
    "data": [{"success": true, "message": "Actualización exitosa"}],
    "message": ""
  }
}
```
