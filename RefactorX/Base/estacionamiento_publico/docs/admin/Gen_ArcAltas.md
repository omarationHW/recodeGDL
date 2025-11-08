# Gen_ArcAltas - Generación de Archivo de Altas

## Propósito Administrativo
Genera archivos de texto para enviar al Estado las altas de estacionamientos exclusivos del municipio en un periodo específico.

## Funcionalidad Principal
Procesa las altas de estacionamientos del periodo seleccionado, ejecuta stored procedure para consolidar datos en tabla de remesa, genera archivo de texto delimitado por pipes para envío al Estado.

## Proceso de Negocio

### ¿Qué hace?
Muestra última remesa de altas procesada. Calcula periodo a procesar (mes siguiente). Permite seleccionar rango de fechas. Ejecuta sp14_Remesa con opción 0 (altas) generando remesa consecutiva. Consolida registros en ta14_datos_mpio. Genera archivo .txt con formato específico para envío al Estado. Registra operación en bitácora.

### ¿Para qué sirve?
Sincroniza información de nuevos estacionamientos exclusivos con el Estado. Cumple con obligaciones de reporte. Facilita intercambio de información interinstitucional.

### ¿Cómo lo hace?
Lee QryAltas para obtener última remesa. Propone fechas del siguiente periodo. Usuario selecciona rango y ejecuta. SP genera registros en ta14_datos_mpio con nombre de remesa consecutivo (ayt_gdl_rNN). Usuario genera archivo .txt que incluye: municipio|tipo|folio|placa|fecha folio|fecha pago|importe|clave|folio estado|gastos|remesa|fecha remesa.

### ¿Qué necesita para funcionar?
- Altas previas registradas para determinar periodo
- SP sp14_Remesa configurado
- Selección de periodo válido

## Datos y Tablas

### Tabla Principal
- **ta14_datos_mpio**: Datos a enviar al estado

### Tablas Relacionadas
- **ta14_folios_adeudo**: Origen de altas
- **ta14_bitacora**: Registro de remesas
- **QryAltas**: Consulta de última remesa

### Stored Procedures (SP)
- **sp14_Remesa**: Genera remesa de altas
  - Parámetros: Opción=0 (altas), Año, Fecha inicio, Fecha fin, Fecha aplicación
  - Retorna: status, observaciones, nombre de remesa

### Tablas que Afecta
- **ta14_datos_mpio**: Insert de registros de remesa
- **ta14_bitacora**: Insert de registro de remesa procesada

## Impacto y Repercusiones

### Repercusiones Operativas
Cumple obligación de reporte al Estado en tiempo y forma.

### Repercusiones Financieras
Permite que el Estado facture correctamente estacionamientos municipales.

### Repercusiones Administrativas
Genera evidencia de cumplimiento. Facilita conciliaciones.

## Validaciones y Controles
- Valida que SP ejecute correctamente (status=0)
- Verifica que haya registros para generar archivo
- Controla consecutivo de remesas
- Registra en bitácora solo si fue exitoso

## Casos de Uso
1. **Envío Mensual**: Al cierre de mes se genera remesa de altas y se envía al Estado
2. **Reproceso**: Se detectan altas faltantes, se genera remesa adicional

## Usuarios del Sistema
- Personal administrativo de Estacionamientos
- Supervisores de intercambio con Estado

## Relaciones con Otros Módulos
- **Cga_ArcEdoEx**: Recibe archivos del Estado (proceso inverso)
- **ConsRemesas**: Consulta remesas generadas
- **sfolios_alta**: Origen de las altas
- **Gen_ArcDiario**: Generación de movimientos diarios
