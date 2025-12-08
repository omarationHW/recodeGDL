# Documentación Administrativa - EmisionLocales.pas

## Información General
**Archivo:** EmisionLocales.pas
**Módulo:** Sistema de Mercados - Emisión de Recibos
**Ubicación:** C:\Sistemas\RefactorX\Guadalajara\Originales\Code\17\Aplicaciones\Aplicaciones SVN\Mercados
**Fecha de Documentación:** 2025-11-04

## Propósito del Módulo
Sistema de emisión de recibos de arrendamiento de locales en mercados municipales, generando documentos de cobro mensual con cálculos de adeudos, recargos y multas.

## Funcionalidades Principales

### 1. Emisión de Recibos de Arrendamiento
- **Descripción:** Generación de recibos mensuales para locales de mercados
- **Proceso:**
  - Selección de recaudadora y mercado
  - Definición de año y periodo de emisión
  - Cálculo automático de rentas según superficie y cuota
  - Generación de recargos por pago tardío
  - Inclusión de multas y gastos de ejecución
- **Validaciones:**
  - Verificación de selección de recaudadora
  - Validación de tipo de emisión del mercado
  - Control de emisión previa para evitar duplicados

### 2. Grabación de Adeudos
- **Descripción:** Registro de adeudos mensuales en base de datos
- **Proceso:**
  - Consulta de locales con adeudos pendientes
  - Validación de emisión previa
  - Inserción masiva de adeudos por local
  - Control transaccional para consistencia de datos
- **Restricciones:**
  - No permite grabar emisión de mercado 99 (recaudadora 1)
  - No permite grabar Tianguis Cultural (mercado 214)

### 3. Cálculo de Rentas
- **Descripción:** Cálculo diferenciado según tipo de local y cuota
- **Metodologías:**
  - **Locales PS (Piso de Plaza):**
    - Cuota 4: superficie × importe_cuota
    - Otras cuotas: (importe_cuota × superficie) × 30
  - **Locales Estándar:** superficie × importe_cuota
- **Stored Procedure:** Sp_CalcRenta para cálculos complejos

### 4. Cálculo de Recargos
- **Descripción:** Aplicación de recargos por mora en pagos
- **Proceso:**
  - Validación de fecha de pago vs fecha límite de recargos
  - Consulta de tabla de recargos mensuales
  - Aplicación de porcentajes según mes de atraso
  - Acumulación de recargos históricos

### 5. Gestión de Requerimientos
- **Descripción:** Registro de multas y gastos de ejecución
- **Componentes:**
  - Folios de requerimiento
  - Importes de multas
  - Gastos administrativos
  - Gastos de ejecución fiscal

### 6. Facturación
- **Descripción:** Generación de facturas agrupadas
- **Opciones:**
  - Facturación individual por mercado
  - Facturación global de todos los mercados
- **Reportes:** QRptFacturaEmision

### 7. Impresión de Recibos
- **Descripción:** Generación de documentos imprimibles
- **Formatos:**
  - Formato continuo (papel químico)
  - Formato láser (individual)
  - Estado de cuenta Mercado Abastos
- **Componentes:**
  - Encabezados con datos del contribuyente
  - Detalle de adeudos por mes
  - Cálculos de recargos y total
  - Subreportes de pagos aplicados

## Componentes Técnicos

### Formulario Principal: TFrmEmisionLocales

#### Controles de Interfaz
- **FlatSpinEditaxo:** Selector de año de emisión
- **FlatSpinEditperiodo:** Selector de periodo (mes)
- **FlatCboxRec:** ComboBox de recaudadoras
- **FlatEdtMercado:** Campo de número de mercado
- **ExDBGrid:** Grid de selección de mercados

#### Botones de Acción
- **FlatBtnEjecutar:** Procesar e imprimir emisión
- **FlatbtnGrabar:** Grabar adeudos en base de datos
- **FlatbtnFacturacion:** Generar facturación
- **FlatbtnExcel:** Exportar a Excel
- **FlatBtnSalir:** Cerrar formulario

### Queries y Tablas

#### QryMerc - Consulta de Mercados
```sql
SELECT * FROM ta_11_mercados
WHERE oficina = :varOficina
ORDER BY num_mercado_nvo
```

