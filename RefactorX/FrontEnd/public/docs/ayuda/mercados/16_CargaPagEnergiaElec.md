# Carga de Pagos de Energía Eléctrica - Módulo Administrativo

## 1. INFORMACIÓN GENERAL

### Identificación del Módulo
- **Nombre**: Carga de Pagos de Energía Eléctrica
- **Archivo**: CargaPagEnergiaElec.pas
- **Tipo**: Formulario de Captura y Procesamiento
- **Módulo**: Sistema de Mercados de Guadalajara

### Propósito Administrativo
Este módulo permite a la administración municipal registrar y procesar los pagos correspondientes al consumo de energía eléctrica de los locales comerciales ubicados en los mercados municipales, asegurando el control financiero de este concepto de cobro.

---

## 2. FUNCIONALIDAD ADMINISTRATIVA

### Proceso Principal: Registro de Pagos de Energía

#### 2.1 Selección de Información del Local
**Actores**: Operador de Recaudación, Supervisor Administrativo

**Datos Requeridos**:
- **Recaudadora**: Oficina municipal responsable del mercado
- **Mercado**: Identificación del mercado municipal
- **Categoría**: Clasificación del mercado
- **Sección**: Área específica dentro del mercado
- **Local**: Número del local comercial (rango inicial y final para búsqueda)

**Proceso**:
1. El operador selecciona la recaudadora de un catálogo predefinido
2. Se filtra automáticamente el catálogo de mercados correspondientes
3. Se identifica el local mediante sección y número
4. El sistema recupera los adeudos pendientes de energía eléctrica del local

#### 2.2 Registro de Datos de Pago
**Información de la Transacción**:
- **Fecha de Pago**: Fecha en que se realizó el pago
- **Oficina de Pago**: Recaudadora que recibe el pago
- **Caja**: Caja específica donde se realizó la operación
- **Número de Operación**: Folio de la transacción
- **Partida Presupuestal**: Clasificación contable del ingreso

**Validaciones Aplicadas**:
- Verificación de datos completos antes de procesar
- Validación de permisos de usuario para la recaudadora
- Confirmación de operación válida registrada en sistema

#### 2.3 Búsqueda y Visualización de Adeudos

**Consulta de Adeudos Pendientes**:
El sistema presenta en un grid los siguientes datos:
- **Control**: ID del registro de energía
- **REC**: Recaudadora
- **MER**: Número de mercado
- **CAT**: Categoría
- **SECC**: Sección
- **LOCAL**: Número de local
- **LET**: Letra del local
- **BLQ**: Bloque
- **CVE**: Clave de consumo
- **CANT F/K**: Cantidad consumida (fuerza/kW)
- **AÑO**: Año del adeudo
- **PER**: Período (mes)
- **CUOTA**: Importe del adeudo
- **PARTIDA**: Campo editable para asignar clasificación presupuestal

**Funcionalidad**:
- Muestra todos los períodos adeudados del local seleccionado
- Permite asignar individualmente la partida presupuestal a cada adeudo
- Valida que todos los adeudos tengan partida asignada antes de procesar

---

## 3. OPERACIONES ADMINISTRATIVAS

### 3.1 Carga de Pagos (FlatBtnAgregarClick)

**Propósito**: Aplicar los pagos de energía eléctrica al sistema financiero

**Proceso Administrativo**:
1. **Validación de Información**:
   - Verifica que todos los adeudos tengan partida presupuestal asignada
   - Cuenta registros sin partida para control estadístico

2. **Transacción de Base de Datos**:
   - Inicia transacción para garantizar integridad de datos
   - Por cada adeudo con partida asignada:
     - Inserta registro en `ta_11_pago_energia` con todos los datos del pago
     - Elimina el adeudo de `ta_11_adeudo_energ` para evitar doble cobro

3. **Control de Errores**:
   - Si falla alguna operación, revierte toda la transacción (Rollback)
   - Garantiza que no queden registros inconsistentes
   - Muestra mensaje de error específico

4. **Confirmación**:
   - Confirma la transacción (Commit) solo si todo fue exitoso
   - Muestra mensaje de confirmación al operador
   - Actualiza automáticamente la consulta de adeudos

**Impacto Financiero**:
- Registra ingresos por concepto de energía eléctrica
- Elimina adeudos del sistema una vez pagados
- Mantiene trazabilidad completa del pago

### 3.2 Consulta de Capturas (FlatBtnConsultaClick)

**Propósito**: Revisar y validar pagos ya capturados

**Funcionalidad Administrativa**:
- Permite consultar pagos registrados en fecha/operación específica
- Útil para auditorías y conciliaciones
- Facilita corrección de errores de captura

