# Reporte: Listados por Registro de Mercados

## Propósito Administrativo
Módulo de generación del reporte impreso de folios de mercados filtrados por mercado específico. Produce documentos oficiales para gestión de locales comerciales.

## Funcionalidad Principal
Genera el formato impreso de listados de folios de mercados organizados por mercado, aplicando diseño oficial y mostrando información del local y locatario.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos físicos de listados de mercados aplicando formato institucional, mostrando datos del local, locatario y ubicación dentro del mercado.

### ¿Para qué sirve?
- Generar reportes por mercado específico
- Aplicar formato para gestión de locales
- Producir listados por ubicación
- Facilitar cobro en mercados municipales

### ¿Cómo lo hace?
1. Recibe parámetros del módulo ListxReg (mercado)
2. Aplica formato oficial
3. Incluye datos del local (sección, número, categoría)
4. Organiza por mercado y local
5. Genera documento con información completa

## Datos y Tablas
Dataset de ta_15_apremios con ta_11_locales.

## Usuarios del Sistema
Invocado por el módulo ListxReg para mercados.

## Relaciones con Otros Módulos
- **ListxReg**: Módulo invocador
- **RptLista_mercados**: Reporte relacionado