#### QryEmision - Locales para Emisión
```sql
SELECT a.*, b.*
FROM ta_11_locales a, ta_11_cuotas b
WHERE a.oficina = :vofn
  AND a.num_mercado = :vmer
  AND a.axo = :vaxo
```

#### QryAdeudo - Validación de Emisión Previa
```sql
SELECT axo, periodo
FROM ta_11_adeudo_local
WHERE axo = :va
  AND periodo = :vm
  AND id_local IN (SELECT id_local FROM ta_11_locales...)
```

#### QryGrabaAdeudo - Inserción de Adeudos
```sql
INSERT INTO ta_11_adeudo_local
(id_adeudo_local, id_local, axo, periodo, importe,
 fecha_alta, id_usuario)
VALUES (0, ?, ?, ?, ?, CURRENT, ?)
```

#### QryPagos - Pagos del Mes Anterior
```sql
SELECT * FROM ta_11_pago_local
WHERE id_local = :vloc
  AND axo = :vaxo
  AND periodo = :vper
```

#### QryRequerimientos - Multas y Gastos
```sql
SELECT * FROM ta_11_control
WHERE modulo = :vmod
  AND control_otr = :vcont
```

#### QryMesAdeudo - Histórico de Adeudos
```sql
SELECT * FROM ta_11_adeudo_local
WHERE id_local = :varlocal
  AND axo <= :varaxo
ORDER BY axo, periodo
```

### Reportes

#### ppReport1 - Reporte Principal
- **Tipo:** Estado de cuenta con desglose de adeudos
- **Componentes:**
  - Header con datos del mercado
  - Detail con información del local
  - Subreportes de pagos y adeudos históricos
  - Footer con totales y formas de pago

#### ppEstadoCuentaME - Estado Mercado Abastos
- **Formato:** Especial para Mercado de Abastos
- **Características:**
  - Diseño institucional con logos
  - Desglose mensual de adeudos
  - Cálculo de recargos por mora
  - Instrucciones de pago

### Stored Procedures

#### Sp_CalcRenta
**Parámetros:**
- parm_alo: Año de cálculo
- parm_categoria: Categoría del mercado
- parm_seccion: Sección del local
- parm_cve_cuota: Clave de cuota
- parm_superficie: Superficie del local
- parm_merc: Número de mercado
- parm_trimestre: Trimestre (0 para mensual)

**Retorna:** Importe de renta calculado

## Reglas de Negocio

### 1. Emisión de Adeudos
- Solo se pueden emitir adeudos una vez por periodo
- La emisión genera automáticamente el adeudo del mes
- No se puede emitir sin seleccionar recaudadora y mercado
- Mercados con tipo_emision = 'M' requieren emisión manual

### 2. Cálculo de Rentas
- **Piso de Plaza (PS):**
  - Cuota 4 (fija): superficie × cuota
  - Otras cuotas: (cuota × superficie) × 30 días
- **Locales Estándar:** superficie × cuota
- **Tianguis Cultural (214):** superficie × cuota × sábados_acumulados

### 3. Recargos por Mora
- Se aplican después de la fecha_recargos del mes
- Porcentaje según tabla ta_11_recargo_mes
- Se acumulan recargos de meses anteriores
- Cálculo: renta × porcentaje / 100

### 4. Multas y Gastos
- Provienen de procedimientos de ejecución fiscal
- Se registran por folio de requerimiento
- Se suman al total del adeudo
- Son independientes del cálculo de renta

### 5. Meses de Adeudo
- Se listan todos los meses con adeudos pendientes
- Se separan adeudos del año actual y años anteriores
- Formato: lista de números de mes separados por coma
- Se excluyen adeudos ya pagados

## Flujos de Proceso

### Flujo 1: Emisión y Grabación de Adeudos
```
1. Usuario selecciona recaudadora
2. Sistema carga lista de mercados
3. Usuario selecciona mercado y periodo
4. Usuario presiona "Grabar"
5. Sistema valida emisión previa
6. Si no existe:
   - Consulta locales vigentes del mercado
   - Calcula renta por local usando Sp_CalcRenta
   - Inserta adeudo en ta_11_adeudo_local
   - Commit de transacción
7. Sistema confirma grabación exitosa
```