**Validaciones**:
- Verifica que estén completos los datos de pago
- Confirma autorización del usuario para consultar otras recaudadoras
- Invoca módulo especializado de consulta (`ConsCapturaFechaEnergia`)

### 3.3 Búsqueda de Adeudos (FlatBtnBuscarClick)

**Propósito**: Localizar adeudos pendientes de un local específico

**Validaciones Administrativas**:
1. Verifica selección de recaudadora
2. Confirma selección de sección del mercado
3. Valida número de local (no puede ser cero)
4. Verifica datos completos de la operación de pago

**Proceso de Consulta**:
- Ejecuta query parametrizado contra base de datos
- Filtra por: oficina, mercado, categoría, sección y rango de locales
- Recupera información completa de adeudos
- Presenta resultados en grid editable para asignación de partidas

---

## 4. ESTRUCTURA DE DATOS

### 4.1 Tablas Involucradas

#### ta_11_pago_energia (Registro de Pagos)
**Propósito**: Almacenar pagos realizados de energía eléctrica

**Campos Principales**:
- `id_pago_energia`: Identificador único (autoincremental)
- `id_energia`: Referencia al registro de consumo
- `axo`: Año del período pagado
- `periodo`: Mes del período pagado
- `fecha_pago`: Fecha en que se realizó el pago
- `oficina_pago`: Recaudadora que recibió el pago
- `caja_pago`: Caja donde se procesó
- `operacion_pago`: Número de operación
- `importe_pago`: Monto pagado
- `cve_consumo`: Clave del tipo de consumo
- `cantidad`: Cantidad de kW consumidos
- `folio`: Partida presupuestal
- `fecha_modificacion`: Timestamp del registro
- `id_usuario`: Usuario que capturó

#### ta_11_adeudo_energ (Adeudos de Energía)
**Propósito**: Mantener registro de períodos pendientes de pago

**Campos Principales**:
- `id_adeudo_energia`: Identificador único
- `id_energia`: Referencia al medidor/local
- `axo`: Año del adeudo
- `periodo`: Mes del adeudo
- `cve_consumo`: Tipo de consumo
- `cantidad`: Consumo medido
- `importe`: Cantidad adeudada
- `fecha_alta`: Fecha de registro del adeudo
- `id_usuario`: Usuario que registró

### 4.2 Catálogos Consultados

#### ta_11_mercados
- Lista de mercados municipales
- Información de categoría y cuenta de ingreso
- Datos de la recaudadora responsable

#### ta_11_operaciones_caja
- Validación de cajas activas por recaudadora
- Control de operaciones válidas

---

## 5. REGLAS DE NEGOCIO

### 5.1 Validaciones de Seguridad
1. **Control de Acceso por Recaudadora**:
   - Usuarios nivel 1 (supervisores) pueden trabajar con todas las recaudadoras
   - Usuarios regulares solo acceden a su recaudadora asignada
   - Se valida al cargar pagos y consultar información

2. **Integridad de Datos**:
   - Todos los campos obligatorios deben estar llenos
   - No se permiten números de local en cero
   - Las operaciones deben existir en el sistema

### 5.2 Proceso Transaccional
1. **Atomicidad**:
   - Todas las operaciones son transaccionales
   - Si falla una, se revierten todas (rollback)
   - Solo se confirma si todo el lote fue exitoso

2. **Control de Partidas**:
   - Cada adeudo debe tener partida presupuestal asignada
   - Se permite procesar solo registros con partida
   - Los registros sin partida se mantienen para posterior asignación

### 5.3 Navegación y Búsqueda
1. **Filtrado en Cascada**:
   - Selección de recaudadora filtra mercados
   - Selección de mercado determina categoría automáticamente
   - Facilita la captura y reduce errores

2. **Búsqueda por Rangos**:
   - Permite buscar desde un local inicial hasta uno final
   - Útil para procesar múltiples locales consecutivos
   - Optimiza el tiempo de captura

---

## 6. CONTROLES Y REPORTES ADMINISTRATIVOS

### 6.1 Información en Pantalla
El grid principal muestra:
- Identificación completa del local
- Detalle del consumo (tipo y cantidad)
- Período adeudado (año y mes)
- Importe del adeudo
- Campo editable para partida presupuestal

### 6.2 Trazabilidad
Cada registro capturado incluye:
- Usuario que capturó
- Fecha y hora exacta de captura
- Datos completos de la operación de caja
- Referencia al adeudo original

### 6.3 Auditoría
El módulo permite:
- Consultar pagos capturados por fecha/operación
- Revisar quien capturó cada pago
- Verificar montos y aplicación correcta
- Identificar adeudos eliminados al aplicar pago

---

## 7. FLUJO OPERATIVO RECOMENDADO

