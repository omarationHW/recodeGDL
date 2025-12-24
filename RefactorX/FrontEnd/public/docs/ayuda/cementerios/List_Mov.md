# List_Mov - Listado de Movimientos

## Propósito Administrativo
Módulo que genera listados detallados de movimientos realizados en el sistema, incluyendo altas, bajas, modificaciones, pagos y traslados, con filtros por período, tipo y usuario.

## Funcionalidad Principal
Produce reportes de auditoría de todas las transacciones realizadas en el sistema, permitiendo trazabilidad completa de operaciones.

## Proceso de Negocio

### ¿Qué hace?
- Lista todos los movimientos por período
- Filtra por tipo de operación
- Muestra usuario que realizó el movimiento
- Presenta fecha y hora de cada transacción
- Detalla datos antes y después del cambio
- Agrupa por tipo de movimiento

### ¿Para qué sirve?
- Auditoría de operaciones
- Trazabilidad de cambios
- Control de usuarios
- Resolución de controversias
- Cumplimiento normativo
- Análisis de productividad

### ¿Cómo lo hace?
1. Usuario selecciona rango de fechas y filtros
2. Sistema consulta tablas de movimientos
3. Consolida información de diferentes fuentes
4. Genera listado ordenado cronológicamente
5. Presenta detalle de cada transacción

## Datos y Tablas
- **ta_13_pagosrcm** - Pagos registrados
- **ta_13_datosrcm** - Altas y modificaciones
- **ta_historico** - Histórico de cambios
- **ta_usuarios** - Información de usuarios

## Usuarios del Sistema
- Supervisores
- Auditoría Interna
- Jefes de Departamento
- Administradores del Sistema
