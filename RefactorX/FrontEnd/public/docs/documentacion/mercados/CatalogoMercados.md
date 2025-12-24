# CatalogoMercados

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Catálogo de Mercados (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Seguridad:** Autenticación Laravel Sanctum/JWT, validación de datos en backend y frontend

## API Unificada `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "list|create|update|delete|report",
    "module": "catalogo_mercados",
    "payload": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": "..."
  }
  ```

## Controlador Laravel
- Un solo método `execute(Request $request)`
- Despacha la acción según el campo `action` y ejecuta el stored procedure correspondiente
- Valida los datos antes de llamar al SP
- Devuelve siempre JSON

## Componente Vue.js
- Página independiente `/catalogo-mercados`
- Tabla con todos los mercados
- Botón para agregar, editar, eliminar, y ver reporte
- Formulario modal para alta/modificación
- Mensajes de error y éxito
- Llama a `/api/execute` con el action adecuado

## Stored Procedures PostgreSQL
- Toda la lógica de CRUD y reportes está en SPs
- Los SPs devuelven siempre un TABLE o un mensaje de resultado
- Validaciones de integridad y errores se manejan en el SP y en el controlador

## Seguridad y Validación
- El backend valida todos los campos requeridos
- El frontend también valida antes de enviar
- El endpoint requiere autenticación

## Navegación
- Breadcrumbs para contexto
- Cada formulario es una página, no hay tabs

## Reportes
- El reporte se obtiene vía SP y se muestra en una tabla modal
- Puede exportarse a Excel/CSV desde el frontend si se requiere

## Errores y Mensajes
- Todos los errores se devuelven en el campo `message` del JSON
- El frontend muestra los mensajes en alertas

## Extensibilidad
- El patrón eRequest/eResponse permite agregar más módulos y acciones fácilmente
- Los SPs pueden ser versionados y auditados

## Pruebas
- Casos de uso y pruebas detalladas incluidas abajo


## Casos de Uso

# Casos de Uso - CatalogoMercados

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Mercado

**Descripción:** El usuario desea agregar un nuevo mercado al catálogo.

**Precondiciones:**
El usuario está autenticado y tiene permisos de administrador.

**Pasos a seguir:**
- El usuario ingresa a la página Catálogo de Mercados.
- Hace clic en 'Agregar Mercado'.
- Llena el formulario con los datos requeridos (oficina, número de mercado, categoría, descripción, cuentas, zona, tipo emisión).
- Hace clic en 'Guardar'.
- El sistema valida y envía la petición a `/api/execute` con action 'create'.

**Resultado esperado:**
El mercado se agrega correctamente y aparece en la tabla. Se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado_nvo": 10,
  "categoria": 1,
  "descripcion": "Mercado San Juan",
  "cuenta_ingreso": 44501,
  "cuenta_energia": 44119,
  "id_zona": 3,
  "tipo_emision": "M"
}

---

## Caso de Uso 2: Modificación de un Mercado existente

**Descripción:** El usuario edita la descripción y cuenta de ingreso de un mercado.

**Precondiciones:**
El mercado existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
- El usuario selecciona un mercado de la tabla y hace clic en 'Editar'.
- Cambia la descripción y la cuenta de ingreso.
- Hace clic en 'Guardar'.
- El sistema valida y envía la petición a `/api/execute` con action 'update'.

**Resultado esperado:**
El mercado se actualiza correctamente y los cambios se reflejan en la tabla.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado_nvo": 10,
  "categoria": 1,
  "descripcion": "Mercado San Juan Renovado",
  "cuenta_ingreso": 44502,
  "cuenta_energia": 44119,
  "id_zona": 3,
  "tipo_emision": "M"
}

---

## Caso de Uso 3: Eliminación de un Mercado

**Descripción:** El usuario elimina un mercado del catálogo.

**Precondiciones:**
El mercado existe y el usuario tiene permisos de eliminación.

**Pasos a seguir:**
- El usuario hace clic en 'Eliminar' en la fila correspondiente.
- Confirma la eliminación.
- El sistema envía la petición a `/api/execute` con action 'delete'.

**Resultado esperado:**
El mercado se elimina de la base de datos y desaparece de la tabla.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado_nvo": 10
}

---



## Casos de Prueba

## Casos de Prueba para Catálogo de Mercados

### 1. Alta de Mercado - Datos Correctos
- **Entrada:** Todos los campos obligatorios llenos y válidos
- **Acción:** Enviar action 'create' con datos válidos
- **Esperado:** Respuesta success=true, el mercado aparece en la lista

### 2. Alta de Mercado - Campo Requerido Faltante
- **Entrada:** Falta 'descripcion'
- **Acción:** Enviar action 'create' sin descripción
- **Esperado:** Respuesta success=false, message indica campo requerido

### 3. Modificación de Mercado - Cambio de Descripción
- **Entrada:** Mercado existente, nueva descripción
- **Acción:** Enviar action 'update' con nueva descripción
- **Esperado:** Respuesta success=true, la descripción se actualiza

### 4. Eliminación de Mercado
- **Entrada:** Oficina y número de mercado válidos
- **Acción:** Enviar action 'delete'
- **Esperado:** Respuesta success=true, el mercado ya no aparece en la lista

### 5. Reporte de Mercados
- **Entrada:** action 'report', oficina=null
- **Acción:** Enviar petición
- **Esperado:** Respuesta success=true, data contiene todos los mercados

### 6. Error de Integridad
- **Entrada:** Crear mercado con oficina/núm. mercado duplicados
- **Acción:** Enviar action 'create' con datos ya existentes
- **Esperado:** Respuesta success=false, message de error de duplicidad

### 7. Seguridad - Usuario no autenticado
- **Entrada:** No autenticado
- **Acción:** Cualquier acción
- **Esperado:** HTTP 401 Unauthorized



