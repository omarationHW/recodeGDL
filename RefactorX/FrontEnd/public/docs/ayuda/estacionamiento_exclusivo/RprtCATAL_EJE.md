# Reporte: Catálogo de Ejecutores

## Propósito Administrativo
Módulo de generación del reporte impreso del catálogo de ejecutores fiscales. Este es el componente de reportes que trabaja en conjunto con el módulo Lista_Eje para producir el listado físico.

## Funcionalidad Principal
Genera el formato impreso del catálogo de ejecutores con toda su información, aplicando el diseño y formato oficial del municipio para distribución y consulta física.

## Proceso de Negocio

### ¿Qué hace?
Recibe los parámetros de filtrado del módulo Lista_Eje y genera el reporte impreso con el formato oficial, incluyendo encabezados, pie de página y organización de la información.

### ¿Para qué sirve?
- Generar el formato físico del listado de ejecutores
- Aplicar diseño oficial del municipio
- Organizar la información para impresión
- Producir documento distribuible

### ¿Cómo lo hace?
1. Recibe parámetros del módulo List_Eje (oficina, filtros)
2. Aplica el formato oficial con logos y encabezados
3. Organiza la información en columnas
4. Genera el documento para impresión o vista previa
5. Incluye pie de página con fecha y numeración

## Datos y Tablas

### Tabla Principal
Utiliza el dataset proporcionado por el módulo llamador

### Stored Procedures (SP)
No utiliza SP. Recibe datos del módulo llamador.

### Tablas que Afecta
Módulo de solo lectura para generación de reportes.

## Usuarios del Sistema
Utilizado automáticamente por el módulo List_Eje

## Relaciones con Otros Módulos
- **List_Eje**: Módulo que invoca este reporte
- **Lista_Eje**: Variante del listado de ejecutores
