# Documentación: descpredfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario Descuentos Predial (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 3 SPA (Single Page Application)
- **API:** Unificada, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Stored Procedures:** Toda la lógica SQL y reglas de negocio en PostgreSQL
- **Autenticación:** JWT o sesión Laravel (no incluido aquí)

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "list|get|create|update|delete|reactivate|catalogs",
    "params": { ... },
    "user": "usuario_actual"
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success|error",
    "data": { ... },
    "message": "..."
  }
  ```

## 3. Controlador Laravel
- Un solo método `execute` que enruta la acción a los métodos privados.
- Cada método llama a un stored procedure y retorna el resultado.
- Validación de parámetros con `Validator`.
- Manejo de errores y mensajes amigables.

## 4. Stored Procedures PostgreSQL
- Toda la lógica de negocio y validación de reglas críticas se implementa en SPs.
- Los SPs devuelven siempre un registro (o tabla) para facilitar el consumo desde Laravel.
- Ejemplo de SPs: `sp_descpred_list`, `sp_descpred_create`, `sp_descpred_update`, etc.

## 5. Frontend Vue.js
- **Página principal:** Listado de descuentos, acciones de alta, edición, baja, reactivación.
- **Cada formulario (alta, edición, baja, reactivación, detalle):** Página independiente (NO tabs).
- **Navegación:** Breadcrumbs y rutas dedicadas.
- **Consumo de API:** Axios, siempre usando `/api/execute`.
- **Catálogos:** Se cargan al inicio y se mantienen en memoria.
- **Validación:** Frontend y backend.

## 6. Seguridad y Auditoría
- El usuario que realiza la acción se pasa siempre como parámetro a los SPs.
- Los SPs registran usuario y fecha de alta/baja/modificación.

## 7. Consideraciones de Migración
- Los triggers y lógica de negocio crítica (validaciones de reglas, fechas, etc.) deben estar en los SPs.
- El frontend sólo muestra/oculta acciones según el estado (`status`) del descuento.
- El backend es responsable de validar reglas de negocio (no permitir duplicados, etc.).

## 8. Ejemplo de Flujo
1. El usuario entra a `/descuentos-predial` y ve el listado.
2. Puede dar de alta un nuevo descuento (formulario independiente).
3. Puede editar, dar de baja o reactivar descuentos según el estado.
4. Todas las acciones se ejecutan vía `/api/execute`.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint.
- Los SPs pueden evolucionar sin afectar el frontend.

## 10. Pruebas y QA
- Los casos de uso y pruebas deben cubrir todos los flujos: alta, edición, baja, reactivación, errores, validaciones, etc.

---

## Casos de Uso

# Casos de Uso - descpredfrm

**Categoría:** Form

## Caso de Uso 1: Alta de Descuento Predial

**Descripción:** Un usuario autorizado da de alta un nuevo descuento de predial para una cuenta específica.

**Precondiciones:**
El usuario tiene permisos y la cuenta no tiene un descuento vigente para el mismo periodo.

**Pasos a seguir:**
1. El usuario accede a la página de alta de descuento.
2. Llena los campos requeridos (cuenta, tipo, bimestres, solicitante, identificación, fecha de nacimiento, institución, porcentaje, observaciones).
3. Envía el formulario.
4. El frontend envía un eRequest con action 'create' a /api/execute.
5. El backend ejecuta el SP correspondiente y retorna el resultado.

**Resultado esperado:**
El descuento se crea correctamente y aparece en el listado como 'Vigente'.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "cvedescuento": 2,
  "bimini": 1,
  "bimfin": 6,
  "solicitante": "Juan Perez",
  "identificacion": "INE123456",
  "fecnac": "1980-05-10",
  "institucion": 1,
  "observaciones": "Descuento por adulto mayor",
  "porcentaje": 50
}

---

## Caso de Uso 2: Baja (Cancelación) de Descuento Predial

**Descripción:** Un usuario autorizado da de baja un descuento vigente, registrando el motivo.

**Precondiciones:**
El descuento está vigente y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario accede a la página de detalle del descuento.
2. Selecciona la opción 'Baja'.
3. Ingresa el motivo de la baja.
4. Confirma la acción.
5. El frontend envía un eRequest con action 'delete' a /api/execute.
6. El backend ejecuta el SP correspondiente y retorna el resultado.

**Resultado esperado:**
El descuento cambia a estado 'Cancelado' y se registra el motivo en observaciones.

**Datos de prueba:**
{
  "id": 1001,
  "motivo": "El beneficiario ya no cumple requisitos"
}

---

## Caso de Uso 3: Reactivación de Descuento Predial

**Descripción:** Un usuario autorizado reactiva un descuento previamente cancelado.

**Precondiciones:**
El descuento está en estado 'Cancelado' y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario accede a la página de detalle del descuento cancelado.
2. Selecciona la opción 'Reactivar'.
3. Confirma la acción.
4. El frontend envía un eRequest con action 'reactivate' a /api/execute.
5. El backend ejecuta el SP correspondiente y retorna el resultado.

**Resultado esperado:**
El descuento cambia a estado 'Vigente' y puede ser aplicado nuevamente.

**Datos de prueba:**
{
  "id": 1001
}

---

## Casos de Prueba

## Casos de Prueba para Descuentos Predial

### 1. Alta de Descuento Correcta
- **Entrada:** Datos válidos, cuenta sin descuento vigente.
- **Acción:** create
- **Resultado esperado:** status=success, descuento creado, estado=Vigente.

### 2. Alta de Descuento Duplicado
- **Entrada:** Datos válidos, pero ya existe descuento vigente para el mismo periodo.
- **Acción:** create
- **Resultado esperado:** status=error, mensaje de duplicidad.

### 3. Baja de Descuento
- **Entrada:** ID de descuento vigente, motivo.
- **Acción:** delete
- **Resultado esperado:** status=success, estado=Cancelado, motivo registrado.

### 4. Reactivación de Descuento
- **Entrada:** ID de descuento cancelado.
- **Acción:** reactivate
- **Resultado esperado:** status=success, estado=Vigente.

### 5. Edición de Descuento
- **Entrada:** ID de descuento vigente, nuevos datos válidos.
- **Acción:** update
- **Resultado esperado:** status=success, datos actualizados.

### 6. Consulta de Catálogos
- **Entrada:** action=catalogs
- **Resultado esperado:** status=success, catálogos de tipos e instituciones.

### 7. Listado de Descuentos
- **Entrada:** action=list, cvecuenta existente
- **Resultado esperado:** status=success, array de descuentos.

### 8. Consulta de Descuento por ID
- **Entrada:** action=get, id existente
- **Resultado esperado:** status=success, datos del descuento.

### 9. Baja de Descuento ya Cancelado
- **Entrada:** ID de descuento ya cancelado
- **Acción:** delete
- **Resultado esperado:** status=error, mensaje de que ya está cancelado.

### 10. Alta con datos incompletos
- **Entrada:** Faltan campos requeridos
- **Acción:** create
- **Resultado esperado:** status=error, mensaje de validación.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

