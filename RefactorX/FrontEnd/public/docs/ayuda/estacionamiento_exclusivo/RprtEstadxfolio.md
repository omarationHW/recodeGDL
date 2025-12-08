# Reporte: Estadísticas por Folio

## Propósito Administrativo
Módulo de generación del reporte impreso de estadísticas de folios. Componente de reportes que trabaja con el módulo EstadxFolio para producir el informe estadístico físico.

## Funcionalidad Principal
Genera el formato impreso de las estadísticas de folios agrupadas por vigencia y estado, aplicando el diseño oficial con tablas, totales y gráficos estadísticos.

## Proceso de Negocio

### ¿Qué hace?
Recibe los datos estadísticos del módulo EstadxFolio y genera el reporte impreso con formato oficial, incluyendo totales, subtotales y presentación organizada de las estadísticas.

### ¿Para qué sirve?
- Generar documento físico de estadísticas
- Aplicar formato oficial para presentaciones
- Organizar datos en tablas y gráficos
- Producir reportes ejecutivos imprimibles

### ¿Cómo lo hace?
1. Recibe dataset con estadísticas del módulo EstadxFolio
2. Aplica diseño oficial con logos y encabezados
3. Organiza estadísticas en tablas
4. Calcula y muestra totales y subtotales
5. Genera documento con formato ejecutivo
6. Incluye pie de página y numeración

## Datos y Tablas

### Tabla Principal
Utiliza dataset proporcionado por el módulo llamador

### Stored Procedures (SP)
No utiliza SP. Recibe datos procesados.

### Tablas que Afecta
Módulo de solo lectura para generación de reportes.

## Usuarios del Sistema
Utilizado automáticamente por el módulo EstadxFolio

## Relaciones con Otros Módulos
- **EstadxFolio**: Módulo que invoca este reporte
