# DocumentaciÃ³n TÃ©cnica: ABC_Recargos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Catálogo de Recargos (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Seguridad**: Validación de parámetros en backend, manejo de errores y mensajes amigables.

## API Unificada `/api/execute`
- **Método**: POST
- **Body**: `{ action: string, params: object }`
- **Ejemplo**:
  ```json
  {
    "action": "recargos.create",
    "params": {
      "aso_mes_recargo": "2024-06-01",
      "porc_recargo": 2.5,
      "porc_multa": 1.5
    }
  }
  ```
- **Respuesta**: `{ success: bool, message: string, data: any }`

## Stored Procedures
- Toda la lógica de negocio y validación reside en SPs PostgreSQL.
- Los SPs devuelven siempre un resultado estructurado (success, message, data).
- El controlador Laravel solo enruta y valida parámetros básicos.

## Vue.js
- Cada formulario es una página completa (no tabs, no subcomponentes).
- Navegación por rutas, breadcrumbs opcional.
- Tabla principal con selección de fila.
- Modal para alta, baja y cambios.
- Validación básica en frontend, validación estricta en backend.

## Flujo de Operación
1. El usuario accede a la página de Recargos.
2. Se listan todos los recargos (consulta vía `/api/execute` con `recargos.list`).
3. El usuario puede seleccionar un registro y realizar alta, baja o cambios.
4. Cada operación abre un modal con el formulario correspondiente.
5. Al guardar, se envía la petición a `/api/execute` con la acción y parámetros.
6. El backend ejecuta el SP correspondiente y responde con éxito o error.
7. El frontend muestra el mensaje y refresca la tabla si corresponde.

## Validaciones
- No se permite crear dos recargos para el mismo periodo.
- No se puede modificar/eliminar un recargo inexistente.
- Los campos son obligatorios y numéricos donde corresponda.

## Seguridad
- Todas las operaciones pasan por validación de usuario (middleware Laravel, no mostrado aquí).
- Los SPs previenen duplicados y operaciones inválidas.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SPs pueden ser versionados y auditados.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.



## Casos de Prueba

## Casos de Prueba para Catálogo de Recargos

### 1. Alta de Recargo Válido
- **Input:**
  - aso_mes_recargo: '2024-08-01'
  - porc_recargo: 2.0
  - porc_multa: 1.0
- **Acción:** POST /api/execute { action: 'recargos.create', params: {...} }
- **Resultado esperado:** success=true, message='Recargo creado correctamente.'

### 2. Alta de Recargo Duplicado
- **Input:**
  - aso_mes_recargo: '2024-08-01' (ya existe)
  - porc_recargo: 2.5
  - porc_multa: 1.5
- **Acción:** POST /api/execute { action: 'recargos.create', params: {...} }
- **Resultado esperado:** success=false, message='Ya existe un recargo para ese periodo.'

### 3. Modificación de Recargo Existente
- **Input:**
  - aso_mes_recargo: '2024-08-01'
  - porc_recargo: 3.0
  - porc_multa: 2.0
- **Acción:** POST /api/execute { action: 'recargos.update', params: {...} }
- **Resultado esperado:** success=true, message='Recargo actualizado correctamente.'

### 4. Eliminación de Recargo Existente
- **Input:**
  - aso_mes_recargo: '2024-08-01'
- **Acción:** POST /api/execute { action: 'recargos.delete', params: {...} }
- **Resultado esperado:** success=true, message='Recargo eliminado correctamente.'

### 5. Eliminación de Recargo Inexistente
- **Input:**
  - aso_mes_recargo: '2023-01-01' (no existe)
- **Acción:** POST /api/execute { action: 'recargos.delete', params: {...} }
- **Resultado esperado:** success=false, message='No existe el recargo para ese periodo.'


## Casos de Uso

# Casos de Uso - ABC_Recargos

**Categoría:** Form

## Caso de Uso 1: Alta de Recargo para un Nuevo Periodo

**Descripción:** El usuario desea agregar un nuevo recargo para el periodo 2024-07 con 2.5% de recargo y 1.5% de multa.

**Precondiciones:**
No existe un recargo para el periodo 2024-07.

**Pasos a seguir:**
1. El usuario accede a la página de Recargos.
2. Hace clic en 'Alta'.
3. Ingresa '2024-07' como periodo, 2.5 como % recargo y 1.5 como % multa.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
El recargo se agrega correctamente y aparece en la tabla.

**Datos de prueba:**
{ "aso_mes_recargo": "2024-07-01", "porc_recargo": 2.5, "porc_multa": 1.5 }

---

## Caso de Uso 2: Intento de Alta Duplicada

**Descripción:** El usuario intenta agregar un recargo para un periodo que ya existe.

**Precondiciones:**
Ya existe un recargo para el periodo 2024-07.

**Pasos a seguir:**
1. El usuario accede a la página de Recargos.
2. Hace clic en 'Alta'.
3. Ingresa '2024-07' como periodo, 3.0 como % recargo y 2.0 como % multa.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Ya existe un recargo para ese periodo.'

**Datos de prueba:**
{ "aso_mes_recargo": "2024-07-01", "porc_recargo": 3.0, "porc_multa": 2.0 }

---

## Caso de Uso 3: Eliminación de Recargo Existente

**Descripción:** El usuario elimina un recargo existente para el periodo 2024-07.

**Precondiciones:**
Existe un recargo para el periodo 2024-07.

**Pasos a seguir:**
1. El usuario selecciona el recargo de 2024-07 en la tabla.
2. Hace clic en 'Baja'.
3. Confirma la eliminación.

**Resultado esperado:**
El recargo desaparece de la tabla y el sistema muestra 'Recargo eliminado correctamente.'

**Datos de prueba:**
{ "aso_mes_recargo": "2024-07-01" }

---



---
**Componente:** `ABC_Recargos.vue`
**MÃ³dulo:** `aseo_contratado`

