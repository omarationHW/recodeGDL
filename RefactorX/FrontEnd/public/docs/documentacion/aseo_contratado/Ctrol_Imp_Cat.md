# DocumentaciÃ³n TÃ©cnica: Ctrol_Imp_Cat

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Ctrol_Imp_Cat (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la impresión y consulta del catálogo de claves de operación. Permite al usuario seleccionar el orden de impresión (por número de control, clave o descripción) y visualizar una vista previa del reporte.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación y vista previa.
- **Base de Datos:** PostgreSQL, lógica de consulta encapsulada en stored procedure `sp_ctrol_imp_cat_report`.

## 3. API (Laravel Controller)
- **Endpoint:** `/api/execute` (POST)
- **Parámetros:**
  - `action`: string. Acción a ejecutar (`getOptions`, `previewReport`)
  - `params`: objeto. Parámetros adicionales según acción.
- **Acciones soportadas:**
  - `getOptions`: Devuelve las opciones de ordenamiento.
  - `previewReport`: Devuelve el catálogo ordenado según parámetro `order` (1,2,3).
- **Respuesta:**
  - `success`: boolean
  - `data`: array de resultados
  - `message`: string (mensaje de error si aplica)

## 4. Frontend (Vue.js)
- Página independiente `/ctrol-imp-cat`.
- Permite seleccionar el orden de impresión mediante radio buttons.
- Botón "Vista Previa" ejecuta la consulta y muestra los resultados en tabla.
- Botón "Salir" regresa al inicio.
- Manejo de loading y errores.

## 5. Stored Procedure (PostgreSQL)
- `sp_ctrol_imp_cat_report(p_order integer)`
- Devuelve el catálogo de claves de operación ordenado según parámetro.
- Utiliza EXECUTE dynamic SQL para seleccionar el campo de ordenamiento.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel).
- Validar que el parámetro `order` sea 1,2,3 para evitar SQL injection.

## 7. Integración
- El frontend consume el endpoint mediante Axios.
- El backend ejecuta el stored procedure y retorna los datos en formato JSON.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- El stored procedure puede ser extendido para filtros adicionales si se requiere.

## 9. Consideraciones de Migración
- El reporte QuickReport de Delphi se reemplaza por tabla HTML en la vista previa.
- La impresión/exportación puede ser implementada posteriormente usando librerías JS (ej: jsPDF, Excel export).

## 10. Dependencias
- Laravel 9+
- Vue.js 2/3
- PostgreSQL 12+



## Casos de Prueba

# Casos de Prueba: Ctrol_Imp_Cat

## Caso 1: Vista previa por número de control
- **Entrada:**
  - action: previewReport
  - params: { order: 1 }
- **Esperado:**
  - success: true
  - data: array ordenada por ctrol_operacion ascendente

## Caso 2: Vista previa por clave
- **Entrada:**
  - action: previewReport
  - params: { order: 2 }
- **Esperado:**
  - success: true
  - data: array ordenada por cve_operacion ascendente

## Caso 3: Vista previa por descripción
- **Entrada:**
  - action: previewReport
  - params: { order: 3 }
- **Esperado:**
  - success: true
  - data: array ordenada por descripcion ascendente

## Caso 4: Parámetro inválido
- **Entrada:**
  - action: previewReport
  - params: { order: 99 }
- **Esperado:**
  - success: true
  - data: array ordenada por ctrol_operacion ascendente (por defecto)

## Caso 5: Error de conexión a BD
- **Simulación:**
  - Desconectar la base de datos
- **Esperado:**
  - success: false
  - message: Mensaje de error de conexión

## Caso 6: Sin registros
- **Simulación:**
  - Vaciar la tabla ta_16_operacion
- **Esperado:**
  - success: true
  - data: []


## Casos de Uso

# Casos de Uso - Ctrol_Imp_Cat

**Categoría:** Form

## Caso de Uso 1: Vista previa del catálogo ordenado por número de control

**Descripción:** El usuario desea ver el catálogo de claves de operación ordenado por número de control.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo.

**Pasos a seguir:**
1. El usuario accede a la página 'Impresión de Claves de Operación'.
2. Selecciona la opción 'Control' en el grupo de radio.
3. Presiona el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con el catálogo de claves de operación ordenado por el campo 'ctrol_operacion'.

**Datos de prueba:**
No se requiere data específica, pero la tabla ta_16_operacion debe tener registros.

---

## Caso de Uso 2: Vista previa del catálogo ordenado por clave

**Descripción:** El usuario desea ver el catálogo de claves de operación ordenado por clave.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo.

**Pasos a seguir:**
1. El usuario accede a la página 'Impresión de Claves de Operación'.
2. Selecciona la opción 'Clave' en el grupo de radio.
3. Presiona el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con el catálogo de claves de operación ordenado por el campo 'cve_operacion'.

**Datos de prueba:**
No se requiere data específica, pero la tabla ta_16_operacion debe tener registros.

---

## Caso de Uso 3: Manejo de error por parámetro inválido

**Descripción:** El usuario o el frontend envía un parámetro de orden inválido.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El frontend envía una petición con 'order' = 99.
2. El backend ejecuta el stored procedure.

**Resultado esperado:**
El backend retorna el catálogo ordenado por 'ctrol_operacion' (valor por defecto) o un mensaje de error si se implementa validación estricta.

**Datos de prueba:**
order = 99

---



---
**Componente:** `Ctrol_Imp_Cat.vue`
**MÃ³dulo:** `aseo_contratado`

