# Documentación Técnica: Mannto_Empresas

## Análisis

# Documentación Técnica: Migración de Formulario Mannto_Empresas (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Comunicación:** JSON, autenticación recomendada vía JWT (no incluida aquí)

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "empresas.create", // o empresas.update, empresas.delete, empresas.list, empresas.get
    "payload": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "Mensaje de resultado",
    "data": { ... }
  }
  ```

## Controlador Laravel
- Un solo método `execute()` que despacha según el campo `action`.
- Valida datos de entrada según la acción.
- Llama a los stored procedures de PostgreSQL usando DB::select.
- Devuelve respuesta estándar eRequest/eResponse.

## Stored Procedures PostgreSQL
- Toda la lógica de negocio (altas, bajas, cambios, validaciones) está en SPs.
- Ejemplo: `sp_empresas_create` valida unicidad, calcula el siguiente número, inserta y retorna mensaje.
- `sp_empresas_delete` verifica que no existan contratos asociados antes de eliminar.
- Todos los SPs devuelven un registro con `success` y `message`.

## Componente Vue.js
- Página independiente `/empresas`.
- Formulario para alta, baja, cambio (modo controlado por variable `mode`).
- Listado de empresas con acciones de editar/eliminar.
- Llama a `/api/execute` con la acción y payload correspondiente.
- Muestra mensajes de éxito/error.
- Usa Bootstrap para estilos (puede adaptarse a cualquier framework CSS).

## Seguridad
- Validación de datos en backend y frontend.
- Eliminar sólo si no hay contratos asociados.
- No se expone SQL directo al frontend.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los SPs pueden ser versionados y auditados.

## Integración
- El endpoint `/api/execute` puede ser consumido por cualquier cliente (SPA, móvil, etc).
- El frontend Vue.js puede ser integrado en cualquier SPA o como microfrontend.

## Consideraciones
- El número de empresa es autoincremental por tipo (`ctrol_emp`).
- El listado de tipos de empresa se obtiene de la tabla `ta_16_tipos_emp`.
- El formulario es completamente funcional y desacoplado de otros módulos.

## Migración de lógica Delphi
- Todas las validaciones y flujos (altas, bajas, cambios, consulta) están implementados en los SPs y el controlador.
- El frontend replica la experiencia de usuario del formulario original, pero en SPA.

## Pruebas
- Casos de uso y pruebas incluidas para validar todos los flujos principales.


## Casos de Uso

# Casos de Uso - Mannto_Empresas

**Categoría:** Form

## Caso de Uso 1: Alta de Empresa Nueva

**Descripción:** El usuario desea registrar una nueva empresa privada en el sistema.

**Precondiciones:**
El usuario tiene permisos de alta. El tipo de empresa existe.

**Pasos a seguir:**
1. El usuario accede a la página de Empresas.
2. Selecciona el tipo de empresa (por ejemplo, 'Privada').
3. Ingresa el nombre/razón social y el representante.
4. Presiona 'Crear'.

**Resultado esperado:**
La empresa se registra correctamente, aparece en el listado y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "ctrol_emp": 9,
  "descripcion": "EMPRESA DE PRUEBA S.A. DE C.V.",
  "representante": "JUAN PEREZ"
}

---

## Caso de Uso 2: Modificación de Empresa Existente

**Descripción:** El usuario necesita actualizar el nombre y representante de una empresa existente.

**Precondiciones:**
La empresa existe y no está eliminada.

**Pasos a seguir:**
1. El usuario busca la empresa en el listado.
2. Presiona 'Editar'.
3. Modifica el nombre y/o representante.
4. Presiona 'Actualizar'.

**Resultado esperado:**
Los datos de la empresa se actualizan y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "num_empresa": 10,
  "ctrol_emp": 9,
  "descripcion": "EMPRESA MODIFICADA S.A. DE C.V.",
  "representante": "MARIA LOPEZ"
}

---

## Caso de Uso 3: Eliminación de Empresa sin Contratos

**Descripción:** El usuario desea eliminar una empresa que no tiene contratos asociados.

**Precondiciones:**
La empresa existe y no tiene contratos asociados.

**Pasos a seguir:**
1. El usuario localiza la empresa en el listado.
2. Presiona 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La empresa se elimina del sistema y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "num_empresa": 11,
  "ctrol_emp": 9
}

---



## Casos de Prueba

## Casos de Prueba para Empresas

### 1. Alta de Empresa Correcta
- **Entrada:**
  - ctrol_emp: 9
  - descripcion: "EMPRESA DE PRUEBA S.A. DE C.V."
  - representante: "JUAN PEREZ"
- **Acción:** empresas.create
- **Esperado:** success=true, message='Empresa creada correctamente', data.num_empresa > 0

### 2. Alta de Empresa Duplicada
- **Entrada:**
  - ctrol_emp: 9
  - descripcion: "EMPRESA DE PRUEBA S.A. DE C.V."
  - representante: "JUAN PEREZ"
- **Acción:** empresas.create (con datos ya existentes)
- **Esperado:** success=false, message contiene 'Ya existe'

### 3. Modificación de Empresa
- **Entrada:**
  - num_empresa: 10
  - ctrol_emp: 9
  - descripcion: "EMPRESA MODIFICADA S.A. DE C.V."
  - representante: "MARIA LOPEZ"
- **Acción:** empresas.update
- **Esperado:** success=true, message='Empresa actualizada correctamente'

### 4. Eliminación de Empresa con Contratos
- **Entrada:**
  - num_empresa: 12
  - ctrol_emp: 9
- **Acción:** empresas.delete
- **Precondición:** La empresa tiene contratos asociados
- **Esperado:** success=false, message contiene 'No se puede eliminar'

### 5. Eliminación de Empresa sin Contratos
- **Entrada:**
  - num_empresa: 11
  - ctrol_emp: 9
- **Acción:** empresas.delete
- **Precondición:** La empresa NO tiene contratos asociados
- **Esperado:** success=true, message='Empresa eliminada correctamente'

### 6. Listado de Empresas
- **Acción:** empresas.list
- **Esperado:** success=true, data es array de empresas

### 7. Consulta de Empresa por ID
- **Entrada:**
  - num_empresa: 10
  - ctrol_emp: 9
- **Acción:** empresas.get
- **Esperado:** success=true, data contiene la empresa solicitada


