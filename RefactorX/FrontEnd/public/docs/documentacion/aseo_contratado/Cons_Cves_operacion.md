# Documentación Técnica: Cons_Cves_operacion

## Análisis

# Documentación Técnica: Migración Formulario Cons_Cves_operacion (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js (SPA, componente de página independiente)
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Seguridad:** Validación de entrada, control de errores, protección contra SQL Injection

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "list|create|update|delete|export_excel",
      "data": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "message": "Mensaje de resultado",
      "data": [ ... ]
    }
  }
  ```

## 3. Controlador Laravel
- **Métodos:**
  - `list`: Devuelve listado de claves de operación, ordenado por campo solicitado
  - `create`: Inserta nueva clave (llama SP)
  - `update`: Actualiza descripción (llama SP)
  - `delete`: Elimina clave si no tiene pagos (llama SP)
  - `export_excel`: (Placeholder, no implementado en API)
- **Validaciones:**
  - Todos los campos requeridos
  - Sanitización de ordenamiento
  - Manejo de errores y mensajes claros

## 4. Componente Vue.js
- **Página independiente** (NO tabs)
- **Funcionalidad:**
  - Listado con orden dinámico
  - Crear, editar, eliminar (modales)
  - Exportar Excel (placeholder)
  - Navegación breadcrumb
  - Mensajes de error y éxito
- **UX:**
  - Botones claros, validación en formulario
  - Modal para crear/editar, confirmación para eliminar

## 5. Stored Procedures PostgreSQL
- **sp16_operacion_create:** Inserta clave, valida unicidad y nulos
- **sp16_operacion_update:** Actualiza descripción por ctrol_operacion
- **sp16_operacion_delete:** Borra clave si no tiene pagos asociados
- **Todos devuelven:** status (0=ok, 1=error), leyenda

## 6. Seguridad
- **API:**
  - Validación de parámetros
  - Sanitización de campos de orden
  - Manejo de errores controlado
- **SP:**
  - Validación de existencia y unicidad
  - Mensajes claros de error

## 7. Integración
- **Frontend** llama a `/api/execute` con acción y datos
- **Backend** enruta a SP correspondiente y retorna resultado
- **Frontend** actualiza UI según respuesta

## 8. Exportación a Excel
- **Nota:**
  - En la API no se implementa exportación real (por seguridad y alcance)
  - Puede implementarse en backend o frontend según requerimiento futuro

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas para ejemplos detallados


## Casos de Uso

# Casos de Uso - Cons_Cves_operacion

**Categoría:** Form

## Caso de Uso 1: Consulta de Claves de Operación ordenadas por Descripción

**Descripción:** El usuario desea ver todas las claves de operación ordenadas alfabéticamente por descripción.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en ta_16_operacion.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Operación.
2. Selecciona 'Descripción' en el combo de clasificación.
3. El sistema envía eRequest con action 'list' y data.order='descripcion'.
4. El backend responde con el listado ordenado.

**Resultado esperado:**
Se muestra la tabla de claves de operación ordenada alfabéticamente por descripción.

**Datos de prueba:**
Registros de ejemplo: {ctrol_operacion:1, cve_operacion:'A', descripcion:'Cuota Normal'}, {ctrol_operacion:2, cve_operacion:'E', descripcion:'Excedente'}

---

## Caso de Uso 2: Alta de Nueva Clave de Operación

**Descripción:** El usuario desea agregar una nueva clave de operación.

**Precondiciones:**
El usuario tiene permisos de alta. La clave y descripción no existen.

**Pasos a seguir:**
1. El usuario hace clic en 'Nuevo'.
2. Llena los campos: Clave='D', Descripción='Contenedores'.
3. Hace clic en 'Guardar'.
4. El frontend envía eRequest con action 'create' y los datos.
5. El backend ejecuta el SP y responde.

**Resultado esperado:**
La clave se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{cve_operacion:'D', descripcion:'Contenedores'}

---

## Caso de Uso 3: Intento de Borrar Clave con Pagos Asociados

**Descripción:** El usuario intenta eliminar una clave de operación que tiene pagos asociados.

**Precondiciones:**
Existe una clave con ctrol_operacion=1 y hay registros en ta_16_pagos con ctrol_operacion=1.

**Pasos a seguir:**
1. El usuario hace clic en 'Eliminar' sobre la clave.
2. Confirma la eliminación.
3. El frontend envía eRequest con action 'delete' y ctrol_operacion=1.
4. El backend ejecuta el SP y detecta pagos asociados.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'EXISTEN PAGOS CON ESTA CLAVE DE OPERACION, NO SE PUEDE BORRAR.'

**Datos de prueba:**
{ctrol_operacion:1}

---



## Casos de Prueba

# Casos de Prueba para Cons_Cves_operacion

| # | Acción | Entrada | Resultado Esperado |
|---|--------|---------|--------------------|
| 1 | Listar claves por Control | {action:'list', data:{order:'ctrol_operacion'}} | Lista ordenada por ctrol_operacion |
| 2 | Listar claves por Descripción | {action:'list', data:{order:'descripcion'}} | Lista ordenada por descripcion |
| 3 | Alta clave válida | {action:'create', data:{cve_operacion:'Z', descripcion:'Prueba'}} | status:success, mensaje de éxito |
| 4 | Alta clave duplicada | {action:'create', data:{cve_operacion:'A', descripcion:'Cuota Normal'}} | status:error, mensaje de duplicidad |
| 5 | Editar descripción | {action:'update', data:{ctrol_operacion:2, descripcion:'Nuevo Desc'}} | status:success, mensaje de éxito |
| 6 | Eliminar clave sin pagos | {action:'delete', data:{ctrol_operacion:99}} | status:success, mensaje de éxito |
| 7 | Eliminar clave con pagos | {action:'delete', data:{ctrol_operacion:1}} | status:error, mensaje de error |
| 8 | Exportar Excel | {action:'export_excel'} | status:success, mensaje placeholder |
| 9 | Acción inválida | {action:'foo'} | status:error, mensaje de acción no soportada |


