# Documentación Técnica: Migración Formulario sfrm_prop_exclusivo

## 1. Descripción General
Este módulo permite el registro y edición de propietarios (personas físicas o morales) en la tabla `ex_propietario` de la base de datos PostgreSQL. La migración incluye:
- Backend Laravel con endpoint unificado `/api/execute`.
- Lógica de negocio en stored procedures PostgreSQL.
- Frontend Vue.js como página independiente.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "nombre_operacion",
    "params": { ... }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

### eRequest soportados:
- `ex_propietario_create`: Alta de propietario.
- `ex_propietario_update`: Modificación de propietario.
- `ex_propietario_by_rfc`: Consulta por RFC.
- `ex_propietario_by_id`: Consulta por ID.

## 3. Stored Procedures
Toda la lógica de inserción, actualización y consulta reside en funciones PostgreSQL:
- **ex_propietario_create**: Inserta nuevo registro, valida duplicidad de RFC.
- **ex_propietario_update**: Actualiza registro existente por ID.
- **ex_propietario_by_rfc**: Consulta por RFC.
- **ex_propietario_by_id**: Consulta por ID.

## 4. Laravel Controller
- Controlador: `App\Http\Controllers\Api\ExecuteController`
- Recibe el eRequest y parámetros, ejecuta el stored procedure correspondiente y retorna la respuesta estándar.
- Maneja errores y mensajes de validación.

## 5. Vue.js Component
- Página independiente para alta/edición de propietario.
- Validaciones en frontend (RFC, nombre, domicilio).
- Consulta y edición si se recibe prop `id`.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## 6. Seguridad
- Validación de datos en frontend y backend.
- El RFC debe ser único.
- Los stored procedures previenen duplicados y validan existencia antes de actualizar.

## 7. Flujo de Operación
1. El usuario accede a la página de registro o edición.
2. El formulario valida los campos requeridos.
3. Al guardar, se envía la petición a `/api/execute` con el eRequest adecuado.
4. El backend ejecuta el stored procedure y retorna el resultado.
5. El frontend muestra el mensaje correspondiente.

## 8. Consideraciones
- El campo "sociedad" es 'F' para física, 'M' para moral.
- El campo RFC es obligatorio y único.
- El formulario puede ser usado tanto para alta como para edición.

## 9. Ejemplo de Peticiones
### Alta:
```json
{
  "eRequest": "ex_propietario_create",
  "params": {
    "sociedad": "F",
    "rfc": "TOHI691108LFA",
    "propietario": "JUAN PEREZ",
    "domicilio": "AV. PRINCIPAL 123",
    "colonia": "CENTRO",
    "telefono": "5551234567",
    "celular": "5559876543",
    "email": "juan@mail.com"
  }
}
```

### Edición:
```json
{
  "eRequest": "ex_propietario_update",
  "params": {
    "id": 1,
    "sociedad": "M",
    "rfc": "TOHI691108LFA",
    "propietario": "EMPRESA SA DE CV",
    "domicilio": "CALLE 2 #45",
    "colonia": "INDUSTRIAL",
    "telefono": "5551112233",
    "celular": "5553332211",
    "email": "empresa@correo.com"
  }
}
```

## 10. Errores Comunes
- RFC duplicado: El stored procedure retorna error y no inserta.
- ID inexistente en edición: Retorna error.
- Campos requeridos vacíos: Validados en frontend y backend.
