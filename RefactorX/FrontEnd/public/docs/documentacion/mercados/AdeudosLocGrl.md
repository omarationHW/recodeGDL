# AdeudosLocGrl

## AnÃ¡lisis TÃ©cnico

# AdeudosLocGrl - Migración Delphi a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite consultar y exportar el reporte de adeudos generales de locales de mercados, filtrando por recaudadora, mercado, año y mes. Incluye la obtención de recaudadoras, mercados, y la consulta principal de adeudos, así como la exportación a Excel (a implementar).

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y tabla de resultados.
- **Base de Datos:** Toda la lógica SQL se implementa en stored procedures PostgreSQL.

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "getAdeudosLocalesGrl",
    "params": {
      "id_rec": 1,
      "num_mercado": 5,
      "axo": 2024,
      "mes": 6
    }
  }
  ```
- **Acciones soportadas:**
  - `getRecaudadoras`: Lista recaudadoras
  - `getMercadosByRecaudadora`: Lista mercados por recaudadora
  - `getAdeudosLocalesGrl`: Consulta principal de adeudos
  - `exportExcel`: (A implementar)

## Stored Procedure Principal
- `sp_adeudos_loc_grl(id_rec, num_mercado, axo, mes)`
- Devuelve todos los campos requeridos para el reporte, incluyendo cálculo de meses y folios de requerimientos.

## Flujo de la Página Vue.js
1. Al cargar, obtiene recaudadoras.
2. Al seleccionar recaudadora, obtiene mercados.
3. El usuario selecciona año y mes, y ejecuta la búsqueda.
4. Se muestra la tabla de resultados.
5. Opción de exportar a Excel (alerta si no implementado).

## Validaciones
- No permite buscar sin seleccionar recaudadora.
- Muestra mensajes de error si la API responde con error.

## Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint puede ser protegido con middleware de autenticación según la política del sistema.

## Consideraciones
- La exportación a Excel debe implementarse en backend o como descarga CSV en frontend.
- El stored procedure puede ser extendido para paginación si el volumen de datos lo requiere.

# Estructura de la Base de Datos
- `ta_11_adeudo_local`: Adeudos de locales
- `ta_11_locales`: Locales de mercados
- `ta_12_recaudadoras`: Catálogo de recaudadoras
- `ta_11_mercados`: Catálogo de mercados
- `ta_15_apremios`: Requerimientos (folios)

# Integración
- El frontend se comunica únicamente con `/api/execute`.
- El backend enruta la acción al stored procedure correspondiente y retorna los datos en formato JSON.

# Pruebas y Casos de Uso
Ver secciones siguientes.


## Casos de Uso

# Casos de Uso - AdeudosLocGrl

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Generales por Mercado y Periodo

**Descripción:** El usuario desea consultar los adeudos generales de un mercado específico hasta un periodo determinado.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar adeudos.

**Pasos a seguir:**
1. Ingresa a la página de Adeudos Generales.
2. Selecciona la recaudadora (ejemplo: 2).
3. Selecciona el mercado (ejemplo: 5).
4. Selecciona el año (ejemplo: 2024) y mes (ejemplo: 6).
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con los adeudos generales del mercado 5 de la recaudadora 2 hasta junio 2024, incluyendo meses y folios de requerimientos.

**Datos de prueba:**
{ "id_rec": 2, "num_mercado": 5, "axo": 2024, "mes": 6 }

---

## Caso de Uso 2: Consulta de Adeudos Generales de Todos los Mercados de una Recaudadora

**Descripción:** El usuario desea ver el reporte global de adeudos de todos los mercados de una recaudadora.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresa a la página de Adeudos Generales.
2. Selecciona la recaudadora (ejemplo: 1).
3. Deja el campo mercado en '000-TODOS LOS MERCADOS'.
4. Selecciona el año y mes deseados.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con los adeudos de todos los mercados de la recaudadora 1 hasta el periodo seleccionado.

**Datos de prueba:**
{ "id_rec": 1, "num_mercado": null, "axo": 2024, "mes": 5 }

---

## Caso de Uso 3: Exportación a Excel (No Implementado)

**Descripción:** El usuario intenta exportar el reporte a Excel.

**Precondiciones:**
El usuario ha realizado una búsqueda de adeudos.

**Pasos a seguir:**
1. Realiza una búsqueda de adeudos.
2. Da clic en 'Exportar Excel'.

**Resultado esperado:**
Se muestra un mensaje indicando que la exportación a Excel no está implementada.

**Datos de prueba:**
N/A

---



## Casos de Prueba

# Casos de Prueba para AdeudosLocGrl

## Caso 1: Consulta exitosa de adeudos por mercado
- **Entrada:** id_rec=2, num_mercado=5, axo=2024, mes=6
- **Acción:** POST /api/execute { action: 'getAdeudosLocalesGrl', params: { id_rec:2, num_mercado:5, axo:2024, mes:6 } }
- **Esperado:** HTTP 200, success=true, data es array con campos requeridos, sin error.

## Caso 2: Consulta de todos los mercados de una recaudadora
- **Entrada:** id_rec=1, num_mercado=null, axo=2024, mes=5
- **Acción:** POST /api/execute { action: 'getAdeudosLocalesGrl', params: { id_rec:1, num_mercado:null, axo:2024, mes:5 } }
- **Esperado:** HTTP 200, success=true, data es array con todos los mercados de la recaudadora 1.

## Caso 3: Error por recaudadora no seleccionada
- **Entrada:** id_rec=null, num_mercado=5, axo=2024, mes=6
- **Acción:** POST /api/execute { action: 'getAdeudosLocalesGrl', params: { id_rec:null, num_mercado:5, axo:2024, mes:6 } }
- **Esperado:** HTTP 200, success=false, message indica que debe seleccionar recaudadora.

## Caso 4: Exportar Excel
- **Acción:** POST /api/execute { action: 'exportExcel', params: {...} }
- **Esperado:** HTTP 200, success=true, message indica que la exportación no está implementada.

## Caso 5: Consulta con parámetros fuera de rango
- **Entrada:** id_rec=1, num_mercado=999, axo=1900, mes=13
- **Acción:** POST /api/execute { action: 'getAdeudosLocalesGrl', params: { id_rec:1, num_mercado:999, axo:1900, mes:13 } }
- **Esperado:** HTTP 200, success=true, data vacío o error controlado.



