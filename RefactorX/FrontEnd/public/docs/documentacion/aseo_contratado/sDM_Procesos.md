# Documentación Técnica: sDM_Procesos

## Análisis

# Documentación Técnica: Migración de sDM_Procesos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la gestión de la entidad **Procesos** en la base de datos `BasePHP`, migrando la lógica de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (almacenamiento y lógica de negocio).

## 2. Estructura de la Base de Datos
Se asume la existencia de la tabla:

```sql
CREATE TABLE procesos (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  descripcion TEXT
);
```

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Patrón:** eRequest/eResponse
- **Métodos soportados:**
  - `list`: Listar todos los procesos
  - `get`: Obtener un proceso por ID
  - `create`: Crear un nuevo proceso
  - `update`: Actualizar un proceso existente
  - `delete`: Eliminar un proceso

### Ejemplo de Request
```json
{
  "eRequest": {
    "action": "create",
    "data": {
      "nombre": "Proceso X",
      "descripcion": "Descripción del proceso X"
    }
  }
}
```

### Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "message": "",
    "data": {
      "id": 1,
      "nombre": "Proceso X",
      "descripcion": "Descripción del proceso X"
    }
  }
}
```

## 4. Stored Procedures
Toda la lógica de acceso y manipulación de datos se realiza mediante funciones almacenadas en PostgreSQL:
- `procesos_listar()`
- `procesos_obtener(p_id)`
- `procesos_crear(p_nombre, p_descripcion)`
- `procesos_actualizar(p_id, p_nombre, p_descripcion)`
- `procesos_eliminar(p_id)`

## 5. Laravel Controller
- Controlador: `ProcesosController`
- Método principal: `execute(Request $request)`
- Utiliza el endpoint `/api/execute` para todas las operaciones.
- Valida y enruta la acción solicitada, invocando los stored procedures correspondientes.

## 6. Vue.js Component
- Página independiente: `ProcesosPage.vue`
- Permite listar, crear, editar y eliminar procesos.
- Utiliza el endpoint `/api/execute` para todas las operaciones.
- Incluye navegación breadcrumb y mensajes de usuario.

## 7. Seguridad
- Validación básica de campos obligatorios en backend y frontend.
- Se recomienda agregar autenticación y autorización según el contexto de la aplicación.

## 8. Consideraciones
- El endpoint es unificado para facilitar la integración y el mantenimiento.
- El frontend es completamente funcional como página independiente.
- La lógica de negocio reside en los stored procedures para facilitar la migración y el mantenimiento.


## Casos de Uso

# Casos de Uso - sDM_Procesos

**Categoría:** Form

## Caso de Uso 1: Crear un nuevo proceso

**Descripción:** El usuario desea registrar un nuevo proceso en el sistema.

**Precondiciones:**
El usuario tiene acceso a la página de procesos y permisos para crear.

**Pasos a seguir:**
1. El usuario hace clic en 'Nuevo Proceso'.
2. Ingresa el nombre y la descripción del proceso.
3. Hace clic en 'Guardar'.

**Resultado esperado:**
El proceso es creado y aparece en la lista de procesos.

**Datos de prueba:**
{ "nombre": "Proceso de Prueba", "descripcion": "Este es un proceso de prueba." }

---

## Caso de Uso 2: Editar un proceso existente

**Descripción:** El usuario necesita modificar los datos de un proceso ya registrado.

**Precondiciones:**
Existe al menos un proceso registrado.

**Pasos a seguir:**
1. El usuario localiza el proceso en la lista.
2. Hace clic en 'Editar'.
3. Modifica el nombre o la descripción.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
Los cambios se guardan y se reflejan en la lista.

**Datos de prueba:**
{ "id": 1, "nombre": "Proceso Modificado", "descripcion": "Descripción actualizada." }

---

## Caso de Uso 3: Eliminar un proceso

**Descripción:** El usuario desea eliminar un proceso que ya no es necesario.

**Precondiciones:**
Existe al menos un proceso registrado.

**Pasos a seguir:**
1. El usuario localiza el proceso en la lista.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El proceso es eliminado y desaparece de la lista.

**Datos de prueba:**
{ "id": 1 }

---



## Casos de Prueba

## Casos de Prueba para Procesos

### Caso 1: Crear proceso válido
- **Entrada:**
  ```json
  { "eRequest": { "action": "create", "data": { "nombre": "Proceso QA", "descripcion": "Prueba de creación" } } }
  ```
- **Esperado:**
  - success: true
  - data contiene el proceso creado con nombre y descripción correctos

### Caso 2: Crear proceso sin nombre (inválido)
- **Entrada:**
  ```json
  { "eRequest": { "action": "create", "data": { "descripcion": "Sin nombre" } } }
  ```
- **Esperado:**
  - success: false
  - message: 'Nombre requerido'

### Caso 3: Listar procesos
- **Entrada:**
  ```json
  { "eRequest": { "action": "list" } }
  ```
- **Esperado:**
  - success: true
  - data: array de procesos

### Caso 4: Obtener proceso por ID existente
- **Entrada:**
  ```json
  { "eRequest": { "action": "get", "data": { "id": 1 } } }
  ```
- **Esperado:**
  - success: true
  - data: proceso con id=1

### Caso 5: Actualizar proceso existente
- **Entrada:**
  ```json
  { "eRequest": { "action": "update", "data": { "id": 1, "nombre": "Nuevo Nombre", "descripcion": "Nueva descripción" } } }
  ```
- **Esperado:**
  - success: true
  - data: proceso actualizado

### Caso 6: Eliminar proceso existente
- **Entrada:**
  ```json
  { "eRequest": { "action": "delete", "data": { "id": 1 } } }
  ```
- **Esperado:**
  - success: true
  - data: proceso eliminado

### Caso 7: Eliminar proceso inexistente
- **Entrada:**
  ```json
  { "eRequest": { "action": "delete", "data": { "id": 9999 } } }
  ```
- **Esperado:**
  - success: true
  - data: null o vacío


