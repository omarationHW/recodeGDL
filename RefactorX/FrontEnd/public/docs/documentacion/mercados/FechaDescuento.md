# FechaDescuento

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - FechaDescuento

**Categoría:** Form

## Caso de Uso 1: Consulta de Fechas de Descuento

**Descripción:** El usuario accede a la página de Fechas de Descuento y visualiza la lista de meses con sus fechas de descuento y recargos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página 'Fechas de Descuento'.
2. El sistema realiza una petición 'list' al endpoint /api/execute.
3. El backend retorna la lista de meses y fechas.
4. El frontend muestra la tabla con los datos.

**Resultado esperado:**
La tabla muestra los 12 meses con sus fechas actuales de descuento y recargos.

**Datos de prueba:**
No se requiere data específica, pero la tabla ta_11_fecha_desc debe tener datos para todos los meses.

---

## Caso de Uso 2: Modificación de Fecha de Descuento

**Descripción:** El usuario selecciona un mes y modifica la fecha de descuento y/o recargos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario selecciona un mes en la tabla.
2. Hace clic en 'Modificar'.
3. Se abre el modal con los datos actuales.
4. El usuario cambia la fecha de descuento y/o recargos.
5. Hace clic en 'Guardar'.
6. El sistema envía una petición 'update' al endpoint /api/execute.
7. El backend actualiza la base de datos y retorna éxito.
8. El frontend refresca la tabla.

**Resultado esperado:**
La fecha de descuento y/o recargos del mes seleccionado se actualiza correctamente y se muestra el nuevo valor en la tabla.

**Datos de prueba:**
{ "mes": 6, "fecha_descuento": "2024-06-10", "fecha_recargos": "2024-06-20", "id_usuario": 2 }

---

## Caso de Uso 3: Intento de Modificar un Mes Inexistente

**Descripción:** El usuario intenta modificar un mes que no existe en la tabla.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario envía una petición 'update' con un mes inexistente (por ejemplo, mes=13).
2. El backend valida y detecta que el mes no existe.
3. El backend retorna un error.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el mes no existe.

**Datos de prueba:**
{ "mes": 13, "fecha_descuento": "2024-06-10", "fecha_recargos": "2024-06-20", "id_usuario": 2 }

---



## Casos de Prueba

# Casos de Prueba: FechaDescuento

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Consulta de todos los meses | action: 'list' | Devuelve 12 filas con los datos de cada mes |
| 2 | Consulta de un mes específico | action: 'get', mes: 5 | Devuelve la fila del mes 5 |
| 3 | Modificación exitosa | action: 'update', mes: 7, fecha_descuento: '2024-07-15', fecha_recargos: '2024-07-25', id_usuario: 1 | success: true, message: 'Actualización exitosa' |
| 4 | Modificación con mes inexistente | action: 'update', mes: 13, ... | success: false, message: 'No existe el mes especificado' |
| 5 | Modificación con fecha inválida | action: 'update', mes: 6, fecha_descuento: '2024-13-01', ... | success: false, message de validación |
| 6 | Modificación sin usuario | action: 'update', mes: 6, fecha_descuento: '2024-06-10', fecha_recargos: '2024-06-20' | success: false, message de validación |
| 7 | Modificación sin cambios (mismos valores) | action: 'update', mes: 6, ... (valores actuales) | success: true, message: 'Actualización exitosa' |