### Flujo 2: Impresión de Recibos
```
1. Usuario selecciona mercado y periodo
2. Usuario presiona "Ejecutar"
3. Sistema valida tipo de emisión del mercado
4. Sistema consulta locales con adeudos
5. Para cada local:
   - Calcula renta del mes
   - Consulta adeudos históricos
   - Calcula recargos si aplican
   - Consulta multas y gastos
   - Genera detalle de pago anterior
6. Sistema genera reporte con todos los locales
7. Presenta diálogo de impresión
```

### Flujo 3: Generación de Facturación
```
1. Usuario selecciona periodo de facturación
2. Sistema pregunta: ¿Solo mercado seleccionado?
3. Si es individual:
   - Factura solo locales del mercado actual
4. Si es global:
   - Factura todos los mercados de la recaudadora
5. Sistema genera reporte de facturación
6. Presenta documento para revisión/impresión
```

### Flujo 4: Cálculo de Recargos
```
1. Sistema obtiene fecha de pago del mes anterior
2. Sistema consulta fecha límite de recargos (ta_11_fecha_desc)
3. Si fecha_pago >= fecha_recargos:
   - Consulta tabla de recargos (ta_11_recargo_mes)
   - Calcula: renta × porcentaje_mes / 100
   - Suma recargo al subtotal
4. Si no aplica recargo: subtotal = adeudo
5. Retorna subtotal para impresión
```

## Variables Globales

```pascal
var
  alo, mes, dia: word;           // Fecha actual del sistema
  Raxo: integer;                 // Año de proceso
  Rperiodo: integer;             // Periodo de proceso
  per: integer;                  // Periodo anterior para recargos
  axo1: integer;                 // Año anterior para recargos
  Roficina: integer;             // Oficina recaudadora
  Rmercado: integer;             // Mercado seleccionado
  mes_d: string;                 // Mes con formato (01-12)
  mes_r: string;                 // Mes de recargo
  folios: string;                // Lista de folios de requerimiento
  TotalRenta: currency;          // Total de renta calculada
  rentaaxos: currency;           // Renta de años anteriores
  Subtotal: currency;            // Subtotal con recargos
  recargo: currency;             // Monto de recargos
  multas: currency;              // Monto de multas
  gastos: currency;              // Gastos de ejecución
```

## Manejo de Errores

### Validaciones de Entrada
```pascal
- Recaudadora no seleccionada
  → ShowMessage('Error... Falta seleccionar la recaudadora')

- Mercado sin tipo de emisión 'M'
  → ShowMessage('Error... No puedes Imprimir de este Mercado')

- Emisión ya grabada
  → ShowMessage('La Emisión del Mercado ya esta Grabada')
```

### Control Transaccional
```pascal
DMGral.DbIngresos.StartTransaction;
try
  // Operaciones de base de datos
  QryGrabaAdeudo.ExecSQL;
  DMGral.DbIngresos.Commit;
except
  DMGral.DbIngresos.Rollback;
  ShowMessage('Error al grabar el Adeudo');
  Close;
end;
```

## Dependencias

### Módulos Utilizados
- **ModuloBD:** Módulo de base de datos general
- **Menu:** Menú principal del sistema
- **RptEmisionLocales:** Reporte formato continuo
- **RptFacturaEmision:** Reporte de facturación
- **RptEmisionRbosAbastos:** Reporte especial Abastos
- **RptEmisionLaser:** Reporte formato láser

### Tablas de Base de Datos
- **ta_11_mercados:** Catálogo de mercados
- **ta_11_locales:** Registros de locales
- **ta_11_cuotas:** Catálogo de cuotas
- **ta_11_adeudo_local:** Adeudos de arrendamiento
- **ta_11_pago_local:** Pagos registrados
- **ta_11_recargo_mes:** Tabla de recargos
- **ta_11_fecha_desc:** Fechas límite de descuento
- **ta_11_control:** Requerimientos y multas

## Casos de Uso

### Caso de Uso 1: Emisión Mensual Normal
**Actor:** Operador de Recaudación
**Precondiciones:**
- Usuario autenticado en el sistema
- Periodo de emisión abierto
- Mercado configurado con tipo_emision = 'M'

