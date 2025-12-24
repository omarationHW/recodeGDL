# RptEstadisticaAdeudos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de RptEstadisticaAdeudos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de estadística global de adeudos vencidos por local y mercado, migrado desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js 3+, componente de página independiente, navegación por rutas.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en un stored procedure.

## 3. Flujo de Datos
1. El usuario accede a la página de reporte y selecciona los parámetros (año, periodo, importe mínimo, tipo de reporte).
2. El frontend envía una petición POST a `/api/execute` con `eRequest: 'RptEstadisticaAdeudos'` y los parámetros.
3. El backend recibe la petición, identifica el eRequest y ejecuta el stored procedure correspondiente en PostgreSQL.
4. El resultado se retorna en el campo `data` del eResponse.
5. El frontend muestra la tabla de resultados y totales.

## 4. Detalle de Componentes
### 4.1. Stored Procedure PostgreSQL
- Nombre: `rpt_estadistica_adeudos`
- Parámetros:
  - `p_axo` (año)
  - `p_periodo` (periodo/mes)
  - `p_importe` (importe mínimo, sólo aplica si opc=2)
  - `p_opc` (1=global, 2=filtrado por importe)
- Devuelve: Tabla con columnas `oficina`, `num_mercado`, `local`, `descripcion`, `adeudo`.

### 4.2. Laravel Controller
- Endpoint: `POST /api/execute`
- Entrada: `{ eRequest: 'RptEstadisticaAdeudos', params: {axo, periodo, importe, opc} }`
- Salida: `{ success, message, data }`
- Seguridad: Puede protegerse con middleware de autenticación si se requiere.

### 4.3. Vue.js Component
- Página independiente, no usa tabs.
- Formulario para parámetros.
- Tabla de resultados, totales y mensajes de error.
- Navegación breadcrumb.

## 5. Consideraciones de Seguridad
- Validar que los parámetros sean numéricos y dentro de rangos válidos.
- El endpoint puede requerir autenticación según la política del sistema.

## 6. Manejo de Errores
- Errores de parámetros faltantes o inválidos retornan `success: false` y mensaje descriptivo.
- Errores de base de datos o ejecución retornan mensaje de error en el campo `message`.

## 7. Extensibilidad
- El endpoint `/api/execute` puede manejar otros eRequest para otros formularios/reports.
- El stored procedure puede ser extendido para incluir más filtros si se requiere.

## 8. Pruebas y Validación
- Casos de uso y pruebas incluidas para asegurar la funcionalidad y robustez del módulo.

## 9. Dependencias
- Laravel 10+, PHP 8+
- Vue.js 3+
- PostgreSQL 12+

## 10. Notas de Migración
- El reporte Delphi usaba QuickReport y lógica procedural; ahora toda la lógica SQL está en el stored procedure.
- El frontend es SPA y puede integrarse en cualquier router de Vue.js.


## Casos de Uso

# Casos de Uso - RptEstadisticaAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta Global de Adeudos Vencidos

**Descripción:** El usuario desea obtener la estadística global de adeudos vencidos al periodo seleccionado, sin filtrar por importe.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudos en la base de datos.

**Pasos a seguir:**
1. Acceder a la página de Estadística de Adeudos.
2. Ingresar el año (por ejemplo, 2024) y el periodo (por ejemplo, 6).
3. Seleccionar 'Global' como tipo de reporte.
4. Dejar el campo 'Importe mínimo' en 0 o vacío.
5. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los adeudos vencidos al periodo 2024-6, agrupados por oficina, mercado y local, con el total de adeudo por cada uno.

**Datos de prueba:**
{ axo: 2024, periodo: 6, importe: 0, opc: 1 }

---

## Caso de Uso 2: Consulta de Adeudos Mayores a un Importe

**Descripción:** El usuario desea obtener sólo los adeudos cuyo importe total es mayor o igual a un valor específico.

**Precondiciones:**
El usuario tiene acceso al sistema y existen adeudos con importes mayores o iguales al valor ingresado.

**Pasos a seguir:**
1. Acceder a la página de Estadística de Adeudos.
2. Ingresar el año (por ejemplo, 2023) y el periodo (por ejemplo, 12).
3. Ingresar '5000' en el campo 'Importe mínimo'.
4. Seleccionar 'Sólo mayores o iguales a importe' como tipo de reporte.
5. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los adeudos vencidos al periodo 2023-12 cuyo importe total es mayor o igual a $5,000, agrupados por oficina, mercado y local.

**Datos de prueba:**
{ axo: 2023, periodo: 12, importe: 5000, opc: 2 }

---

## Caso de Uso 3: Consulta sin Resultados

**Descripción:** El usuario realiza una consulta para un periodo y un importe mínimo tan alto que no existen adeudos que cumplan el criterio.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Acceder a la página de Estadística de Adeudos.
2. Ingresar el año (por ejemplo, 2022) y el periodo (por ejemplo, 1).
3. Ingresar '9999999' en el campo 'Importe mínimo'.
4. Seleccionar 'Sólo mayores o iguales a importe' como tipo de reporte.
5. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron resultados para los criterios seleccionados.

**Datos de prueba:**
{ axo: 2022, periodo: 1, importe: 9999999, opc: 2 }

---



## Casos de Prueba

## Casos de Prueba para RptEstadisticaAdeudos

### Caso 1: Consulta Global Exitosa
- **Entrada:** { axo: 2024, periodo: 6, importe: 0, opc: 1 }
- **Acción:** POST /api/execute con eRequest 'RptEstadisticaAdeudos'
- **Resultado esperado:**
  - success: true
  - data: Array con al menos un registro
  - Cada registro contiene: oficina, num_mercado, local, descripcion, adeudo
  - Suma de adeudo coincide con suma manual de la base de datos

### Caso 2: Consulta Filtrada por Importe
- **Entrada:** { axo: 2023, periodo: 12, importe: 5000, opc: 2 }
- **Acción:** POST /api/execute con eRequest 'RptEstadisticaAdeudos'
- **Resultado esperado:**
  - success: true
  - data: Array con registros donde adeudo >= 5000
  - Ningún registro tiene adeudo < 5000

### Caso 3: Consulta Sin Resultados
- **Entrada:** { axo: 2022, periodo: 1, importe: 9999999, opc: 2 }
- **Acción:** POST /api/execute con eRequest 'RptEstadisticaAdeudos'
- **Resultado esperado:**
  - success: true
  - data: Array vacío
  - Mensaje: 'Consulta exitosa' o similar

### Caso 4: Parámetros Faltantes
- **Entrada:** { axo: 2024, periodo: null, importe: 0, opc: 1 }
- **Acción:** POST /api/execute con eRequest 'RptEstadisticaAdeudos'
- **Resultado esperado:**
  - success: false
  - message: 'Parámetros requeridos: axo, periodo, opc'

### Caso 5: Error de Base de Datos
- **Simulación:** Renombrar temporalmente la función rpt_estadistica_adeudos
- **Acción:** POST /api/execute con cualquier parámetro válido
- **Resultado esperado:**
  - success: false
  - message: Error de base de datos indicando función no existe

### Caso 6: Validación de Tipos
- **Entrada:** { axo: 'abcd', periodo: 'xyz', importe: 'foo', opc: 'bar' }
- **Acción:** POST /api/execute con eRequest 'RptEstadisticaAdeudos'
- **Resultado esperado:**
  - success: false
  - message: 'Parámetros requeridos: axo, periodo, opc' o error de tipo/conversión



