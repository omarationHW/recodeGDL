# Reporte: Listados por Registro de Estacionamientos Públicos

## Propósito Administrativo
Módulo de generación de reportes de folios de estacionamientos públicos. Produce documentos oficiales organizados por estacionamiento para gestión de cobro.

## Funcionalidad Principal
Genera formatos impresos de listados de folios de estacionamientos públicos, mostrando información del establecimiento y datos del requerimiento.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos de listados de estacionamientos públicos con formato institucional, incluyendo datos del permiso y establecimiento.

### ¿Para qué sirve?
- Generar reportes por estacionamiento
- Organizar folios por establecimiento
- Facilitar seguimiento de cobro
- Documentar gestión por ubicación

### ¿Cómo lo hace?
1. Recibe parámetros del módulo ListxReg
2. Aplica formato oficial
3. Incluye datos del estacionamiento
4. Organiza por número de establecimiento
5. Genera documento completo

## Datos y Tablas
Dataset de ta_15_apremios con dbestacion::pubmain.

## Usuarios del Sistema
Invocado por el módulo ListxReg.

## Relaciones con Otros Módulos
- **ListxReg**: Módulo invocador
