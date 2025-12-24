# DocumentaciÃ³n TÃ©cnica: ActCont_CR

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario ActCont_CR (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "Actualiza Contratos en Cantidad de Recolección" (ActCont_CR) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite consultar contratos de recolección filtrados por tipo de aseo.

## 2. Arquitectura
- **Frontend**: Componente Vue.js como página independiente, con selección de tipo de aseo y tabla de resultados.
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` que recibe un `eRequest` y parámetros, y responde con `eResponse`.
- **Base de Datos**: PostgreSQL, con lógica encapsulada en stored procedures (funciones).

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "get_ta_catalog",
    "params": {}
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre**: `get_ta_catalog`
- **Tipo**: CATALOG
- **Función**: Devuelve todos los registros de la tabla `ta`.
- **Uso**: El controlador Laravel ejecuta esta función para obtener los datos requeridos.

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Selector de tipo de aseo (con valores: 9, 8, 4).
- Botón para consultar contratos.
- Tabla de resultados filtrada por el tipo de aseo seleccionado.
- Mensajes de carga, error y vacío.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse según las políticas de autenticación de la aplicación.
- Validar el valor de `eRequest` y los parámetros recibidos.

## 7. Extensibilidad
- Para agregar nuevas operaciones, implementar nuevos stored procedures y ampliar el switch-case en el controlador.

## 8. Notas
- La estructura de la tabla `ta` debe ajustarse según el modelo real de datos.
- El filtrado por tipo de aseo se realiza en frontend, pero puede optimizarse agregando un parámetro al stored procedure si se requiere.


## Casos de Prueba

# Casos de Prueba: Formulario ActCont_CR

| ID | Descripción | Precondiciones | Pasos | Resultado Esperado |
|----|-------------|----------------|-------|-------------------|
| TC01 | Consulta contratos Zona Centro | Existen contratos con tipo_aseo=9 | 1. Acceder a la página. 2. Seleccionar '9 .- Zona Centro'. 3. Consultar. | Se muestran los contratos con tipo_aseo=9. |
| TC02 | Consulta contratos Ordinarios | Existen contratos con tipo_aseo=8 | 1. Acceder a la página. 2. Seleccionar '8 .- Ordinarios'. 3. Consultar. | Se muestran los contratos con tipo_aseo=8. |
| TC03 | Consulta contratos Hospitalarios sin resultados | No existen contratos con tipo_aseo=4 | 1. Acceder a la página. 2. Seleccionar '4 .- Hospitalarios'. 3. Consultar. | Se muestra mensaje de 'No se encontraron contratos'. |
| TC04 | Error de conexión API | API no disponible | 1. Acceder a la página. 2. Seleccionar cualquier tipo. 3. Consultar. | Se muestra mensaje de error de red. |
| TC05 | Validación de selección obligatoria | No seleccionar tipo de aseo | 1. Acceder a la página. 2. Intentar consultar sin seleccionar tipo. | El formulario no permite enviar y muestra validación. |


## Casos de Uso

# Casos de Uso - ActCont_CR

**Categoría:** Form

## Caso de Uso 1: Consulta de contratos por tipo de aseo: Zona Centro

**Descripción:** El usuario desea ver todos los contratos de recolección correspondientes al tipo 'Zona Centro' (valor 9).

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen contratos con tipo_aseo = 9 en la tabla ta.

**Pasos a seguir:**
1. El usuario accede a la página 'Actualiza Contratos en Cantidad de Recolección'.
2. Selecciona '9 .- Zona Centro' en el selector de tipo de aseo.
3. Presiona el botón 'Consultar Contratos'.
4. El sistema consulta la API y muestra los contratos filtrados.

**Resultado esperado:**
Se muestra una tabla con todos los contratos cuyo tipo de aseo es 9.

**Datos de prueba:**
En la tabla ta, existen registros con tipo_aseo = 9.

---

## Caso de Uso 2: Consulta de contratos por tipo de aseo: Ordinarios

**Descripción:** El usuario consulta los contratos de tipo 'Ordinarios' (valor 8).

**Precondiciones:**
El usuario tiene acceso y existen contratos con tipo_aseo = 8.

**Pasos a seguir:**
1. Acceder a la página.
2. Seleccionar '8 .- Ordinarios'.
3. Hacer clic en 'Consultar Contratos'.

**Resultado esperado:**
Se listan los contratos con tipo_aseo = 8.

**Datos de prueba:**
En la tabla ta, existen registros con tipo_aseo = 8.

---

## Caso de Uso 3: Consulta sin resultados para tipo de aseo: Hospitalarios

**Descripción:** El usuario consulta contratos para 'Hospitalarios' (valor 4), pero no existen registros.

**Precondiciones:**
No existen contratos con tipo_aseo = 4 en la tabla ta.

**Pasos a seguir:**
1. Acceder a la página.
2. Seleccionar '4 .- Hospitalarios'.
3. Hacer clic en 'Consultar Contratos'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron contratos.

**Datos de prueba:**
La tabla ta no contiene registros con tipo_aseo = 4.

---



---
**Componente:** `ActCont_CR.vue`
**MÃ³dulo:** `aseo_contratado`

