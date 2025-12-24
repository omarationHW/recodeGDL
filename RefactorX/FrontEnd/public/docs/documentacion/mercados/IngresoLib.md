# IngresoLib

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario IngresoLib (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, página independiente para IngresoLib)
- **Base de Datos:** PostgreSQL (toda la lógica SQL en stored procedures)
- **Comunicación:** Patrón eRequest/eResponse (todas las operaciones a través de `/api/execute`)

## 2. Flujo de la Aplicación
1. **Carga inicial:**
   - El componente Vue solicita la lista de mercados (`get_mercados`).
   - El usuario selecciona mes, año y mercado.
2. **Procesar:**
   - Al hacer submit, Vue envía la acción `get_ingresos` con parámetros mes, año, mercado_id.
   - El backend ejecuta el SP correspondiente y retorna los datos.
   - Vue muestra los ingresos por fecha y caja.
   - Vue solicita también los totales por caja (`get_cajas`) y los totales globales (`get_totals`).

## 3. API Backend
- **Endpoint:** `/api/execute` (POST)
- **Body:** `{ action: 'nombre_accion', params: { ... } }`
- **Acciones soportadas:**
  - `get_mercados`: Lista de mercados tipo 'D'.
  - `get_ingresos`: Ingresos por fecha y caja.
  - `get_cajas`: Totales por caja.
  - `get_totals`: Totales globales.
- **Respuesta:** `{ success: bool, data: ..., message: string }`

## 4. Stored Procedures
- Toda la lógica de consulta se implementa en SPs PostgreSQL.
- Los SPs reciben parámetros y retornan tablas (RETURNS TABLE ...).
- El controlador Laravel ejecuta los SPs vía DB::select.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para seleccionar mes, año y mercado.
- Botón Procesar ejecuta la consulta.
- Muestra tres tablas: ingresos por fecha/caja, totales por caja, totales globales.
- Manejo de loading y errores.

## 6. Validaciones
- El backend valida los parámetros recibidos.
- El frontend valida que todos los campos estén completos antes de enviar.

## 7. Seguridad
- Todas las consultas se parametrizan para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación si se requiere.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones/SPs fácilmente.
- El frontend puede adaptarse a otros formularios siguiendo el mismo patrón.

## 9. Pruebas
- Casos de uso y pruebas incluidas para validar la funcionalidad principal.

---


## Casos de Uso

# Casos de Uso - IngresoLib

**Categoría:** Form

## Caso de Uso 1: Consulta de Ingresos del Mercado Libertad para un Mes

**Descripción:** El usuario desea consultar todos los ingresos registrados para el Mercado Libertad en el mes de marzo de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros de pagos para el Mercado Libertad en marzo 2024.

**Pasos a seguir:**
- El usuario accede a la página de Ingreso Mercado Libertad.
- Selecciona el mes '3' (marzo) y el año '2024'.
- Selecciona el mercado '001 - Mercado Libertad'.
- Hace clic en 'Procesar'.

**Resultado esperado:**
Se muestran las tablas con los ingresos por fecha y caja, los totales por caja y los totales globales para el Mercado Libertad en marzo 2024.

**Datos de prueba:**
{ mes: 3, anio: 2024, mercado_id: 1 }

---

## Caso de Uso 2: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar ingresos sin seleccionar un mercado.

**Precondiciones:**
El usuario accede a la página pero no selecciona ningún mercado.

**Pasos a seguir:**
- El usuario deja el campo 'Mercado' vacío.
- Hace clic en 'Procesar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo 'Mercado' es obligatorio.

**Datos de prueba:**
{ mes: 3, anio: 2024, mercado_id: null }

---

## Caso de Uso 3: Consulta de Totales por Caja

**Descripción:** El usuario desea ver el desglose de pagos por cada caja para el Mercado Libertad en abril 2024.

**Precondiciones:**
Existen registros de pagos en diferentes cajas para el Mercado Libertad en abril 2024.

**Pasos a seguir:**
- El usuario selecciona mes '4', año '2024', mercado '001'.
- Hace clic en 'Procesar'.
- Observa la tabla de 'Totales por Caja'.

**Resultado esperado:**
La tabla muestra una fila por cada caja con el total de pagos y el total de renta pagada.

**Datos de prueba:**
{ mes: 4, anio: 2024, mercado_id: 1 }

---



## Casos de Prueba

## Casos de Prueba para IngresoLib

### Caso 1: Consulta exitosa de ingresos
- **Entrada:** mes=3, anio=2024, mercado_id=1
- **Acción:** POST /api/execute { action: 'get_ingresos', params: { mes:3, anio:2024, mercado_id:1 } }
- **Resultado esperado:** Código 200, success=true, data contiene lista de ingresos.

### Caso 2: Validación de parámetros
- **Entrada:** mes=3, anio=2024, mercado_id=null
- **Acción:** POST /api/execute { action: 'get_ingresos', params: { mes:3, anio:2024, mercado_id:null } }
- **Resultado esperado:** Código 200, success=false, message indica error de validación.

### Caso 3: Consulta de totales por caja
- **Entrada:** mes=4, anio=2024, mercado_id=1
- **Acción:** POST /api/execute { action: 'get_cajas', params: { mes:4, anio:2024, mercado_id:1 } }
- **Resultado esperado:** Código 200, success=true, data contiene lista de totales por caja.

### Caso 4: Consulta de totales globales
- **Entrada:** mes=4, anio=2024, mercado_id=1
- **Acción:** POST /api/execute { action: 'get_totals', params: { mes:4, anio:2024, mercado_id:1 } }
- **Resultado esperado:** Código 200, success=true, data contiene total_pagos y total_importe.

### Caso 5: Consulta de mercados
- **Entrada:** ninguna
- **Acción:** POST /api/execute { action: 'get_mercados' }
- **Resultado esperado:** Código 200, success=true, data contiene lista de mercados tipo 'D'.



