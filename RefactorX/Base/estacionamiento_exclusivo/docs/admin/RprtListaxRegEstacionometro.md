# Reporte: Listados por Registro de Estacionómetros

## Propósito Administrativo
Módulo de generación del reporte impreso de folios de infracciones de estacionómetros filtrados por colonia. Produce documentos oficiales para gestión de multas vehiculares.

## Funcionalidad Principal
Genera el formato impreso de listados de infracciones organizados por colonia, aplicando diseño oficial y mostrando información de la placa y vehículo.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos físicos de listados de infracciones aplicando formato institucional, mostrando datos del vehículo, placa, propietario y ubicación.

### ¿Para qué sirve?
- Generar reportes de infracciones por zona
- Aplicar formato para gestión vehicular
- Producir listados por colonia
- Facilitar cobro de multas de estacionómetros

### ¿Cómo lo hace?
1. Recibe parámetros del módulo ListxReg (colonia)
2. Aplica formato oficial
3. Incluye datos del vehículo y propietario
4. Organiza por colonia
5. Genera documento con información de infracciones

## Datos y Tablas
Dataset de ta_15_apremios con ta_14_infracciones_placas.

## Usuarios del Sistema
Invocado por el módulo ListxReg para infracciones.

## Relaciones con Otros Módulos
- **ListxReg**: Módulo invocador
