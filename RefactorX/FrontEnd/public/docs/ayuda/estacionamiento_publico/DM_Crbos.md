# DM_Crbos - Data Module de Contrarecibos

## Propósito Administrativo
Módulo de datos compartido que gestiona el acceso a información de contrarecibos, proveedores, órdenes de compra y movimientos presupuestales relacionados con el área de Estacionamientos.

## Funcionalidad Principal
Centraliza el acceso a tablas y consultas relacionadas con el proceso de contrarecibos, proveedores, órdenes de compra, facturas y movimientos contables para gestionar egresos del área.

## Proceso de Negocio

### ¿Qué hace?
Proporciona DataSets, Queries y StoredProcs para gestionar contrarecibos, proveedores, órdenes de compra, artículos, facturas y movimientos presupuestales. Implementa lógica de cálculos de campo para estados de contrarecibos y totales de artículos.

### ¿Para qué sirve?
Centraliza la lógica de acceso a datos para evitar duplicación. Facilita el mantenimiento al tener un solo punto de configuración. Permite reutilización de consultas y stored procedures en múltiples formularios.

### ¿Qué necesita para funcionar?
- Conexión activa a base de datos (DsDBGasto)
- Tablas de contrarecibos, proveedores, órdenes, facturas configuradas

## Datos y Tablas

### Tabla Principal
- **Tb_contrarecibos**: Contrarecibos registrados
- **Tb_Proveedor**: Catálogo de proveedores
- **tb_ta_ordenes**: Órdenes de compra
- **tb_ta_articulos**: Artículos de órdenes

### Tablas Relacionadas
- **Tb_movimientos**: Movimientos contables
- **TB_Dependencia**: Catálogo de dependencias
- **Tb_cuentas**: Catálogo de cuentas contables
- **Tb_gto_Compro**: Gastos comprometidos
- **Tb_relRamos**: Relación de ramos presupuestales
- **Tb_facturas**: Facturas de proveedores

### Stored Procedures (SP)
- **StProc_mov_ins**: Inserta movimientos contables
- **StProc_orden_abc**: ABC de órdenes
- **StProc_articuilos_abc**: ABC de artículos
- **StProc_facturas_abc**: ABC de facturas
- **StProc_orden_afect**: Afectación de órdenes
- **StProc_orden_upd_crbo**: Actualiza orden con contrarecibo
- **StProc_up_proveedor**: Actualiza proveedor
- **StProc_crbo_abc**: ABC de contrarecibos

### Tablas que Afecta
Depende del StoredProc ejecutado. Generalmente: Tb_contrarecibos, Tb_movimientos, tb_ta_ordenes, Tb_Proveedor.

## Impacto y Repercusiones

### Repercusiones Operativas
Facilita el desarrollo y mantenimiento de formularios de egresos.

### Repercusiones Financieras
Controla el registro correcto de egresos y compromisos presupuestales.

### Repercusiones Administrativas
Estandariza el acceso a datos para consistencia en reportes.

## Validaciones y Controles
- Cálculos de campo para estado de contrarecibos
- Cálculos de totales de artículos con IVA y descuentos
- Validación de formato numérico (función NInvalidVal)

## Casos de Uso
Utilizado por todos los formularios que gestionan contrarecibos, proveedores y órdenes de compra.

## Usuarios del Sistema
Indirectamente: Personal de egresos, compradores, contabilidad.

## Relaciones con Otros Módulos
- Módulos de egresos (no incluidos en este análisis)
- DsDBGasto: Conexión a base de datos
