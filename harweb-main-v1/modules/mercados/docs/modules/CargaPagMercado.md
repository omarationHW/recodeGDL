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
