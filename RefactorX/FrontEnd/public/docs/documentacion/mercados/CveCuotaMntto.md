# CveCuotaMntto

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Mantenimiento de Claves para la Cuota (CveCuotaMntto)

## Descripción General
Este módulo permite la administración de las claves de cuota (catálogo) utilizadas en el sistema de mercados municipales. Incluye la creación, edición, listado y eliminación de claves de cuota.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  - `action`: Acción a ejecutar (`list_cve_cuota`, `get_cve_cuota`, `create_cve_cuota`, `update_cve_cuota`, `delete_cve_cuota`)
  - `params`: Parámetros requeridos para la acción
- **Ejemplo de request:**
```json
{
  "action": "create_cve_cuota",
  "params": {
    "clave_cuota": 5,
    "descripcion": "CUOTA ESPECIAL"
  }
}
```
- **Ejemplo de response:**
```json
{
  "success": true,
  "data": null,
  "message": "Clave de cuota creada correctamente."
}
```

## Stored Procedures (PostgreSQL)
- `sp_cve_cuota_insert(p_clave_cuota, p_descripcion)`
- `sp_cve_cuota_update(p_clave_cuota, p_descripcion)`
- `sp_cve_cuota_delete(p_clave_cuota)`

## Frontend (Vue.js)
- Página independiente para el catálogo de claves de cuota.
- Permite listar, crear, editar y eliminar claves de cuota.
- Validación de campos en frontend y backend.
- Mensajes de éxito/error.

## Seguridad
- Validación de datos en backend (Laravel) y frontend (Vue).
- Uso de stored procedures para evitar SQL injection.
- Eliminar claves sólo si no están en uso (recomendación: agregar validación referencial en la base de datos).

## Flujo de Trabajo
1. El usuario accede a la página de claves de cuota.
2. Puede ver el listado, crear una nueva clave, editar o eliminar una existente.
3. Las operaciones se realizan vía API `/api/execute`.
4. El backend ejecuta el stored procedure correspondiente.
5. El frontend muestra el resultado y actualiza la vista.

## Errores Comunes
- Intentar crear una clave existente: retorna mensaje de error.
- Intentar eliminar una clave en uso: debe manejarse a nivel de base de datos o con validación adicional.

## Recomendaciones
- Agregar auditoría de cambios si es necesario.
- Validar integridad referencial en la base de datos.

# Esquema de la Tabla
```sql
CREATE TABLE ta_11_cve_cuota (
    clave_cuota INTEGER PRIMARY KEY,
    descripcion VARCHAR(60) NOT NULL
);
```


## Casos de Uso

# Casos de Uso - CveCuotaMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva clave de cuota

**Descripción:** Un usuario desea agregar una nueva clave de cuota para un tipo de local especial.

**Precondiciones:**
El usuario tiene permisos de administrador. La clave de cuota no existe.

**Pasos a seguir:**
1. El usuario ingresa a la página de Claves de Cuota.
2. Hace clic en 'Nueva Clave de Cuota'.
3. Ingresa el número de clave (ej: 10) y la descripción (ej: 'CUOTA ESPECIAL').
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La clave de cuota se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "clave_cuota": 10, "descripcion": "CUOTA ESPECIAL" }

---

## Caso de Uso 2: Edición de una clave de cuota existente

**Descripción:** El usuario necesita corregir la descripción de una clave de cuota.

**Precondiciones:**
La clave de cuota existe.

**Pasos a seguir:**
1. El usuario selecciona la clave de cuota a editar.
2. Hace clic en 'Editar'.
3. Modifica la descripción (ej: 'CUOTA MODIFICADA').
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La descripción se actualiza correctamente.

**Datos de prueba:**
{ "clave_cuota": 10, "descripcion": "CUOTA MODIFICADA" }

---

## Caso de Uso 3: Eliminación de una clave de cuota

**Descripción:** El usuario elimina una clave de cuota que ya no se utiliza.

**Precondiciones:**
La clave de cuota existe y no está referenciada en otras tablas.

**Pasos a seguir:**
1. El usuario selecciona la clave de cuota a eliminar.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La clave de cuota se elimina del sistema.

**Datos de prueba:**
{ "clave_cuota": 10 }

---



## Casos de Prueba

# Casos de Prueba para CveCuotaMntto

## 1. Alta de clave de cuota válida
- **Entrada:** clave_cuota=20, descripcion="CUOTA TEMPORAL"
- **Acción:** create_cve_cuota
- **Resultado esperado:** success=true, mensaje de éxito, la clave aparece en el listado.

## 2. Alta de clave de cuota duplicada
- **Entrada:** clave_cuota=20, descripcion="CUOTA DUPLICADA"
- **Acción:** create_cve_cuota
- **Resultado esperado:** success=false, mensaje de error "La clave de cuota ya existe."

## 3. Edición de clave de cuota existente
- **Entrada:** clave_cuota=20, descripcion="CUOTA ACTUALIZADA"
- **Acción:** update_cve_cuota
- **Resultado esperado:** success=true, mensaje de éxito, descripción actualizada.

## 4. Eliminación de clave de cuota existente
- **Entrada:** clave_cuota=20
- **Acción:** delete_cve_cuota
- **Resultado esperado:** success=true, mensaje de éxito, la clave ya no aparece en el listado.

## 5. Eliminación de clave de cuota inexistente
- **Entrada:** clave_cuota=9999
- **Acción:** delete_cve_cuota
- **Resultado esperado:** success=true (o false si se valida existencia), mensaje de éxito o advertencia.

## 6. Listado de claves de cuota
- **Acción:** list_cve_cuota
- **Resultado esperado:** success=true, data es un array de claves de cuota.

## 7. Validación de campos obligatorios
- **Entrada:** clave_cuota vacío o descripcion vacío
- **Acción:** create_cve_cuota
- **Resultado esperado:** success=false, mensaje de error de validación.



