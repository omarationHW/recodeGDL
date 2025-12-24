# PasoMdos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración PasoMdos (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite migrar los registros de la tabla `cobrotrimestral` (Tianguis) a la tabla de padrón de locales (`ta_11_locales`) en el contexto del Mercado de Abastos (num_mercado=214). La migración verifica si el local ya existe en el padrón antes de insertarlo. El proceso está expuesto como una API RESTful unificada y una interfaz Vue.js.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa, sin tabs, con tabla de datos y acciones
- **Base de Datos:** PostgreSQL, lógica de inserción en stored procedure
- **Seguridad:** Se recomienda proteger el endpoint con autenticación JWT o similar

## Flujo de Datos
1. El usuario accede a la página de migración y carga los datos de Tianguis.
2. El usuario ejecuta la migración, que llama al endpoint `/api/execute` con acción `migrar_tianguis_a_padron`.
3. El backend recorre los registros, verifica existencia en padrón y llama al stored procedure para insertar los nuevos.
4. Se retorna un resumen de errores y registros existentes.

## API
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `action`: string (ej: 'get_tianguis', 'migrar_tianguis_a_padron')
  - `data`: objeto (parámetros adicionales)
- **Salida:**
  - `status`: 'success' | 'error'
  - `message`: string
  - `data`: objeto (según acción)

## Stored Procedure
- **sp_insert_tianguis_padron**: Inserta un registro de Tianguis en el padrón de locales.
- **Validación de existencia**: Se realiza en el controlador antes de llamar al SP.

## Frontend
- Página Vue.js con tabla de Tianguis y botón para migrar.
- Muestra resultado de la migración (errores, existentes).
- No usa tabs ni componentes tabulares.

## Consideraciones
- El proceso es idempotente: no inserta duplicados.
- El usuario debe tener permisos para ejecutar la migración.
- El SP puede ser extendido para registrar logs de auditoría.

## Seguridad
- Se recomienda proteger el endpoint con autenticación y autorización.
- Validar los datos de entrada en el backend.

## Extensibilidad
- El endpoint puede ser extendido para otras acciones relacionadas con el padrón.
- El frontend puede mostrar más detalles o permitir filtros adicionales.


## Casos de Uso

# Casos de Uso - PasoMdos

**Categoría:** Form

## Caso de Uso 1: Migrar todos los registros de Tianguis a Padron

**Descripción:** El usuario desea migrar todos los registros de la tabla cobrotrimestral al padrón de locales del Mercado de Abastos.

**Precondiciones:**
El usuario tiene permisos de administrador y la base de datos contiene registros en cobrotrimestral.

**Pasos a seguir:**
1. El usuario accede a la página PasoMdos.
2. Hace clic en 'Cargar Tianguis' y visualiza la tabla.
3. Hace clic en 'Migrar a Padron'.
4. El sistema ejecuta la migración y muestra el resultado.

**Resultado esperado:**
Todos los registros de Tianguis que no existían en el padrón son insertados. Se muestra el número de errores y existentes.

**Datos de prueba:**
cobrotrimestral: Folio=1001, Nombre='JUAN PEREZ', Domicilio='AV. CENTRAL', Superficie=10.5, Giro='ALIMENTOS', Descuento=0, MotivoDescuento=''

---

## Caso de Uso 2: Intentar migrar cuando todos los registros ya existen

**Descripción:** El usuario ejecuta la migración pero todos los folios ya existen en el padrón.

**Precondiciones:**
Todos los folios de cobrotrimestral ya existen en ta_11_locales.

**Pasos a seguir:**
1. El usuario accede a la página PasoMdos.
2. Hace clic en 'Cargar Tianguis'.
3. Hace clic en 'Migrar a Padron'.

**Resultado esperado:**
No se insertan nuevos registros. El resultado muestra existencias igual al total y errores igual a cero.

**Datos de prueba:**
cobrotrimestral: Folio=1001, ... (ya existe en ta_11_locales)

---

## Caso de Uso 3: Error de inserción por dato inválido

**Descripción:** Un registro de Tianguis tiene un valor inválido (por ejemplo, superficie negativa) y la inserción falla.

**Precondiciones:**
cobrotrimestral contiene un registro con Superficie=-5.

**Pasos a seguir:**
1. El usuario accede a la página PasoMdos.
2. Hace clic en 'Cargar Tianguis'.
3. Hace clic en 'Migrar a Padron'.

**Resultado esperado:**
El registro inválido no se inserta y aparece en la lista de errores con el mensaje correspondiente.

**Datos de prueba:**
cobrotrimestral: Folio=2002, Nombre='ERROR', Superficie=-5

---



## Casos de Prueba

# Casos de Prueba PasoMdos

## 1. Migración exitosa de nuevos registros
- **Preparación:**
  - Insertar en cobrotrimestral: Folio=3001, Nombre='MARIA LOPEZ', Domicilio='CALLE 1', Superficie=12, Giro='ROPA', Descuento=0, MotivoDescuento=''
  - Asegurarse que Folio=3001 no existe en ta_11_locales
- **Ejecución:**
  - Ejecutar acción 'migrar_tianguis_a_padron'
- **Verificación:**
  - El registro aparece en ta_11_locales
  - El resultado muestra errores=0, existentes=0

## 2. Migración con registros existentes
- **Preparación:**
  - Insertar en cobrotrimestral: Folio=4001, ...
  - Insertar en ta_11_locales un registro con local=4001, oficina=1, num_mercado=214, categoria=1, seccion='SS'
- **Ejecución:**
  - Ejecutar acción 'migrar_tianguis_a_padron'
- **Verificación:**
  - El resultado muestra errores=0, existentes=1

## 3. Migración con error de datos
- **Preparación:**
  - Insertar en cobrotrimestral: Folio=5001, Nombre='INVALIDO', Superficie=-10
- **Ejecución:**
  - Ejecutar acción 'migrar_tianguis_a_padron'
- **Verificación:**
  - El resultado muestra errores=1, existentes=0
  - El error indica el folio y el mensaje de error de la base de datos



