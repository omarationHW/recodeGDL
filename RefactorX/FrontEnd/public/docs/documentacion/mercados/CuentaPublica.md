# CuentaPublica

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Cuenta Pública (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (no tabs)
- **Base de Datos:** PostgreSQL 13+, lógica SQL migrada a stored procedures
- **Autenticación:** Laravel Sanctum/JWT (según política del proyecto)

## 2. API Backend
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "getEstadAdeudo", // o getTotalAdeudo, getCuentaPublicaReport, etc
    "params": { "oficina": 1, "axo": 2024, "periodo": 6 }
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
- **Acciones soportadas:**
  - `getRecaudadoras`: Lista de recaudadoras
  - `getEstadAdeudo`: Llama SP para resumen por mercado y mes
  - `getTotalAdeudo`: Llama SP para resumen por recaudadora y mes
  - `getCuentaPublicaReport`: Llama SP para reporte imprimible/exportable

## 3. Stored Procedures PostgreSQL
- Toda la lógica de agregación y consulta de adeudos se implementa en SPs.
- Los SPs reciben parámetros y devuelven tablas (RETURNS TABLE)
- Se recomienda crear índices en `ta_11_locales.vigencia`, `ta_11_locales.oficina`, `ta_11_adeudo_local.axo`, etc.

## 4. Frontend Vue.js
- Página independiente `/cuenta-publica` (ruta propia)
- Formulario con selección de recaudadora, año y mes
- Botón de consulta y botón de impresión/exportación
- Dos tablas: resumen por mercado/mes y resumen por recaudadora/mes
- Totales calculados en frontend
- Navegación breadcrumb
- Uso de Axios para llamadas al endpoint `/api/execute`
- Manejo de loading y errores

## 5. Seguridad
- Validación de parámetros en backend
- Solo usuarios autenticados pueden consultar
- Los SPs no permiten SQL injection (parámetros tipados)

## 6. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones
- Los SPs pueden ser reutilizados por otros reportes

## 7. Pruebas y Auditoría
- Todas las acciones quedan registradas en logs de Laravel
- Los SPs pueden ser auditados vía logs de PostgreSQL

## 8. Migración de Datos
- Se recomienda migrar los datos de las tablas originales a PostgreSQL usando ETL (no incluido en este código)

## 9. Consideraciones de UI/UX
- No usar tabs ni componentes tabulares para formularios
- Cada formulario es una página completa
- Breadcrumb para navegación
- Tablas responsivas y exportables

## 10. Dependencias
- Laravel 10+
- Vue.js 3+
- Axios
- Bootstrap 4/5 (opcional para estilos)

---


## Casos de Uso

# Casos de Uso - CuentaPublica

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos por Mercado y Mes

**Descripción:** El usuario desea consultar el resumen de adeudos de una recaudadora específica para un año y mes determinados.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página 'Cuenta Pública'.
2. Selecciona la recaudadora (por ejemplo, '1 - Zona Centro').
3. Selecciona el año (por ejemplo, 2024) y el mes (por ejemplo, 6).
4. Presiona el botón 'Consultar'.
5. El sistema muestra la tabla de adeudos por mercado y mes, y la tabla de totales por recaudadora y mes.

**Resultado esperado:**
Se muestran correctamente los datos de adeudos agregados por mercado y mes, y los totales, sin errores.

**Datos de prueba:**
{ "oficina": 1, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 2: Generación de Reporte Imprimible de Cuenta Pública

**Descripción:** El usuario desea generar un reporte imprimible/exportable de la cuenta pública para una recaudadora y año seleccionados.

**Precondiciones:**
El usuario está autenticado y ha realizado una consulta previa.

**Pasos a seguir:**
1. El usuario realiza una consulta de adeudos como en el caso anterior.
2. Presiona el botón 'Imprimir'.
3. El sistema llama al SP de reporte y genera el archivo (PDF/Excel).

**Resultado esperado:**
El usuario recibe el archivo generado correctamente, listo para impresión o exportación.

**Datos de prueba:**
{ "oficina": 1, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 3: Validación de Parámetros y Seguridad

**Descripción:** El sistema debe rechazar consultas con parámetros inválidos o usuarios no autenticados.

**Precondiciones:**
El usuario no está autenticado o envía parámetros inválidos.

**Pasos a seguir:**
1. El usuario intenta consultar sin autenticarse o con parámetros fuera de rango (por ejemplo, año 1800).
2. El sistema valida la sesión y los parámetros.

**Resultado esperado:**
El sistema responde con un error adecuado y no ejecuta la consulta.

**Datos de prueba:**
{ "oficina": 1, "axo": 1800, "periodo": 6 }

---



## Casos de Prueba

# Casos de Prueba para Cuenta Pública

## Caso 1: Consulta exitosa de adeudos
- **Input:** { "action": "getEstadAdeudo", "params": { "oficina": 1, "axo": 2024, "periodo": 6 } }
- **Resultado esperado:** HTTP 200, success=true, data=[...], message=""

## Caso 2: Consulta de totales exitosa
- **Input:** { "action": "getTotalAdeudo", "params": { "oficina": 1, "axo": 2024, "periodo": 6 } }
- **Resultado esperado:** HTTP 200, success=true, data=[...], message=""

## Caso 3: Generación de reporte
- **Input:** { "action": "getCuentaPublicaReport", "params": { "oficina": 1, "axo": 2024 } }
- **Resultado esperado:** HTTP 200, success=true, data=[...], message=""

## Caso 4: Parámetros inválidos
- **Input:** { "action": "getEstadAdeudo", "params": { "oficina": 1, "axo": 1800, "periodo": 6 } }
- **Resultado esperado:** HTTP 200, success=false, data=null, message contiene error de validación

## Caso 5: Usuario no autenticado
- **Input:** { "action": "getEstadAdeudo", "params": { "oficina": 1, "axo": 2024, "periodo": 6 } } (sin token de autenticación)
- **Resultado esperado:** HTTP 401 Unauthorized

## Caso 6: Acción no soportada
- **Input:** { "action": "unknownAction", "params": {} }
- **Resultado esperado:** HTTP 200, success=false, message='Acción no soportada'



