# Consulta de Anuncios

## Descripción General

### ¿Qué hace este módulo?
Módulo integral de consulta de anuncios publicitarios. Permite buscar anuncios por múltiples criterios, visualizar información completa, consultar adeudos específicos, ver historial, generar extractos y gestionar bloqueos de anuncios.

### ¿Para qué sirve en el proceso administrativo?
- Consultar información de anuncios vigentes y cancelados
- Verificar adeudos de anuncios específicos
- Consultar licencia asociada al anuncio
- Generar extractos de adeudo
- Exportar información para análisis
- Bloquear/desbloquear anuncios
- Ver historial de cambios
- Consultar pagos realizados
- Ver requerimientos de pago
- Consultar zona catastral del anuncio
- Autorizar permisos de pago parcial para baja

### ¿Quiénes lo utilizan?
- Personal del área de Anuncios
- Personal de cobros
- Ventanilla de atención ciudadana
- Inspectores de anuncios
- Supervisores
- Área de estadísticas

## Proceso Administrativo

### Métodos de Búsqueda:

#### 1. Por Número de Anuncio:
- Búsqueda directa por número
- Más rápida y precisa

#### 2. Por Ubicación:
- Calle (búsqueda o selección múltiple)
- Número exterior (puede ser rango)
- Número interior
- Letras exterior/interior

#### 3. Por Propietario:
- Nombre del titular de la licencia asociada
- Solo busca en licencias vigentes

#### 4. Por Trámite:
- Folio de trámite que generó el anuncio

#### 5. Por Fechas:
- Rango de fechas de otorgamiento

#### 6. Por Tipo de Anuncio:
- Giro/tipo del anuncio
- Con/sin adeudo
- Rango de fechas

#### 7. Por Licencia:
- Número de licencia asociada
- Muestra todos los anuncios de esa licencia

#### 8. Por Características:
- Vigencia (vigente/cancelado)
- Con/sin adeudo
- Número de caras
- Zona y subzona
- Bloqueados/desbloqueados
- Grupo de anuncios (vigencia especial)

#### 9. Por Empresa:
- Número de empresa asociada

#### 10. Búsqueda Masiva (Hoja de Cálculo):
- Pegar lista de números de anuncio
- Sistema filtra múltiples anuncios a la vez
- Útil para consultas masivas

### Información que se Visualiza:

**Pestaña Datos Generales:**
- Número de anuncio
- Tipo de anuncio (giro)
- Medidas (alto × ancho)
- Número de caras
- Área total del anuncio
- Ubicación completa
- Fecha de otorgamiento
- Estado (vigente/cancelado)
- Bloqueado/desbloqueado
- Licencia asociada
- Propietario

**Pestaña Licencia Asociada:**
- Datos de la licencia vinculada
- Nombre del titular
- Ubicación del establecimiento
- Giro de la licencia

**Pestaña Saldos:**
- Adeudos por año del anuncio
- Derechos, recargos, formas
- Total adeudado específico del anuncio
- Gastos de ejecución
- Multas administrativas
- Descuentos aplicables

**Pestaña Pagos:**
- Historial de pagos del anuncio
- Recaudación, caja, folio
- Fecha y hora de pago
- Montos aplicados
- Detalle por concepto
- Requerimientos pagados

**Pestaña Historial:**
- Versiones anteriores del anuncio
- Cambios de datos
- Modificaciones realizadas

**Pestaña Requerimientos:**
- Requerimientos emitidos
- Gastos de ejecución
- Multas aplicadas
- Fechas de citatorio y práctica
- Estado de los requerimientos

**Pestaña Permisos Pago Parcial:**
- Autorizaciones de baja con adeudo
- Usuario que autorizó
- Fecha de autorización
- Tipo de permiso

**Pestaña Zona Catastral:**
- Zona y subzona del anuncio
- Historial de cambios de zona
- Recaudación asociada

**Pestaña Bloqueos:**
- Historial de bloqueos
- Motivos de bloqueo
- Fechas de bloqueo/desbloqueo
- Usuarios que bloquearon
- Estado actual

## Tablas de Base de Datos

### Tablas Principales:
- **anuncios**: Datos de los anuncios

### Tablas que Consulta:
- licencias: Licencia asociada
- TipoAnuncio: Catálogo de tipos
- giros: Giros de anuncios
- detsaldos: Detalle de adeudos
- detpago: Detalle de pagos
- pagos_anu_400: Historial de pagos
- h_anuncios: Historial
- spget_lic_adeudos: SP de adeudos (para anuncios)
- get_gastosanun: SP de gastos y multas
- get_reqanun: SP de requerimientos
- get_reqanunpag: SP de requerimientos pagados
- anuncios_zona: Zonas catastrales
- bloqueos: Bloqueos del anuncio
- lic_pagoparcial: Permisos especiales
- GruposAnun: Grupos de anuncios
- Descmultalic: Descuentos en multas

### Tablas que Modifica:
- **bloqueaAnun**: UPDATE para bloquear
- **DesbloqueaAnun**: UPDATE para desbloquear
- **cancelaUltimo**: UPDATE historial de bloqueos
- **addbloqueo**: INSERT nuevo bloqueo
- **sp_lic_pagoparcial**: SP para autorizar baja con adeudo

