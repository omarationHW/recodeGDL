# RptPadronLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de RptPadronLocales (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (PHP 8+), API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación:** El frontend consume el endpoint `/api/execute` enviando `{ action, params }` y recibe `{ success, data, message }`.

## 2. Flujo de Datos
1. El usuario accede a la página de Padrón de Locales.
2. El componente Vue carga recaudadoras y mercados vía `/api/execute` (`getRecaudadora`, `getMercado`).
3. Al seleccionar y consultar, Vue envía `getPadronLocales` con parámetros.
4. Laravel recibe la petición, despacha al stored procedure correspondiente y retorna los datos.
5. Vue muestra la tabla y totales.

## 3. Backend (Laravel)
- **Controlador:** `RptPadronLocalesController`
  - Método único `execute(Request $request)`.
  - Despacha según `action` a métodos privados que llaman los stored procedures.
  - Maneja errores y retorna respuesta estándar.
- **Seguridad:**
  - Se recomienda proteger el endpoint con autenticación JWT o session según el contexto.
  - Validar parámetros antes de ejecutar SPs.

## 4. Frontend (Vue.js)
- **Componente:** `PadronLocalesPage.vue`
  - Página completa, sin tabs.
  - Formulario para seleccionar recaudadora y mercado.
  - Tabla de resultados con totales calculados en frontend.
  - Manejo de loading y errores.
  - Uso de breadcrumbs para navegación.

## 5. Stored Procedures (PostgreSQL)
- Todos los queries SQL del formulario se encapsulan en SPs.
- Los SPs devuelven tablas con los campos necesarios, incluyendo campos calculados (vigencia, renta, etc).
- Se recomienda usar transacciones sólo donde sea necesario (no para consultas).

## 6. API Unificada
- **Endpoint:** `/api/execute` (POST)
- **Request:**
  ```json
  {
    "action": "getPadronLocales",
    "params": { "oficina": 1, "mercado": 2 }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 7. Validaciones y Seguridad
- Validar que los parámetros requeridos estén presentes antes de llamar SPs.
- Manejar errores de base de datos y retornar mensajes claros.
- Limitar el acceso a usuarios autenticados.

## 8. Extensibilidad
- Para agregar nuevos formularios, crear nuevos SPs y métodos en el controlador.
- El frontend puede agregar nuevas páginas siguiendo el mismo patrón.

## 9. Pruebas
- Se recomienda usar PHPUnit para backend y Cypress/Jest para frontend.
- Los casos de uso y pruebas deben cubrir escenarios de éxito, error y edge cases.

---


## Casos de Uso

# Casos de Uso - RptPadronLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Locales por Recaudadora y Mercado

**Descripción:** El usuario desea consultar el padrón de locales de una recaudadora y un mercado específico.

**Precondiciones:**
El usuario está autenticado y tiene acceso al sistema. Existen recaudadoras y mercados registrados.

**Pasos a seguir:**
[
  "El usuario accede a la página 'Padrón de Locales'.",
  "Selecciona una recaudadora de la lista.",
  "Selecciona un mercado asociado a la recaudadora.",
  "Hace clic en 'Consultar'.",
  "El sistema muestra la tabla de locales con sus datos y totales."
]

**Resultado esperado:**
Se muestra la lista de locales del mercado seleccionado, con totales de superficie y renta.

**Datos de prueba:**
{
  "oficina": 1,
  "mercado": 5
}

---

## Caso de Uso 2: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta consultar el padrón sin seleccionar recaudadora o mercado.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
[
  "El usuario accede a la página 'Padrón de Locales'.",
  "No selecciona recaudadora o mercado.",
  "Hace clic en 'Consultar'."
]

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los parámetros son requeridos.

**Datos de prueba:**
{
  "oficina": null,
  "mercado": null
}

---

## Caso de Uso 3: Cálculo Correcto de Totales

**Descripción:** El sistema debe calcular correctamente el total de superficie y renta de los locales mostrados.

**Precondiciones:**
Existen locales con diferentes superficies y rentas en el mercado consultado.

**Pasos a seguir:**
[
  "El usuario consulta el padrón de un mercado.",
  "El sistema suma la columna 'superficie' y 'renta' de todos los locales mostrados.",
  "Se muestran los totales al pie de la tabla."
]

**Resultado esperado:**
Los totales de superficie y renta coinciden con la suma de los valores individuales.

**Datos de prueba:**
{
  "oficina": 2,
  "mercado": 10
}

---



## Casos de Prueba

# Casos de Prueba para RptPadronLocales

## Caso 1: Consulta exitosa de padrón
- **Input:** oficina=1, mercado=5
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { oficina: 1, mercado: 5 } }
- **Resultado esperado:** success=true, data contiene array de locales, message=''
- **Validar:**
  - El array no está vacío
  - Cada local tiene los campos: id_local, datosmercado, vigdescripcion, renta, etc.

## Caso 2: Parámetros faltantes
- **Input:** oficina=null, mercado=null
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { oficina: null, mercado: null } }
- **Resultado esperado:** success=false, data=null, message contiene 'Parámetros requeridos'

## Caso 3: Totales correctos
- **Input:** oficina=2, mercado=10
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { oficina: 2, mercado: 10 } }
- **Resultado esperado:** success=true, data contiene array de locales
- **Validar:**
  - Sumar superficie y renta de todos los locales y comparar con los totales mostrados en frontend

## Caso 4: Consulta de recaudadora
- **Input:** oficina=1
- **Acción:** POST /api/execute { action: 'getRecaudadora', params: { oficina: 1 } }
- **Resultado esperado:** success=true, data contiene info de recaudadora

## Caso 5: Consulta de mercados
- **Input:** oficina=1
- **Acción:** POST /api/execute { action: 'getMercado', params: { oficina: 1 } }
- **Resultado esperado:** success=true, data contiene array de mercados

## Caso 6: Consulta de renta
- **Input:** axo=2024, categoria=1, seccion='SS', clave_cuota=2
- **Acción:** POST /api/execute { action: 'getRenta', params: { axo:2024, categoria:1, seccion:'SS', clave_cuota:2 } }
- **Resultado esperado:** success=true, data contiene info de cuota



