# FechasDescuentoMntto

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - FechasDescuentoMntto

**Categoría:** Form

## Caso de Uso 1: Consulta de todas las fechas de descuento

**Descripción:** El usuario accede al módulo y visualiza la tabla con todos los meses y sus fechas de descuento y recargos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página de Fechas de Descuento.
2. El frontend realiza una petición POST a /api/execute con action 'getAll'.
3. El backend retorna la lista de meses y fechas.

**Resultado esperado:**
Se muestra la tabla con los 12 meses y sus fechas correspondientes.

**Datos de prueba:**
No se requiere data específica, solo que existan registros en ta_11_fecha_desc.

---

## Caso de Uso 2: Actualización de la fecha de descuento y recargos para un mes

**Descripción:** El usuario edita la fecha de descuento y recargos del mes de mayo.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario hace clic en 'Editar' en la fila de mayo.
2. Se muestra el formulario con los datos actuales.
3. El usuario cambia la fecha de descuento a '2024-05-15' y la de recargos a '2024-05-23'.
4. El usuario guarda los cambios.
5. El frontend envía la petición POST a /api/execute con action 'update' y los datos.
6. El backend valida y actualiza.

**Resultado esperado:**
Las fechas se actualizan correctamente y la tabla se refresca.

**Datos de prueba:**
{ "mes": 5, "fecha_descuento": "2024-05-15", "fecha_recargos": "2024-05-23", "id_usuario": 2 }

---

## Caso de Uso 3: Validación de mes incorrecto en fechas

**Descripción:** El usuario intenta poner una fecha de descuento de junio para el mes de mayo.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario edita el mes de mayo.
2. Ingresa fecha_descuento '2024-06-01' y fecha_recargos '2024-05-23'.
3. Guarda los cambios.
4. El backend valida y rechaza la operación.

**Resultado esperado:**
Se muestra un mensaje de error: 'La fecha de descuento y recargos debe corresponder al mes seleccionado.'

**Datos de prueba:**
{ "mes": 5, "fecha_descuento": "2024-06-01", "fecha_recargos": "2024-05-23", "id_usuario": 2 }

---



## Casos de Prueba

## Casos de Prueba para FechasDescuentoMntto

### Caso 1: Consulta de todas las fechas
- **Acción:** POST /api/execute { "action": "getAll" }
- **Resultado esperado:** 12 registros, uno por cada mes, con fechas válidas.

### Caso 2: Consulta por mes
- **Acción:** POST /api/execute { "action": "getByMes", "data": { "mes": 5 } }
- **Resultado esperado:** Un registro para el mes 5 (mayo).

### Caso 3: Actualización exitosa
- **Acción:** POST /api/execute { "action": "update", "data": { "mes": 5, "fecha_descuento": "2024-05-15", "fecha_recargos": "2024-05-23", "id_usuario": 2 } }
- **Resultado esperado:** success=true, message='Actualización exitosa'.
- **Verificación:** Consultar nuevamente y ver que las fechas cambiaron.

### Caso 4: Validación de mes incorrecto
- **Acción:** POST /api/execute { "action": "update", "data": { "mes": 5, "fecha_descuento": "2024-06-01", "fecha_recargos": "2024-05-23", "id_usuario": 2 } }
- **Resultado esperado:** success=false, message='La fecha de descuento y recargos debe corresponder al mes seleccionado.'

### Caso 5: Usuario no autenticado
- **Acción:** POST /api/execute sin sesión válida
- **Resultado esperado:** HTTP 401 Unauthorized

### Caso 6: SQL Injection
- **Acción:** POST /api/execute { "action": "update", "data": { "mes": "5; DROP TABLE ta_11_fecha_desc;--", ... } }
- **Resultado esperado:** Error de validación, sin ejecución de SQL malicioso.



