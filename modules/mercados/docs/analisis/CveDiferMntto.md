# Documentación Técnica: Mantenimiento de Claves de Diferencias por Cobrar

## Descripción General
Este módulo permite la administración (alta, modificación y consulta) de las claves de diferencias por cobrar, almacenadas en la tabla `ta_11_catalogo_dif`. Incluye la selección de la cuenta de ingreso asociada y el registro del usuario que realiza la operación.

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `list_cve_diferencias`: Lista todas las claves de diferencias.
  - `get_cve_diferencia`: Obtiene una clave específica.
  - `insert_cve_diferencia`: Inserta una nueva clave.
  - `update_cve_diferencia`: Actualiza una clave existente.
  - `list_cuentas`: Lista las cuentas de ingreso disponibles.

## Stored Procedures
- Toda la lógica de inserción y actualización se realiza mediante stored procedures PostgreSQL:
  - `sp_insert_cve_diferencia`
  - `sp_update_cve_diferencia`

## Validaciones
- No se permite descripción vacía ni cuenta de ingreso vacía.
- No se permite duplicar claves.
- El usuario debe estar autenticado (el frontend debe enviar el id_usuario).

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej. JWT o sesión Laravel).
- Los stored procedures validan existencia antes de insertar/actualizar.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para alta/modificación.
- Tabla de consulta con edición inline.
- Selección de cuenta de ingreso desde catálogo.
- Mensajes de éxito/error.

## Navegación
- Breadcrumb para navegación contextual.
- Botón de cancelar para limpiar el formulario.

## Flujo de Trabajo
1. El usuario accede a la página de mantenimiento.
2. Puede agregar una nueva clave o editar una existente.
3. Al guardar, se llama al endpoint `/api/execute` con la acción correspondiente.
4. El backend ejecuta el stored procedure y retorna el resultado.
5. El frontend muestra el mensaje y actualiza la lista.

## Integración
- El componente Vue puede ser usado en cualquier SPA Vue.js con Vue Router.
- El controlador Laravel puede ser registrado en `routes/api.php` como:
  ```php
  Route::post('/execute', [CveDiferMnttoController::class, 'execute']);
  ```

## Consideraciones
- El catálogo de cuentas se obtiene en tiempo real para evitar inconsistencias.
- El id_usuario debe ser proporcionado por el frontend (ej. desde sesión).

# Esquema de Tabla (Referencia)
```sql
CREATE TABLE ta_11_catalogo_dif (
  clave_diferencia integer PRIMARY KEY,
  descripcion varchar(60) NOT NULL,
  cuenta_ingreso integer NOT NULL,
  fecha_actual timestamp DEFAULT now(),
  id_usuario integer NOT NULL
);
```

# Ejemplo de eRequest/eResponse
```json
{
  "action": "insert_cve_diferencia",
  "params": {
    "clave_diferencia": 101,
    "descripcion": "DIFERENCIA POR REDONDEO",
    "cuenta_ingreso": 44501,
    "id_usuario": 5
  }
}
```

# Ejemplo de Respuesta
```json
{
  "success": true,
  "message": "Clave de diferencia insertada correctamente"
}
```