## Stored Procedures:

**spget_lic_adeudos**: Calcula adeudos detallados (parámetro tipo='A' para anuncios)
**get_gastosanun**: Obtiene gastos de ejecución y multas de anuncios
**get_reqanun**: Obtiene requerimientos emitidos al anuncio
**get_reqanunpag**: Obtiene requerimientos pagados
**sp_lic_pagoparcial**: Autoriza o cancela permiso de baja con adeudo

## Documentos que Genera:
1. **Extracto de Adeudo**: Estado de cuenta del anuncio específico
2. **Listado**: Reporte de todos los anuncios consultados
3. **Exportación**: Archivo de texto con información completa

## Funcionalidades Especiales:

### Cálculo de Adeudos:
- Calcula derechos por m² de anuncio
- Considera número de caras
- Aplica valores vigentes por año
- Incluye recargos por mora
- Suma gastos de ejecución
- Suma multas administrativas
- Aplica descuentos autorizados
- Distingue adeudos normales de convenios

### Bloqueo Masivo:
- Permite bloquear múltiples anuncios
- Requiere motivo
- Marca como bloqueado=1
- Registra en historial
- Muestra barra de progreso
- Permite cancelar con Escape

### Desbloqueo:
- Desbloquea anuncios bloqueados
- Requiere observaciones
- Marca como bloqueado=0
- Actualiza historial

### Autorización de Baja con Adeudo:
- Permite autorizar baja de anuncio aunque tenga adeudo
- Requiere autorización especial
- Se registra permiso en tabla
- Usuario y fecha quedan registrados
- Se puede cancelar autorización

### Cambio de Zona:
- Permite modificar zona/subzona del anuncio
- Actualiza ubicación catastral
- Registra cambio con usuario y fecha

### Exportación:
- Genera archivo separado por pipes (|)
- Incluye todos los resultados
- Datos de ubicación, tipo, titular
- Adeudos y pagos del año actual
- Zona y subzona
- Estado de vigencia y bloqueo

### Búsqueda con Hoja de Cálculo:
- Permite pegar lista de números de anuncio
- Sistema filtra automáticamente
- Útil para verificaciones masivas
- Exporta resultados

### Extracto:
- Documento imprimible
- Estado de cuenta completo
- Desglose de adeudos
- Incluye gastos y multas
- Muestra descuentos
- Información de convenios si aplica
- Detalle del último pago

## Impacto y Repercusiones:

### De Consultas:
- No modifican datos (solo lectura)
- Información en tiempo real
- Base para atención y cobros

### De Bloqueos:
- Impide renovación del anuncio
- Detiene trámites relacionados
- Se registra en historial
- Reversible con desbloqueo

### De Autorizaciones de Baja:
- Permite dar de baja con adeudo
- El adeudo se mantiene
- Se puede cobrar posteriormente
- Queda registrado el permiso

### De Cambios de Zona:
- Afecta cálculos de adeudos futuros
- Puede cambiar recaudación asignada
- Se actualiza ubicación catastral

## Notas Importantes:

### Cálculo de Superficie:
- Superficie = Medida1 × Medida2 × Núm. Caras
- Se redondea hacia arriba
- Mínimo 1 m²
- Base para cálculo de derechos

### Tipos de Adeudos:
- **Normal (bloq='5')**: Derechos regulares
- **Convenio derechos (bloq='1')**: Pago convenido
- **Convenio recargos (bloq='2')**: Recargos convenidos
- **Convenio multas (bloq='3')**: Multas convenidas
- **Convenio actualización (bloq='4')**: Actualización convenida

### Estados de Vigencia:
- **V (Vigente)**: Anuncio activo
- **C (Cancelado)**: Anuncio cancelado
- **B (Baja)**: Anuncio dado de baja

### Bloqueos:
- Valor 0: Sin bloqueo
- Valor 1: Bloqueado
- Se registra motivo y usuario
- Se puede desbloquear

### Descuentos en Multas:
- Se pueden aplicar descuentos porcentuales
- Se registran en tabla específica
- Se aplican automáticamente en cálculos
- Requieren autorización

### Mejores Prácticas:
1. Verificar licencia asociada
2. Revisar adeudos completos (incluyendo gastos y multas)
3. Consultar requerimientos pendientes
4. Verificar historial de pagos
5. Documentar motivo de bloqueos
6. Verificar zona catastral
7. Generar extracto para entregar al contribuyente
8. Usar búsqueda masiva para verificaciones múltiples
9. Exportar para análisis estadísticos
10. Coordinar con área de inspección para anuncios bloqueados

### Casos Especiales:

#### Anuncios sin Licencia:
- Pueden existir anuncios sin licencia asociada
- id_licencia = 0 o NULL
- Requieren proceso de liga
- Se cobran independientemente

#### Anuncios Ligados:
- Adeudo se suma a la licencia
- Se pagan en conjunto
- Se muestran en estado de cuenta de la licencia

#### Grupos de Anuncios:
- Anuncios pueden pertenecer a grupos
- Grupos para vigencias especiales
- Facilita gestión masiva

#### Requerimientos:
- Documentos de cobro coactivo
- Generan gastos de ejecución
- Pueden generar multas
- Se registran fechas de práctica
- Estado: vigente, cancelado, pagado