**Flujo Principal:**
1. Operador accede al módulo de Emisión de Locales
2. Selecciona la recaudadora del dropdown
3. Selecciona el mercado del grid
4. Establece año y periodo de emisión
5. Presiona botón "Grabar"
6. Sistema valida que no exista emisión previa
7. Sistema calcula rentas de todos los locales
8. Sistema graba adeudos en base de datos
9. Sistema confirma grabación exitosa
10. Operador presiona "Ejecutar" para imprimir
11. Sistema genera recibos de todos los locales
12. Operador revisa e imprime documento

**Postcondiciones:**
- Adeudos grabados en ta_11_adeudo_local
- Recibos generados para impresión
- Log de movimiento registrado

### Caso de Uso 2: Reimpresión de Recibos
**Actor:** Supervisor de Recaudación
**Precondiciones:**
- Emisión ya grabada en el sistema
- Usuario con permisos de reimpresión

**Flujo Principal:**
1. Supervisor accede al módulo
2. Selecciona recaudadora y mercado
3. Selecciona periodo ya emitido
4. Presiona botón "Ejecutar"
5. Sistema genera recibos sin grabar nuevamente
6. Sistema incluye pagos ya realizados
7. Supervisor imprime documentos

**Flujo Alternativo:**
- Si el mercado no tiene emisión grabada
  → Sistema muestra error y no permite impresión

### Caso de Uso 3: Facturación Mensual
**Actor:** Contador del Área
**Precondiciones:**
- Emisiones del periodo completadas
- Periodo contable abierto

**Flujo Principal:**
1. Contador accede al módulo
2. Selecciona periodo de facturación
3. Presiona botón "Facturación"
4. Sistema pregunta si es individual o global
5. Contador selecciona opción global
6. Sistema genera factura consolidada
7. Sistema agrupa por mercado
8. Contador revisa totales
9. Contador imprime o exporta factura

**Postcondiciones:**
- Documento de facturación generado
- Totales calculados por mercado
- Registro para contabilidad

## Consideraciones Especiales

### Mercados Especiales
1. **Mercado 99 (Especial):**
   - No permite grabación de emisión
   - Solo consulta y reimpresión

2. **Mercado 214 (Tianguis Cultural):**
   - No permite grabación de emisión
   - Cálculo especial: superficie × cuota × sábados_acumulados

3. **Mercado de Abastos:**
   - Tiene reporte especial personalizado
   - Formato diferente de estado de cuenta

### Cálculos por Sección
- **PS (Piso de Plaza):** Cálculo por día (× 30)
- **Locales cerrados:** Cálculo por superficie
- **Puestos semifijos:** Según tabla de cuotas

### Restricciones de Seguridad
- Solo usuarios autorizados pueden grabar emisiones
- Control por recaudadora según usuario
- Log de todas las operaciones de emisión

## Notas de Implementación

### Optimizaciones Requeridas
1. **Cálculo de Rentas:**
   - Usar Sp_CalcRenta para todos los casos
   - Evitar lógica duplicada en código

2. **Consultas de Adeudos:**
   - Optimizar query de histórico de adeudos
   - Usar índices en ta_11_adeudo_local

3. **Generación de Reportes:**
   - Cachear datos de recargos y fechas
   - Reducir consultas repetitivas por local

### Mantenimiento Futuro
1. Unificar lógica de cálculo de rentas
2. Parametrizar fechas de recargos
3. Implementar caché de catálogos
4. Agregar exportación directa a Excel
5. Implementar envío de recibos por correo electrónico

## Puntos de Contacto con Otros Módulos

### Integración con:
- **Módulo de Pagos:** Consulta de pagos aplicados
- **Módulo de Locales:** Catálogo de locales vigentes
- **Módulo de Cuotas:** Tarifas actualizadas
- **Módulo de Requerimientos:** Multas y gastos
- **Sistema Contable:** Generación de pólizas

### Datos Compartidos:
- Adeudos de arrendamiento
- Información de contribuyentes
- Histórico de pagos
- Parámetros de recargos

## Historial de Cambios

| Fecha | Versión | Descripción | Autor |
|-------|---------|-------------|-------|
| 2004 | 1.0 | Implementación inicial | Sistema Original |
| 2013 | 1.1 | Agregado Sp_CalcRenta | Desarrollo |
| 2015 | 1.2 | Formato láser agregado | Desarrollo |

---
**Documentación generada para refactorización del Sistema de Mercados de Guadalajara**