### Proceso Estándar de Captura:
1. **Preparación**:
   - Tener a mano los recibos de pago físicos
   - Verificar que las operaciones estén registradas en caja
   - Contar con las partidas presupuestales aplicables

2. **Captura**:
   - Seleccionar recaudadora y mercado
   - Ingresar datos del local
   - Registrar información de la operación de pago
   - Buscar adeudos pendientes

3. **Asignación**:
   - Asignar partida presupuestal a cada adeudo a pagar
   - Verificar importes contra recibos físicos
   - Confirmar que todos los campos estén completos

4. **Aplicación**:
   - Ejecutar la carga de pagos
   - Verificar mensaje de confirmación
   - Revisar que los adeudos ya no aparezcan en consultas

5. **Verificación**:
   - Usar función de consulta para validar captura
   - Conciliar contra reportes de caja
   - Archivar documentación física

---

## 8. CONSIDERACIONES PARA SUPERVISIÓN

### 8.1 Puntos de Control
- Verificar que todos los pagos recibidos sean capturados
- Confirmar correcta asignación de partidas presupuestales
- Validar consistencia entre recibos físicos y sistema
- Revisar que no queden adeudos duplicados

### 8.2 Reportes de Gestión
El módulo alimenta:
- Ingresos por concepto de energía eléctrica
- Estadísticas de cobranza por mercado
- Identificación de locales con adeudos recurrentes
- Análisis de consumos por tipo de servicio

### 8.3 Soporte a Decisiones
La información permite:
- Evaluar eficiencia de cobranza por recaudadora
- Identificar tendencias de consumo
- Detectar locales con problemas de pago
- Planificar estrategias de recuperación de cartera

---

## 9. INTEGRACIÓN CON OTROS MÓDULOS

### 9.1 Módulos Relacionados
- **ConsCapturaFechaEnergia**: Consulta y validación de pagos capturados
- **CatalogoMercados**: Información de mercados y configuración
- **ModuloBD**: Gestión de conexiones y transacciones

### 9.2 Flujo de Información
**Entrada**:
- Operaciones de caja registradas
- Adeudos generados por sistema de facturación
- Catálogos de mercados y locales

**Salida**:
- Registros de pagos aplicados
- Actualización de estado de adeudos
- Información para reportes financieros

---

## 10. MEJORES PRÁCTICAS OPERATIVAS

### Para Operadores:
1. Verificar siempre los datos antes de buscar adeudos
2. Asignar partidas presupuestales correctamente
3. No cerrar la pantalla hasta confirmar mensaje de éxito
4. Usar la función de consulta para verificar capturas dudosas

### Para Supervisores:
1. Revisar periódicamente las capturas del día
2. Validar que las partidas sean las correctas
3. Conciliar contra ingresos reportados por cajas
4. Investigar discrepancias inmediatamente

### Para Mantenimiento:
1. Monitorear logs de errores en transacciones
2. Verificar integridad referencial entre tablas
3. Respaldar datos antes de operaciones masivas
4. Mantener actualizados los catálogos base

---

## 11. SOPORTE Y RESOLUCIÓN DE PROBLEMAS

### Problemas Comunes:

**"Error... Falta Información en Datos del Pago"**
- **Causa**: Campos obligatorios vacíos
- **Solución**: Completar fecha, oficina, caja y operación

**"Error... No tienes Autorización a Cargar Pagos de otra Recaudadora"**
- **Causa**: Usuario sin permisos suficientes
- **Solución**: Solicitar acceso a supervisor o cambiar a recaudadora propia

**"Error al ejecutar la Carga de Pagos de Energia Electrica"**
- **Causa**: Problema en base de datos o datos inconsistentes
- **Solución**: Verificar conectividad, revisar logs, contactar soporte técnico

**"Error al Borrar el Adeudo de Energia Electrica"**
- **Causa**: Problema de integridad referencial
- **Solución**: Verificar que no existan referencias pendientes, revisar con DBA

---

## 12. GLOSARIO DE TÉRMINOS

- **Adeudo**: Período de energía pendiente de pago
- **Caja**: Punto de recaudación específico en oficina
- **Cve Consumo**: Clave que identifica el tipo de servicio de energía
- **Operación**: Número de transacción registrado en sistema de caja
- **Partida**: Clasificación presupuestal del ingreso
- **Recaudadora**: Oficina municipal responsable de cobros
- **Período**: Mes del año al que corresponde el consumo

---

## INFORMACIÓN DEL DOCUMENTO
- **Versión**: 1.0
- **Fecha de Análisis**: 2025
- **Elaborado**: Análisis de código fuente CargaPagEnergiaElec.pas
- **Sistema**: Mercados de Guadalajara
