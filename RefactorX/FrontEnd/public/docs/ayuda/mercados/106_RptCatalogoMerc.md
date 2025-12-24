# RptCatalogoMerc.pas - Reporte de Catálogo de Mercados

## Información General
- **Archivo:** RptCatalogoMerc.pas
- **Ubicación:** C:\Sistemas\RefactorX\Guadalajara\Originales\Code\17\Aplicaciones\Aplicaciones SVN\Mercados
- **Tipo:** Módulo de Reportes QuickReport
- **Propósito:** Generación de reporte del catálogo de mercados del sistema

## Descripción
Este módulo genera un reporte del catálogo de mercados, mostrando información detallada sobre los mercados registrados en el sistema. Utiliza QuickReport para la generación de reportes en formato imprimible y PDF.

## Arquitectura

### Componentes Principales

#### Clase TQRptCatalogoMerc
```pascal
TQRptCatalogoMerc = class(TQuickRep)
```

**Responsabilidad:** Formulario de reporte que gestiona la presentación del catálogo de mercados.

### Consultas y Datasets

#### QryCatalogo (TQuery)
**Propósito:** Consulta principal que obtiene la información del catálogo de mercados.

**Campos:**
- oficina: Número de oficina recaudadora
- num_mercado_nvo: Número del mercado
- categoria: Categoría del mercado
- descripcion: Nombre del mercado
- cuenta_ingreso: Cuenta contable de ingresos
- cuenta_energia: Cuenta contable de energía
- id_zona: Identificador de zona
- zona: Nombre de la zona
- id_rec: Identificador de recaudadora
- recaudadora: Nombre de la oficina recaudadora
- domicilio: Dirección del mercado
- tel: Teléfono
- recaudador: Nombre del recaudador
- sector: Sector
- tipo_emision: Tipo de emisión

### Bandas del Reporte

1. **QRBand1 (Header):** Encabezado con logo e información general
2. **ColumnHeaderBand1:** Encabezados de columnas
3. **DetailBand1:** Detalle de cada mercado
4. **SummaryBand1:** Resumen con totales
5. **PageFooterBand1:** Pie de página

## Funcionalidades Principales

### Procedimiento Inicio
```pascal
procedure Inicio(oficina:integer);
```

**Parámetros:**
- oficina: ID de la oficina recaudadora

**Flujo:**
1. Almacena el parámetro de oficina
2. Construye consulta SQL dinámica
3. Aplica filtro según nivel de usuario:
   - Nivel 1 (Administrador): Muestra todas las oficinas
   - Otros niveles: Filtra por oficina del usuario
4. Excluye mercados con tipo_emision = "B"
5. Une tablas de mercados, zonas y recaudadoras
6. Ordena por oficina y número de mercado
7. Configura el título según la oficina
8. Genera vista previa del reporte

## Tablas de Base de Datos

### ta_11_mercados
**Descripción:** Tabla principal de mercados

**Campos utilizados:**
- oficina
- num_mercado_nvo
- categoria
- descripcion
- cuenta_ingreso
- cuenta_energia
- id_zona
- tipo_emision

### ta_12_zonas
**Descripción:** Catálogo de zonas geográficas

**Campos utilizados:**
- id_zona
- zona (nombre)

### ta_12_recaudadoras
**Descripción:** Catálogo de oficinas recaudadoras

**Campos utilizados:**
- id_rec
- recaudadora (nombre)
- domicilio
- tel
- recaudador
- sector

## Lógica de Negocio

### Sistema de Seguridad por Niveles
El reporte implementa filtrado basado en el nivel del usuario:
- **Nivel 1:** Acceso completo a todas las oficinas
- **Otros niveles:** Solo ve la información de su oficina asignada

### Oficinas Recaudadoras
El sistema reconoce 5 oficinas recaudadoras:
1. Zona Centro
2. Zona Olímpica
3. Zona Oblatos
4. Zona Minerva
5. Zona Cruz del Sur

### Filtro de Tipo de Emisión
Los mercados con tipo_emision = "B" (Baja) se excluyen del catálogo.

## Exportación

### Formatos Disponibles
- **PDF:** A través de QRPDFFilter1
- **Vista Previa:** Preview directo en pantalla
- **Impresión:** Configuración de impresora

## Dependencias

### Módulos Externos
```pascal
uses ModuloBD;
```

**ModuloBD:** Módulo de base de datos que proporciona:
- DMGral.QryUsuario: Información del usuario actual
- Conexión a la base de datos

### Librerías Utilizadas
- Windows, SysUtils, Messages, Classes, Graphics, Controls
- StdCtrls, ExtCtrls, Forms
- Quickrpt, QRCtrls: Motor de reportes
- Db, DBTables, printers: Acceso a datos e impresión
- QRPDFFilt: Exportación a PDF

## Elementos Visuales

### Componentes de Presentación
- **QRImage1:** Logo institucional
- **QRLabel1, QRLabel2, QRLabel3:** Títulos y encabezados
- **QRLabel5:** Título dinámico según oficina
- **QRDBText:** Campos de datos enlazados
- **QRExpr5:** Expresión para totalización
- **QRSysData1, QRSysData2:** Datos del sistema (fecha, página)

## Consideraciones Técnicas

### Rendimiento
- Consulta SQL con joins múltiples puede ser costosa
- Se recomienda índices en: oficina, id_zona, id_rec
- Filtro por tipo_emision mejora performance

### Seguridad
- Validación de nivel de usuario antes de mostrar datos
- Filtrado automático según permisos del usuario
- Exclusión de mercados dados de baja

### Mantenibilidad
- SQL construido dinámicamente (considerar usar procedimientos almacenados)
- Nombres de oficinas hardcodeados (considerar tabla de configuración)
- Código bien estructurado y legible

## Posibles Mejoras

1. **Parametrización de Consultas:** Usar parámetros SQL en lugar de concatenación
2. **Tabla de Configuración:** Mover nombres de oficinas a tabla de configuración
3. **Paginación:** Implementar paginación para grandes volúmenes de datos
4. **Filtros Adicionales:** Agregar filtros por zona, categoría, etc.
5. **Exportación Multi-formato:** Agregar Excel, HTML, etc.
6. **Caché de Consultas:** Implementar caché para consultas frecuentes

## Notas de Implementación

- El reporte utiliza el framework QuickReport estándar de Delphi
- La configuración de impresora se obtiene del sistema
- El módulo ModuloBD debe estar inicializado antes de usar este reporte
- La variable global Roficina mantiene el estado de la oficina seleccionada

## Historial de Cambios

**Versión Actual:** No especificada en el código
**Última Modificación:** No disponible

---
**Documentado:** 2025-11-04
**Sistema:** Mercados de Guadalajara
**Módulo:** Reportes
