# Documentación: autdescto

## Análisis Técnico

# Documentación Técnica: Migración de Formulario autdescto (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 (SPA), componente de página independiente para autdescto.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (action, params).

## 2. Endpoints y Flujo
- **POST /api/execute**
  - Entrada: `{ action: string, params: object }`
  - Salida: `{ status: string, data: any, message: string }`
  - Acciones soportadas:
    - `list`: Listar descuentos de una cuenta
    - `create`: Crear descuento
    - `update`: Actualizar descuento
    - `cancel`: Cancelar descuento
    - `reactivate`: Reactivar descuento
    - `catalogs`: Catálogos de tipos de descuento e instituciones

## 3. Seguridad
- Autenticación JWT/Sanctum (Laravel)
- Validación de permisos por usuario (en el controller)
- Validación de datos en backend y frontend

## 4. Stored Procedures
- Toda la lógica de negocio (validaciones, folios, duplicidad, etc.) está en SPs de PostgreSQL.
- Los SPs devuelven mensajes claros y status.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario de alta/edición de descuento.
- Tabla de descuentos con acciones (editar, cancelar, reactivar).
- Uso de breadcrumbs para navegación.
- Validación de campos obligatorios y reglas de negocio.
- Mensajes de éxito/error claros.

## 6. Backend (Laravel)
- Controlador único `AutDesctoController`.
- Métodos para cada acción, todos usan SPs.
- Validación de entrada con Laravel Validator.
- Manejo de errores y mensajes amigables.

## 7. Base de Datos
- Tabla principal: `descpred` (ver estructura migrada de Delphi)
- Catálogos: `c_descpred`, `c_instituciones`
- Folios: calculados por SP según recaudadora

## 8. Pruebas y Casos de Uso
- Casos de uso y pruebas incluidas para alta, edición, cancelación, reactivación y validaciones.

## 9. Consideraciones
- El endpoint `/api/execute` es genérico y puede ser extendido para otros formularios.
- El frontend puede ser adaptado fácilmente a otros módulos siguiendo el mismo patrón.
- Los SPs pueden ser versionados y auditados en la base de datos.

## 10. Ejemplo de eRequest/eResponse
```json
{
  "action": "create",
  "params": {
    "cvecuenta": 12345,
    "cvedescuento": 1,
    "bimini": 1,
    "bimfin": 6,
    "solicitante": "Juan Perez",
    "observaciones": "Descuento por adulto mayor",
    "institucion": 2,
    "identificacion": "INE 123456",
    "fecnac": "1950-01-01"
  }
}
```

## 11. Mensajes de Error
- Todos los errores de validación y negocio se devuelven en el campo `message` del eResponse.

## 12. Extensibilidad
- El patrón permite agregar más acciones y módulos sin romper la API ni el frontend.

## Casos de Uso

# Casos de Uso - autdescto

**Categoría:** Form

## Caso de Uso 1: Alta de Descuento Predial

**Descripción:** El usuario desea registrar un nuevo descuento de predial para una cuenta específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos para crear descuentos.

**Pasos a seguir:**
[
  "El usuario accede a la página de Autorización de Descuentos Predial.",
  "Llena el formulario con los datos requeridos (cuenta, tipo de descuento, bimestre inicial/final, solicitante, etc).",
  "Presiona el botón 'Guardar'.",
  "El sistema valida que no exista un descuento vigente para ese periodo.",
  "El sistema genera el folio y almacena el registro.",
  "El sistema muestra el nuevo descuento en la tabla."
]

**Resultado esperado:**
El descuento es creado y visible en la tabla de descuentos.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "cvedescuento": 1,
  "bimini": 1,
  "bimfin": 6,
  "solicitante": "Juan Perez",
  "observaciones": "Descuento por adulto mayor",
  "institucion": 2,
  "identificacion": "INE 123456",
  "fecnac": "1950-01-01"
}

---

## Caso de Uso 2: Cancelación de Descuento

**Descripción:** El usuario necesita cancelar un descuento vigente.

**Precondiciones:**
El descuento está vigente y el usuario tiene permisos.

**Pasos a seguir:**
[
  "El usuario localiza el descuento en la tabla.",
  "Presiona el botón 'Cancelar'.",
  "Confirma la acción.",
  "El sistema marca el descuento como cancelado, registra la fecha y usuario.",
  "El descuento aparece como 'Cancelado' en la tabla."
]

**Resultado esperado:**
El descuento queda cancelado y no puede ser editado.

**Datos de prueba:**
{
  "id": 101,
  "motivo": "Error en datos del solicitante"
}

---

## Caso de Uso 3: Reactivación de Descuento Cancelado

**Descripción:** El usuario requiere reactivar un descuento previamente cancelado.

**Precondiciones:**
El descuento está cancelado y el usuario tiene permisos.

**Pasos a seguir:**
[
  "El usuario localiza el descuento cancelado en la tabla.",
  "Presiona el botón 'Reactivar'.",
  "Confirma la acción.",
  "El sistema reactiva el descuento, borra la fecha de baja y usuario.",
  "El descuento aparece como 'Vigente' en la tabla."
]

**Resultado esperado:**
El descuento vuelve a estar vigente y editable.

**Datos de prueba:**
{
  "id": 101
}

---

## Casos de Prueba

## Casos de Prueba para Autorización de Descuentos Predial

### 1. Alta de Descuento Correcto
- **Entrada:** Todos los campos obligatorios llenos, bimestre inicial <= final, sin traslape de periodos.
- **Acción:** create
- **Resultado esperado:** status=ok, mensaje 'Descuento creado correctamente', registro visible en tabla.

### 2. Alta con Bimestre Inicial Mayor que Final
- **Entrada:** bimini=6, bimfin=1
- **Acción:** create
- **Resultado esperado:** status=error, mensaje 'Error en el rango de bimestres'.

### 3. Alta con Traslape de Periodos
- **Entrada:** Ya existe descuento vigente para bimini=1, bimfin=6. Se intenta crear otro para bimini=3, bimfin=4.
- **Acción:** create
- **Resultado esperado:** status=error, mensaje 'Ya existe un descuento vigente sobre este periodo'.

### 4. Cancelación de Descuento Vigente
- **Entrada:** id de descuento vigente
- **Acción:** cancel
- **Resultado esperado:** status=ok, mensaje 'Descuento cancelado correctamente', status='C' en tabla.

### 5. Reactivación de Descuento Cancelado
- **Entrada:** id de descuento cancelado
- **Acción:** reactivate
- **Resultado esperado:** status=ok, mensaje 'Descuento reactivado correctamente', status='V' en tabla.

### 6. Edición de Descuento
- **Entrada:** id de descuento vigente, nuevos datos válidos
- **Acción:** update
- **Resultado esperado:** status=ok, mensaje 'Descuento actualizado correctamente', datos actualizados en tabla.

### 7. Catálogos
- **Entrada:** acción catalogs
- **Acción:** catalogs
- **Resultado esperado:** status=ok, data con descTypes e institutions.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

