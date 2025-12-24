# Secciones

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Catálogo de Secciones (Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite la administración del catálogo de secciones de mercados. Incluye la visualización, alta, edición y eliminación de secciones. La arquitectura utiliza Laravel para el backend, Vue.js para el frontend y PostgreSQL como base de datos, empleando stored procedures para toda la lógica de negocio.

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` que recibe peticiones con el patrón `eRequest/eResponse`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y formularios independientes.
- **Base de Datos:** PostgreSQL, toda la lógica encapsulada en stored procedures.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": {
      "action": "secciones.list|secciones.create|secciones.update|secciones.delete",
      "params": { ... }
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": "..."
    }
  }
  ```

## Stored Procedures
- **sp_secciones_list:** Devuelve todas las secciones.
- **sp_secciones_create:** Inserta una nueva sección.
- **sp_secciones_update:** Actualiza la descripción de una sección.
- **sp_secciones_delete:** Elimina una sección.

## Seguridad
- Validación de parámetros en el controlador Laravel.
- Uso de transacciones y manejo de errores en los stored procedures.
- El frontend valida campos requeridos y longitud máxima.

## Flujo de Trabajo
1. El usuario accede a la página de Secciones.
2. El frontend carga la lista de secciones vía `secciones.list`.
3. El usuario puede agregar, editar o eliminar secciones.
4. Cada acción envía una petición a `/api/execute` con el action correspondiente.
5. El backend ejecuta el stored procedure y retorna el resultado.

## Integración
- El componente Vue.js puede ser montado en cualquier ruta, por ejemplo `/secciones`.
- El backend debe exponer el endpoint `/api/execute` y registrar el controlador.
- Los stored procedures deben estar creados en la base de datos PostgreSQL.

## Consideraciones
- No se permite duplicidad de claves de sección.
- No se permite eliminar una sección inexistente.
- Todas las operaciones son atómicas y devuelven mensajes claros de éxito o error.

## Ejemplo de Petición
```json
{
  "eRequest": {
    "action": "secciones.create",
    "params": {
      "seccion": "A1",
      "descripcion": "Zona Norte"
    }
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": [{"success": true, "message": "Sección creada correctamente."}],
    "message": ""
  }
}
```


## Casos de Uso

# Casos de Uso - Secciones

**Categoría:** Form

## Caso de Uso 1: Alta de una nueva sección

**Descripción:** El usuario desea agregar una nueva sección al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador. No existe una sección con la clave 'B2'.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Hace clic en 'Agregar Sección'.
3. Ingresa 'B2' como clave y 'Zona Sur' como descripción.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La sección 'B2' se agrega correctamente y aparece en la lista.

**Datos de prueba:**
{ "seccion": "B2", "descripcion": "Zona Sur" }

---

## Caso de Uso 2: Edición de una sección existente

**Descripción:** El usuario desea modificar la descripción de la sección 'A1'.

**Precondiciones:**
La sección 'A1' existe en el catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Hace clic en 'Editar' junto a la sección 'A1'.
3. Cambia la descripción a 'Zona Norte Actualizada'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La descripción de la sección 'A1' se actualiza correctamente.

**Datos de prueba:**
{ "seccion": "A1", "descripcion": "Zona Norte Actualizada" }

---

## Caso de Uso 3: Eliminación de una sección

**Descripción:** El usuario desea eliminar la sección 'B2'.

**Precondiciones:**
La sección 'B2' existe en el catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Hace clic en 'Eliminar' junto a la sección 'B2'.
3. Confirma la eliminación.

**Resultado esperado:**
La sección 'B2' se elimina correctamente y ya no aparece en la lista.

**Datos de prueba:**
{ "seccion": "B2" }

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Secciones

## Caso 1: Alta de sección válida
- **Entrada:** seccion='C3', descripcion='Zona Este'
- **Acción:** secciones.create
- **Esperado:** success=true, mensaje de éxito, la sección aparece en la lista.

## Caso 2: Alta de sección duplicada
- **Entrada:** seccion='A1', descripcion='Zona Duplicada'
- **Acción:** secciones.create
- **Esperado:** success=false, mensaje 'La sección ya existe.'

## Caso 3: Edición de sección existente
- **Entrada:** seccion='C3', descripcion='Zona Este Modificada'
- **Acción:** secciones.update
- **Esperado:** success=true, mensaje de éxito, la descripción se actualiza.

## Caso 4: Edición de sección inexistente
- **Entrada:** seccion='ZZ', descripcion='No existe'
- **Acción:** secciones.update
- **Esperado:** success=false, mensaje 'La sección no existe.'

## Caso 5: Eliminación de sección existente
- **Entrada:** seccion='C3'
- **Acción:** secciones.delete
- **Esperado:** success=true, mensaje de éxito, la sección desaparece de la lista.

## Caso 6: Eliminación de sección inexistente
- **Entrada:** seccion='ZZ'
- **Acción:** secciones.delete
- **Esperado:** success=false, mensaje 'La sección no existe.'

## Caso 7: Listado de secciones
- **Acción:** secciones.list
- **Esperado:** success=true, data es un array de objetos con campos seccion y descripcion.



