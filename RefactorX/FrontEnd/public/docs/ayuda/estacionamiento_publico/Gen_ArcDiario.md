# Gen_ArcDiario - Generación de Archivo Diario

## Propósito Administrativo
Genera archivos de texto para enviar al Estado los movimientos diarios de estacionamientos: pagos normales (PN), cancelaciones (C) y pagos con requerimiento (PR).

## Funcionalidad Principal
Procesa movimientos diarios en un rango de fechas, consolida información en remesa, genera archivo .txt para envío al Estado.

## Proceso de Negocio

### ¿Qué hace?
Muestra último periodo procesado. Permite seleccionar rango de fechas de movimientos diarios y periodo de altas relacionadas. Ejecuta sp14_Remesa opción 1 (diario). Genera remesa con folios tipo PN, C y PR. Crea archivo .txt delimitado por pipes. Registra en bitácora.

### ¿Para qué sirve?
Envía información diaria de movimientos al Estado para sincronización. Mantiene actualizado el sistema estatal con pagos y cancelaciones municipales. Cumple obligaciones de reporte interinstitucional.

### ¿Qué necesita para funcionar?
- Rango de fechas de movimientos diarios
- Rango de fechas de altas relacionadas
- SP sp14_Remesa configurado

## Datos y Tablas

### Tabla Principal
- **ta14_datos_mpio**: Almacena datos para enviar

### Stored Procedures (SP)
- **sp14_Remesa**: Con parámetro opción=1 (movimientos diarios)

### Tablas que Afecta
- **ta14_datos_mpio**: Insert
- **ta14_bitácora**: Insert

## Impacto y Repercusiones

### Repercusiones Operativas
Actualiza información en el Estado diariamente.

### Repercusiones Financieras
Facilita conciliación diaria de ingresos.

### Repercusiones Administrativas
Mantiene sincronizada información interinstitucional.

## Casos de Uso
1. **Envío Diario**: Al cierre de día se genera y envía remesa
2. **Reproceso Semanal**: Se genera remesa con movimientos de la semana

## Usuarios del Sistema
- Personal de procesamiento diario
- Supervisores

## Relaciones con Otros Módulos
- **Gen_ArcAltas**: Generación de altas
- **Cga_ArcEdoEx**: Recepción de archivos del Estado
- **ConsRemesas**: Consulta de remesas
