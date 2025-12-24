# CargaPagMercado

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: CargaPagMercado (Laravel + Vue.js + PostgreSQL)

## Descripción General
El formulario **CargaPagMercado** permite la carga masiva de pagos de locales de un mercado, validando los importes contra los ingresos de caja y eliminando los adeudos correspondientes. El proceso es transaccional y requiere validaciones de negocio específicas.

## Arquitectura
- **Backend:** Laravel Controller (API REST, endpoint único `/api/execute`)
- **Frontend:** Vue.js (Single Page Component, sin tabs)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón API:** eRequest/eResponse (un solo endpoint, acción por parámetro)

## Flujo de Trabajo
1. El usuario selecciona recaudadora, mercado, sección y local.
2. El sistema muestra los adeudos pendientes del local.
3. El usuario ingresa los datos de pago (fecha, caja, operación, partidas).
4. El sistema valida los importes contra el ingreso de caja y la captura previa.
5. Al grabar, se insertan los pagos y se eliminan los adeudos correspondientes (transacción).
6. El sistema muestra el resumen de importes y el estado de la operación.

## Endpoints API
- **POST /api/execute**
  - **action:** string (ej: 'getMercados', 'getAdeudosLocal', 'insertPagosMercado', etc)
  - **params:** objeto con los parámetros requeridos por la acción

## Stored Procedures
Toda la lógica de negocio y validación reside en stored procedures PostgreSQL. El controlador Laravel solo orquesta la llamada y retorna el resultado.

## Validaciones Clave
- No se permite grabar pagos si el importe total supera el ingreso disponible de la operación de caja.
- Solo se graban pagos con partida válida (no vacía ni cero).
- El proceso es transaccional: si falla un pago, se revierte todo.

## Seguridad
- El endpoint requiere autenticación (no incluida aquí, pero debe usarse middleware de Laravel).
- El usuario_id se pasa explícitamente para auditoría.

## Errores y Mensajes
- Todos los errores se retornan en el campo `message` del eResponse.
- El frontend muestra los mensajes en pantalla.

## Extensibilidad
- El endpoint y los stored procedures permiten agregar nuevas acciones sin modificar la estructura básica.

# Estructura de la Base de Datos (Tablas Clave)
- **ta_11_mercados**: Catálogo de mercados
- **ta_11_locales**: Locales de mercado
- **ta_11_adeudo_local**: Adeudos pendientes por local
- **ta_11_pagos_local**: Pagos realizados por local
- **ta_12_importes**: Ingresos de caja
- **ta_12_passwords**: Usuarios

# Frontend (Vue.js)
- Página independiente, sin tabs.
- Navegación breadcrumb.
- Formulario reactivo con validaciones.
- Tabla editable para partidas.
- Estado y mensajes claros para el usuario.

# Backend (Laravel)
- Un solo controlador, método `execute`.
- Llama a los stored procedures según la acción.
- Maneja transacciones y errores.

# Pruebas y Casos de Uso
Ver secciones correspondientes.


## Casos de Uso

# Casos de Uso - CargaPagMercado

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos de Mercado Correcta

**Descripción:** El usuario carga pagos de varios locales de un mercado, todos los importes y partidas son válidos.

**Precondiciones:**
El usuario está autenticado y tiene permisos. Existen adeudos pendientes para el local seleccionado.

**Pasos a seguir:**
1. El usuario selecciona la recaudadora, mercado, sección y local.
2. El sistema muestra los adeudos pendientes.
3. El usuario ingresa los datos de pago (fecha, caja, operación, partidas).
4. El usuario presiona 'Grabar Pagos'.
5. El sistema valida los importes y partidas.
6. El sistema graba los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos se graban correctamente, los adeudos se eliminan, y el sistema muestra un mensaje de éxito.

**Datos de prueba:**
oficina: 1, mercado: 10, categoria: 2, seccion: 'A', local: 123, fecha_pago: '2024-06-10', oficina_pago: 1, caja: '01', operacion: 1001, usuario_id: 5, pagos: [{id_local: 123, axo: 2024, periodo: 6, importe: 1000, partida: 'P001'}]

