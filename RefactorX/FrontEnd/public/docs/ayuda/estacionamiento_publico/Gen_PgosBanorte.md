# Gen_PgosBanorte - Generación de Archivo de Pagos Banorte

## Propósito Administrativo
Genera archivos de texto para enviar al Estado los pagos de estacionamientos realizados a través de Banorte en un rango de fechas específico.

## Funcionalidad Principal
Procesa pagos realizados en Banorte durante un periodo, ejecuta stored procedure para consolidar en remesa, genera archivo .txt para envío al Estado.

## Proceso de Negocio

### ¿Qué hace?
Muestra última remesa de pagos Banorte. Permite seleccionar rango de fechas de pagos. Ejecuta sp14_Remesa opción 2 (Banorte). Consolida pagos en ta14_datos_mpio con remesa consecutiva. Genera archivo .txt con formato específico. Registra en bitácora tipo D (pagos Banorte).

### ¿Para qué sirve?
Reportar al Estado pagos realizados en sucursales Banorte. Facilitar conciliación de pagos bancarios. Cumplir obligaciones de reporte de recaudación.

### ¿Cómo lo hace?
Consulta última remesa tipo D en bitácora. Propone fechas siguientes. Usuario selecciona rango. Ejecuta sp14_Remesa con opción=2. SP consulta ta14_fol_banorte y genera registros en ta14_datos_mpio. Usuario genera archivo .txt incluyendo: municipio|PN|folio|placa|fecha pago|fecha alta|folioec|remesa|fecha remesa|importe|clave. Registra en bitácora.

### ¿Qué necesita para funcionar?
- Tabla ta14_fol_banorte con pagos registrados
- SP sp14_Remesa configurado
- Rango de fechas válido

## Datos y Tablas

### Tabla Principal
- **ta14_fol_banorte**: Pagos realizados en Banorte
- **ta14_datos_mpio**: Destino de remesa

### Tablas Relacionadas
- **ta14_bitacora**: Registro de remesas tipo D
- **ta14_folios_adeudo**: Folios origen

### Stored Procedures (SP)
- **sp14_Remesa**: Con opción=2 (pagos Banorte)
  - Parámetros: Opción, Año, Fecha inicio, Fecha fin, Fecha aplicación
  - Retorna: status, observaciones, nombre remesa

### Tablas que Afecta
- **ta14_datos_mpio**: Insert de pagos Banorte
- **ta14_bitacora**: Insert de remesa tipo D

## Impacto y Repercusiones

### Repercusiones Operativas
Sincroniza pagos bancarios con el Estado.

### Repercusiones Financieras
Facilita conciliación de ingresos por canal bancario. Permite auditoría de recaudación Banorte.

### Repercusiones Administrativas
Documenta pagos realizados fuera de ventanillas municipales.

## Validaciones y Controles
- Valida ejecución exitosa de SP (status=0)
- Verifica que haya registros para generar archivo
- Controla consecutivo de remesas tipo D
- Registra en bitácora solo si fue exitoso

## Casos de Uso
1. **Reporte Semanal**: Cada semana se genera remesa con pagos Banorte
2. **Conciliación Mensual**: Al cierre de mes se envía remesa completa
3. **Auditoría**: Se regenera remesa de periodo específico para verificación

## Usuarios del Sistema
- Personal de conciliación bancaria
- Supervisores de recaudación
- Personal de intercambio con Estado

## Relaciones con Otros Módulos
- **srfrm_conci_banorte**: Conciliación de pagos Banorte
- **ConsRemesas**: Consulta de remesas generadas
- **Cga_ArcEdoEx**: Recepción de archivos del Estado
- **Gen_ArcDiario**: Generación de movimientos diarios
