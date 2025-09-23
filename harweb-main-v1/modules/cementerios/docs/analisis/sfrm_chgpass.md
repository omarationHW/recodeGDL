# Documentación Técnica: Cambio de Clave de Acceso (sfrm_chgpass)

## Descripción General
Este módulo permite a los usuarios autenticados cambiar su clave de acceso de manera segura, cumpliendo con las reglas de seguridad establecidas. La migración Delphi → Laravel + Vue.js + PostgreSQL se implementa usando:

- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Componente Vue.js como página independiente
- **Base de Datos**: Stored Procedures en PostgreSQL para validación y cambio de clave

## Flujo de Proceso
1. **Validación de Clave Actual**: El usuario ingresa su clave actual y se valida contra la base de datos.
2. **Ingreso de Nueva Clave**: El usuario ingresa la nueva clave y confirmación. Se validan reglas:
   - No igual a la actual
   - Al menos 6 caracteres
   - Debe contener letras y números
   - Los 3 primeros caracteres diferentes a la actual
   - Confirmación igual
3. **Cambio de Clave**: Si todas las validaciones pasan, se actualiza la clave en la base de datos usando hash seguro (bcrypt).

## API: Endpoint Unificado
- **URL**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "chgpass.change",
      "data": {
        "current_password": "...",
        "new_password": "...",
        "confirm_password": "..."
      }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "Clave cambiada satisfactoriamente.",
      "data": null,
      "errors": null
    }
  }
  ```

## Seguridad
- El cambio de clave requiere autenticación previa (middleware auth).
- Las contraseñas se almacenan usando hash seguro (bcrypt).
- Todas las validaciones se realizan tanto en frontend como en backend.

## Stored Procedures
- `sp_chgpass_validate_current`: Valida la clave actual del usuario.
- `sp_chgpass_change`: Realiza el cambio de clave con todas las validaciones de negocio.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Navegación paso a paso: actual → nueva → confirmación.
- Mensajes de error y éxito claros.
- Redirección automática tras éxito.

## Consideraciones
- El endpoint `/api/execute` puede ser extendido para otros formularios y acciones.
- El patrón eRequest/eResponse permite desacoplar el frontend del backend.

# Esquema de la Tabla de Usuarios (Ejemplo)
```sql
CREATE TABLE ta_12_passwords (
    id_usuario serial PRIMARY KEY,
    usuario varchar(50) NOT NULL,
    password varchar(255) NOT NULL,
    estado char(1) DEFAULT 'A',
    fecha_mov timestamp DEFAULT now()
);
```

# Seguridad Adicional
- Se recomienda usar HTTPS en producción.
- El backend debe proteger el endpoint con autenticación JWT o session.
- El SP sólo permite cambiar la clave del usuario autenticado.