---

## Caso de Uso 2: Intento de Carga con Importe Excedido

**Descripción:** El usuario intenta cargar pagos cuyo importe total supera el ingreso disponible de la operación de caja.

**Precondiciones:**
El ingreso de caja es menor al total de pagos a capturar.

**Pasos a seguir:**
1. El usuario selecciona los datos y adeudos.
2. Ingresa partidas y montos que suman más que el ingreso disponible.
3. Presiona 'Grabar Pagos'.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que el importe excede el ingreso disponible.

**Datos de prueba:**
oficina: 1, mercado: 10, categoria: 2, seccion: 'A', local: 123, fecha_pago: '2024-06-10', oficina_pago: 1, caja: '01', operacion: 1001, usuario_id: 5, pagos: [{id_local: 123, axo: 2024, periodo: 6, importe: 2000, partida: 'P001'}] (Ingreso disponible: 1000)

---

## Caso de Uso 3: Carga de Pagos con Partidas Vacías

**Descripción:** El usuario intenta grabar pagos dejando la partida vacía o en cero.

**Precondiciones:**
Existen adeudos pendientes.

**Pasos a seguir:**
1. El usuario selecciona los datos y adeudos.
2. Deja la columna 'Partida' vacía o en cero para algunos adeudos.
3. Presiona 'Grabar Pagos'.

**Resultado esperado:**
El sistema ignora los pagos sin partida válida y solo graba los que tienen partida distinta de vacío/cero.

**Datos de prueba:**
pagos: [{id_local: 123, axo: 2024, periodo: 6, importe: 1000, partida: ''}, {id_local: 124, axo: 2024, periodo: 6, importe: 800, partida: 'P002'}]

---



## Casos de Prueba

# Casos de Prueba para CargaPagMercado

## Caso 1: Carga Correcta
- **Entradas:**
  - oficina: 1
  - mercado: 10
  - categoria: 2
  - seccion: 'A'
  - local: 123
  - fecha_pago: '2024-06-10'
  - oficina_pago: 1
  - caja: '01'
  - operacion: 1001
  - usuario_id: 5
  - pagos: [{id_local: 123, axo: 2024, periodo: 6, importe: 1000, partida: 'P001'}]
- **Acción:** POST /api/execute {action: 'insertPagosMercado', params: ...}
- **Esperado:**
  - HTTP 200, success: true, message: 'Pagos cargados correctamente'
  - El adeudo del local 123, año 2024, periodo 6, desaparece de la tabla de adeudos

## Caso 2: Importe Excedido
- **Entradas:**
  - pagos: suma de importes mayor al ingreso disponible
- **Acción:** POST /api/execute {action: 'insertPagosMercado', params: ...}
- **Esperado:**
  - HTTP 200, success: false, message: 'El Importe total (...) de locales a capturar es mayor al importe por capturar'
  - No se graba ningún pago

## Caso 3: Partidas Vacías
- **Entradas:**
  - pagos: algunos con partida vacía o cero
- **Acción:** POST /api/execute {action: 'insertPagosMercado', params: ...}
- **Esperado:**
  - HTTP 200, success: true
  - Solo se graban los pagos con partida válida
  - Los adeudos correspondientes se eliminan

## Caso 4: Validación de Campos Obligatorios
- **Entradas:**
  - Falta algún campo obligatorio en params
- **Acción:** POST /api/execute {action: 'insertPagosMercado', params: ...}
- **Esperado:**
  - HTTP 200, success: false, message: 'Completa todos los campos para buscar.'

## Caso 5: Consulta de Adeudos
- **Entradas:**
  - oficina, mercado, categoria, seccion, local
- **Acción:** POST /api/execute {action: 'getAdeudosLocal', params: ...}
- **Esperado:**
  - HTTP 200, success: true, data: [ ...adeudos... ]



