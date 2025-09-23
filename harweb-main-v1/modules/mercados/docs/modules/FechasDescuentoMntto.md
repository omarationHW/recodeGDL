# Documentación Técnica: Mantenimiento a Fechas de Descuento

## Descripción General
Este módulo permite la consulta y actualización de las fechas de descuento y recargos para cada mes del año, utilizadas en el cálculo de vencimientos y descuentos en el sistema de mercados municipales. El mantenimiento se realiza sobre la tabla `ta_11_fecha_desc`.

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  - `action`: string (ej: 'getAll', 'getByMes', 'update')
  - `data`: objeto con los parámetros necesarios

### Ejemplo de Request para actualizar:
```json
{
  "action": "update",
  "data": {
    "mes": 5,
    "fecha_descuento": "2024-05-15",
    "fecha_recargos": "2024-05-23",
    "id_usuario": 2
  }
}
```

### Ejemplo de Response:
```json
{
  "success": true,
  "message": "Actualización exitosa",
  "data": null
}
```

## Stored Procedures
- `fechas_descuento_get_all()`: Devuelve todas las fechas de descuento y recargos.
- `fechas_descuento_get_by_mes(p_mes)`: Devuelve la fecha de descuento y recargos para un mes.
- `fechas_descuento_update(p_mes, p_fecha_descuento, p_fecha_recargos, p_id_usuario)`: Actualiza las fechas para un mes, validando que correspondan al mes indicado.

## Validaciones
- El mes de las fechas de descuento y recargos debe coincidir con el mes seleccionado.
- Solo usuarios autenticados pueden modificar (el id_usuario debe ser válido).

## Seguridad
- El endpoint debe estar protegido por autenticación JWT o sesión.
- Los stored procedures validan la lógica de negocio y devuelven mensajes claros.

## Frontend
- Página Vue.js con tabla de meses y fechas.
- Edición inline mediante formulario modal o expandible.
- Validación de fechas en el cliente y servidor.
- Mensajes de error amigables.

## Navegación
- Breadcrumb para volver a inicio.
- Cada formulario es una página independiente.

## Integración
- El frontend llama a `/api/execute` con la acción correspondiente.
- El backend enruta la acción al stored procedure adecuado y retorna eResponse.

## Auditoría
- El campo `fecha_alta` y `id_usuario` se actualizan en cada modificación.

# Tabla Relacionada
- **ta_11_fecha_desc**
  - mes (smallint, PK)
  - fecha_descuento (date)
  - fecha_recargos (date)
  - fecha_alta (timestamp)
  - id_usuario (integer)

# Casos de Uso
Ver sección `use_cases`.

# Casos de Prueba
Ver sección `test_cases`.
