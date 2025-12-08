# Documentación Técnica: Mannto_Operaciones

## Análisis

# Documentación Técnica: Migración de Formulario Mannto_Operaciones (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe un objeto `eRequest` con la acción y datos, y responde con `eResponse`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs), navegación por rutas.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio (validaciones, reglas de negocio) se implementa en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "list|create|update|delete|check_usage",
      "data": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": { ... }
  }
  ```

## Controlador Laravel
- Un solo método `execute` que despacha la acción a los stored procedures correspondientes.
- Todas las validaciones de negocio críticas (unicidad, uso en pagos, etc.) se delegan a los SP.
- Manejo de errores y mensajes amigables.

## Stored Procedures PostgreSQL
- **sp16_operaciones_list**: Devuelve todas las claves de operación.
- **sp16_operaciones_create**: Inserta una nueva clave, valida unicidad.
- **sp16_operaciones_update**: Actualiza la descripción de una clave.
- **sp16_operaciones_delete**: Elimina una clave si no tiene pagos asociados.
- **sp16_operaciones_check_usage**: Indica si una clave está en uso en pagos.

## Componente Vue.js
- Página completa, muestra listado, permite alta, edición y baja.
- Modal para alta/edición, modal de confirmación para baja.
- Validaciones en frontend y backend.
- Mensajes de error y éxito.
- Navegación breadcrumb.

## Seguridad
- Todas las acciones críticas requieren validación en SP (no confiar solo en frontend).
- El endpoint debe estar protegido por autenticación (no incluido aquí por simplicidad).

## Flujo de Operación
1. El usuario accede a la página y ve el listado de claves.
2. Puede crear una nueva clave (modal), editar una existente o eliminarla.
3. Antes de eliminar, se verifica si la clave está en uso (pagos asociados).
4. Todas las operaciones se hacen vía `/api/execute` con el patrón eRequest/eResponse.

## Notas de Migración
- El campo `ctrol_operacion` es autoincremental en PostgreSQL.
- El campo `cve_operacion` es único (1 carácter).
- La lógica de Delphi se traduce a lógica de SP y validaciones en backend.
- El frontend no usa tabs ni componentes tabulares, cada formulario es una página.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint.
- Los SP pueden evolucionar para reglas más complejas.



## Casos de Uso

# Casos de Uso - Mannto_Operaciones

**Categoría:** Form

## Caso de Uso 1: Alta de nueva Clave de Operación

**Descripción:** El usuario desea registrar una nueva clave de operación para un nuevo tipo de movimiento.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Operación.
2. Hace clic en 'Nueva Clave'.
3. Ingresa la clave (un carácter) y la descripción.
4. Presiona 'Guardar'.

**Resultado esperado:**
La clave se registra y aparece en el listado. Si la clave ya existe, se muestra un mensaje de error.

**Datos de prueba:**
{ "cve_operacion": "Z", "descripcion": "ZONA ESPECIAL" }

---

## Caso de Uso 2: Edición de descripción de Clave de Operación

**Descripción:** El usuario necesita corregir la descripción de una clave existente.

**Precondiciones:**
Existe al menos una clave de operación registrada.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Operación.
2. Hace clic en 'Editar' sobre la clave deseada.
3. Modifica la descripción.
4. Presiona 'Guardar'.

**Resultado esperado:**
La descripción se actualiza correctamente.

**Datos de prueba:**
{ "cve_operacion": "A", "descripcion": "CUOTA NORMAL ACTUALIZADA" }

---

## Caso de Uso 3: Eliminación de Clave de Operación sin pagos asociados

**Descripción:** El usuario desea eliminar una clave que no está en uso.

**Precondiciones:**
Existe una clave de operación sin pagos asociados.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Operación.
2. Hace clic en 'Eliminar' sobre la clave deseada.
3. Confirma la eliminación.

**Resultado esperado:**
La clave se elimina del catálogo.

**Datos de prueba:**
{ "ctrol_operacion": 10 }

---



## Casos de Prueba

# Casos de Prueba para Mannto_Operaciones

## 1. Alta de Clave de Operación
- **Entrada**: { "action": "create", "data": { "cve_operacion": "X", "descripcion": "PRUEBA X" } }
- **Esperado**: Respuesta success true, mensaje 'Clave creada', la clave aparece en el listado.

## 2. Alta de Clave Duplicada
- **Entrada**: { "action": "create", "data": { "cve_operacion": "X", "descripcion": "OTRA" } }
- **Esperado**: Respuesta success false, mensaje 'Ya existe la clave de operación'.

## 3. Edición de Descripción
- **Entrada**: { "action": "update", "data": { "cve_operacion": "X", "descripcion": "NUEVA DESCRIPCION" } }
- **Esperado**: Respuesta success true, mensaje 'Clave actualizada', la descripción cambia en el listado.

## 4. Eliminación con Pagos Asociados
- **Precondición**: Existen pagos con ctrol_operacion = X.
- **Entrada**: { "action": "delete", "data": { "ctrol_operacion": X } }
- **Esperado**: Respuesta success false, mensaje 'No se puede eliminar: existen pagos asociados'.

## 5. Eliminación sin Pagos Asociados
- **Precondición**: No existen pagos con ctrol_operacion = Y.
- **Entrada**: { "action": "delete", "data": { "ctrol_operacion": Y } }
- **Esperado**: Respuesta success true, mensaje 'Clave eliminada'.

## 6. Listado de Claves
- **Entrada**: { "action": "list" }
- **Esperado**: Respuesta success true, data es arreglo de claves existentes.


