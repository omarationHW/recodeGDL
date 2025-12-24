# CveDiferMntto

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - CveDiferMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva clave de diferencia

**Descripción:** El usuario desea registrar una nueva clave de diferencia por cobrar.

**Precondiciones:**
El usuario tiene permisos de administrador y conoce la cuenta de ingreso.

**Pasos a seguir:**
1. Accede a la página de Mantenimiento de Claves de Diferencias.
2. Da clic en 'Agregar'.
3. Ingresa el número de clave, la descripción y selecciona la cuenta de ingreso.
4. Ingresa su id_usuario (o se autocompleta).
5. Da clic en 'Agregar'.

**Resultado esperado:**
La clave se inserta correctamente y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "clave_diferencia": 200, "descripcion": "DIFERENCIA POR AJUSTE", "cuenta_ingreso": 44502, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de clave de diferencia existente

**Descripción:** El usuario necesita actualizar la descripción y cuenta de ingreso de una clave existente.

**Precondiciones:**
Existe una clave de diferencia registrada.

**Pasos a seguir:**
1. Busca la clave en la tabla.
2. Da clic en 'Editar'.
3. Modifica la descripción y/o la cuenta de ingreso.
4. Da clic en 'Actualizar'.

**Resultado esperado:**
La clave se actualiza correctamente y la lista se refresca. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "clave_diferencia": 200, "descripcion": "DIFERENCIA POR REDONDEO", "cuenta_ingreso": 44503, "id_usuario": 1 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta guardar una clave sin descripción o sin cuenta de ingreso.

**Precondiciones:**
El usuario está en el formulario de alta o edición.

**Pasos a seguir:**
1. Deja vacío el campo descripción o cuenta de ingreso.
2. Da clic en 'Agregar' o 'Actualizar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando el campo faltante y no realiza la operación.

**Datos de prueba:**
{ "clave_diferencia": 201, "descripcion": "", "cuenta_ingreso": "", "id_usuario": 1 }

---



## Casos de Prueba

# Casos de Prueba: Mantenimiento Claves de Diferencias

## 1. Alta exitosa
- **Input:** clave_diferencia=300, descripcion="DIFERENCIA TEST", cuenta_ingreso=44510, id_usuario=2
- **Acción:** insert_cve_diferencia
- **Esperado:** success=true, mensaje de éxito, registro aparece en listado

## 2. Alta duplicada
- **Input:** clave_diferencia=300, descripcion="DIFERENCIA DUPLICADA", cuenta_ingreso=44510, id_usuario=2
- **Acción:** insert_cve_diferencia
- **Esperado:** success=false, mensaje de error "ya existe"

## 3. Modificación exitosa
- **Input:** clave_diferencia=300, descripcion="DIFERENCIA MODIFICADA", cuenta_ingreso=44511, id_usuario=2
- **Acción:** update_cve_diferencia
- **Esperado:** success=true, mensaje de éxito, registro actualizado

## 4. Modificación inexistente
- **Input:** clave_diferencia=9999, descripcion="NO EXISTE", cuenta_ingreso=44512, id_usuario=2
- **Acción:** update_cve_diferencia
- **Esperado:** success=false, mensaje de error "no existe"

## 5. Validación de campos vacíos
- **Input:** clave_diferencia=301, descripcion="", cuenta_ingreso=0, id_usuario=2
- **Acción:** insert_cve_diferencia
- **Esperado:** success=false, mensaje de error de validación

## 6. Consulta de listado
- **Acción:** list_cve_diferencias
- **Esperado:** success=true, data es array de registros

## 7. Consulta de cuentas
- **Acción:** list_cuentas
- **Esperado:** success=true, data es array de cuentas



